@isTest
public class VehicleSelectionOnOpportunityConTest {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    
    static TestMethod void searchModelListTest() {
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id, Is_Currently_Sold__c= true);
        insert modelVehicle;
        User portalUser = TestUtility.createPortaluser('India', 'Sales Executive');
        system.debug('portalUser ' + portalUser);
        
        System.RunAs(portaluser) {
            
            Id priceBookId = Test.getStandardPricebookId();
            
            Product2 p2 = new product2(name='y', Model_Alternative__c= 'F-Type', Family='Vehicle');
            insert p2;
            PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id, unitprice=1.0, isActive=true, UseStandardPrice = false);
            insert PricebookEntry; 
            
            Pricebook2 standardPB = new Pricebook2(Name = 'India', Description = 'India', Region_or_Market__c = 'IN', IsActive = true);
            insert standardPB;
            
            PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id, unitprice=1.0, isActive=true, UseStandardPrice = false);
            insert PricebookEntry2;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode  
                                 FROM User 
                                 WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null 
                                 AND AccountId != null];
            
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test', FirstName = 'Valid Firstname', PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'IN';  
            account.Is_Primary__c = false;
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =[SELECT Id FROM Product2 Limit 1].Id;
            testasset.Status = Label.Asset_Status_List.split(', ')[0];
            // testasset.CurrencyIsoCode = 'IN';
            testasset.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name= 'Test Opp' , 
                                                      StageName = 'Vehicle Selection', 
                                                      Primary_Model_Interest__c = modelVehicle.Id, 
                                                      Brand__c = modelVehicle.Make__c, 
                                                      closedate = system.today().adddays(30), 
                                                      Purchase_Type__c = 'New Vehicle', 
                                                      Type = 'Product', 
                                                      Sub_Type__c = 'Retail', 
                                                      // pricebook2Id = standardPB.Id, 
                                                      Is_New_RDA_Process__c = true);                                                       
            insert opportunity;  
            
            OpportunityLineItem testOpportunityLineItem=  new OpportunityLineItem(Asset__c = testasset.Id, 
                                                                                  Brand__c = testasset.Brand__c, 
                                                                                  OpportunityId = opportunity.Id, 
                                                                                  QUANTITY = 1, 
                                                                                  UnitPrice = 3453, 
                                                                                  PricebookEntryId = PricebookEntry.Id );
            insert testOpportunityLineItem;
            
            Test.startTest();
            VehicleSelectionOnOpportunityController.updateOpportunity(opportunity.Id, standardPB.Name);
            VehicleSelectionOnOpportunityController.getOpportunity(opportunity.Id);
            VehicleSelectionOnOpportunityController.removeOpportunityProduct(opportunity.Id);
            VehicleSelectionOnOpportunityController.getPriceBookList();
            Test.stopTest();
        }
    }
    
}