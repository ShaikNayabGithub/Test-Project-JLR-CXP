public class BRS_PicklistGroup_Global extends BRS_PicklistGroup_A {
	public SF_MetadataAPI.GlobalPicklist Picklist { public get; private set; }
    public Map<String, SF_MetadataAPI.GlobalPicklistValue> PicklistValues;
    
    
    public BRS_PicklistGroup_Global(String name)
    {
    	super(new SF_MetadataAPI.GlobalPicklist());
    	this.Picklist = (SF_MetadataAPI.GlobalPicklist)this.Metadata;
    	this.Picklist.fullName = name;
    	this.Picklist.masterLabel = name;
    	this.Picklist.sorted = false;
    	this.Picklist.globalPicklistValues = new List<SF_MetadataAPI.GlobalPicklistValue>();
    	this.PicklistValues = new Map<String, SF_MetadataAPI.GlobalPicklistValue>();
    }
    
        
    public override void AddPicklistValue(String value)
    {
    	if(this.PicklistValues.ContainsKey(value)) { return; }

		SF_MetadataAPI.GlobalPicklistValue picklistValue = new SF_MetadataAPI.GlobalPicklistValue();
		picklistValue.fullName = value;
		picklistValue.default_x = false;
		picklistValue.isActive = true;
		
		this.Picklist.globalPicklistValues.Add(picklistValue);
		this.PicklistValues.put(value, picklistValue);
    }

    public override String GetFullName()
    {
        return this.Picklist.fullName;
    }

    public override Set<String> GetValues()
    {
        return this.PicklistValues.KeySet();
    }

    public override Boolean GetIsLocal()
    {
        return false;
    }
}