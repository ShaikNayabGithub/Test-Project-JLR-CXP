@isTest(seeAllData=false)
public class CreativeBriefHandler_test {
    
    @testSetup static void setup() 
    { 
        List<Campaign> updateCamps = new List<Campaign>();
        Account acct = COOP_TestDataFactory.CreateAccount();
        insert acct;
        Campaign CoOpJLR = COOP_TestDataFactory.CreateCampaign('Co Op Retailer', 'Jaguar', acct);       
        insert CoOpJLR;
        List<CooP_Campaign_Activity__c> lst_coopActJLR = COOP_TestDataFactory.createCoOpActivities(1, CoOpJLR.id);
        insert lst_coopActJLR;  
        Creative_Brief__c CEB =new Creative_Brief__c(Name='Test CB',Campaign_Activity__c=lst_coopActJLR[0].id,Type__c='ATL',Sub_Type__c='ATL',Format__c='GIF',Brand__c='Jaguar',Model__c='XE',Status__c='CB Created');
        insert CEB;
    } 
    
    static testmethod void CreativeBriefTrigger_ChangeStatus_WhenRecordCreated()
    {
        
        Creative_Brief__c   CEB = [SELECT Status__c FROM Creative_Brief__c Limit 1];
        Test.startTest();    
        system.assertEquals('CB Assigned',CEB.Status__c);
        
        ContentVersion contentDoc = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc;
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :contentDoc.Id];
        ContentDocument testCD = [SELECT Id, Title FROM ContentDocument LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = CEB.Id;
        contentLink.ContentDocumentId = testcontent.ContentDocumentId;
        insert contentLink;
        CEB.Status__c='CB APPROVED';
        Update CEB;
        test.stopTest();
    }
}