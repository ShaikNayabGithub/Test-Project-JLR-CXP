@isTest
private class DMSInboundIntegrationService_VolumeTest {    
	/*
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given1000Records() {
        RunVolumeTest(1000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given2000Records() {
        RunVolumeTest(2000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given3000Records() {
        RunVolumeTest(3000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given4000Records() {
        RunVolumeTest(4000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given5000Records() {
        RunVolumeTest(5000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given7000Records() {
        RunVolumeTest(7000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given10000Records() {
        RunVolumeTest(10000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given20000Records() {
        RunVolumeTest(20000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given40000Records() {
        RunVolumeTest(40000);
    }
    
    static testMethod void UpdateMultipleOpportunities_DoesNotFail_Given60000Records() {
        RunVolumeTest(60000);
    }
    
    static testMethod void Accounts_DoesNotFail_Given10000Records() {
        AccountTest(10000);
    }
    
    private static void AccountTest(integer volume)
    {
    	List<Account> accounts = new List<Account>();
    	for(integer i = 0; i < volume; i++)
    	{
    		Account account = new Account();
    		account.Name = CreateNewUniqueString();
    		accounts.add(account);
    	}
    	DateTime startTime = datetime.now();
    	insert accounts;
    	DateTime endTime = datetime.now();
    	System.assertEquals(startTime, endTime);
    }
    
    
    
    private static void RunVolumeTest(integer volume)
    {
    	List<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> requests = new List<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity>();    	
    	    	
    	for(integer i = 0; i <= volume; i++)
    	{
    		DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
    		request.DMSOpportunityID = CreateNewUniqueString();
    		request.Stage = CreateNewUniqueString();
    		request.StageTimestamp = datetime.now();
    		request.Amount = 1000.111;
    		request.CloseDate = date.today();
    		request.NextFollowUpDate = date.today();
    		request.NextPlannedActivity = CreateNewUniqueString();
    		requests.add(request);
    	}
    	List<DMSInboundIntegrationService.DMSInboundUpdateResponse> responses = DMSInboundIntegrationService.UpdateMultipleOpportunities(requests);
    	
    	System.assertEquals(0, Limits.getHeapSize());
    }
    
    public static string CreateNewUniqueString()
    {
    	Blob aes = Crypto.generateAesKey(128);
        return EncodingUtil.convertToHex(aes);
    }*/
}