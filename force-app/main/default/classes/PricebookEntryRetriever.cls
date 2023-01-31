public class PricebookEntryRetriever {
    public List<PricebookEntry> Retrieve(Map<String, List<SObject>> recordsByCountry, Schema.DescribeFieldResult productField)
    {
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        String productFieldName = productField.getName();
        
        for(String country : recordsByCountry.keySet()){
            Set<String> products = SObjectUtilities.GetFieldValues(recordsByCountry.get(country), productFieldName);
            List<PricebookEntry> countryPriceBookEntries = [Select UnitPrice, Product2Id, Pricebook2.Name From PricebookEntry Where Pricebook2.Name=:country And Product2Id In:products];
            priceBookEntries.addAll(countryPriceBookEntries);
        }
        
        return priceBookEntries;
    }

    public Map<Id,List<PricebookEntry>> RetrieveByPricebookMapBy(Id pricebookId, Schema.DescribeFieldResult mapByField)
    {
        List<PricebookEntry> pricebookEntries = [SELECT Product2Id, Pricebook2Id, CurrencyIsoCode FROM PricebookEntry WHERE Pricebook2Id =: pricebookId];

        if(pricebookEntries.size() == 0) return new Map<Id,List<PricebookEntry>>();

        return SObjectUtilities.MapByIdField(pricebookEntries, mapByField);
    }
    
    public Map<Id,List<PricebookEntry>> RetrieveByPricebookMapByCurrency(Id pricebookId, Schema.DescribeFieldResult mapByField, String currencyIsoCode, set<Id> SourceProductIdSet)
    {
        List<PricebookEntry> pricebookEntries = [SELECT Product2Id, Pricebook2Id, CurrencyIsoCode FROM PricebookEntry WHERE Pricebook2Id =: pricebookId AND CurrencyISOCode = :currencyIsoCode AND product2Id IN :SourceProductIdSet];

        if(pricebookEntries.size() == 0) return new Map<Id,List<PricebookEntry>>();

        return SObjectUtilities.MapByIdField(pricebookEntries, mapByField);
    }
}