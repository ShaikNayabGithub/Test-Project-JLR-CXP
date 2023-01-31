@isTest
public class Batch_FixAssetOwner_T {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    public static Id DemoOrLoanRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Demonstrator_Loan_Quota').getRecordTypeId();
    public static Id salestargetRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Sales_Target').getRecordTypeId();
    public static Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
    public static Id dealerOwnedRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Dealer_Owned').getRecordTypeId();
    public static Id OUVRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('OUV').getRecordTypeId();
    public static Id newRetailRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    public static Id onSellRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    
    static TestMethod void Batch_FixAssetOwner_Test(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        Id priceBookId = Test.getStandardPricebookId();
        List<Product2> prods = new List<Product2>();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        
        prods.add(p2);
        
        insert prods;
        
        List<PricebookEntry> pbes = new List<PricebookEntry>();
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        
        pbes.add(PricebookEntry);
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        pbes.add(PricebookEntry2);
        insert pbes;     
        Id accId;
        Vehicle_specification__c modelVehicle;
        Vehicle_specification__c makeVehicle;
        System.RunAs(portaluser){
            makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            accId = loggedinUser.AccountId; 
            
            
            List<Account> accs = new List<Account>();
            Account accoun2 = new Account(RecordTypeId = individualRecordType, LastName = 'test2',FirstName = 'Valid Firstname2',PersonMailingStreet = 'Valid Street');
            accoun2.PersonMailingPostalCode = 'Valid PostalCode';
            accoun2.PersonMailingState = 'Valid State';
            accoun2.PersonMailingCity = 'Valid City';        
            accoun2.PersonEmail = 'test2@test.com';      
            accoun2.Country_ISO_Code__c = 'AU';  
            accoun2.Is_Primary__c = false;
            //     accoun2.Loyalty_Scheme__c = lSheme.Id;
            accoun2.Phone = '1234562890';
            accs.add(accoun2);
            
            
            
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'resultingOwner',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'AU';  
            account.Is_Primary__c = false;
            // account.Loyalty_Scheme__c = lSheme.Id;
            account.Phone = '1234567890';
            accs.add(account);
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(accs, dml);
            
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = accId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Derivative__c  =p2.Id;
            testasset.Common_Sale_Type__c='Demonstrator';
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.ProductCode = '3762457362';
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
                                                      pricebook2id=standardPB.Id,
                                                      Handover_Date__c = system.today(),
                                                      Is_New_RDA_Process__c = true);
            insert opportunity;  
            
            //ensure RDA is not locked
            for(RDA_Locked__mdt rdal : [SELECT MasterLabel, RDA_Locked__c FROM RDA_Locked__mdt]){
                rdal.RDA_Locked__c = false;
            }
       
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
            List<RDA__c> rdaList = new List<RDA__c>();
            
            rdaList.Add(new RDA__c(recordtypeId =onSellRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                                   Registration_Number__c='TEST123', Retail_Offer__c='None',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Completed'));
            
            insert rdaList;
             }
            
            List<asset> asses = [select account.name, accountid from asset];
            List<Account> acces = [select id, name from account where lastname = 'test2'];
            // testRDA.Handover_Date__c = null;
            System.debug('HERE asses '+asses);
            system.debug('HERE asses'+asses[0].account.name);
            System.debug('HERE acces '+acces);
            
            Asset assest = new Asset();
            assest.Id = asses[0].Id;
            assest.AccountId = acces[0].id;
            update assest;
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            
            Database.executeBatch(new Batch_FixAssetOwner(null),500);
            Test.stopTest();
            List<asset> assesFinal = [select account.LastName, accountid from asset];
            system.debug('HERE assesFinal'+assesFinal);
            system.debug('HERE assesFinal'+assesFinal[0].account.LastName);
            System.assertEquals('resultingOwner', assesFinal[0].account.LastName);
        
    }
    
    
}