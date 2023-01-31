@isTest
public class TestClass_CampaignBuilder {
    public static Campaign BuildCampaign(){
        Campaign campaign = new Campaign(Name='TestCampaign', StartDate=Date.today(), EndDate=Date.today().addDays(5), BudgetedCost=5000, Market_ID__c = 'IN');
        return campaign;
    }
}