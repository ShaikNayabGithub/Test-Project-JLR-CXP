/*****************************************************
 *  Name        : JaguarSurveyTest
 *  
 *  Company     : ETMarlabs
 *    
 *  Purpose     : Test class for JaguarSurvey
 * 
 *  Developer   : Tejashree J
 *
 *  Created Date: 12/11/2020
 *
 *  Modified    : 20/11/2020
*****************************************************/
@isTest
public class SurveyTest {
    public static Account surveyAcc;
    public static Event serviceAppointment,serviceAppointment2;
    public static Jaguar_Survey__c jgSurvey,jgSurvey2;
    public static List<Event> serviceAptList = new List<Event>(); 
    public static List<Jaguar_Survey__c> jgList = new List<Jaguar_Survey__c>();
    public static List<Landrover_Survey__c> lvList = new List<Landrover_Survey__c>();
    public static List<Email_Capture__c> ecList = new List<Email_Capture__c>();
    @testSetup
    public static void initialize() {
        surveyAcc= new Account ();
        surveyAcc.name='Test Account 1';
         // Insert Account data
        insert surveyAcc;
        
        serviceAppointment = new Event();
        serviceAppointment.WhatId=surveyAcc.id;
        serviceAppointment.StartDateTime=system.today();
        serviceAppointment.EndDateTime=system.today()+5;
        serviceAppointment.Subject = 'Service Appointment';
        serviceAppointment.Survey_Email_Id__c = '';
        // Insert Event data
        serviceAptList.add(serviceAppointment); 
        
        serviceAppointment2 = new Event();
        serviceAppointment2.WhatId=surveyAcc.id;
        serviceAppointment2.StartDateTime=system.today();
        serviceAppointment2.EndDateTime=system.today()+5;
        serviceAppointment2.Survey_Email_Id__c = 'qwertyuiopqwe';
        serviceAptList.add(serviceAppointment2);
        // Insert Event data
        insert serviceAptList; 
    }
    static testMethod void jaguarSurvey(){
        List<Event> eveList = [select id,WhatId,StartDateTime,EndDateTime,Survey_Email_Id__c from Event];
        jgList.add(new Jaguar_Survey__c(Event_Id__c = eveList[0].Id));
        jgList.add(new Jaguar_Survey__c(Event_Id__c = eveList[1].Id));
        Test.startTest();  
			try{
                insert jgList;
                jgList[0].Event_Id__c = eveList[1].Id;
                update jgList;
			}catch(Exception ex){
				Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot be Created') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);                
			}
		Test.stopTest();  
    }
    static testMethod void landRoverSurvey(){
        List<Event> eveList = [select id,WhatId,StartDateTime,EndDateTime,Survey_Email_Id__c from Event];
        lvList.add(new Landrover_Survey__c(Event_Id__c = eveList[0].Id));
        lvList.add(new Landrover_Survey__c(Event_Id__c = eveList[1].Id));
        Test.startTest();  
			try{
                insert lvList;
                lvList[0].Event_Id__c = eveList[1].Id;
                update lvList;
			}catch(Exception ex){
				Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot be Created') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);                
			}
		Test.stopTest();  
    }
    static testMethod void emailCapture(){
        List<Event> eveList = [select id,WhatId,StartDateTime,EndDateTime,Survey_Email_Id__c from Event];
        ecList.add(new Email_Capture__c(Event_Id__c = eveList[0].Id));
        ecList.add(new Email_Capture__c(Event_Id__c = eveList[1].Id));
        Test.startTest();  
			try{
                insert ecList;
                ecList[0].Event_Id__c = eveList[1].Id;
                update ecList;
			}catch(Exception ex){
				Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot be Created') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);                
			}
		Test.stopTest();  
    }
}