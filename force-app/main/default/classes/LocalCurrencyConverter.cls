public class LocalCurrencyConverter {
    
    Public Map<String,CurrencyType> returnCurrencyMapFromCampaigns(List<Campaign> newCampaigns){
        List<String> currencyIsoCodes = New List<String>();
        Map<String,CurrencyType> currencyMap = new Map<String,CurrencyType>();
        for(Campaign c:newCampaigns){
            
            if(c.CurrencyIsoCode != null){
                currencyIsoCodes.add(c.CurrencyIsoCode);
            }
            if(c.Local_Currency__c != null){
                currencyIsoCodes.add(c.Local_Currency__c);
            }
            List<CurrencyType> currencies = [Select id,ConversionRate,DecimalPlaces,IsActive,IsCorporate,IsoCode from CurrencyType where IsoCode in :currencyIsoCodes ];
            if(!currencies.isEmpty()){
                for(CurrencyType ct :currencies){
                    currencyMap.put(ct.IsoCode,ct);
                }
            }
            
        }
        return currencyMap;
    }
    
    public decimal convertFieldFromCurrencyToCurrency(decimal value, CurrencyType fromCurrency, CurrencyType toCurrency ){
        
         decimal local;
          decimal campaignValue;
         local = (value / fromCurrency.ConversionRate);
        
        return campaignValue  = local*toCurrency.ConversionRate;
        
    }
    
    
}