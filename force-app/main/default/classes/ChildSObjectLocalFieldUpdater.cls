public class ChildSObjectLocalFieldUpdater {
    private final Map<String, Map<SObjectType, String>> fieldMapping;
    private final Map<SObjectType, String> childRelationshipMap;
    private final ChildObjectRetriever childObjectRetriever = new ChildObjectRetriever();
    private final SObjectMapper_I sObjectMapper;
    
    
    public ChildSObjectLocalFieldUpdater(Map<String, Map<SObjectType, String>> fieldMapping, Map<SObjectType, String> childRelationshipMap)
    {
        this.fieldMapping = fieldMapping;
        this.childRelationshipMap = childRelationshipMap;
        this.sObjectMapper = new SObjectMapper_Standard();
    }
    
    public ChildSObjectLocalFieldUpdater(Map<String, Map<SObjectType, String>> fieldMapping, Map<SObjectType, String> childRelationshipMap,
        SObjectMapper_I sObjectMapper)
    {
        this.fieldMapping = fieldMapping;
        this.childRelationshipMap = childRelationshipMap;
        this.sObjectMapper = sObjectMapper;
    }
    
    
    public void UpdateChildren(List<SObject> parentsNew, List<SObject> parentsOld)
    {  
        List<SObject> childRecordsForUpdate = new List<SObject>();
        List<SObject> parentsUpdated = SObjectUtilities.GetChanged(parentsNew, parentsOld, fieldMapping.KeySet());
        if(parentsUpdated.size() == 0) { return; }
        
        Map<Id, SObject> parentsUpdatedMap = this.sObjectMapper.ConvertToMap(parentsUpdated);
        
        for(SObjectType sObjectType : childRelationshipMap.KeySet())
        {
            String parentLookupFieldName = childRelationshipMap.get(sObjectType);
            List<SObject> childRecords = childObjectRetriever.RetrieveChildObjects(sObjectType, parentLookupFieldName,
                parentsUpdatedMap.KeySet());
                
            for(SObject childRecord : childRecords)
            {
                for(String parentField : fieldMapping.keySet())
                {
                    SObject parent = parentsUpdatedMap.get((Id)childRecord.get(parentLookupFieldName));
                    object fieldValue = parent.get(parentField);
                    childRecord.put(fieldMapping.get(parentField).get(sObjectType), fieldValue);
                }
            }
            childRecordsForUpdate.addAll(childRecords);
        }
        
        if(childRecordsForUpdate.Size() > 0)
        {
            update childRecordsForUpdate;
        }
    }
}