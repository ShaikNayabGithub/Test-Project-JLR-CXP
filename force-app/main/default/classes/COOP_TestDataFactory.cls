@isTest
public class COOP_TestDataFactory 
{
    public static Account CreateAccount() 
    {
        Id AccrecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';        
        retailerAccount.RecordTypeId = AccrecId;
        return retailerAccount; 
    }
    public static List<Campaign> CreateCampaigns(Integer No_of_Campaigns, String RecordTypeName) 
    {
        List<Campaign> cmps = new List<Campaign>();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();
        for(Integer i=0; i<No_of_Campaigns; i++)
        {
        Campaign coopCampaign = new Campaign(Name = 'Test Campaign' + i + 'FY 19-20' + 'Q4', 
                                             RecordTypeId = coopRecordTypeId, 
                                             Status = 'Plan Created', 
                                             CurrencyIsoCode='INR',
                                             Market_ID__c = 'IN',
                                             Retailer_Quarter_Budget__c=500000);
        cmps.add(coopCampaign);
        }
        return cmps;
        
    }
    public static Campaign CreateCampaign(String RecordTypeName, String Brandname, Account a) 
    {
       // User portalUser = TestUtility.createPortaluser('India','Sales Manager/Receptionist');
        Account acc = [select id, name from Account where id =: a.id];
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(RecordTypeName).getRecordTypeId();        
        
        Campaign coopCampaign =  new Campaign();
        if(Brandname == 'Jaguar')
        coopCampaign.Name = 'Test Campaign' + 'JAG_FY 19-20' + 'Q4' ;
        else
        coopCampaign.Name = 'Test Campaign' + 'LR_FY 19-20' + 'Q4' ;   
        coopCampaign.RecordTypeId = coopRecordTypeId;
        coopCampaign.Campaign_Brand__c = Brandname;
        coopCampaign.Status = 'Plan Created';
        coopCampaign.Retailer_Quarter_Budget__c=500000;
        coopCampaign.Market_ID__c = 'IN';
        coopCampaign.CurrencyIsoCode='INR';
        coopCampaign.Retailer__c = acc.id;
        return coopCampaign;        
    }
    
    public static List<CooP_Campaign_Activity__c> createCoOpActivities(Integer no_of_activities, Id campaignId)
    {
        List<CooP_Campaign_Activity__c> lstAct = new List<CooP_Campaign_Activity__c>();
        for(Integer i=0; i<no_of_activities; i++)
        {
        CooP_Campaign_Activity__c coopAct = new CooP_Campaign_Activity__c(
                                                Name='Test Coop Q4 FY 19-20' + i, 
                                                Claimable_Proportion__c='100%', 
                                                Campaign__c=campaignId, 
                                                Status__c='Activity Created',                                               
                                                PlannedspendforActivity__c=200,
                                                Start_Date__c=Date.newInstance(2020,12,9),
                                                End_Date__c=Date.newInstance(2020, 12, 10),
                                                CurrencyIsoCode='INR');
            lstAct.add(coopAct);
        }
        return lstAct;
    } 
}