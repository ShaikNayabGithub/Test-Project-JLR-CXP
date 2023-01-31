@isTest
public class TestClass_BRSRequestCreator {
    public static BRS_Request__c Create()
    {
    	return Create(new Map<Schema.SObjectField, Object>());
    }
    
    public static BRS_Request__c Create(Map<Schema.SObjectField, Object> fieldValues)
    {
    	BRS_Request__c request = new BRS_Request__c();
    	
    	if(!fieldValues.ContainsKey(Schema.BRS_Request__c.Name)){
    		request.Name = 'Test';
    	}
    	
    	for(Schema.SObjectField field : fieldValues.KeySet()) {
    		request.put(field, fieldValues.get(field));
    	}
    	
    	insert request;
    	return request;
    }
}