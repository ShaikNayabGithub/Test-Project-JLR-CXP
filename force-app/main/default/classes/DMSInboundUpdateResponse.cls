public class DMSInboundUpdateResponse {
    public boolean IsSuccess;
	public Id SFOpportunityID;
	public string DMSOpportunityID;
	public integer ErrorCode;
	public string ResponseMessage;
	
	public DMSInboundUpdateResponse(Id SFOpportunityID, string DMSOpportunityID)
	{
		this.IsSuccess = true;
		this.ResponseMessage = 'Update successful';
		this.ErrorCode = 0;
		this.SFOpportunityID = SFOpportunityID;
		this.DMSOpportunityID = DMSOpportunityID;
	}
	
	public void SetError(integer errorCode, string responseMessage)
	{
		this.IsSuccess = false;
		this.ErrorCode = errorCode;
		this.ResponseMessage = responseMessage;
	}
}