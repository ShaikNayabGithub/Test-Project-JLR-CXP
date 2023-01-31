@IsTest
public class LocalCurrencyConverter_T {
    
    @isTest
    static void test_convertFieldFromCurrencyToCurrency(){        
        
        CurrencyType currency1 = new CurrencyType();
        currency1.IsoCode = 'GBP';
        currency1.ConversionRate = 2; 
        CurrencyType currency2 = new CurrencyType();
        currency2.IsoCode = 'SGD';
        currency2.ConversionRate = 4;
        LocalCurrencyConverter LCC = new LocalCurrencyConverter();
        decimal conveted =  LCC.convertFieldFromCurrencyToCurrency(8,currency1,currency2);       

        System.assertEquals(16,conveted);
    }
        @isTest
    static void test_returnCurrencyMapFromCampaigns(){        
        List<Campaign> newCampaigns = new List<Campaign>();        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
     
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Retailer_Quarter_Budget__c = 1000, CurrencyIsoCode = 'GBP', Local_Currency__c = 'SGD'  );
        Campaign retailerCampaign2 = new Campaign(Name = 'Test Campaign 2', RecordTypeId = retailerRecordTypeId, Retailer_Quarter_Budget__c = 1000, CurrencyIsoCode = 'INR', Local_Currency__c = 'SGD');
      
       newCampaigns.Add(retailerCampaign1);
        newCampaigns.Add(retailerCampaign2);
        LocalCurrencyConverter LCC = new LocalCurrencyConverter();
        Map<String,CurrencyType> newMap = LCC.returnCurrencyMapFromCampaigns(newCampaigns);
        System.assertEquals(3,newMap.size());
           

        //System.assertEquals(16,conveted);
    }
}