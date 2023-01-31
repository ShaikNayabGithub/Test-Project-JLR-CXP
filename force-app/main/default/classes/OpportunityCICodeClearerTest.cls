@isTest
public class OpportunityCICodeClearerTest {

    private static Id stdPricebookId;
    static testmethod void oppCodeClearer()
    {
           // Id stdPricebookId;
            Vehicle_Specification__c make = new Vehicle_Specification__c(); 
            make.RecordTypeId = [select Id from RecordType where Name = 'Make' and SObjectType = 'Vehicle_Specification__c' limit 1].id; 
            make.Name = 'Jaguar'; 
            insert make; 
             
            Vehicle_Specification__c model = new Vehicle_Specification__c(); 
            model.RecordTypeId = [select Id from RecordType where Name = 'Model' and SObjectType = 'Vehicle_Specification__c' limit 1].id;
            model.Name = 'Test Model';
            model.Make__c = make.Id;
            model.Is_Currently_Sold__c = true;
            insert model;
            
            Opportunity opportunity = new Opportunity();
            opportunity.Name = 'test';
            //opportunity.AccountId = CreateAccount().Id;
            opportunity.Brand__c = make.Id;
            opportunity.Primary_Model_Interest__c = model.Id;
            //opportunity.Derivative__c = derivative.Id;
            opportunity.CloseDate = Date.today();
            opportunity.StageName = 'Contacted';
            opportunity.DMS_Opportunity_ID__c = 'dmsId';
            insert opportunity;
            
            Pricebook2 countryBook = new Pricebook2(Name ='India', IsActive=true);
            insert countryBook;
            
            OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
            List<OpportunityLineItem> lisOfLineItem = new List<OpportunityLineItem>();
            Product2 model1 = new Product2();

            model1.Name = 'test model';
            model1.Make__c = make.Id;
    
            insert model1;
        

           // PricebookEntry pricebookEntry = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(countryBook , 'test', model1, make);
            
            Product2 product = new Product2();
            product.Name = 'Test product';
            product.Make__c = make.Id;
            product.Model__c = model1.Id;
            insert product;
    
            PriceBookEntry standardPriceBookEntry = new PriceBookEntry();

            standardPriceBookEntry.Product2Id = product.Id;

            standardPricebookEntry.PriceBook2Id = Test.getStandardPricebookId();
            standardPriceBookEntry.UnitPrice = 1;
            //sometimes the standard pricebook record is locked so pricebook entry cannot be entered
            //so try multiple (5) times
            //TestClass_LockableRecordInserter.AttemptInsert(standardPricebookEntry, 5);
            insert standardPriceBookEntry ;
            
            PriceBookEntry priceBookEntry = new PriceBookEntry();
            priceBookEntry.Product2Id = product.Id;
            priceBookEntry.PriceBook2Id = countryBook.Id;
            priceBookEntry.UnitPrice = 1;
            priceBookEntry.isActive = true;
    
            insert priceBookEntry;
            
            opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
            opportunityLineItem.OpportunityId = opportunity.Id;
            opportunityLineItem.Brand__c = make.Id;
            opportunityLineItem.Model__c = model1.Id;
            opportunityLineItem.Quantity = 1;
            opportunityLineItem.TotalPrice = 1;
        

            Test.startTest();
                
                insert opportunityLineItem;
                lisOfLineItem.add(opportunityLineItem);
                OpportunityCICodeClearer oppCICode = new OpportunityCICodeClearer ();
                oppCICode.Clear(lisOfLineItem); 
                System.assertEquals(model1.Name, 'test model');
            Test.stopTest();
        
            
    }
    
    @testSetup
    public static void PopulateStandardPricebookId(){
        stdPricebookId = Test.getStandardPricebookId();
    }


}