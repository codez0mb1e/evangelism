using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Twitter.Streaming;
using Twitter.Streaming.Configurations;

namespace Twitter.Listner.Console
{
    class Program
    {
        static void Main(string[] args)
        {
            var listner = new TwitterListner(new TwitterListnerConfiguration(), new EventHubConfiguration(), new ConsoleLogger());
            listner.StartAsync().Wait();

            System.Console.ReadLine();
        }
    }
}
