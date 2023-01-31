@isTest
public class ConnectedCarCleanseSchedule_Test {
    
    @isTest static void TestCaseConsentLastMonthsTest(){
        Datetime lastmonth = Datetime.now().addmonths(-1);
        Connected_Services_Consent__c cons = new Connected_Services_Consent__c();
        insert cons;
        Connected_Services_Alert__c consAlert = new Connected_Services_Alert__c();
        insert consAlert;
        Test.setCreatedDate(cons.Id, lastmonth);  
        Test.setCreatedDate(consAlert.Id, lastmonth);  
        Test.startTest();
        ConnectedCarCleanseSchedule sch = new ConnectedCarCleanseSchedule();
        sch.execute(null);
        Test.stopTest();
        List<Connected_Services_Consent__c> consentList = [select id from Connected_Services_Consent__c];
        system.debug('consentList --> '+consentList);
        system.assert(!consentList.isEmpty());
        List<Connected_Services_Alert__c> alertList = [select id from Connected_Services_Alert__c];
        system.debug('consentLalertListist --> '+alertList);
        system.assert(!alertList.isEmpty());
    }
    
    @isTest static void TestCaseConsentCurrMonthsTest(){
        Connected_Services_Consent__c cons = new Connected_Services_Consent__c();
        insert cons;
        Connected_Services_Alert__c consAlert = new Connected_Services_Alert__c();
        insert consAlert;
        Test.startTest();
        ConnectedCarCleanseSchedule sch = new ConnectedCarCleanseSchedule();
        sch.execute(null);
        Test.stopTest();
        List<Connected_Services_Consent__c> consentList = [select id from Connected_Services_Consent__c];
        system.assert(!consentList.isEmpty(),false);
        List<Connected_Services_Alert__c> alertList = [select id from Connected_Services_Alert__c];
        system.assert(!alertList.isEmpty(),false);
    }
    
    @isTest static void TestCaseConsentLastTwoMonthsTest(){
        Datetime lastmonth = Datetime.now().addmonths(-2);
        Connected_Services_Consent__c cons = new Connected_Services_Consent__c();
        insert cons;
        Connected_Services_Alert__c consAlert = new Connected_Services_Alert__c();
        insert consAlert;
        Test.setCreatedDate(cons.Id, lastmonth);  
        Test.setCreatedDate(consAlert.Id, lastmonth);  
        Test.startTest();
        ConnectedCarCleanseSchedule sch = new ConnectedCarCleanseSchedule();
        sch.execute(null);
        Test.stopTest();
        List<Connected_Services_Consent__c> consentList = [select id from Connected_Services_Consent__c];
        system.assert(!consentList.isEmpty());
        List<Connected_Services_Alert__c> alertList = [select id from Connected_Services_Alert__c];
        system.assert(!alertList.isEmpty());
    }
    
    @isTest static void TestCaseConsentLastTwoThreeTest(){
        Datetime lastmonth = Datetime.now().addmonths(-3);
        Connected_Services_Consent__c cons = new Connected_Services_Consent__c();
        insert cons;
        Connected_Services_Alert__c consAlert = new Connected_Services_Alert__c();
        insert consAlert;
        Test.setCreatedDate(cons.Id, lastmonth);  
        Test.setCreatedDate(consAlert.Id, lastmonth);  
        Test.startTest();
        ConnectedCarCleanseSchedule sch = new ConnectedCarCleanseSchedule();
        sch.execute(null);
        Test.stopTest();
        List<Connected_Services_Consent__c> consentList = [select id from Connected_Services_Consent__c];
        system.assert(!consentList.isEmpty());
        List<Connected_Services_Alert__c> alertList = [select id from Connected_Services_Alert__c];
        system.assert(!alertList.isEmpty());
    }
    
    @isTest static void TestCaseConsentLastTwoFourTest(){
        Datetime lastmonth = Datetime.now().addmonths(-4);
        Connected_Services_Consent__c cons = new Connected_Services_Consent__c();
        insert cons;
        Connected_Services_Alert__c consAlert = new Connected_Services_Alert__c();
        insert consAlert;
        Test.setCreatedDate(cons.Id, lastmonth);  
        Test.setCreatedDate(consAlert.Id, lastmonth);  
        Test.startTest();
        ConnectedCarCleanseSchedule sch = new ConnectedCarCleanseSchedule();
        sch.execute(null);
        Test.stopTest();
        List<Connected_Services_Consent__c> consentList = [select id from Connected_Services_Consent__c];
        system.assert(consentList.isEmpty());
        List<Connected_Services_Alert__c> alertList = [select id from Connected_Services_Alert__c];
        system.assert(alertList.isEmpty());
    }
    
    @isTest static void TestCaseConsentLastTwoFiveTest(){
        Datetime lastmonth = Datetime.now().addmonths(-5);
        Connected_Services_Consent__c cons = new Connected_Services_Consent__c();
        insert cons;
        Connected_Services_Alert__c consAlert = new Connected_Services_Alert__c();
        insert consAlert;
        Test.setCreatedDate(cons.Id, lastmonth);  
        Test.setCreatedDate(consAlert.Id, lastmonth);  
        Test.startTest();
        ConnectedCarCleanseSchedule sch = new ConnectedCarCleanseSchedule();
        sch.execute(null);
        Test.stopTest();
        List<Connected_Services_Consent__c> consentList = [select id from Connected_Services_Consent__c];
        system.assert(consentList.isEmpty());
        List<Connected_Services_Alert__c> alertList = [select id from Connected_Services_Alert__c];
        system.assert(alertList.isEmpty());
    }
    
    @isTest static void TestCaseConsentLast6Test(){
        Datetime lastmonth = Datetime.now().addmonths(-6);
        Connected_Services_Consent__c cons = new Connected_Services_Consent__c();
        insert cons;
        Connected_Services_Alert__c consAlert = new Connected_Services_Alert__c();
        insert consAlert;
        Test.setCreatedDate(cons.Id, lastmonth);  
        Test.setCreatedDate(consAlert.Id, lastmonth);  
        Test.startTest();
        ConnectedCarCleanseSchedule sch = new ConnectedCarCleanseSchedule();
        sch.execute(null);
        Test.stopTest();
        List<Connected_Services_Consent__c> consentList = [select id from Connected_Services_Consent__c];
        system.assert(consentList.isEmpty());
        List<Connected_Services_Alert__c> alertList = [select id from Connected_Services_Alert__c];
        system.assert(alertList.isEmpty());
    } 
}