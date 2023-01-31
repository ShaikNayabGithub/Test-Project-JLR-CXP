@isTest
public class OpportunityDeferDecisionValuesUpdTest {

     public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    static TestMethod void searchModelListTest(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false, Is_OppLineItem_Logic_Run__c = true);
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
         System.RunAs(portaluser){
                    Id priceBookId = Test.getStandardPricebookId();
            Pricebook2 standardPB = new Pricebook2(Name = 'India', Description = 'India', Region_or_Market__c = 'IN', IsActive = true);
            insert standardPB;
            Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
            insert p2;
            PricebookEntry PricebookEntry = new PricebookEntry(CurrencyIsoCode = 'INR',pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
            insert PricebookEntry;
                PricebookEntry PricebookEntry2 = new PricebookEntry(CurrencyIsoCode = 'INR',pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
       // insert PricebookEntry2;
            Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y', Product__c  = p2.Id,Months__c=43, Service_Plan_Type__c ='Free Service', Model_Alternative__c= 'F-Type',Family='Vehicle');
            insert servicePlan;
        Loyalty_Scheme__c lSheme = new Loyalty_Scheme__c(API_URL__c='www.testURL.come');
        insert lSheme;
        Loyalty_points__c lPints = new Loyalty_points__c(Number_of_Points__c=2000, Is_Eligible__c=true,
                                                         Corporate_multiplier__c =2,
                                                         Bonus_Points__c=3000,
                                                         Offer_Start_Date__c=system.today().addDays(-10), 
                                                         Individual_multiplier__c=2,
                                                         Product__c=p2.id,
                                                         Loyalty_Scheme__c =lSheme.Id,
                                                         Offer_End_Date__c=system.today().addDays(10));
        insert lPints;
       
            
            
            
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
			Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
			account.PersonMailingPostalCode = 'Valid PostalCode';
			account.PersonMailingState = 'Valid State';
			account.PersonMailingCity = 'Valid City';        
			account.PersonEmail = 'test@test.com';      
			account.Country_ISO_Code__c = 'IN';  
			account.Is_Primary__c = false;
			account.Phone = '1234567890';
			account.Loyalty_Scheme__c = lSheme.Id;
			//Database.DMLOptions dml = new Database.DMLOptions(); 
			//dml.DuplicateRuleHeader.AllowSave = true;
			//Database.insert(account, dml);
			insert account;
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.Derivative__c = p2.Id;
            //testasset.product2Id =[SELECT Id FROM Product2 Limit 1].Id;
            testasset.product2Id =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            
            insert testasset;
          
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name= 'Test Opp' , 
                                                      StageName ='Vehicle Selection',
                                                      Primary_Model_Interest__c = modelVehicle.Id,
                                                      Brand__c = modelVehicle.Make__c,
                                                      closedate = system.today().adddays(30),
                                                      Purchase_Type__c = 'New Vehicle',
                                                      Type = 'Product',
                                                      Sub_Type__c = 'Retail',
                                                      pricebook2id=priceBookId);
            insert opportunity;  
            opportunity oppIns = [select id,CurrencyIsoCode from opportunity where id =:opportunity.Id];
            //system.assertequals(oppIns.CurrencyIsoCode,null);
            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(Asset__c = testasset.Id, Product2Id = p2.Id,Brand__c = testasset.Brand__c,
                                       OpportunityId = opportunity.Id, QUANTITY = 1, UnitPrice = 1233, PricebookEntryId = PricebookEntry.Id );
            Test.startTest();
            insert testOpportunityLineItem;
             testOpportunityLineItem.UnitPrice = 1233;
            update testOpportunityLineItem;
            delete testOpportunityLineItem;
            Test.stopTest();
        }
        
    }
}