public class BRS_PicklistGroup_Local extends BRS_PicklistGroup_A {   
    private final SF_MetadataAPI.CustomField picklist;
    private final Map<String, SF_MetadataAPI.CustomValue> picklistValues;


	public BRS_PicklistGroup_Local(String name)
    {
    	super(new SF_MetadataAPI.CustomField());
        this.Metadata.API_Version = '39.0';
        this.picklist = (SF_MetadataAPI.CustomField)this.Metadata;
        this.picklist.fullName = name;
        this.picklist.type_x = 'Picklist';
        String[] splitName = name.split('\\.');
        this.picklist.label = Schema.getGlobalDescribe().get(splitName[0]).getDescribe().fields.getMap().get(splitName[1]).getDescribe().getLabel();
        this.picklist.valueSet = new SF_MetadataAPI.ValueSet();
        this.picklist.valueSet.valueSetDefinition = new SF_MetadataAPI.ValueSetValuesDefinition();
        this.picklist.valueSet.valueSetDefinition.value = new List<SF_MetadataAPI.CustomValue>();
        this.picklistValues = new Map<String, SF_MetadataAPI.CustomValue>();    	
    }

    
    public override void AddPicklistValue(String value)
    {
        if(this.picklistValues.ContainsKey(value)) { return; }

        SF_MetadataAPI.CustomValue newCustomValue = new SF_MetadataAPI.CustomValue();
        newCustomValue.fullName = value;
        newCustomValue.isActive = true;

        this.picklist.valueSet.valueSetDefinition.value.Add(newCustomValue);
        this.picklistValues.put(value, newCustomValue);
    }

    public override String GetFullName()
    {
        return this.picklist.fullName;
    }

    public override Set<String> GetValues()
    {
        return this.picklistValues.KeySet();
    }

    public override Boolean GetIsLocal()
    {
        return true;
    }
}