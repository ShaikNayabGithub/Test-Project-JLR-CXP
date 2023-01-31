public abstract class BRS_MetadataGroup {
    public SF_MetadataAPI.Metadata Metadata;
    public Map<Id, BRS_Request__c> Requests { public get; protected set; }    
    
    
    protected BRS_MetadataGroup(SF_MetadataAPI.Metadata metadata)
    {
    	this.Metadata = metadata;
    	this.Requests = new Map<Id, BRS_Request__c>();
    }
}