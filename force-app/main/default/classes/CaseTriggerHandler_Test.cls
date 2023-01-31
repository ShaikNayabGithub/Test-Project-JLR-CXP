/*
* @description  Test Class for Case Trigger Handler
* @author    JLR
* @V1.0        JLR
* @V2.0        Uvais Komath@ChangiConsulting - Inherited existing code, Added Change Log - 28-Mar-2019
*/

@isTest
public class CaseTriggerHandler_Test {
    static testmethod void PreCreate_SetsContactId_GivenCaseOriginPhone()
    {
        //ARRANGE
        User currentUser = new User(Id=UserInfo.getUserId());
        Account account = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contact = TestClass_ValidContactBuilder.Build(account);

        User user;
        Case caseRecord;

        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contact);
            user.Market__c = 'BR';
        }

        //ACT
        test.startTest();
         System.runAs(user){   
            caseRecord = TestClass_CaseCreator.Create('Phone','01217396328','test@test.com');
        }
        Case updatedCase =[Select id,OwnerId from Case where id =:caseRecord.Id];
        updatedCase.OwnerId = user.Id;
        update updatedCase;
        test.stopTest();


        //ASSERT
        Case updatedCase2 = [Select id,Owner_Region_Or_Market__c,Owner.Name from Case Limit 1];
        List<Case> cases = [Select ContactId From Case Where Id=:updatedCase2.Id Limit 1];

        //System.AssertNotEquals(null, cases[0].ContactId); //LB- Case/Contact linking functionality has been removed from the case trigger
        System.AssertNotEquals(null, cases[0].ContactId);
    }
    
    static testmethod void PreCreate_SetsContactId_GivenCaseOriginEmail()
    {
        test.startTest();
        Case caseRecord = TestClass_CaseCreator.Create('Email');
        
        List<Case> cases = [Select ContactId From Case Where Id=:caseRecord.Id Limit 1];
        test.stopTest();
        //System.AssertNotEquals(null, cases[0].ContactId);//LB- Case/Contact linking functionality has been removed from the case trigger
        System.assertNotEquals(null, cases[0].ContactId);
    }
    
    /*
* @description  EscalationDateTest - Test Method for Case Escalation Dates
* @author    Uvais Komath@ChangiConsulting
* @V2.0        Uvais Komath@ChangiConsulting - Inherited existing code, Added Change Log - 28-Mar-2019
*/
    static testmethod void EscalationDateTest()
    {
        //Create a Test Record
        Case caseRecord;
        User MenaUser;
        
        MenaUser = new User(  firstname = 'Mena',
                               lastName = 'User',
                               email = 'adminuser@mena.jlr',
                               Username = 'adminuser@mena.jlr',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias ='muser',
                               Market__c='MENA',
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id
                               /* UserRoleId = roleId */);
        Insert MenaUser;
        
        Test.startTest();
        System.runAs(MenaUser)
        {
            caseRecord = TestClass_CaseCreator.Create('Email');
        }
        List<Case> cases = [SELECT Priority,Level_1_Escalation_Date__c,Level_2_Escalation_Date__c,
                            Level_3_Escalation_Date__c,Level_4_Escalation_Date__c,Next_Follow_up_Date__c
                            FROM CASE WHERE Id=:caseRecord.Id LIMIT 1];
        
        //Get the Business Logic from Custom Metadata
        List<Escalation_Settings__mdt> es = [SELECT Level__c,Priority__c,Number_of_business_hours__c
                                             FROM Escalation_Settings__mdt]; 
        
        
        Id BusinessHourId=[SELECT Id FROM BusinessHours WHERE Name =: Label.MenaBusinessHour].Id;
        
        Map<String,Decimal> priotityLevelToHoursMap = new Map<String,Decimal>();
        //create Priority-Level to Business Hours SLA Map
        for(Escalation_Settings__mdt esv : es)
        {
            priotityLevelToHoursMap.put(esv.Priority__c+esv.Level__c,esv.Number_of_business_hours__c);
        }
        
        //Verify the record has Escalation dates set as per Business Logic
        System.assert(cases[0].Level_1_Escalation_Date__c==BusinessHours.Add(BusinessHourId,cases[0].Next_Follow_up_Date__c,3600000*Integer.valueof(priotityLevelToHoursMap.get(cases[0].Priority+'1'))));
        System.assert(cases[0].Level_2_Escalation_Date__c==BusinessHours.Add(BusinessHourId,cases[0].Next_Follow_up_Date__c,3600000*Integer.valueof(priotityLevelToHoursMap.get(cases[0].Priority+'2'))));
        System.assert(cases[0].Level_3_Escalation_Date__c==BusinessHours.Add(BusinessHourId,cases[0].Next_Follow_up_Date__c,3600000*Integer.valueof(priotityLevelToHoursMap.get(cases[0].Priority+'3'))));
        System.assert(cases[0].Level_4_Escalation_Date__c==BusinessHours.Add(BusinessHourId,cases[0].Next_Follow_up_Date__c,3600000*Integer.valueof(priotityLevelToHoursMap.get(cases[0].Priority+'4'))));        
        Test.stopTest();
        
    }
    /*
* @description  EscalationDateTest - Test Method for Case Escalation Dates (Negative Scenario)
* @author    Uvais Komath@ChangiConsulting
* @V2.0        Uvais Komath@ChangiConsulting - Inherited existing code, Added Change Log - 02-May-2019
*/
    static testmethod void EscalationDateTestNegative()
    {
        //Create a Test Record as non MENA User
        Case caseRecord;
        
        User nonMenaUser;
        
        nonMenaUser = new User(  firstname = 'nonMena',
                               lastName = 'User',
                               email = 'adminuser@nonmena.jlr',
                               Username = 'adminuser@nonmena.jlr',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias ='nmuser',
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id
                               /* UserRoleId = roleId */);
        Insert nonMenaUser;
        Test.startTest();
        System.runAs(nonMenaUser)
        {
            caseRecord = TestClass_CaseCreator.Create('Email');
        }
        List<Case> cases = [SELECT Priority,Level_1_Escalation_Date__c,Level_2_Escalation_Date__c,
                            Level_3_Escalation_Date__c,Level_4_Escalation_Date__c,Next_Follow_up_Date__c
                            FROM CASE WHERE Id=:caseRecord.Id LIMIT 1];
        
        //Verify the record has Escalation dates not set, As owner is not MENA User
        System.assert(cases[0].Level_1_Escalation_Date__c==null);
        System.assert(cases[0].Level_2_Escalation_Date__c==null);
        System.assert(cases[0].Level_3_Escalation_Date__c==null);
        System.assert(cases[0].Level_4_Escalation_Date__c==null);        
        
     Test.stopTest();   
    }
}