public abstract class BRS_PicklistGroup_A extends BRS_MetadataGroup {
	protected BRS_PicklistGroup_A(SF_MetadataAPI.Metadata metadata)
    {
    	super(metadata);
    }


	public void AddPicklistValue(String value, BRS_Request__c request)
	{
		this.AddPicklistValue(value);
		
		if(this.Requests.ContainsKey(request.Id)) { return; }        
		this.Requests.put(request.Id, request);
	}

	
	public abstract void AddPicklistValue(String value);
	public abstract String GetFullName();
	public abstract Set<String> GetValues();
	public abstract Boolean GetIsLocal();
}