@isTest
public class PrimaryAccount_AccountCreator_Test {

    static testmethod void CreatorCreatesGoldenRecord_GivenCorporateAccountWithCountryISOCode() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Account retailerAccount = new Account(Name='Test Retailer', Industry='Test', RecordTypeId=retailerRecordTypeId);
        insert retailerAccount;
        CreateTestData tdata = new CreateTestData();
       
        User retailerUser = tdata.createPartnerCommunityUser(retailerAccount);
        retailerUser.Country_ISO_Code__c = 'IN';
                     System.RunAs(new User(Id=userinfo.getUserId())){
        insert retailerUser;
             }
        Account acc = new Account(Name='Test Corporate', Phone='123456', RecordTypeId=corporateRecordTypeId, Is_Primary__c=true);
        System.runAs(retailerUser){
            insert acc;
        }
        acc.Is_Primary__c = false;
        update acc;
        Account modifiedAcc = new Account(Id=acc.Id, Create_Golden_Record__c=true);
        update modifiedAcc;
        List<Account> newgrs = [SELECT Id FROM Account WHERE Name='Test Corporate' AND Is_Primary__c=true];
        System.assertEquals(1, newgrs.size());
    }
    
    /*static testmethod void CreatorCreatesGoldenRecord_GivenInidividualAccountWithCountryISOCode() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Account retailerAccount = new Account(Name='Test Retailer', Industry='Test', RecordTypeId=retailerRecordTypeId);
        insert retailerAccount;
        CreateTestData tdata = new CreateTestData();
        User retailerUser = tdata.createPartnerCommunityUser(retailerAccount);
        retailerUser.Country_ISO_Code__c = 'IN';
        insert retailerUser;
        Account acc = new Account(LastName='Test Individual', Phone='123456', RecordTypeId=individualRecordTypeId, Is_Primary__c=true);
        System.runAs(retailerUser){
            insert acc;
        }
        acc.Is_Primary__c = false;
        update acc;
        Account modifiedAcc = new Account(Id=acc.Id, Create_Golden_Record__c=true);
        update modifiedAcc;
        List<Account> newgrs = [SELECT Id FROM Account WHERE Name='Test Individual' AND Is_Primary__c=true];
        System.assertEquals(1, newgrs.size());
    }*/
    
    static testmethod void CreatorAssignsGoldenRecordCorrectly_GivenCorporateAccountOwnedByRetailerWithCountryISOCode() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Account retailerAccount = new Account(Name='Test Retailer', Industry='Test', RecordTypeId=retailerRecordTypeId);
        insert retailerAccount;
        CreateTestData tdata = new CreateTestData();
          
        User retailerUser = tdata.createPartnerCommunityUser(retailerAccount);
        retailerUser.Country_ISO_Code__c = 'IN'; 
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert retailerUser;
           }
        Account acc = new Account(Name='Test Corporate', Phone='123456', RecordTypeId=corporateRecordTypeId, Is_Primary__c=true);
        System.runAs(retailerUser){
            insert acc;
        }
        acc.Is_Primary__c = false;
        acc.Country_ISO_Code__c = null;
        acc.BillingCountry = null;
        update acc;
        Account modifiedAcc = new Account(Id=acc.Id, Create_Golden_Record__c=true);
        update modifiedAcc;
        Account newgr = [SELECT Owner.Country_ISO_Code__c FROM Account WHERE Name='Test Corporate' AND Is_Primary__c=true];
        System.assertEquals('IN', newgr.Owner.Country_ISO_Code__c);
    }
    
    static testmethod void CreatorAssignsGoldenRecordCorrectly_GivenCorporateAccountOwnedByRetailerWithMarket() {
        Id retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Account retailerAccount = new Account(Name='Test Retailer', Industry='Test', RecordTypeId=retailerRecordTypeId);
        insert retailerAccount;
        CreateTestData tdata = new CreateTestData();
        User retailerUser = tdata.createPartnerCommunityUser(retailerAccount);
        retailerUser.Market__c = 'APIO';
         System.RunAs(new User(Id=userinfo.getUserId())){
        insert retailerUser;
           }
        Account acc = new Account(Name='Test Corporate', Phone='123456', RecordTypeId=corporateRecordTypeId, Is_Primary__c=true);
        System.runAs(retailerUser){
            insert acc;
        }
        acc.Is_Primary__c = false;
        update acc;
        Account modifiedAcc = new Account(Id=acc.Id, Create_Golden_Record__c=true);
        update modifiedAcc;
        Account newgr = [SELECT Owner.Name FROM Account WHERE Name='Test Corporate' AND Is_Primary__c=true];
        System.assert(newgr.Owner.Name.toUpperCase().contains('APIO'));
    }

}