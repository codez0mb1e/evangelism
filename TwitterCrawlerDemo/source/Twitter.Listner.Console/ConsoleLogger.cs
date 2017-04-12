using System;

namespace Twitter.Streaming
{
    public class ConsoleLogger : ILogger
    {
        public void LogInfo(string message)
        {
            if (message == null)
                throw new ArgumentNullException(nameof(message));

            Console.WriteLine(message);
        }

        public void LogWarn(string message)
        {
            if (message == null)
                throw new ArgumentNullException(nameof(message));

            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine(message);
            Console.ResetColor();
        }

        public void LogError(Exception ex)
        {
            if (ex == null)
                throw new ArgumentNullException(nameof(ex));

            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine(ex.Message);
            Console.ResetColor();
        }
    }
}