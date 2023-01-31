@isTest
private class AccountByCodeRetriever_Test {
    @isTest
    static void RetrieveByRetailerCode_ReturnsEmptyAccount_GivenNonExistantAccountId() {
        AccountByCodeRetriever accountRetriever = new AccountByCodeRetriever();
        
        string nonExistantAccountId = 'account code';
        Account result = accountRetriever.Retrieve(nonExistantAccountId);
        
        System.assertEquals(null, result.Id);
    }
    
    @isTest
    static void RetrieveByRetailerCode_ReturnsNonEmptyAccount_GivenExistingAccountId() {
        AccountByCodeRetriever accountRetriever = new AccountByCodeRetriever();
        
        Account existingAccount = new Account();
        existingAccount.Name = 'Test 1';
        existingAccount.Secondary_Dealer_Code__c = 'account code';
        insert existingAccount;
        
        Account result = accountRetriever.Retrieve(existingAccount.Secondary_Dealer_Code__c);
        
        System.assertNotEquals(null, result.Id);
    }
}