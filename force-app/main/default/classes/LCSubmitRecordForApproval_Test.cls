@isTest
public class LCSubmitRecordForApproval_Test {

    static testmethod void Controller_SubmitsCampaignActivityEvidenceForApproval_GivenCampaign() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Start_Date__c=Date.newInstance(2020,4,10),End_Date__c=Date.newInstance(2020, 4, 25), Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        insert coop;
        Campaign_Activity_Evidence__c cae = new Campaign_Activity_Evidence__c(Name = 'Test CAE', Campaign_Activity__c = coop.Id);
        insert cae;
        ContentVersion contentDoc = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc;
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :contentDoc.Id];
        ContentDocument testCD = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = cae.Id;
        contentLink.ContentDocumentId = testcontent.ContentDocumentId;
        contentLink.Visibility = 'AllUsers'; 
        contentLink.ShareType = 'V';
        insert contentLink;
        //need to submit approval as a MENA user
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User menaUser;
        System.runAs (thisUser) {
        menaUser = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
        }
        menaUser.Market__c = 'MENA';
        update menaUser;
        System.runAs(menaUser){
            LCSubmitRecordForApproval_Controller.submitForApproval(cae.Id, UserInfo.getUserId(), 'test');
            System.assert(Approval.IsLocked(cae.Id));
        }
    }
    
}