public class LC_CoopCampaignBudgetController {

	@AuraEnabled
    public static boolean getCoopBudgetWarningMessage(Id campaignId) {
        Campaign currentCampaign = [SELECT Id, RecordType.DeveloperName, Regional_Quarter_Budget__c, Retailer_Quarter_Budget__c, BudgetedCost FROM Campaign WHERE Id = :campaignId];
        if(currentCampaign != null){
            Double totalCost = 0;
            if(currentCampaign.RecordType.DeveloperName == 'Co_Op_Retailer' && currentCampaign.Retailer_Quarter_Budget__c != null){ //sum the child campaigns
                for(Campaign childCampaign : [SELECT BudgetedCost FROM Campaign WHERE ParentId = :campaignId AND BudgetedCost != null]){
                    totalCost += childCampaign.BudgetedCost;
                }
                if(totalCost > currentCampaign.Retailer_Quarter_Budget__c){
                    return true;
                }
            }
            else if(currentCampaign.RecordType.DeveloperName == 'Co_Op' && currentCampaign.BudgetedCost != null){ //sum the child Campaign Actitivies
                for(Coop_Campaign_Activity__c childCampaign : [SELECT PlannedspendforActivity__c FROM Coop_Campaign_Activity__c WHERE Campaign__c = :campaignId AND PlannedspendforActivity__c != null]){
                   	totalCost += childCampaign.PlannedspendforActivity__c;
                }
                if(totalCost > currentCampaign.BudgetedCost){
                    return true;
                }
            }
        }
        return false;
    }

}