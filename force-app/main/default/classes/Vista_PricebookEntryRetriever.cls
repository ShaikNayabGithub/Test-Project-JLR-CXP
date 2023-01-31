public class Vista_PricebookEntryRetriever implements Vista_EntityRetriever_I {
    private static final String WHERE_CLAUSE_FORMAT = '(Product2.ProductCode = \'\'{0}\'\' AND PriceBook2.Name = \'\'{1}\'\')';
    

    public void Retrieve(Vista_RequestCollection requestCollection)
    {
        if(requestCollection.PriceBookEntries == null) {
            requestCollection.PriceBookEntries = new Map<String, PriceBookEntry>();
        }
        
        String priceBookEntryQuery = 'SELECT Id, ProductCode, Product2Id, CurrencyISOCode, PriceBook2.Name, UnitPrice FROM PriceBookEntry WHERE ';
        List<String> WhereClauses = new List<String>();
        String pricebook;
        
        for(List<Vista_RecordGroup> recordGroupList : requestCollection.RecordGroups.values()) {
            for(Vista_RecordGroup recordGroup : recordGroupList) {
            
                pricebook=Vista_PricebookEntryKeyBuilder.getPriceBookNameFromLabel(recordGroup.Request.Market_Description__c);
                WhereClauses.add(String.format(WHERE_CLAUSE_FORMAT, 
                    new List<String>{ recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId, 
                                    pricebook}));
            }
        }

        if(WhereClauses.isEmpty()) { return; }
        priceBookEntryQuery += String.join(WhereClauses, 'OR');
        
        for(PriceBookEntry priceBookEntry : database.query(priceBookEntryQuery)) {
            String pbeKey = Vista_PricebookEntryKeyBuilder.Build(priceBookEntry.ProductCode, 
                    priceBookEntry.PriceBook2.Name);
            requestCollection.PriceBookEntries.put(pbeKey, priceBookEntry);
        }
    }
}