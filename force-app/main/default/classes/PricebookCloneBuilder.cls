public class PricebookCloneBuilder {
    
    private static final Schema.DescribeFieldResult PRICEBOOK_FIELD = Schema.PricebookEntry.Pricebook2Id.getDescribe();
    private static final Schema.DescribeFieldResult PRICEBOOK_PRODUCT_FIELD = Schema.PricebookEntry.Product2Id.getDescribe();
    private static final Schema.DescribeFieldResult PRICEBOOK_SETTING_SOURCE_FIELD = Schema.Pricebook_Clone__c.Source_Pricebook__c.getDescribe();
    private static final Integer STANDARD_PRICEBOOK_UNIT_PRICE = 1;
    private static final Integer PRICEBOOK_UNIT_PRICE = 0;

    private  final PricebookEntryRetriever pricebookEntryRetriever;
    private Map<Id,List<PricebookEntry>> standardEntriesByProduct;


    Map<Id,List<PricebookEntry>> destinationEntriesByProduct;

    private List<PricebookEntry> newPricebookEntries;
    private Pricebook_Clone__c pricebookSetting;

    public PricebookCloneBuilder(Pricebook_Clone__c pricebookSetting)
    {
        this.pricebookSetting = pricebookSetting;
        this.pricebookEntryRetriever = new PricebookEntryRetriever();
    }

    public List<PricebookEntry> Build()
    {
        newPricebookEntries  = new List<PricebookEntry>();

        Pricebook2 sourcePricebook = PriceBookUtilities.ExistingPricebooks.get(pricebookSetting.Source_Pricebook__c);
        Pricebook2 destinationPricebook = PriceBookUtilities.ExistingPricebooks.get(pricebookSetting.Destination_Pricebook__c);
        Pricebook2 standardPricebook = PriceBookUtilities.StandardPriceBook;

        if(sourcePricebook == null || destinationPricebook == null || standardPricebook == null) return newPricebookEntries;

        System.debug(sourcePricebook.Id);

        Map<Id,List<PricebookEntry>> sourceEntriesByProduct =  this.pricebookEntryRetriever.RetrieveByPricebookMapBy(sourcePricebook.Id,PRICEBOOK_PRODUCT_FIELD);
        destinationEntriesByProduct =  this.pricebookEntryRetriever.RetrieveByPricebookMapBy(destinationPricebook.Id,PRICEBOOK_PRODUCT_FIELD);
        //standardEntriesByProduct =  this.pricebookEntryRetriever.RetrieveByPricebookMapBy(standardPricebook.Id,PRICEBOOK_PRODUCT_FIELD);
        standardEntriesByProduct =  this.pricebookEntryRetriever.RetrieveByPricebookMapByCurrency(standardPricebook.Id,PRICEBOOK_PRODUCT_FIELD, pricebookSetting.Destination_Currency__c, sourceEntriesByProduct.keySet());

        System.debug(sourceEntriesByProduct.keySet().size());
        System.debug(destinationEntriesByProduct.keySet().size());
        System.debug(standardEntriesByProduct.keySet().size());

        for(Id productId : sourceEntriesByProduct.keySet())
        {
            List<PricebookEntry> pricebookEntries = sourceEntriesByProduct.get(productId);

            for(PricebookEntry pricebookEntry : pricebookEntries)
            {
                if(!DoesEntryExistInDestination(productId, pricebookSetting.Destination_Currency__c))
                {
                    if(!IsInStandardPricebook(pricebookEntry.Product2Id, pricebookSetting.Destination_Currency__c))
                    {
                        CreatePricebookEntry(standardPricebook.Id,pricebookEntry.Product2Id, pricebookSetting.Destination_Currency__c, STANDARD_PRICEBOOK_UNIT_PRICE);
                    }
                    CreatePricebookEntry(destinationPricebook.Id,pricebookEntry.Product2Id, pricebookSetting.Destination_Currency__c, PRICEBOOK_UNIT_PRICE);
                }
            }           
        }
        return newPricebookEntries;
    }

    private void CreatePricebookEntry(Id destinationPricebookId, Id productId, String currencyISOcode, Integer unitPrice)
    {
        if(!IsAlreadyoBeInsterted(destinationPricebookId, productId, currencyISOcode))
        {
            PricebookEntry newPricebookEntry = new PricebookEntry();
            newPricebookEntry.Product2Id = productId;
            newPricebookEntry.Pricebook2Id = destinationPricebookId;
            newPricebookEntry.CurrencyIsoCode = currencyISOcode;
            newPricebookEntry.IsActive = false;
            newPricebookEntry.UnitPrice = unitPrice;
            newPricebookEntries.add(newPricebookEntry);
        }
    }

    private Boolean DoesEntryExistInDestination(Id productId, String currencyIsoCode)
    {
        List<PricebookEntry> existingProducts = destinationEntriesByProduct.get(productId);
        if(existingProducts == null) return false;

        for(PricebookEntry pbEntry : existingProducts)
        {
            if(pbEntry.CurrencyIsoCode == currencyIsoCode)
            {
                return true;
            }
        }

        return false;
    }

    private Boolean IsAlreadyoBeInsterted(Id pricebookId, Id productId, String currencyIsoCode)
    {
        for(PricebookEntry pbEntry : newPricebookEntries)
        {
            if(pbEntry.CurrencyIsoCode == currencyIsoCode && pbEntry.Pricebook2Id == pricebookId && pbEntry.Product2Id == productId)
            {
                return true;
            }
        }
        return false;
    }

    private Boolean IsInStandardPricebook(Id productId, String currencyISOcode)
    {
        if(!standardEntriesByProduct.containsKey(productId)) return false;

        for(PricebookEntry pricebookEntry : standardEntriesByProduct.get(productId))
        {
            if(pricebookEntry.CurrencyIsoCode == currencyISOcode) return true;
        }
        return false;
    }
}