using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using Tweetinvi.Models;

namespace Twitter.Streaming.DTO
{
    public static class TweetExtensions
    {
        public static Tweet ToTweet(this ITweet source, IEnumerable<string> matchingTracks)
        {
            if (source == null)
                throw new ArgumentNullException(nameof(source));

            IEnumerable<string> tracks = matchingTracks
                .Select(s => s.TrimStart('#').ToLower())
                .Distinct()
                .ToList();

            return new Tweet
            {
                Id = source.Id,
                Text = source.Text,
                Tags = tracks.Aggregate((c, s) => String.Concat(s, " ,", c)),
                CreatedBy = $"@{source.CreatedBy.ScreenName}",
                CreatedAt = source.CreatedAt,
                PartitionKey = $"{tracks.Aggregate((s, c) => String.Concat(s, "+", c))}:{source.CreatedAt:yyyyMMdd}"
            };
        }

        public static string ToJson(this Tweet source)
        {
            if (source == null)
                throw new ArgumentNullException(nameof(source));

            return JsonConvert.SerializeObject(source);
        }
    }
}