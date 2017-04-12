using System;
using System.Runtime.Serialization;

namespace Twitter.Streaming.DTO
{
    [DataContract]
    public class Tweet
    {
        [DataMember]
        public long Id { get; set; }

        [DataMember]
        public string PartitionKey { get; set; }

        [DataMember]
        public string Text { get; set; }

        [DataMember]
        public string Tags { get; set; }

        [DataMember]
        public string CreatedBy { get; set; }

        [DataMember]
        public DateTime CreatedAt { get; set; }
    }
}
