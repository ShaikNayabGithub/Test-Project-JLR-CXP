public class LeadTypeDictionary {
    /*private static Map<string, id> requestToleadTypeMap = new Map<string, id>(); 
    
    public static id FromRequestType(string requestType)
    {
    	if(requestToleadTypeMap.Size() == 0){ LeadTypeDictionary.SetMaps(); }
    	
    	return requestToleadTypeMap.get(requestType);
    }
    
    
    private static void SetMaps()
    {
    	List<RecordType> recordTypes = [Select DeveloperName From RecordType  Where SobjectType = 'Lead' and IsActive = true];
    	Map<string, AvokaRequestTypeToLeadRecordType__c> requestToRecordTypes = AvokaRequestTypeToLeadRecordType__c.getAll();
    	
        for(string requestType : requestToRecordTypes.keySet())
        {
            AddRecordTypeIdToMap(recordTypes, requestToRecordTypes.get(requestType));
        }
    }

    private static void AddRecordTypeIdToMap(List<RecordType> recordTypes, AvokaRequestTypeToLeadRecordType__c requestToRecordType)
    {
        for(RecordType recordType : recordTypes)
        {
            if(recordType.DeveloperName == requestToRecordType.Lead_Record_Type__c)
            {
                requestToleadTypeMap.put(requestToRecordType.Name, recordType.Id); 
            }
        }
    }*/
}