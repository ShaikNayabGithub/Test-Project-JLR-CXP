/*
Name : Batch_PrimaryToSecondary_Lnk_Test.apxc

Author: Suhan Jain - NTT Data

Purpose: Update the primary accounts into seconday and create new Primary account. 

Created Date : 04/11/2020
*/
@isTest(seeAllData=true)
public class Batch_PrimaryToSecondary_Lnk_Test {
    public static testMethod void TestBatch(){
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        Id IndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        list<string> CountryIsoCodeLst=label.BATCH_COUNTRY_FOR_ACCOUNT_MERGE.split(';');
        List<Account> accountLstForInsert = New List<Account>();
        
        for(integer i=0; i<CountryIsoCodeLst.size(); i++)
        {
            system.debug('CountryIsoCodeLst'+CountryIsoCodeLst[i]);
            Account account = new Account();
            String chars = 'abcdefghijklmnopqrstuvwxyz123';
            account.RecordTypeId = corporateRecordTypeId;
            account.Name = '';
            account.is_Primary__c=true;
            account.BillingStreet = 'Valid Street';
            account.BillingPostalCode = 'Valid PostalCode';
            account.BillingState = 'Valid State';
            account.BillingCity = 'Valid City';
            account.Retailer_Email__c = 'test@test.com';
            account.Country_ISO_Code__c = CountryIsoCodeLst[i];
            for (Integer k = 0; k < 10; k++) {
                Integer randomNum = (Integer) (Math.random() * 26);
                account.Name += chars.substring(randomNum, randomNum + 1);
                account.BillingStreet += chars.substring(randomNum, randomNum + 1);
                account.BillingState += chars.substring(randomNum, randomNum + 1);
                account.BillingCity += chars.substring(randomNum, randomNum + 1);
                account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            }  
            accountLstForInsert.add(account);      
            system.debug('account'+account);
            Account acc = new Account();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
            acc.LastName = '';
            for(Integer l=0; l<10; l++){
                Integer randomNum = (Integer)(Math.random() * 26);
                acc.LastName += chars.substring(randomNum, randomNum+1);
            }
            acc.FirstName = 'Valid Firstname';
            acc.PersonMailingStreet = 'Valid Street';
            acc.PersonMailingPostalCode = 'Valid PostalCode';
            acc.PersonMailingState = 'Valid State';
            acc.PersonMailingCity = 'Valid City';        
            acc.PersonEmail = 'test123@test.com';
            acc.Country_ISO_Code__pc = CountryIsoCodeLst[i];
            acc.Country_ISO_Code__c = CountryIsoCodeLst[i];
            accountLstForInsert.add(acc);      
        }
        
        insert accountLstForInsert;
        string accId='';
        for(Account acc:accountLstForInsert)
        {
            if(string.isNotEmpty(accId))
                accId+=',';  
            accId+='\''+acc.Id+'\'';
        }        
        test.startTest();
        database.executeBatch(new Batch_PrimaryToSecondary_Lnk('Select Id, recordTypeId, isPersonAccount, (SELECT id from Retailer_Accounts__r limit 1 ) From Account where Id IN ('+accId+')',null,null,false));
        test.stopTest();
    }
    
    
    public static testMethod void TestCheckOnly(){
        Id corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        Id IndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        list<string> CountryIsoCodeLst=label.BATCH_COUNTRY_FOR_ACCOUNT_MERGE.split(';');
        List<Account> accountLstForInsert = New List<Account>();
        
        for(integer i=0; i<CountryIsoCodeLst.size(); i++)
        {
            system.debug('CountryIsoCodeLst'+CountryIsoCodeLst[i]);
            Account account = new Account();
            String chars = 'abcdefghijklmnopqrstuvwxyz123';
            account.RecordTypeId = corporateRecordTypeId;
            account.Name = '';
            account.is_Primary__c=true;
            account.BillingStreet = 'Valid Street';
            account.BillingPostalCode = 'Valid PostalCode';
            account.BillingState = 'Valid State';
            account.BillingCity = 'Valid City';
            account.Retailer_Email__c = 'test@test.com';
            account.Country_ISO_Code__c = CountryIsoCodeLst[i];
            for (Integer k = 0; k < 10; k++) {
                Integer randomNum = (Integer) (Math.random() * 26);
                account.Name += chars.substring(randomNum, randomNum + 1);
                account.BillingStreet += chars.substring(randomNum, randomNum + 1);
                account.BillingState += chars.substring(randomNum, randomNum + 1);
                account.BillingCity += chars.substring(randomNum, randomNum + 1);
                account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            }  
            accountLstForInsert.add(account);      
            system.debug('account'+account);
            Account acc = new Account();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
            acc.LastName = '';
            for(Integer l=0; l<10; l++){
                Integer randomNum = (Integer)(Math.random() * 26);
                acc.LastName += chars.substring(randomNum, randomNum+1);
            }
            acc.FirstName = 'Valid Firstname';
            acc.PersonMailingStreet = 'Valid Street';
            acc.PersonMailingPostalCode = 'Valid PostalCode';
            acc.PersonMailingState = 'Valid State';
            acc.PersonMailingCity = 'Valid City';        
            acc.PersonEmail = 'test123@test.com';
            acc.Country_ISO_Code__pc = CountryIsoCodeLst[i];
            acc.Country_ISO_Code__c = CountryIsoCodeLst[i];
            accountLstForInsert.add(acc);      
        }
        
        insert accountLstForInsert;
        string accId='';
        for(Account acc:accountLstForInsert)
        {
            if(string.isNotEmpty(accId))
                accId+=',';  
            accId+='\''+acc.Id+'\'';
        }        
        test.startTest();
        database.executeBatch(new Batch_PrimaryToSecondary_Lnk('Select Id, recordTypeId, Preferred_Sales_Retailer__r.Country_ISO_Code__c, Country_ISO_Code__c, owner.Market__c, isPersonAccount, Review_Required__c, (SELECT id from Retailer_Accounts__r limit 1 ), (select Id from Assets limit 1) From Account where Id IN ('+accId+')',null,null,true));
        test.stopTest();
    }
}