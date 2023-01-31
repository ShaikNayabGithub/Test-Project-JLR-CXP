@isTest
public class CoopCampaignActivityController_Test {

    static testmethod void Controller_GetsAllFiles_GivenCampaignActivity() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        insert coop;
        ContentVersion contentDoc = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc;
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :contentDoc.Id];
        ContentDocument testCD = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = coop.Id;
        contentLink.ContentDocumentId = testcontent.ContentDocumentId;
        contentLink.Visibility = 'AllUsers'; 
        //contentLink.ContentDocumentId = testCD.Id;
        contentLink.ShareType = 'V';
        insert contentLink;
        List<Id> contentIds = CoopCampaignActivityController.getActivityFiles(coop.Id);
        System.assertEquals(1, contentIds.size());
    }

}