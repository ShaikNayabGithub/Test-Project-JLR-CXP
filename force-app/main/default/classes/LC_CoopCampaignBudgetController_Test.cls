@isTest
public class LC_CoopCampaignBudgetController_Test {

    public static testmethod void Controller_ReturnsFalseWhenCampaignCostDoesNotExceedBudget_ForRetailerCampaign() {
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign retailerCampaign = new Campaign(Name = 'Test Retailer Campaign', RecordTypeId = retailerRecordTypeId, Status = 'Created', Retailer_Quarter_Budget__c = 1000);
        insert retailerCampaign;
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, ParentId = retailerCampaign.Id, Status = 'Created', BudgetedCost = 500);
        insert coopCampaign;
        System.assert(LC_CoopCampaignBudgetController.getCoopBudgetWarningMessage(retailerCampaign.Id) == false);
    }
    
    public static testmethod void Controller_ReturnsTrueWhenCampaignCostExceedsBudget_ForRetailerCampaign() {
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Campaign retailerCampaign = new Campaign(Name = 'Test Retailer Campaign', RecordTypeId = retailerRecordTypeId, Status = 'Created', Retailer_Quarter_Budget__c = 1000);
        insert retailerCampaign;
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, ParentId = retailerCampaign.Id, Status = 'Created', BudgetedCost = 1500);
        insert coopCampaign;
        System.assert(LC_CoopCampaignBudgetController.getCoopBudgetWarningMessage(retailerCampaign.Id) == true);
    }
    
    public static testmethod void Controller_ReturnsFalseWhenCampaignCostDoesNotExceedBudget_ForCoopCampaign() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();        
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', BudgetedCost = 1000);
        insert coopCampaign;
        CooP_Campaign_Activity__c coop1 = new CooP_Campaign_Activity__c(Name = 'Test Coop 1', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created', PlannedspendforActivity__c = 500);
        insert coop1;
        System.assert(LC_CoopCampaignBudgetController.getCoopBudgetWarningMessage(coopCampaign.Id) == false);
    }

    public static testmethod void Controller_ReturnsTrueWhenCampaignCostExceedsBudget_ForCoopCampaign() {
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();        
        Campaign coopCampaign = new Campaign(Name = 'Test Coop Campaign', RecordTypeId = coopRecordTypeId, Status = 'Created', BudgetedCost = 1000);
        insert coopCampaign;
        CooP_Campaign_Activity__c coop1 = new CooP_Campaign_Activity__c(Name = 'Test Coop 1', Claimable_Proportion__c = '100%', Campaign__c = coopCampaign.Id, Status__c = 'Activity Created', PlannedspendforActivity__c = 1500);
        insert coop1;
        System.assert(LC_CoopCampaignBudgetController.getCoopBudgetWarningMessage(coopCampaign.Id) == true);
    }

}