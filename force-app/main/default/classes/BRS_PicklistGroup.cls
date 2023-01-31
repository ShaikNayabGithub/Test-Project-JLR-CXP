//deprecated
public class BRS_PicklistGroup extends BRS_MetadataGroup {
    /*public SF_MetadataAPI.GlobalPicklist Picklist { public get; private set; }
    public Map<String, SF_MetadataAPI.GlobalPicklistValue> PicklistValues;
    
    
    */public BRS_PicklistGroup(String name)
    {
    	super(new SF_MetadataAPI.GlobalPicklist());
    	/*this.Picklist = (SF_MetadataAPI.GlobalPicklist)this.Metadata;
    	this.Picklist.fullName = name;
    	this.Picklist.masterLabel = name;
    	this.Picklist.sorted = false;
    	this.Picklist.globalPicklistValues = new List<SF_MetadataAPI.GlobalPicklistValue>();
    	this.PicklistValues = new Map<String, SF_MetadataAPI.GlobalPicklistValue>();*/
    }
    
    /*
    public void AddPicklistValue(String value, BRS_Request__c request)
    {
    	this.AddPicklistValue(value);
		
		if(!this.Requests.ContainsKey(request.Id)) {
			this.Requests.put(request.Id, request);
		}
    }
    
    public void AddPicklistValue(String value)
    {
    	if(!this.PicklistValues.ContainsKey(value)) { 
    		SF_MetadataAPI.GlobalPicklistValue picklistValue = new SF_MetadataAPI.GlobalPicklistValue();
			picklistValue.fullName = value;
			picklistValue.default_x = false;
			picklistValue.isActive = true;
			
			this.Picklist.globalPicklistValues.Add(picklistValue);
			this.PicklistValues.put(value, picklistValue);
		}
    }*/
}