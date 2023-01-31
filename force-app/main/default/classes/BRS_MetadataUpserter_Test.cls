@isTest
public class BRS_MetadataUpserter_Test {
    static testmethod void UpsertMetadataPicklistGroup_DoesNothing_GivenEmptyMap()
    {
    	BRS_MetadataUpserter upserter = BuildUpserter(true);
    	
    	Map<String, BRS_PicklistGroup_A> input = new Map<String, BRS_PicklistGroup_A>();
    	
    	upserter.UpsertMetadata(input);
    	
    	System.AssertEquals(0, input.Size());
    }
    
    static testmethod void UpsertMetadataTranslationGroup_DoesNothing_GivenEmptyMap()
    {
    	BRS_MetadataUpserter upserter = BuildUpserter(true);
    	
    	Map<String, BRS_TranslationGroup_A> input = new Map<String, BRS_TranslationGroup_A>();
    	
    	upserter.UpsertMetadata(input);
    	
    	System.AssertEquals(0, input.Size());
    }
    
    static testmethod void UpsertMetadataPicklistGroup_DoesNotChangeRequestStatus_GivenPortUpsertSuccessful()
    {
    	String status = 'startStatus';
    	BRS_MetadataUpserter upserter = BuildUpserter(true);
    	
    	Map<String, BRS_PicklistGroup_A> input = new Map<String, BRS_PicklistGroup_A>();
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	Map<Schema.SObjectField, Object> fieldValues = new Map<Schema.SObjectField, Object>();
    	fieldValues.put(Schema.BRS_Request__c.Status__c, status);
    	
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create(fieldValues);
    	picklistGroup.AddPicklistValue('test', request);
    	input.Put('test', picklistGroup);
    	
    	upserter.UpsertMetadata(input);
    	
    	System.AssertEquals(status, request.Status__c);
    }    
    
    static testmethod void UpsertMetadataPicklistGroup_SetsRequestStatusToFailed_GivenPortUpsertUnsuccessful()
    {
    	String status = 'startStatus';
    	BRS_MetadataUpserter upserter = BuildUpserter(false);
    	
    	Map<String, BRS_PicklistGroup_A> input = new Map<String, BRS_PicklistGroup_A>();
    	BRS_PicklistGroup_Global picklistGroup = new BRS_PicklistGroup_Global('test');
    	
    	Map<Schema.SObjectField, Object> fieldValues = new Map<Schema.SObjectField, Object>();
    	fieldValues.put(Schema.BRS_Request__c.Status__c, status);
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create(fieldValues);
    	
    	picklistGroup.AddPicklistValue('test', request);
    	input.Put('test', picklistGroup);
    	
    	upserter.UpsertMetadata(input);
    	
    	System.AssertEquals(BRSRequestUtilities.FailureStatus, request.Status__c);
    }    
    
    
    private static BRS_MetadataUpserter BuildUpserter(Boolean isSuccessful)
    {
    	DummyPort dummyPort = new DummyPort(isSuccessful);
    	return new BRS_MetadataUpserter(dummyPort);
    }
    
    
    private class DummyPort extends SF_MetadataAPI.MetadataPort
    {
    	private Boolean isSuccessful;
    	
    	
    	public DummyPort(Boolean isSuccessful)
    	{
    		this.isSuccessful = isSuccessful;
    	}
    	
    	
    	public override SF_MetadataAPI.UpsertResult[] upsertMetadata(SF_MetadataAPI.Metadata[] metadataCollection) {
    		List<SF_MetadataAPI.UpsertResult> results = new List<SF_MetadataAPI.UpsertResult>();
    		
    		for(SF_MetadataAPI.Metadata metadata : metadataCollection){
    			SF_MetadataAPI.UpsertResult result = new SF_MetadataAPI.UpsertResult();
    			result.success = isSuccessful;
    			result.errors = new List<SF_MetadataAPI.Error>();
    			SF_MetadataAPI.Error resultException = new SF_MetadataAPI.Error();
    			resultException.message = 'exception';
    			result.errors.Add(resultException);
    			results.Add(result);
    		}
    		
    		return results;
    	}
    }
}