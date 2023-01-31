@IsTest(SeeAllData=false)
public class CampaignVINRecallAppletController_Test {

    @TestSetup static void setup() {
        Asset a = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        Campaign c = TestClass_CampaignBuilder.BuildCampaign();
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Campaign' AND DeveloperName = 'Recall'];
        c.RecordTypeId = rt.Id;
        c.VINs_for_Recall__c = 'TestVehicle';
        insert c;
    } 

    @IsTest
    static void addVINs() {
        Campaign c = [SELECT Id, VINs_for_Recall__c FROM Campaign];
        CampaignVINRecallAppletController cc = new CampaignVINRecallAppletController(new ApexPages.StandardController(c));
        cc.includeContacts = true;  
        PageReference pageResult = cc.addVINs();
        String assetStatus = cc.assetStatus;
        Boolean showRemoveButton = cc.showRemoveBtn;        
        Asset a = [SELECT Recall_Campaign__c, Name, Id FROM Asset WHERE Name = 'TestVehicle'];
        c.VINs_for_Recall__c=null;
        update c; 
        cc = new CampaignVINRecallAppletController(new ApexPages.StandardController(c));
        pageResult = cc.addVINs();
        System.assert(a.Recall_Campaign__c==c.Id);
    }

    @IsTest
    static void removeVINs() {
        Campaign c = [SELECT Id, VINs_for_Recall__c FROM Campaign];
        CampaignVINRecallAppletController cc = new CampaignVINRecallAppletController(new ApexPages.StandardController(c));
        cc.includeContacts = true; 
        cc.alsoRemoveContacts = true;
        cc.includeAuditData=true;
        PageReference pageResultAdd = cc.addVINs();
        PageReference pageResultRemove = cc.clearVINs();
        String assetStatus = cc.assetStatus;
        Boolean showRemoveButton = cc.showRemoveBtn;  
        Asset a = [SELECT Recall_Campaign__r.Name, Recall_Campaign__c, Name, Id FROM Asset WHERE Name = 'TestVehicle'];
        System.assert(a.Recall_Campaign__c==null);
        pageResultRemove = cc.clearVINs();
        System.assert([SELECT Id FROM Asset WHERE Recall_Campaign__c = : c.Id].isEmpty());
    }
}