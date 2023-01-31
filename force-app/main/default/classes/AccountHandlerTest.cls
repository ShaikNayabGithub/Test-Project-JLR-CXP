/**
 * Created by caleb@argologic.com.au on 26/03/2021.
 */

@IsTest
public with sharing class AccountHandlerTest
{
    
    @IsTest
    public static void insertAccountTest()
    {
        // ARRANGE
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = '';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }

        // ACT
        Test.startTest();
        insert account;
        Test.stopTest();

        // ASSERT

    }

    @IsTest
    public static void updateAccountTest()
    {
        // ARRANGE
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = '';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }
        insert account;

        // ACT
        Test.startTest();
        account.Name = 'new';
        update account;
        Test.stopTest();

        // ASSERT
    }

    @IsTest
    public static void deleteAccountTest()
    {
        // ARRANGE
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = '';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }
        insert account;

        // ACT
        Test.startTest();
        delete account;
        Test.stopTest();

        // ASSERT
    }
    
    @isTest
    public static void insertKoreanAccountAsDataloaderUser() {
        TriggerFramework__c framework = new TriggerFramework__c();
        framework.Is_Enable_Primary_Account_Creation__c = true;
        insert framework;
        
        System.debug('test running user');
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Enable_Primary_Account_Creation__c);
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()));
        
        Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        Profile p = [SELECT Id FROM Profile WHERE Name='MMIT Read only Dataloader' LIMIT 1]; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName= guid + '@testorg.com');
        insert u;
        
        
        
        // ARRANGE
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = 'jklmno';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'KR';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }

        // ACT
        System.runAs(u) {
            
            System.debug('test running user');
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Enable_Primary_Account_Creation__c);
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()));
            
            Test.startTest();
        	insert account;
        	Test.stopTest();
        }
        

        // ASSERT
    }
    
    @isTest
    public static void insertNonKoreanAccountAsDataloaderUser() {
        TriggerFramework__c framework = new TriggerFramework__c();
        framework.Is_Enable_Primary_Account_Creation__c = true;
        insert framework;
        
        System.debug('test running user');
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Enable_Primary_Account_Creation__c);
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()));
        
        Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        Profile p = [SELECT Id FROM Profile WHERE Name='MMIT Read only Dataloader' LIMIT 1]; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName= guid + '@testorg.com');
        insert u;
        
        
        
        // ARRANGE
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = 'jklmno';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }

        // ACT
        System.runAs(u) {
            
            System.debug('test running user');
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Enable_Primary_Account_Creation__c);
            System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()));
            
            Test.startTest();
        	insert account;
        	Test.stopTest();
        }
        

        // ASSERT
    }

    @IsTest
    public static void accountSubTeamHandlerTestKR()
    {
        // ARRANGE
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.LastName = 'Demo1';
        account.PersonMobilePhone = '0111122221';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'KR';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            
        }

        // ACT
        Test.startTest();
        insert account;
        Test.stopTest();

        // ASSERT

    }
    
    
    
    
}