public class VistaSubscriptionEventWrapper {
    
    public VistaSubscriptionEventWrapper(){}
    
    public String privateKey;
    public String event;
    public String source;
    public String sourceId;
    public String uri;
    public String timestamp; 
    public String subscription;
    public String subscriptionType;
    public List<EventData> eventData;
    
    public class EventData {
        public String key;
        public String value;
        public String dealerCode;
    }
}