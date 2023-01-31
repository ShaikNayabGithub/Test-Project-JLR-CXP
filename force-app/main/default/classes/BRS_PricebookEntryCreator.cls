/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		07/07/2021			CXPD-1321: Insert EUR currency Pricebook for Georgia market
* 2.0		Ashwin		20/07/2021			CXPD-1410: Insert USD currency Pricebook for Georgia market
* 
*/
public class BRS_PricebookEntryCreator { //refactor me!!
    private final BRS_EnhancedUpserter upserter;
    private final JSONDeserializer deserializer;    
    private final Map<String,BRS_Market_Settings__c> marketSettings = BRS_Market_Settings__c.getAll();
    
    public BRS_PricebookEntryCreator(BRS_EnhancedUpserter upserter, JSONDeserializer deserializer)
    {
        this.upserter = upserter;
        this.deserializer = deserializer;
    }
    
    
    public void Create(BRS_RequestCollection requestCollection)
    {        
        this.Create(requestCollection, true);
        this.Create(requestCollection, false);
    }
    
    
    private void Create(BRS_RequestCollection requestCollection, Boolean createStandard)
    {
        Map<Id, List<PricebookEntry>> pricebookEntriesByRequestIdMap = new Map<Id, List<PricebookEntry>>();
        for(Product2 product : requestCollection.ProductByProductCode.Values()){
            List<BRS_Request__c> requests = requestCollection.RequestsByProductCode.get(product.ProductCode);
            if(requests == null) continue;
            for(BRS_Request__c request : requests) {
                Pricebook2 pricebook;
                if(createStandard) {
                    pricebook = PriceBookUtilities.StandardPriceBook;
                } else {
                     pricebook = PriceBookUtilities.ExistingPricebooks.get(Vista_PricebookEntryKeyBuilder.getPriceBookNameFromLabel(request.Market_Description__c));
                }
                if(pricebook == null) continue;


                Set<String> currencies = new Set<String>();

                //Attempt to lookup the pricebook currency from the custom setting
                if(request.Market__c != null && string.isNotBlank(request.Market__c)){
                    if(marketSettings.containsKey(request.Market__c)){
                        String marketCurrencies = marketSettings.get(request.Market__c).Currency__c;
                        
                        //The currencies are stored in a comma seperated text string
                        if(String.isNotBlank(marketCurrencies)){
                            currencies.addAll(marketCurrencies.split(','));
                        }
                    }   
                }
                
                //If no currencies have been added, take the currency from the BRS data
                if(currencies.size() == 0){
                    currencies = new Set<String>((List<String>)this.deserializer.DeserializeSingle(request.Currencies__c, Type.forName('List<String>')));
                }

                List<PricebookEntry> requestPricebookEntries = pricebookEntriesByRequestIdMap.get(request.Id);
                if(requestPricebookEntries == null) {
                    requestPricebookEntries = new List<PricebookEntry>();
                    pricebookEntriesByRequestIdMap.put(request.Id, requestPricebookEntries);
                }
                for(String currencyCode : currencies) {
                    if('GEL' == currencyCode){//1.0
                        requestPricebookEntries.add(createPricebookEntry('EUR', createStandard, priceBook.Id, product.Id));
                        requestPricebookEntries.add(createPricebookEntry('USD', createStandard, priceBook.Id, product.Id));//2.0
                    }
                    requestPricebookEntries.add(createPricebookEntry(currencyCode, createStandard, priceBook.Id, product.Id));
                }
            }
        }
        Set<String> validatedEntryKeys = this.ValidateEntries(pricebookEntriesByRequestIdMap);

        List<PricebookEntry> pricebookEntriesToUpsert = new List<PricebookEntry>();
        List<BRS_Request__c> requestsByUpsert = new List<BRS_Request__c>();

        for(Id requestId : pricebookEntriesByRequestIdMap.keySet()) {
            List<PricebookEntry> subList = pricebookEntriesByRequestIdMap.get(requestId);
            if(subList == null) continue;

            for(PricebookEntry upsertRecord : subList) {
                String pricebookEntryKey = this.GeneratePricebookEntryKey(upsertRecord);
                if(validatedEntryKeys.contains(pricebookEntryKey)) {
                    pricebookEntriesToUpsert.add(upsertRecord);
                    requestsByUpsert.add(requestCollection.Requests.get(requestId));
                }
            }
        }
        this.upserter.UpsertRecords(pricebookEntriesToUpsert, requestsByUpsert);
    }
    
    private Set<String> ValidateEntries(Map<Id, List<PricebookEntry>> pricebookEntriesByRequestIdMap)
    {
        Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();

        for(List<PricebookEntry> recordList : pricebookEntriesByRequestIdMap.values()) {
            for(PricebookEntry pricebookEntry : recordList) {
                String pricebookEntryKey = this.GeneratePricebookEntryKey(pricebookEntry);
                pricebookEntryMap.put(pricebookEntryKey, pricebookEntry);
            }
        }
        
        Set<String> productIds = SObjectUtilities.GetFieldValues(pricebookEntryMap.values(), 
                PricebookEntryUtilities.ProductIdFieldName);
        Set<String> currencies = SObjectUtilities.GetFieldValues(pricebookEntryMap.values(), 
                PricebookEntryUtilities.CurrencyIsoCodeFieldName);
        Set<String> pricebooks = SObjectUtilities.GetFieldValues(pricebookEntryMap.values(), 
                PricebookEntryUtilities.PricebookIdFieldName);
        
        List<PriceBookEntry> currentPricebookEntries = [Select Pricebook2Id, Product2Id, CurrencyIsoCode FROM PriceBookEntry Where Product2Id IN: productIds AND 
            CurrencyIsoCode IN: currencies AND Pricebook2Id IN: pricebooks];
            
        for(PriceBookEntry currentPricebookEntry : currentPricebookEntries){
            String pricebookEntryKey = this.GeneratePricebookEntryKey(currentPricebookEntry);
            if(pricebookEntryMap.containsKey(pricebookEntryKey)){
                pricebookEntryMap.Remove(pricebookEntryKey);
            }
        }

        return pricebookEntryMap.keySet();
    }

    private String GeneratePricebookEntryKey(PricebookEntry pricebookEntry) 
    {
        String key = (String)pricebookEntry.Pricebook2Id + (String)pricebookEntry.Product2Id + (String)pricebookEntry.CurrencyIsoCode;
        return key;
    }
    //1.0
    private PricebookEntry createPricebookEntry(String currencyIsoCode, Boolean createStandard, Id priceBookId, Id productId){
        return new PricebookEntry(CurrencyIsoCode = currencyIsoCode,
                                  IsActive = createStandard,
                                  Pricebook2Id = priceBookId,
                                  Product2Id = productId,
                                  UnitPrice = 0
                                 );
    } 
}