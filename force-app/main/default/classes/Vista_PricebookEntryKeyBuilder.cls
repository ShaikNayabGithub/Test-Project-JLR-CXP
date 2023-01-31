public class Vista_PricebookEntryKeyBuilder {
    private static final String PBE_KEY_FORMAT = '{0}_{1}';


    public static String Build(String productCode, String market)
    {
    
        market=getPriceBookNameFromLabel(market);      
        return String.format(PBE_KEY_FORMAT, new List<String> { productCode, market });
    }
    
    public static String getPriceBookNameFromLabel(String market){
    
        CountryToPricebook__mdt[] customMeta= [select masterlabel,id,Pricebook_Name__c from CountryToPricebook__mdt where masterlabel=:market];
        String countryName;
        
        if(customMeta!=null)
            if(!customMeta.isEmpty())
            {
                countryName=customMeta[0].Pricebook_Name__c ;
                
                if(countryName!=null && countryName!='')
                    market=countryName;
                
            }
        
     return market;
    }
    
    
    
    
}