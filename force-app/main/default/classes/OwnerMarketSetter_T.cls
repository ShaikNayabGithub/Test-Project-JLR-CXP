@isTest
public class OwnerMarketSetter_T {
    static testmethod void SetMarketFromOwner_DoesNotFail_GivenEmptyList()
    {
        OwnerMarketSetter ownerMarketSetter = new OwnerMarketSetter();
        
        List<Lead> records = new List<Lead>();
        
        ownerMarketSetter.SetMarketFromOwner(records, Schema.Lead.Owners_Market__c);
        
        System.Assert(true);
    }
    
    static testmethod void SetMarketFromOwner_ReturnsSetsOwnersMarketToIN_GivenLeadOwnedByQueueForAccountWithMarketIN()
    {
        Group queue = new Group(Name='test');
        insert queue;
        Account account = TestClass_AccountCreator.CreateRetailer();
        account.Region_or_Market__c = 'IN';
        account.Queue_ID__c = queue.Id;
        update account;
        
        OwnerMarketSetter ownerMarketSetter = new OwnerMarketSetter();
        
        List<Lead> records = new List<Lead>();
        Lead lead = TestClass_LeadCreator.CreateLead();
        lead.OwnerId = queue.Id;
        records.add(lead);
        
        ownerMarketSetter.SetMarketFromOwner(records, Schema.Lead.Owners_Market__c);
        
        System.AssertEquals(account.Region_or_Market__c, records[0].Owners_Market__c);
    }
    
    static testmethod void SetMarketFromOwner_ReturnsSetsOwnersMarketToAPIO_GivenLeadOwnedByUserWithMarketAPIO()
    {
        User testOwner = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
        testOwner.Market__c = 'APIO';
        update testOwner;
        
        OwnerMarketSetter ownerMarketSetter = new OwnerMarketSetter();
        
        List<Lead> records = new List<Lead>();
        System.runAs(new User(Id=UserInfo.getUserId())) {
	        Lead lead = TestClass_LeadCreator.CreateLead();
	        lead.OwnerId = testOwner.Id;
	        records.add(lead);
        }
        
        ownerMarketSetter.SetMarketFromOwner(records, Schema.Lead.Owners_Market__c);
        
        System.AssertEquals(testOwner.Market__c, records[0].Owners_Market__c);
    }
}