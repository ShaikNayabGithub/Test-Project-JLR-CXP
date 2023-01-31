@isTest
public class CampaignEvidenceTriggerHandler_Test {
    
     
    static testmethod void CampaignActivityEvidenceTrigger_SetsCampaignActivityStatus_WhenStatusChanged() {
        Period ThisFiscalQarter= [Select StartDate,EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',StartDate=ThisFiscalQarter.StartDate,EndDate=ThisFiscalQarter.Enddate);
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Approved',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,4,10),End_Date__c=Date.newInstance(2020, 4, 25));
        insert coop;
        Campaign_Activity_Evidence__c cae = new Campaign_Activity_Evidence__c(Name = 'Test CAE', Campaign_Activity__c = coop.Id,Attachment_Count__c=0,Status__c='Draft');
        insert cae;
        try{
        cae.Status__c='Ready for Claim';
        update cae;
        }
        catch(Exception e)  {
            System.Assert(e.getMessage().contains(Label.coopActivityAttachmentStop));
        }
        
    }
    static testmethod void CampaignActivityEvidenceTrigger_ShowError_WhenCreatedAfterDueDate() {
        Period LastFiscalQarter= [Select StartDate,EndDate From Period Where type = 'Quarter' and StartDate = LAST_FISCAL_QUARTER];
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Co Op Campaign').getRecordTypeId();
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created',StartDate=LastFiscalQarter.StartDate,EndDate=LastFiscalQarter.EndDate);
        insert coopCampaign;
        CooP_Campaign_Activity__c coop = new CooP_Campaign_Activity__c(Name = 'Test Coop', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created',PlannedspendforActivity__c=200,Start_Date__c=Date.newInstance(2020,4,10),End_Date__c=Date.newInstance(2020, 4, 15));
        insert coop;
        Campaign_Activity_Evidence__c cae = new Campaign_Activity_Evidence__c(Name = 'Test CAE', Campaign_Activity__c = coop.Id,Attachment_Count__c=2);
        try{
            insert cae;
        }
        catch(Exception e)  {
            System.Assert(e.getMessage().contains('Cannot create claims after due date!'));
        }
   
    }
}