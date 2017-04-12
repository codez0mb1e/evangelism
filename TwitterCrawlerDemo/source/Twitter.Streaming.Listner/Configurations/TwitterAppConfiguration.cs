namespace Twitter.Streaming.Configurations
{
    public interface ITwitterCredential
    {
        string AccessToken { get; }

        string AccessTokenSecret { get; }

        string ConsumerKey { get; }

        string ConsumerSecret { get; }
    }


    public class TwitterCredential : ITwitterCredential
    {
        public string ConsumerKey => "<your_key_here>";

        public string ConsumerSecret => "<your_key_here>";

        public string AccessToken => "<your_key_here>";

        public string AccessTokenSecret => "<your_key_here>";
    }
}