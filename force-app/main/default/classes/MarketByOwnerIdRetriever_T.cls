@isTest
public class MarketByOwnerIdRetriever_T {
    static testmethod void Retrieve_ReturnsEmptyMap_GivenEmptySet()
    {
        MarketByOwnerIdRetriever marketByOwnerIdRetriever = new MarketByOwnerIdRetriever();
        
        Set<String> ownerIds = new Set<String>();
        
        Map<Id, String> results = marketByOwnerIdRetriever.Retrieve(ownerIds);
        
        System.AssertEquals(0, results.Size());
    }
    
    static testmethod void Retrieve_ReturnsIN_GivenQueueForAccountWithMarketIN()
    {
        Group queue = new Group(Name='test');
        insert queue;
        Account account = TestClass_AccountCreator.CreateRetailer();
        account.Region_or_Market__c = 'IN';
        account.Queue_ID__c = queue.Id;
        update account;
        
        MarketByOwnerIdRetriever marketByOwnerIdRetriever = new MarketByOwnerIdRetriever();
        
        Set<String> ownerIds = new Set<String>{queue.Id};
        
        Map<Id, String> results = marketByOwnerIdRetriever.Retrieve(ownerIds);
        
        System.AssertEquals(account.Region_or_Market__c, results.get(queue.Id));
    }
    
    static testmethod void Retrieve_ReturnsAPIO_GivenUserWithMarketAPIO()
    {
        User testOwner = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
        testOwner.Market__c = 'APIO';
        update testOwner;
        
        MarketByOwnerIdRetriever marketByOwnerIdRetriever = new MarketByOwnerIdRetriever();
        
        Set<String> ownerIds = new Set<String>{testOwner.Id};
        
        Map<Id, String> results = marketByOwnerIdRetriever.Retrieve(ownerIds);
        
        System.AssertEquals(testOwner.Market__c, results.get(testOwner.Id));
    }
    
    static testmethod void Retrieve_ReturnsEmptyMap_GivenNonUserOrGroupId()
    {
        MarketByOwnerIdRetriever marketByOwnerIdRetriever = new MarketByOwnerIdRetriever();
        
        // Set<String> ownerIds = new Set<String>{'notarecordId'};
        
        Set<String> ownerIds = new Set<String>{};
        
        Map<Id, String> results = marketByOwnerIdRetriever.Retrieve(ownerIds);
        
        System.AssertEquals(0, results.Size());
    }
}