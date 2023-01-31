public class LocalCampaignBudgetCalculationsLogic {
    
    public void beforeUpdateLogic(Map<Id,Campaign> oldCampaigns, List<Campaign> newCampaigns){
        
        boolean hasBudgetFieldChanged = false;
        boolean hasRetailerBudgetFieldChanged = false;
        boolean hasLocalFieldChanged = false;
        
        for(Campaign Camp : newCampaigns){
            Campaign oldCampaign = oldCampaigns.get(Camp.Id);
            
            if((camp.Local_Amount__c !=null && camp.Local_Currency__c != null) && ((oldCampaign.Local_Amount__c != camp.Local_Amount__c)||( camp.Local_Currency__c != oldCampaign.Local_Currency__c))){
                hasLocalFieldChanged = true;
            }
            if((oldCampaign.BudgetedCost != camp.BudgetedCost && camp.BudgetedCost !=null)){
                hasBudgetFieldChanged = true;
            }
            if(oldCampaign.Retailer_Quarter_Budget__c != camp.Retailer_Quarter_Budget__c && camp.Retailer_Quarter_Budget__c !=null  ){
                system.debug('Retailer budget changed');
                hasRetailerBudgetFieldChanged = true;
            }
            
        }
        if(hasRetailerBudgetFieldChanged || hasBudgetFieldChanged || hasLocalFieldChanged ){           
            
            LocalCurrencyConverter LCC = new LocalCurrencyConverter();
            Map<String,CurrencyType> currencyMap = LCC.returnCurrencyMapFromCampaigns(newCampaigns);
            for(Campaign ca:newCampaigns){
                if(ca.Local_Currency__c!=null){
                    CurrencyType localCurrency = currencyMap.get(ca.Local_Currency__c);        
                    CurrencyType campaignCurrency = currencyMap.get(ca.CurrencyIsoCode);
                    // ca.BudgetedCost = local*campaignCurrency.ConversionRate;
                    if(hasBudgetFieldChanged || hasRetailerBudgetFieldChanged ){
                        if(hasBudgetFieldChanged){
                            ca.Local_Amount__c = LCC.convertFieldFromCurrencyToCurrency(ca.BudgetedCost,campaignCurrency,localCurrency);
                            system.debug('local one: '+  ca.Local_Amount__c);
                        }
                        if(hasRetailerBudgetFieldChanged){
                            ca.Local_Amount__c = LCC.convertFieldFromCurrencyToCurrency(ca.Retailer_Quarter_Budget__c,campaignCurrency,localCurrency);
                            system.debug('local one: '+  ca.Local_Amount__c);
                        }  
                        
                    }
                    
                    if((!hasBudgetFieldChanged && hasLocalFieldChanged)||(!hasRetailerBudgetFieldChanged && hasLocalFieldChanged)){
                        Id CooprecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
                        Id CoopRetailerrecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
                        if(ca.RecordTypeId == CooprecordTypeId && !hasBudgetFieldChanged && hasLocalFieldChanged){
                            ca.BudgetedCost = LCC.convertFieldFromCurrencyToCurrency(ca.Local_Amount__c,localCurrency,campaignCurrency);
                            system.debug('Budget one: '+  ca.BudgetedCost);
                        }
                        if(ca.RecordTypeId == CoopRetailerrecordTypeId && !hasRetailerBudgetFieldChanged && hasLocalFieldChanged){
                            system.debug('Retailer one: '+  ca.Retailer_Quarter_Budget__c);
                            ca.Retailer_Quarter_Budget__c = LCC.convertFieldFromCurrencyToCurrency(ca.Local_Amount__c,localCurrency,campaignCurrency);
                            
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    
    public void beforeInsertLogic( List<Campaign> newCampaigns){
        Id CooprecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Id CoopRetailerrecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        boolean hasBudgetField = false;
        boolean hasRetailerBudgetField = false;
        boolean hasLocalField = false;
        
        for(Campaign Camp : newCampaigns){ 
   
            if(Camp.Local_Amount__c != null && Camp.Local_Amount__c != 0 && (camp.RecordTypeId == CooprecordTypeId ||camp.RecordTypeId == CoopRetailerrecordTypeId )){
             
                hasLocalField = true;
            }
            if(Camp.BudgetedCost != null && Camp.BudgetedCost != 0 && camp.RecordTypeId == CooprecordTypeId){
                
                hasBudgetField = true;
            }
            if(Camp.Retailer_Quarter_Budget__c != null && Camp.Retailer_Quarter_Budget__c != 0 &&camp.RecordTypeId == CoopRetailerrecordTypeId ){
                      System.debug('Camp.Retailer_Quarter_Budget__c '+Camp.Retailer_Quarter_Budget__c);
                hasRetailerBudgetField = true;             
                
            }
            
        }
        if(hasRetailerBudgetField || hasBudgetField || hasLocalField ){           
            system.debug('Atleast one has value');
            LocalCurrencyConverter LCC = new LocalCurrencyConverter();
            Map<String,CurrencyType> currencyMap = LCC.returnCurrencyMapFromCampaigns(newCampaigns);
            for(Campaign ca:newCampaigns){
                if(ca.Local_Currency__c!=null){
                    system.debug('local currency not null ');
                    CurrencyType localCurrency = currencyMap.get(ca.Local_Currency__c);        
                    CurrencyType campaignCurrency = currencyMap.get(ca.CurrencyIsoCode);
                    // ca.BudgetedCost = local*campaignCurrency.ConversionRate;
                    if(hasBudgetField || hasRetailerBudgetField ){
                        if(hasBudgetField){
                            ca.Local_Amount__c = LCC.convertFieldFromCurrencyToCurrency(ca.BudgetedCost,campaignCurrency,localCurrency);
                            system.debug('local one: '+  ca.Local_Amount__c);
                        }
                        if(hasRetailerBudgetField){
                            ca.Local_Amount__c = LCC.convertFieldFromCurrencyToCurrency(ca.Retailer_Quarter_Budget__c,campaignCurrency,localCurrency);
                            system.debug('local one: '+  ca.Local_Amount__c);
                        }  
                        
                    }
                    
                    if((!hasBudgetField && hasLocalField)||(!hasRetailerBudgetField && hasLocalField)){
                        
                        if(ca.RecordTypeId == CooprecordTypeId && !hasBudgetField && hasLocalField){
                            ca.BudgetedCost = LCC.convertFieldFromCurrencyToCurrency(ca.Local_Amount__c,localCurrency,campaignCurrency);
                            system.debug('Budget one: '+  ca.BudgetedCost);
                        }
                        if(ca.RecordTypeId == CoopRetailerrecordTypeId && !hasRetailerBudgetField && hasLocalField){
                            system.debug('Retailer one: '+  ca.Retailer_Quarter_Budget__c);
                            ca.Retailer_Quarter_Budget__c = LCC.convertFieldFromCurrencyToCurrency(ca.Local_Amount__c,localCurrency,campaignCurrency);
                            
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    
    
}