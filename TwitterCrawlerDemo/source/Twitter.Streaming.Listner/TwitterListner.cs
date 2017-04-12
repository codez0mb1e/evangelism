using System;
using System.Text;
using System.Threading.Tasks;
using Microsoft.ServiceBus.Messaging;
using Tweetinvi;
using Tweetinvi.Events;
using Tweetinvi.Models;
using Tweetinvi.Streaming;
using Twitter.Streaming.Configurations;
using Twitter.Streaming.DTO;

namespace Twitter.Streaming
{
    public class TwitterListner
    {
        private readonly ITwitterListnerConfiguration _sourceConfig;
        private readonly IEventHubConfiguration _targetConfig;
        private readonly ILogger _logger;

        private EventHubClient _eventHubClient;


        public TwitterListner(ITwitterListnerConfiguration sourceConfig, IEventHubConfiguration targetConfig, ILogger logger)
        {
            if (sourceConfig == null)
                throw new ArgumentNullException(nameof(sourceConfig));
            if (targetConfig == null)
                throw new ArgumentNullException(nameof(targetConfig));
            if (logger == null)
                throw new ArgumentNullException(nameof(logger));

            _sourceConfig = sourceConfig;
            _targetConfig = targetConfig;
            _logger = logger;
        }


        public async Task StartAsync()
        {
            _eventHubClient = EventHubClient.CreateFromConnectionString(_targetConfig.ConnectionString, _targetConfig.EventHubName);

            Auth.SetUserCredentials(_sourceConfig.Credentials.ConsumerKey, _sourceConfig.Credentials.ConsumerSecret, _sourceConfig.Credentials.AccessToken, _sourceConfig.Credentials.AccessTokenSecret);

            IFilteredStream stream = Stream.CreateFilteredStream();

            foreach (var language in _sourceConfig.Languages)
                stream.AddTweetLanguageFilter((LanguageFilter)language);

            foreach (string track in _sourceConfig.Tracks)
                stream.AddTrack(track);

            stream.MatchingTweetReceived += OnMatchingTweetReceived;
            stream.DisconnectMessageReceived += OnDisconnectMessageReceived;
            stream.StreamStopped += OnStreamStopped;

            stream.StallWarnings = true;

            await stream.StartStreamMatchingAnyConditionAsync();
        }



        private void OnMatchingTweetReceived(object sender, MatchedTweetReceivedEventArgs args)
        {
            string message = args.Tweet
                .ToTweet(args.MatchingTracks)
                .ToJson();
            try
            {
                _logger.LogInfo($"Sending message: {message}");
                if (!args.Tweet.IsRetweet)
                    _eventHubClient.Send(new EventData(Encoding.UTF8.GetBytes(message)));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex);
                throw;
            }
        }

        private void OnDisconnectMessageReceived(object sender, DisconnectedEventArgs args)
        {
            _logger.LogWarn(args.DisconnectMessage.Reason ?? "Disconnect");
        }

        private void OnStreamStopped(object sender, StreamExceptionEventArgs args)
        {
            _logger.LogError(args.Exception);
        }
    }
}