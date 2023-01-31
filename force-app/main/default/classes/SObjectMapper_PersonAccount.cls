public class SObjectMapper_PersonAccount implements SObjectMapper_I {
    public Map<Id, SObject> ConvertToMap(List<SObject> records)
    {
    	Map<Id, SObject> recordMap = new Map<Id, SObject>();
    	
    	for(SObject record : records)
    	{
    		if(record.getSObjectType() == Schema.Account.SObjectType && (Boolean)record.get('IsPersonAccount'))
    		{
    			recordMap.put((Id)record.get('PersonContactId'), record);
    		}
    	}
    	
    	return recordMap;
    }
}