using System;

namespace Twitter.Streaming
{
    public interface ILogger
    {
        void LogInfo(string message);

        void LogWarn(string message);

        void LogError(Exception ex);
    }
}