public class BRS_RecordTypeGroup extends BRS_MetadataGroup {
    public SF_MetadataAPI.RecordType RecordType { public get; private set; }
    private Map<String, SF_MetadataAPI.RecordTypePicklistValue> Picklists;
    private Map<String, Map<String, SF_MetadataAPI.PicklistValue>> PicklistValues;
    
    
    public BRS_RecordTypeGroup(RecordType recordType)
    {
        super(new SF_MetadataAPI.RecordType());
        this.RecordType = (SF_MetadataAPI.RecordType)this.Metadata;
        this.RecordType.fullName = recordType.SobjectType + '.' + recordType.DeveloperName;
        this.RecordType.label = recordType.Name;
        this.RecordType.active = true;
        this.RecordType.picklistValues = new List<SF_MetadataAPI.RecordTypePicklistValue>();
        this.Picklists = new Map<String, SF_MetadataAPI.RecordTypePicklistValue>();
        this.PicklistValues = new Map<String, Map<String, SF_MetadataAPI.PicklistValue>>();
    }
    
    
    public void AddPicklistValues(String picklistName, Set<String> values, Map<Id, BRS_Request__c> requests)
    {
        if(picklistName.contains('.')) {
            picklistName = picklistName.split('\\.')[1];
        }
        SF_MetadataAPI.RecordTypePicklistValue picklist = Picklists.get(picklistName);
        Map<String, SF_MetadataAPI.PicklistValue> picklistValueMap = PicklistValues.get(picklistName);
        if(picklist == null) {
            picklist = new SF_MetadataAPI.RecordTypePicklistValue();
            picklist.picklist = picklistName;
            
            picklist.values = new List<SF_MetadataAPI.PicklistValue>();
            RecordType.picklistValues.Add(picklist);
            Picklists.put(picklistName, picklist);
            picklistValueMap = new Map<String, SF_MetadataAPI.PicklistValue>();
            PicklistValues.put(picklistName, picklistValueMap);
        }
        
        for(String picklistValueName : values) {
            if(!picklistValueMap.containsKey(picklistValueName)) {
                SF_MetadataAPI.PicklistValue picklistValue = new SF_MetadataAPI.PicklistValue();
                picklistValue.fullName = picklistValueName;
                picklistValue.default_x = false;
                picklistValue.isActive = true;
                
                picklist.values.Add(picklistValue);
                picklistValueMap.put(picklistValueName, picklistValue);
            }
        }
        
        this.Requests.PutAll(requests);
    }
}