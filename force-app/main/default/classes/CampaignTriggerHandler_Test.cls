@isTest (seeAllData=false)
public class CampaignTriggerHandler_Test {

    static testmethod void CampaignTrigger_SetsStatusOfChildrenCooPCampaigns_WhenRetailerCampaignStatusUpdated() {
         Test.startTest();
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign parentRetailerCampaign = new Campaign(Name = 'Test Parent Coop Campaign', RecordTypeId = retailerRecordTypeId, Status = 'Created');
        insert parentRetailerCampaign;
        Campaign childCoopCampaign = new Campaign(Name = 'Test Child Coop Campaign', ParentId = parentRetailerCampaign.Id, RecordTypeId = coopRecordTypeId, Status = 'Ready for Claim');
        insert childCoopCampaign;
        parentRetailerCampaign.Status = 'Ready for Claim';
        update parentRetailerCampaign;
         Test.stopTest();
        childCoopCampaign = [SELECT Status FROM Campaign WHERE Id = :childCoopCampaign.Id];
        System.assertEquals('Ready for Claim', childCoopCampaign.Status);
    }
   
    static testmethod void CampaignTrigger_SetsStatusOfCampaignActivties_WhenCooPCampaignReimbursed() {
         Test.startTest();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign retailerCampaign = new Campaign(Name = 'Test Campaign', RecordTypeId = coopRecordTypeId, Reimbursement__c = false);
        insert retailerCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = retailerCampaign.Id, Status__c = 'Ready for Claim',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coop;
        retailerCampaign.Reimbursement__c = true;
        update retailerCampaign;
        coop = [SELECT Status__c FROM CooP_Campaign_Activity__c WHERE Id = :coop.Id];
        System.assertEquals('Reimbursed', coop.Status__c);
            Test.stopTest();
    }
    
    static testmethod void CampaignTrigger_SetsStatusOfCampaignActivties_whencampaignchanges() {
         Test.startTest();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign retailerCampaign = new Campaign(Name = 'Test Campaign', RecordTypeId = coopRecordTypeId, status='Created');
        insert retailerCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = retailerCampaign.Id, Status__c = 'Activity Approved',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coop;
        retailerCampaign.status ='Approved';
        update retailerCampaign;
        coop = [SELECT Status__c FROM CooP_Campaign_Activity__c WHERE Id = :coop.Id];
        System.assertEquals('Activity Approved', coop.Status__c);
            Test.stopTest();
    }
    static testmethod void CampaignTrigger_SetsStatusOfCampaignActivityEvidences_WhenRetailerCampaignReimbursed() {
          Test.startTest();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign retailerCampaign = new Campaign(Name = 'Test Campaign', RecordTypeId = coopRecordTypeId, Reimbursement__c = false);
        insert retailerCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = retailerCampaign.Id, Status__c = 'Activity Created',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,12,9),End_Date__c=Date.newInstance(2020, 12, 10));
        insert coop;
        Campaign_Activity_Evidence__c cae = new Campaign_Activity_Evidence__c(Name = 'Test CAE', Campaign_Activity__c = coop.Id, Status__c = 'Draft');
        insert cae;
        retailerCampaign.Reimbursement__c = true;
        update retailerCampaign;
        cae = [SELECT Status__c FROM Campaign_Activity_Evidence__c WHERE Id = :cae.Id];
        System.assertEquals('Reimbursed', cae.Status__c);
            Test.stopTest();
    }
    
    static testmethod void CampaignTrigger_RollsUpRetailerBudgetToRegionalBudget_WhenChildRetailerCampaignIsUpdated() {
        Test.startTest();
        Id regionalRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Regional_Plan').getRecordTypeId();
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Campaign regionalCampaign = new Campaign(Name = 'Test Regional Plan', RecordTypeId = regionalRecordTypeId);
        insert regionalCampaign;
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Retailer_Quarter_Budget__c = 1000, ParentId = regionalCampaign.Id);
        Campaign retailerCampaign2 = new Campaign(Name = 'Test Campaign 2', RecordTypeId = retailerRecordTypeId, Retailer_Quarter_Budget__c = 1000, ParentId = regionalCampaign.Id);
        List<Campaign> retailerCampaigns = new List<Campaign>();
        retailerCampaigns.add(retailerCampaign1);
        retailerCampaigns.add(retailerCampaign2);
        insert retailerCampaigns;
        retailerCampaign2.Retailer_Quarter_Budget__c = 1500;
        update retailerCampaign2;
        regionalCampaign = [SELECT Regional_Quarter_Budget__c FROM Campaign WHERE Id = :regionalCampaign.Id];
        System.assertEquals(2500, regionalCampaign.Regional_Quarter_Budget__c);
        Test.stopTest();
    }
    
    static testmethod void CampaignTrigger_SharesCoopCampaignWithRetailer_WhenParentCampaignPopulated() {
        Test.startTest();
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();
        testRetailer.Record_Sub_Type__c = 'Dual Brand';
        insert testRetailer;
        Contact testContact = TestClass_ValidContactBuilder.Build(testRetailer);
        //insert testContact;
        User testUser = new User();
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        System.runAs(usrAdmin) {
        testUser = TestClass_UserCreator.CreateRetailerUser(testContact);
        }
        //insert testUser;
        System.debug('Created User: ' + testUser);
        List<UserRole> urlist = [SELECT Id, Name FROM UserRole WHERE Name = 'test retailer Partner Manager'];
        List<Group> glist = [SELECT Id, Name, Related.Name, Type FROM Group WHERE RelatedId = :urlist[0].Id AND Type = 'Role'];
        System.debug('UserRoles: ' + urlist);
        System.debug('Groups: ' + glist);
        for(Group g : glist){
            System.debug('Related name: ' + g.Related.Name);
        }
        Campaign retailerCampaign = new Campaign(Name='Test Campaign 1', RecordTypeId=retailerRecordTypeId, Retailer__c=testRetailer.Id);
        insert retailerCampaign;
        //Campaign coopCampaign = new Campaign(Name='Test Coop', RecordTypeId=coopRecordTypeId, ParentId=retailerCampaign.Id);
        //insert coopCampaign;
        List<CampaignShare> cs = [SELECT Id, UserOrGroupId FROM CampaignShare WHERE CampaignId = :retailerCampaign.Id AND RowCause = 'Manual'];
        System.assertEquals(1, cs.size());
        Test.stopTest();
    }
    

}