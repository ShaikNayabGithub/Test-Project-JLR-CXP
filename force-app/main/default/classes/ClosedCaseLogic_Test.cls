/*
* @description  Test Class for ClosedCaseLogic
* @author    JPatman 17/02/2020
*      
*/

@isTest
public class ClosedCaseLogic_Test{
    
    static testmethod void Preupdate_DoesntSetsSolvedDate_GivenCaseIsOpen()
    {
        //ARRANGE
        Account acc =  createPersonAccount();
        Case caseRecord = new Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
        caseRecord.Priority='Low';
        caseRecord.Status = 'Open';
        caseRecord.Origin = 'Email';
        caseRecord.accountId = acc.id;
        caseRecord.Case_Contact_Email__c = 'test123@test.com';
        caseRecord.SuppliedEmail = 'test123@test.com';   
        caseRecord.Subject = 'Subject 1';
        //Set RecordType to Retailer
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
        insert caseRecord; 
        
        
        //ACT
        System.Test.startTest();
        Case updateCase = new Case();
        updateCase.Id = caseRecord.Id;
        updateCase.status = 'In Progress';
        update updateCase;
        System.Test.stopTest();
        //ASSERT
        Case cas = [Select Id,IsClosed,status,Solved_Date__c from Case where id = :caseRecord.Id];
        
        
        System.assertEquals(null, cas.Solved_Date__c);
    }
    
    static testmethod void Preupdate_SetsSolvedDate_GivenCaseIsClosed()
    {
        //ARRANGE
        Account acc =  createPersonAccount();
        Case caseRecord = new Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
        caseRecord.Priority='Low';
        caseRecord.Status = 'Open';
        caseRecord.Origin = 'Email';
        caseRecord.accountId = acc.id;
        caseRecord.Case_Contact_Email__c = 'test123@test.com';
        caseRecord.SuppliedEmail = 'test123@test.com';   
        caseRecord.Subject = 'Subject 1';
        //Set RecordType to Retailer
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
        insert caseRecord; 
        
        
        //ACT
        System.Test.startTest();
        Case updateCase = new Case();
        updateCase.Id = caseRecord.Id;
        updateCase.status = 'Cancelled';
        update updateCase;
        System.Test.stopTest();
        //ASSERT
        Case cas = [Select Id,IsClosed,status,Solved_Date__c from Case where id = :caseRecord.Id];
        System.debug('Assert '+cas.Solved_Date__c );
        System.debug('Assert '+cas.IsClosed );
        System.debug('Assert st '+cas.status );
        
        DateTime dT =cas.Solved_Date__c;
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        System.assertEquals(Date.today(), myDate);
    }
    static testmethod void Preupdate_WipesSetsSolvedDate_GivenCaseIsReOpened()
    {
        //ARRANGE
        Account acc =  createPersonAccount();
        Case caseRecord = new Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
        caseRecord.Priority='Low';
        caseRecord.Status = 'Open';
        caseRecord.Origin = 'Email';
        caseRecord.accountId = acc.id;
        caseRecord.Case_Contact_Email__c = 'test123@test.com';
        caseRecord.SuppliedEmail = 'test123@test.com';   
        caseRecord.Subject = 'Subject 1';
        //Set RecordType to Retailer
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
        insert caseRecord; 
        Case updateCase = new Case();
        updateCase.Id = caseRecord.Id;
        updateCase.status = 'Cancelled';
        update updateCase;
        
        //ACT
        System.Test.startTest();
        Case updateCase2 = new Case();
        updateCase2.Id = caseRecord.Id;
        updateCase2.status = 'Open';
        update updateCase2;
        System.Test.stopTest();
        //ASSERT
        Case cas = [Select Id,IsClosed,status,Solved_Date__c from Case where id = :caseRecord.Id];
        System.debug('Assert '+cas.Solved_Date__c );
        System.debug('Assert '+cas.IsClosed );
        System.debug('Assert st '+cas.status );
        
        
        
        System.assertEquals(cas.Solved_Date__c, null);
    }
    
    
    
    private static Account createPersonAccount()
    {
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        System.assertNotEquals(null, acc.RecordTypeId);
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        acc.LastName = '';
        for(Integer i=0; i<10; i++){
            Integer randomNum = (Integer)(Math.random() * 26);
            acc.LastName += chars.substring(randomNum, randomNum+1);
        }
        acc.FirstName = 'Valid Firstname';
        acc.PersonMailingStreet = 'Valid Street';
        acc.PersonMailingPostalCode = 'Valid PostalCode';
        acc.PersonMailingState = 'Valid State';
        acc.PersonMailingCity = 'Valid City';        
        acc.PersonEmail = 'test123@test.com';
        acc.Country_ISO_Code__pc = 'IN';
        acc.Country_ISO_Code__c = 'IN';
        
        insert acc;
        //System.assert(acc.IsPersonAccount);
        return acc;
    }
    
}