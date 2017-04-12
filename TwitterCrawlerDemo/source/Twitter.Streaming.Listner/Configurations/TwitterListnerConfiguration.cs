using System.Collections.Generic;

namespace Twitter.Streaming.Configurations
{
    public interface ITwitterListnerConfiguration
    {
        ITwitterCredential Credentials { get; }

        IEnumerable<string> Tracks { get; }

        IEnumerable<int> Languages { get; }
    }

    public class TwitterListnerConfiguration : ITwitterListnerConfiguration
    {
        public ITwitterCredential Credentials => new TwitterCredential();

        public IEnumerable<string> Tracks => new[] {"Azure", "AWS", "GCP", "#GlobalAzure"};

        public IEnumerable<int> Languages => new[] {12};
    }
}