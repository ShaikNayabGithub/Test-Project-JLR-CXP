@isTest(seeAllData=false)
public class COOP_CampActivityCleanupBatch_Test {
@testSetup static void setup() 
    { 
        Period LastFiscalQarter= [Select StartDate,EndDate From Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER];
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Retailer').getRecordTypeId();
        Campaign oldCoopCampaign = new Campaign(Name = 'Old Campaign'+ 'FY 19-20' + 'Q4',
                                             startdate=LastFiscalQarter.StartDate,
                                             enddate=LastFiscalQarter.EndDate,
                                             RecordTypeId = coopRecordTypeId, 
                                             Status = 'Plan Created', 
                                             CurrencyIsoCode='INR',
                                             Market_ID__c = 'IN',
                                             Retailer_Quarter_Budget__c=500000);
        Insert oldCoopCampaign;
        
        List<CooP_Campaign_Activity__c> lstAct = new List<CooP_Campaign_Activity__c>();
        for(Integer i=0; i<2; i++)
        {
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(
                                                Name='Test Coop Q4 FY 19-20' + i, 
                                                Claimable_Proportion__c='100%', 
                                                Campaign__c=oldCoopCampaign.id, 
                                                Status__c='Activity Created',                                               
                                                PlannedspendforActivity__c=200,
                                                Start_Date__c=Date.newInstance(2020,12,9),
                                                End_Date__c=Date.newInstance(2020, 12, 10),
                                                CurrencyIsoCode='INR');
            lstAct.add(coopAct);
        }
        
        insert lstAct;
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User IndiaUser;
        System.runAs (thisUser) {
        IndiaUser = TestClass_UserCreator.CreateUser(ProfileUtilities.Profiles.get('JLR System Administrator'));
        }
        IndiaUser.Market__c = 'IN';
        update IndiaUser;        
        System.runAs (IndiaUser) {
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setComments('Test Class');
        approvalRequest.setObjectId(oldCoopCampaign.id);
        approvalRequest.setSubmitterId(userinfo.getUserId());
        approvalRequest.setSkipEntryCriteria(false);
        Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
        }
    } 
    
       static testmethod void Testmethod1(){
           Test.startTest();
		   COOP_CampActivityCleanupBatch_Scheduler sch= new COOP_CampActivityCleanupBatch_Scheduler();
           sch.execute(null);
           //database.executeBatch(new COOP_CarryFwdCalculationBatch());
           Test.stopTest();
       }
}