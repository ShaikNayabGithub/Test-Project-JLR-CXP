@isTest(seeAllData=false)
public class COOP_BatchRemindRetailers_Test {
@testSetup static void setup() 
    { 
        Period ThisFiscalQarter= [Select StartDate,EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Retailer').getRecordTypeId();
        Campaign oldCoopCampaign = new Campaign(Name = 'New Campaign'+ 'FY 19-20' + 'Q4',
                                             startdate=ThisFiscalQarter.StartDate,
                                             enddate=ThisFiscalQarter.EndDate,
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
                                                Start_Date__c=system.today()-5,
                                                End_Date__c=system.Today(),
                                                CurrencyIsoCode='INR');
            lstAct.add(coopAct);
        }
        insert lstAct;
    } 
    
       static testmethod void Testmethod1(){
           Test.startTest();
		   COOP_batchRemindRetailers_Scheduler sch= new COOP_batchRemindRetailers_Scheduler();
           sch.execute(null);
           //database.executeBatch(new COOP_CarryFwdCalculationBatch());
           Test.stopTest();
       }
}