@isTest
public with sharing class AccountSharingSetter_Test {
    
    static testmethod void SetAccountSharing_NewUser_AccountShareCreated(){
        Account account = TestClass_AccountCreator.CreateRetailer();
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        
        User currentUser = new User(Id=UserInfo.getUserId());
        User testUser;
        System.runAs(currentUser){
            Test.startTest();
            testUser = TestClass_UserCreator.CreateRetailerUser(contact);
            Test.stopTest();
        }
        List<AccountShare> allShares = [SELECT Id, RowCause FROM AccountShare WHERE AccountId = :account.Id AND UserOrGroupId = :testUser.Id];
        System.assertEquals(1, allShares.size());
    }
    
}