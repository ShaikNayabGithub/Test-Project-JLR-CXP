@isTest(seeAllData=false)
public class COOP_CarryFwdCalculationBatch_test {
    
    @testSetup static void setup() 
    { 
        List<Campaign> campaingForInsert = new List<Campaign>();
        Period ThisFiscalQarter= [Select StartDate,EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
        Period LastFiscalQarter= [Select StartDate,EndDate From Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER];
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Retailer').getRecordTypeId();
        Campaign newCoopCampaign = new Campaign(Name = 'New Campaign FY 19-20 Q4',
                                             startdate=ThisFiscalQarter.StartDate,
                                             enddate=ThisFiscalQarter.EndDate,
                                             RecordTypeId = coopRecordTypeId, 
                                             Status = 'Plan Created', 
                                             CurrencyIsoCode='INR',
                                             Market_ID__c = 'IN',
                                             Retailer_Quarter_Budget__c=500000);
        campaingForInsert.add(newCoopCampaign);
        
        Campaign oldCoopCampaign = new Campaign(Name = 'Old Campaign'+ 'FY 19-20' + 'Q4',
                                             startdate=LastFiscalQarter.StartDate,
                                             enddate=LastFiscalQarter.EndDate,
                                             RecordTypeId = coopRecordTypeId, 
                                             Status = 'Plan Created', 
                                             CurrencyIsoCode='INR',
                                             Market_ID__c = 'IN',
                                             Retailer_Quarter_Budget__c=500000);
        campaingForInsert.add(oldCoopCampaign);
        Insert campaingForInsert;
    } 
    
       static testmethod void COOP_CarryFwdCalculationBatch_CarryForwardBudget_FromPreviousQuarter(){
           Test.startTest();
		   COOP_CarryFwdCalculationBatch_Scheduler sch= new COOP_CarryFwdCalculationBatch_Scheduler();
           sch.execute(null);
           //database.executeBatch(new COOP_CarryFwdCalculationBatch());
           Test.stopTest();
           campaign coopNewCampaign=[select Carry_Forwarded_Budget__c from Campaign Where Name='New Campaign FY 19-20 Q4'];
           system.assertEquals(500000,coopNewCampaign.Carry_Forwarded_Budget__c);
           
       } 
}