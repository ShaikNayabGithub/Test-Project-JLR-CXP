public class BRS_RecordTypeAdapter {
    private static final Map<String, ESB_ObjectRecordTypes__c> esbRecordTypeSettings = ESB_ObjectRecordTypes__c.getAll();
    
    
    public Map<String, BRS_RecordTypeGroup> Adapt(Map<String, BRS_PicklistGroup_A> picklistGroups)
    {
        Map<String, BRS_RecordTypeGroup> recordTypeMap = new Map<String, BRS_RecordTypeGroup>();
        
        for(BRS_PicklistGroup_A picklistGroup : picklistGroups.Values()) {
            this.AddPicklistValuesToRecordTypes(picklistGroup, recordTypeMap);
        }
        
        return recordTypeMap;
    }
    
    
    private void AddPicklistValuesToRecordTypes(BRS_PicklistGroup_A picklistGroup, Map<String, BRS_RecordTypeGroup> recordTypeMap)
    {
        for(ESB_ObjectRecordTypes__c esbRecordTypeSetting : esbRecordTypeSettings.Values()) {
            AddPicklistValuesToRecordType(picklistGroup, recordTypeMap, esbRecordTypeSetting);
        }
    }
    
    private void AddPicklistValuesToRecordType(BRS_PicklistGroup_A picklistGroup, Map<String, BRS_RecordTypeGroup> recordTypeMap, ESB_ObjectRecordTypes__c esbRecordTypeSetting)
    {
    	if(picklistGroup.GetFullName() == 'Asset.Exterior_Colour__c' && !esbRecordTypeSetting.Uses_Colour__c){ return; }
    	
    	String recordTypeName = esbRecordTypeSetting.Name.split('\\.')[1];
        RecordType recordType = ProductUtilities.RecordTypes.get(recordTypeName);
        if(recordType == null) { 
        	recordType = AssetUtilities.RecordTypes.get(recordTypeName);
        }
        if(recordType == null) { return; }
        
        BRS_RecordTypeGroup recordTypeGroup = recordTypeMap.get(esbRecordTypeSetting.Name);
        if(recordTypeGroup == null){
            recordTypeGroup = new BRS_RecordTypeGroup(recordType);
            recordTypeMap.put(esbRecordTypeSetting.Name, recordTypeGroup);
        }
        
        recordTypeGroup.AddPicklistValues(picklistGroup.GetFullName(), picklistGroup.GetValues(), picklistGroup.Requests);
    }
}