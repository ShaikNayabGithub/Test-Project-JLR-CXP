public interface I_DMSMessager {
    DMSOutboundResponse SendOpportunity(Opportunity opportunity);
    void SendResponses(DMSInboundUpdateResponseCollection responseCollection);
}