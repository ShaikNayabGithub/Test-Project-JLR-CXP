@isTest
public class TestClass_PriceBookEntryBuilder {
    
    private static Id stdPricebookId;
    
    public static PriceBookEntry BuildPriceBookEntry(PriceBook2 priceBook, String productName, Product2 model, Vehicle_Specification__c make) {
        Product2 product = new Product2();
        product.Name = productName;
        product.Make__c = make.Id;
        product.Model__c = model.Id;
        insert product;

        PriceBookEntry standardPriceBookEntry = new PriceBookEntry();

        standardPriceBookEntry.Product2Id = product.Id;
        //standardPriceBookEntry.PriceBook2Id = [select Id from Pricebook2 where isStandard=true].Id;
        if(stdPricebookId == null){
            PopulateStandardPricebookId();
        }
        standardPricebookEntry.PriceBook2Id = stdPricebookId;
        standardPriceBookEntry.UnitPrice = 1;
        //sometimes the standard pricebook record is locked so pricebook entry cannot be entered
        //so try multiple (5) times
        TestClass_LockableRecordInserter.AttemptInsert(standardPricebookEntry, 5);

        PriceBookEntry priceBookEntry = new PriceBookEntry();
        priceBookEntry.Product2Id = product.Id;
        priceBookEntry.PriceBook2Id = priceBook.Id;
        priceBookEntry.UnitPrice = 1;
        priceBookEntry.isActive = true;

        insert priceBookEntry;
        return priceBookEntry;
    }
    
    public static PriceBookEntry BuildPriceBookEntry(PriceBook2 priceBook){
        return BuildPriceBookEntry(priceBook, 'test product');
    }
    
    public static PriceBookEntry BuildPriceBookEntry(PriceBook2 priceBook, String productName){
        return BuildPriceBookEntry(priceBook, productName, new Product2(), new Vehicle_Specification__c());
    }
    
    public static PriceBookEntry BuildPriceBookEntry(PriceBook2 priceBook, Product2 model){
        PriceBookEntry standardPriceBookEntry = new PriceBookEntry();

        standardPriceBookEntry.Product2Id = model.Id;
        if(stdPricebookId == null){
            PopulateStandardPricebookId();
        }
        standardPricebookEntry.PriceBook2Id = stdPricebookId;
        standardPriceBookEntry.UnitPrice = 1;
        //sometimes the standard pricebook record is locked so pricebook entry cannot be entered
        //so try multiple (5) times
        TestClass_LockableRecordInserter.AttemptInsert(standardPricebookEntry, 5);

        PriceBookEntry priceBookEntry = new PriceBookEntry();
        priceBookEntry.Product2Id = model.Id;
        priceBookEntry.PriceBook2Id = priceBook.Id;
        priceBookEntry.UnitPrice = 1;
        priceBookEntry.isActive = true;

        insert priceBookEntry;
        return priceBookEntry;
    }

    public static PriceBookEntry BuildPriceBookEntry(Id productId, PriceBook2 priceBook){
        return BuildPriceBookEntry(priceBook, new Product2(), productId, new Vehicle_Specification__c());
    }

    public static PriceBookEntry BuildPriceBookEntry(PriceBook2 priceBook, Product2 model, Id productId, Vehicle_Specification__c make) {
        Product2 product = new Product2();
        product.Id = productId;

        PriceBookEntry standardPriceBookEntry = new PriceBookEntry();

        standardPriceBookEntry.Product2Id = product.Id;
        //standardPriceBookEntry.PriceBook2Id = [select Id from Pricebook2 where isStandard=true].Id;
        if(stdPricebookId == null){
            PopulateStandardPricebookId();
        }
        standardPricebookEntry.PriceBook2Id = stdPricebookId;
        standardPriceBookEntry.UnitPrice = 1;
        //sometimes the standard pricebook record is locked so pricebook entry cannot be entered
        //so try multiple (5) times
        TestClass_LockableRecordInserter.AttemptInsert(standardPricebookEntry, 5);

        PriceBookEntry priceBookEntry = new PriceBookEntry();
        priceBookEntry.Product2Id = product.Id;
        priceBookEntry.PriceBook2Id = priceBook.Id;
        priceBookEntry.UnitPrice = 1;
        priceBookEntry.isActive = true;

        insert priceBookEntry;
        return priceBookEntry;
    }
    
    @testSetup
    public static void PopulateStandardPricebookId(){
        stdPricebookId = Test.getStandardPricebookId();
    }
}