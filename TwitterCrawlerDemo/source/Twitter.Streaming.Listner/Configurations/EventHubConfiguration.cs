namespace Twitter.Streaming.Configurations
{
    public interface IEventHubConfiguration
    {
        string ConnectionString { get; }

        string EventHubName { get; }
    }


    public class EventHubConfiguration : IEventHubConfiguration
    {
        public string ConnectionString => "Endpoint=sb://twittercrawler.servicebus.windows.net/;SharedAccessKeyName=Sender;SharedAccessKey=<your_key_here>";

        public string EventHubName => "cloud-raw-tweets";
    }
}