public class DMSInboundUpdateResponseCollection {
    public final DMSInboundUpdateResponse[] responses;
	public final string batchId;
	
	public DMSInboundUpdateResponseCollection(DMSInboundUpdateResponse[] responses, string batchId)
	{
		this.responses = responses;
		this.batchId = batchId;
	}
}