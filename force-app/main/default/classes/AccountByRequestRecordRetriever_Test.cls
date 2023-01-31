@isTest
private class AccountByRequestRecordRetriever_Test {
    @isTest
    static void Retrieve_ReturnsEmptyAccount_GivenNonExistantLastName() {
        ContactMatcher contactMatcher = new ContactMatcher();
        AccountByRequestRecordRetriever accountRetriever = new AccountByRequestRecordRetriever(contactMatcher);
        
        Request__c request = new Request__c();
        request.Last_Name__c = 'lastname';
        Account result = accountRetriever.Retrieve(request);
        
        System.assertEquals(null, result.Id);
    }
    
    @isTest
    static void Retrieve_ReturnsNonEmptyAccount_GivenExistingLastName() {
        ContactMatcher contactMatcher = new ContactMatcher();
        AccountByRequestRecordRetriever accountRetriever = new AccountByRequestRecordRetriever(contactMatcher);
        
        Request__c request = new Request__c();
        request.Last_Name__c = 'lastname';
        request.Email__c = 'email@test.com';
        
        Account existingAccount = new Account();
        existingAccount.LastName = request.Last_Name__c;
        existingAccount.PersonEmail = request.Email__c;
        insert existingAccount;
        
        Account result = accountRetriever.Retrieve(request);
        
        System.assertNotEquals(null, result.Id);
    }
}