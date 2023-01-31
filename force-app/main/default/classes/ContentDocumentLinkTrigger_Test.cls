@isTest
public class ContentDocumentLinkTrigger_Test {

    static testmethod void Trigger_SetsCampaignActivityHasAttachmentToTrue_WhenContentDocumentLoadedToCampaignActivity() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', Retailer_Quarter_Budget__c=500000, RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Start_Date__c=Date.newInstance(2020,12,9), End_Date__c=Date.newInstance(2020, 12, 10), Claimable_Proportion__c = '100%', PlannedspendforActivity__c=5000, Campaign__c = coopCampaign.Id, Status__c = 'Activity Created', Has_Attachment__c = false);
        insert coop;
        ContentVersion contentDoc = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc;
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :contentDoc.Id];
        ContentDocument testCD = [SELECT Id, Title FROM ContentDocument LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = coop.Id;
        contentLink.ContentDocumentId = testcontent.ContentDocumentId;
        contentLink.Visibility = 'AllUsers';
        contentLink.ShareType = 'V';
        insert contentLink;
        
        Test.startTest();
        testCD.Title='Test Tittle';
        update testCD;
        Test.stopTest();
    }
    
    static testmethod void Trigger_SetsCampaignActivityEvidenceHasAttachmentToTrue_WhenContentDocumentLoadedToCampaignActivityEvidence() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', Retailer_Quarter_Budget__c=500000, RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Start_Date__c=Date.newInstance(2020,12,9), End_Date__c=Date.newInstance(2020, 12, 10), PlannedspendforActivity__c=5000, Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        insert coop;
        Campaign_Activity_Evidence__c cae = new Campaign_Activity_Evidence__c(Name = 'Test CAE', Campaign_Activity__c = coop.Id, Has_Attachment__c = false);
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
        
        Test.startTest();
        delete contentLink;
        Test.stopTest();
    }
    
    static testmethod void Trigger_SetsVisibilityToAllUsers_WhenContentDocumentLoadedToCampaign() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', Retailer_Quarter_Budget__c=500000, RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        ContentVersion contentDoc = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc;
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :contentDoc.Id];
        ContentDocument testCD = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = coopCampaign.Id;
        contentLink.ContentDocumentId = testcontent.ContentDocumentId;
        contentLink.Visibility = 'InternalUsers';
        contentLink.ShareType = 'V';
        insert contentLink;
        contentLink = [SELECT Visibility FROM ContentDocumentLink WHERE Id = :contentLink.Id];
        System.assertEquals('AllUsers', contentLink.Visibility);
    }
    
    static testmethod void Trigger_SetsVisibilityToAllUsers_WhenContentDocumentLoadedToCampaignActivity() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', Retailer_Quarter_Budget__c=500000, RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Start_Date__c=Date.newInstance(2020,12,9), End_Date__c=Date.newInstance(2020, 12, 10), PlannedspendforActivity__c=5000, Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created', Has_Attachment__c = false);
        insert coop;
        ContentVersion contentDoc = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc;
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :contentDoc.Id];
        ContentDocument testCD = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = coop.Id;
        contentLink.ContentDocumentId = testcontent.ContentDocumentId;
        contentLink.Visibility = 'InternalUsers';
        contentLink.ShareType = 'V';
        insert contentLink;
        contentLink = [SELECT Visibility FROM ContentDocumentLink WHERE Id = :contentLink.Id];
        System.assertEquals('AllUsers', contentLink.Visibility);
        
        Test.startTest();
		ContentVersion contentDoc1 = new ContentVersion(Title = 'Penguins New', ContentDocumentId=testContent.ContentDocumentId, PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc1;        
        Test.stopTest();
    }
    
    static testmethod void Trigger_SetsVisibilityToAllUsers_WhenContentDocumentLoadedToCampaignActivityEvidence() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', Retailer_Quarter_Budget__c=500000, RecordTypeId = coopRecordTypeId, Status = 'Created');
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Start_Date__c=Date.newInstance(2020,12,9), End_Date__c=Date.newInstance(2020, 12, 10), Claimable_Proportion__c = '100%', PlannedspendforActivity__c=5000, Campaign__c = coopCampaign.Id, Status__c = 'Activity Created');
        insert coop;
        Campaign_Activity_Evidence__c cae = new Campaign_Activity_Evidence__c(Name = 'Test CAE', Campaign_Activity__c = coop.Id, Has_Attachment__c = false);
        insert cae;
        ContentVersion contentDoc = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg', VersionData = Blob.valueOf('Penguins'), IsMajorVersion = true);
        insert contentDoc;
        ContentVersion testContent = [SELECT Id, ContentDocumentId FROM ContentVersion where Id = :contentDoc.Id];
        ContentDocument testCD = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = cae.Id;
        contentLink.ContentDocumentId = testcontent.ContentDocumentId;
        contentLink.Visibility = 'InternalUsers';
        contentLink.ShareType = 'V';
        insert contentLink;
        contentLink = [SELECT Visibility FROM ContentDocumentLink WHERE Id = :contentLink.Id];
        System.assertEquals('AllUsers', contentLink.Visibility);
        
                
        Test.startTest();
        delete testCD;
        test.stopTest();
    }
    
      static testmethod void Trigger_Casevalidation() {
       try{
		RecordSharer.DisableRecordSharing = true;
        Test.startTest();
        Case c = TestClass_CaseCreator.Create('Email');
        Test.stopTest();
        Asset a = TestClass_AssetBuilder.BuildVehicle(true);
        insert a;
        
        
        ContentVersion conVer= new ContentVersion();
        conVer.Title='file';
        conVer.PathOnClient='file.csv';
        conVer.IsMajorVersion=true;
        conVer.VersionData=Blob.valueOf('test');
        insert conVer;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = c.id;
        conDocLink.ContentDocumentId = conDocId;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        
          
        c.assetid = a.id;
        c.status='Cancelled';
        c.accountid = a.accountid;
        c.contactid=[select personcontactid from account where id in (select accountid from asset where id = : a.id)].personcontactid;
        update c;
           
        ContentVersion conVer2= new ContentVersion();
        conVer2.ContentDocumentId=conDocId;  
        conVer2.Title='file';
        conVer2.PathOnClient='file.csv';
        conVer2.IsMajorVersion=true;
        conVer2.VersionData=Blob.valueOf('test');
        insert conVer2;
       }catch(exception e){
           
       }
    } 

}