@isTest(SeeAllData=False)
public class COOP_BatchClaimsReminder_Test {

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
                                                Status__c='Activity Approved',                                               
                                                PlannedspendforActivity__c=200,
                                                Start_Date__c=Date.newInstance(2020,12,9),
                                                End_Date__c=Date.newInstance(2020, 12, 10),
                                                CurrencyIsoCode='INR');
            lstAct.add(coopAct);
        }
        
        insert lstAct;
    } 
    
       static testmethod void Testmethod1(){
           Test.startTest();
		   COOP_BatchClaimsReminder_Scheduler sch= new COOP_BatchClaimsReminder_Scheduler();
           sch.execute(null);
           //database.executeBatch(new COOP_CarryFwdCalculationBatch());
           Test.stopTest();
       }
}