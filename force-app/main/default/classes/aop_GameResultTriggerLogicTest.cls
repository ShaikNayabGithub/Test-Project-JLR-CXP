@isTest
public class aop_GameResultTriggerLogicTest {
  
   /*
    static TestMethod void TestTriggerLoggiceAfterInsert()
    {       
  //Record type make sure is event and right campaign memeber
        RecordType rtCamp = [SELECT Id FROM RecordType WHERE Name = 'Game Event' AND sObjectType = 'Campaign' LIMIT 1];
        RecordType rtCampM = [SELECT Id FROM RecordType WHERE Name = 'Event Booking' AND sObjectType = 'CampaignMember' LIMIT 1];
         Campaign newCamp = new Campaign(Name = 'Testamp1',RecordTypeId = rtCamp.Id, CampaignMemberRecordTypeId= rtCampM.Id,  ExpectedResponse = 0.20); //RecordTypeId = '0127E0000004IOg'
        insert newCamp;
    
        System.debug('Campaig name= ' + newCamp.Name + ' id= ' + newCamp.ID);    
        Contact newContact = new Contact(FirstName = 'Test', LastName = 'Contact', Phone='055488654');
        insert newContact;
        System.debug('Contact name= ' + newContact.LastName + ' id= ' + newContact.ID);  
    
   //create a campaign member with contact, campaign and stuff inset it, use booking id create game result and set run number 1 then assert name is equal
         CampaignMember cm = new CampaignMember();
             cm.CampaignId=newCamp.Id;
        cm.ContactId=newContact.Id;
        cm.aop_CF_Status__c='CF';
         insert cm;
        
        CampaignMember newcm = [Select Id, Name, ContactId, aop_Booking_Id__c From CampaignMember Where Id =: cm.Id];
     
        System.debug('Campaign Member name= ' + cm.Name + ' id= ' + cm.ID);    
         aop_Game_Result__c gr = new aop_Game_Result__c(aop_Booking_Id__c = newcm.aop_Booking_Id__c, aop_Run_Number__c = 1, aop_Event__c=newCamp.Id);
         insert gr;
     
          System.debug('b4 insert name= ' + gr.aop_Booking_Id__c + ' id= ' + gr.ID);    
          aop_Game_Result__c rgr = [Select Name From aop_Game_Result__c Where Id =:gr.Id];
          System.debug('Retrieved Game Results name= ' + rgr.Name + ' id= ' + rgr.ID);  
       
      System.assertEquals('1 - Test Contact', rgr.Name);    
    } */
    }