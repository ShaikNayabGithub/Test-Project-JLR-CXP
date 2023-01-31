@isTest
public class CampaignMonthlyBatchDelete_Test{
        
    static testmethod void TestDeleteCampaignDoesNotDeleteInDate(){
        //create a new campaign and set the status to 'Rejected'
        Campaign campaign = TestClass_CampaignBuilder.BuildCampaign();
        insert campaign; //The status of a newly created campaign must be 'Created'
        campaign.Status = 'Ready for Approval'; //The status can only go from 'Created' to 'Ready for Approval'
        update campaign;
        campaign.Status = 'Rejected'; //Status can only go from 'Ready for Approval' to 'Approved' or 'Rejected'
        update campaign;
        //make a call to the batch class
        Test.startTest();
            CampaignMonthlyBatchDelete campaignDelete = new CampaignMonthlyBatchDelete();
            Database.executeBatch(campaignDelete);
        Test.stopTest();
        //test that the campaign has not been deleted
        List<Campaign> retrievedCampaigns = [SELECT Id FROM Campaign WHERE Id = :campaign.Id];
        System.assertEquals(1, retrievedCampaigns.size());
    }
    
    static testmethod void TestDeleteCampaignDoesNotDeleteUnrejected(){
        //create a new campaign and set the CreatedDate to last month
        Campaign campaign = TestClass_CampaignBuilder.BuildCampaign();
        insert campaign;
        Test.setCreatedDate(campaign.Id, Date.today().addDays(-31)); //don't need to update the database record
        //make a call to the batch class
        Test.startTest();
            CampaignMonthlyBatchDelete campaignDelete = new CampaignMonthlyBatchDelete();
            Database.executeBatch(campaignDelete);
        Test.stopTest();
        //test that the campaign has not been deleted
        List<Campaign> retrievedCampaigns = [SELECT Id FROM Campaign WHERE Id = :campaign.Id];
        System.assertEquals(1, retrievedCampaigns.size());
    }
    
    static testmethod void TestDeleteCampaignDoesDelete(){
        //create a new campaign and set the status to 'Rejected'
        Campaign campaign = TestClass_CampaignBuilder.BuildCampaign();
        insert campaign; //The status of a newly created campaign must be 'Created'
        campaign.Status = 'Ready for Approval'; //The status can only go from 'Created' to 'Ready for Approval'
        update campaign;
        campaign.Status = 'Rejected'; //Status can only go from 'Ready for Approval' to 'Approved' or 'Rejected'
        update campaign;
        Test.setCreatedDate(campaign.Id, Date.today().addDays(-31)); //don't need to update the database record
        //make a call to the batch class
        Test.startTest();
            CampaignMonthlyBatchDelete campaignDelete = new CampaignMonthlyBatchDelete();
            Database.executeBatch(campaignDelete);
        Test.stopTest();
        //test that the campaign has been deleted
        List<Campaign> retrievedCampaigns = [SELECT Id FROM Campaign WHERE Id = :campaign.Id];
        System.assertEquals(0, retrievedCampaigns.size());
    }
    
    static testmethod void TestScheduling(){
        //create a cron exp string
        String CRON_EXP = '0 0 0 15 3 ? '; //need to add a year
        Integer yearPortion = Date.today().year() + 1;
        CRON_EXP = CRON_EXP + yearPortion;
        String jobId = '';
        Test.startTest();
            jobId = System.schedule('ScheduleCampaignMonthlyBatchDelete', CRON_EXP, new CampaignMonthlyBatchDelete());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
    
}