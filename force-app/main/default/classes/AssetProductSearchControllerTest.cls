@isTest
public class AssetProductSearchControllerTest {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
    
    static TestMethod void AssetProductSearchControllerTotalTestPt1(){
        Vehicle_specification__c makeVehicle = new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle = new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c = makeVehicle.Id, Is_Currently_Sold__c = true);
        insert modelVehicle;
        
        User portalUser = TestUtility.createPortaluser('India', 'Sales Executive');
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'India', Description = 'India', Region_or_Market__c = 'IN', IsActive = true, CurrencyIsoCode = 'GBP');
        user u = TestUtility.CreateMarketSpecificUser('INRUser', 'JLR System Administrator (Super)', 'India', 'IN', 'INR', 'IN');
        system.runAs(u){    
            insert standardPB;
        }
        String currentYear = String.valueOf(System.today().year());
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y', Model_Alternative__c = 'F-Type', Family='Vehicle', Model_Year__c=currentYear);
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry2;
        System.RunAs(portaluser) {
            // Get logged in user 
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            // Create an Account
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
            
            // Create an Asset
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.VIN__c = 'SALZA2AT5MH123456';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id = p2.Id;
            testasset.Derivative__c = p2.Id;
            testasset.Status = Label.Asset_Status_List.split(', ')[0];
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            // Create an Opportunity
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name = 'Test Opp' , 
                                                      StageName ='Vehicle Selection', 
                                                      Primary_Model_Interest__c = modelVehicle.Id, 
                                                      Brand__c = modelVehicle.Make__c, 
                                                      closedate = system.today().adddays(30), 
                                                      Purchase_Type__c = 'New Vehicle', 
                                                      Type = 'Product', 
                                                      Sub_Type__c = 'Retail', 
                                                      CurrencyIsoCode = 'GBP', 
                                                      pricebook2id = standardPB.Id);
            insert opportunity;  
            
            Test.startTest();          
            List<String> AssetStatusList = Label.Asset_Status_List.split(', ');
            AssetProductSearchController.getFieldLabel('Asset');
            AssetProductSearchController.searchModelList();
            AssetProductSearchController.getOpportunity(opportunity.Id);
            AssetProductSearchController.getAssetList(opportunity.Id, null, null);
            AssetProductSearchController.getAssetList(opportunity.Id, modelVehicle.Id, null);
            AssetProductSearchController.getAssetList(opportunity.Id, modelVehicle.Id, p2.Id);
            List<Map<String, String>> prodList =  AssetProductSearchController.searchProductList(opportunity.Id, modelVehicle.Id);
            AssetProductSearchController.saveproductLineItem(new OpportunityLineItem(), opportunity.Id, testasset.Id, modelVehicle.Id, null); 
            AssetProductSearchController.updateOpportunity(opportunity.Id, testasset.Id, modelVehicle.Id, null); 
            AssetProductSearchController.updateOpportunity(opportunity.Id, null, modelVehicle.Id, p2.Id);
            AssetProductSearchController.searchProductList(opportunity.Id, '');
            AssetProductSearchController.createOppProduct(opportunity.Id, p2.Id, modelVehicle.Id, testasset.Id);
            AssetProductSearchController.getFilteredListOfProducts(prodList, 'y');
            AssetProductSearchController.getAssetListUsingVIN(testasset.VIN__c);
            AssetProductSearchController.getRelatedAccAndOppty(testasset.Id);
            AssetProductSearchController.getAssetLinkedOpportunities(testasset.Id);
            
            
            Test.stopTest(); 
        }
    }

    static TestMethod void AssetProductSearchControllerTotalTestPt2(){
        Vehicle_specification__c makeVehicle = new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle = new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c = makeVehicle.Id, Is_Currently_Sold__c = true);
        insert modelVehicle;
        
        User portalUser = TestUtility.createPortaluser('India', 'Sales Executive');
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'India', Description = 'India', Region_or_Market__c = 'IN', IsActive = true, CurrencyIsoCode = 'GBP');
        user u = TestUtility.CreateMarketSpecificUser('INRUser', 'JLR System Administrator (Super)', 'India', 'IN', 'INR', 'IN');
        system.runAs(u){    
            insert standardPB;
        }
        String currentYear = String.valueOf(System.today().year());
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y', Model_Alternative__c = 'F-Type', Family='Vehicle', Model_Year__c=currentYear);
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry2;
        System.RunAs(portaluser) {
            // Get logged in user 
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            // Create an Account
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
            
            // Create an Asset
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.VIN__c = 'SALZA2AT5MH123456';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id = p2.Id;
            testasset.Derivative__c = p2.Id;
            testasset.Status = Label.Asset_Status_List.split(', ')[0];
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            // Create an Opportunity
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name = 'Test Opp' , 
                                                      StageName ='Vehicle Selection', 
                                                      Primary_Model_Interest__c = modelVehicle.Id, 
                                                      Brand__c = modelVehicle.Make__c, 
                                                      closedate = system.today().adddays(30), 
                                                      Purchase_Type__c = 'New Vehicle', 
                                                      Type = 'Product', 
                                                      Sub_Type__c = 'Retail', 
                                                      CurrencyIsoCode = 'GBP', 
                                                      pricebook2id = standardPB.Id);
            insert opportunity;  
            
            Test.startTest();          
            List<String> AssetStatusList = Label.Asset_Status_List.split(', ');
            
            
            // Create Opportunity Wrapper
            AssetProductSearchController.OpportunityWrapper objOpportunityWrapper = new AssetProductSearchController.OpportunityWrapper();
            objOpportunityWrapper.opptyId = opportunity.Id;
            objOpportunityWrapper.opptyName = 'Test Opportunity';
            objOpportunityWrapper.opptyAccName = 'Test Account';
            objOpportunityWrapper.opptyCreatedBy = 'Test User';
            objOpportunityWrapper.opptyCreatedDate = system.today();
            objOpportunityWrapper.opptyPrimaryModelInt = 'Jaguar';
            objOpportunityWrapper.opptyLineItemAsset = 'VIP_Jaugar';
            
            try {
                AssetProductSearchController.getLineItem(opportunity.Id, testasset.Id, modelVehicle.Id, null);      
                AssetProductSearchController.sendAccountsForReview(new List < Account > {account});
                
                AssetProductSearchController.CustomException ex = new AssetProductSearchController.CustomException();
            } catch(Exception e){
                
            } 
            Test.stopTest(); 
        }
    }
    
    static TestMethod void AssetProductSearchControllerMENAPt1(){
        Vehicle_specification__c makeVehicle = new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle = new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c = makeVehicle.Id, Is_Currently_Sold__c = true);
        insert modelVehicle;
        
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        Account accountForUpsert;
        
        User runningUser = new User();
        system.runAs(new user(id=userinfo.getUserId()))
        {
            runningUser.Phone = '07681102495';
            runningUser.Email = 'test@test1.test';
            runningUser.ProfileId = systemAdmin.Id;
            runningUser.UserName = 'test@test.test.admin';
            runningUser.Alias = 'TTT';
            runningUser.UserRoleId=[select id from UserRole where Name='System Administrator' Limit 1 ].Id;
            runningUser.FirstName = 'Test';
            runningUser.LastName = 'Test';
            runningUser.Country = 'Jordan';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            //runningUser.DefaultCurrencyIsoCode ='JOD';   
            runningUser.Market__c = 'MENA';
            runningUser.Country_ISO_Code__c='JO';
            Insert runningUser;
        }
        User portalUser1;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            insert retailerAccount;
            
            testCommContact.LastName = 'Test Name';
            testCommContact.AccountID = retailerAccount.Id;
            //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
            testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
            testCommContact.Email = 'test@test.test';
            insert testCommContact;
        }
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        portalUser1 = new User();
        portalUser1.Phone = '07681102495';
        portalUser1.Email = 'test@test.test';
        portalUser1.ProfileId = salesExecutiveProfile.Id;
        portalUser1.UserName = 'test@test.test.retailer';
        portalUser1.Alias = 'TTT';
        portalUser1.ContactID = testCommContact.Id;
        portalUser1.FirstName = 'Test';
        portalUser1.LastName = 'Test';
        portalUser1.Country = 'Jordan';
        portalUser1.LanguageLocaleKey = 'en_US';
        portalUser1.LocaleSidKey = 'en_US';
        portalUser1.TimeZoneSidKey = 'America/Chicago';
        portalUser1.EmailEncodingKey = 'UTF-8';
        portalUser1.DefaultCurrencyIsoCode ='GBP';   
        portalUser1.Market__c = 'MENA';
        portalUser1.Country_ISO_Code__c='JO';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser1;
        }

        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Jordan', Description = 'Jordan', Region_or_Market__c = 'MENA', IsActive = true, CurrencyIsoCode = 'GBP');
        user u = TestUtility.CreateMarketSpecificUser('MENAUser', 'JLR System Administrator (Super)', 'Jordan', 'JO', 'GBP', 'MENA');
        system.runAs(u){    
            insert standardPB;
        }
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y', Model_Alternative__c = 'F-Type', Family='Vehicle');
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry2;
        System.RunAs(portalUser1) {
            // Get logged in user 
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            // Create an Account
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test1', FirstName = 'Valid Firstname1', PersonMailingStreet = 'Valid Street1');
            account.PersonMailingPostalCode = 'Valid PostalCode1';
            account.PersonMailingState = 'Valid State1';
            account.PersonMailingCity = 'Valid City1';        
            account.PersonEmail = 'test@test1.com';      
            account.Country_ISO_Code__c = 'JO';  
            account.Is_Primary__c = false;
            account.Phone = '12345678901';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            // Create an Asset
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset1';
            testasset.VIN__c = 'SALZA2AT5MH1234561';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id = p2.Id;
            testasset.Derivative__c = p2.Id;
            testasset.Status = Label.Asset_Status_List.split(', ')[0];
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            // Create an Opportunity
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name = 'Test Opp1' , 
                                                      StageName ='Vehicle Selection', 
                                                      Primary_Model_Interest__c = modelVehicle.Id, 
                                                      Brand__c = modelVehicle.Make__c, 
                                                      closedate = system.today().adddays(30), 
                                                      Purchase_Type__c = 'Used Vehicle', 
                                                      Type = 'Product', 
                                                      Sub_Type__c = 'Retail', 
                                                      CurrencyIsoCode = 'GBP', 
                                                      pricebook2id = standardPB.Id);
            insert opportunity;  
            
            Test.startTest();          
            List<String> AssetStatusList = Label.Asset_Status_List.split(', ');
            AssetProductSearchController.getFieldLabel('Asset');
            AssetProductSearchController.searchModelList();
            AssetProductSearchController.getOpportunity(opportunity.Id);
            AssetProductSearchController.getAssetList(opportunity.Id, null, null);
            AssetProductSearchController.getAssetList(opportunity.Id, modelVehicle.Id, null);
            AssetProductSearchController.getAssetList(opportunity.Id, modelVehicle.Id, p2.Id);
            List<Map<String, String>> prodList =  AssetProductSearchController.searchProductList(opportunity.Id, modelVehicle.Id);
            AssetProductSearchController.saveproductLineItem(new OpportunityLineItem(), opportunity.Id, testasset.Id, modelVehicle.Id, null); 
            AssetProductSearchController.updateOpportunity(opportunity.Id, testasset.Id, modelVehicle.Id, null); 
            AssetProductSearchController.updateOpportunity(opportunity.Id, null, modelVehicle.Id, p2.Id);
            AssetProductSearchController.searchProductList(opportunity.Id, '');
            AssetProductSearchController.createOppProduct(opportunity.Id, p2.Id, modelVehicle.Id, testasset.Id);
            AssetProductSearchController.getFilteredListOfProducts(prodList, 'y');
            AssetProductSearchController.getAssetListUsingVIN(testasset.VIN__c);
            AssetProductSearchController.getRelatedAccAndOppty(testasset.Id);
            AssetProductSearchController.getAssetLinkedOpportunities(testasset.Id);
            
            
            Test.stopTest(); 
        }
    }

    static TestMethod void AssetProductSearchControllerMENAPt2(){
        Vehicle_specification__c makeVehicle = new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle = new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c = makeVehicle.Id, Is_Currently_Sold__c = true);
        insert modelVehicle;
        
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        Account accountForUpsert;
        
        User runningUser = new User();
        system.runAs(new user(id=userinfo.getUserId()))
        {
            runningUser.Phone = '07681102495';
            runningUser.Email = 'test@test1.test';
            runningUser.ProfileId = systemAdmin.Id;
            runningUser.UserName = 'test@test.test.admin';
            runningUser.Alias = 'TTT';
            runningUser.UserRoleId=[select id from UserRole where Name='System Administrator' Limit 1 ].Id;
            runningUser.FirstName = 'Test';
            runningUser.LastName = 'Test';
            runningUser.Country = 'Jordan';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            //runningUser.DefaultCurrencyIsoCode ='JOD';   
            runningUser.Market__c = 'MENA';
            runningUser.Country_ISO_Code__c='JO';
            Insert runningUser;
        }
        User portalUser1;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            insert retailerAccount;
            
            testCommContact.LastName = 'Test Name';
            testCommContact.AccountID = retailerAccount.Id;
            //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
            testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
            testCommContact.Email = 'test@test.test';
            insert testCommContact;
        }
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        portalUser1 = new User();
        portalUser1.Phone = '07681102495';
        portalUser1.Email = 'test@test.test';
        portalUser1.ProfileId = salesExecutiveProfile.Id;
        portalUser1.UserName = 'test@test.test.retailer';
        portalUser1.Alias = 'TTT';
        portalUser1.ContactID = testCommContact.Id;
        portalUser1.FirstName = 'Test';
        portalUser1.LastName = 'Test';
        portalUser1.Country = 'Jordan';
        portalUser1.LanguageLocaleKey = 'en_US';
        portalUser1.LocaleSidKey = 'en_US';
        portalUser1.TimeZoneSidKey = 'America/Chicago';
        portalUser1.EmailEncodingKey = 'UTF-8';
        portalUser1.DefaultCurrencyIsoCode ='GBP';   
        portalUser1.Market__c = 'MENA';
        portalUser1.Country_ISO_Code__c='JO';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser1;
        }

        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Jordan', Description = 'Jordan', Region_or_Market__c = 'MENA', IsActive = true, CurrencyIsoCode = 'GBP');
        user u = TestUtility.CreateMarketSpecificUser('MENAUser', 'JLR System Administrator (Super)', 'Jordan', 'JO', 'GBP', 'MENA');
        system.runAs(u){    
            insert standardPB;
        }
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y', Model_Alternative__c = 'F-Type', Family='Vehicle');
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry2;
        System.RunAs(portalUser1) {
            // Get logged in user 
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            // Create an Account
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test1', FirstName = 'Valid Firstname1', PersonMailingStreet = 'Valid Street1');
            account.PersonMailingPostalCode = 'Valid PostalCode1';
            account.PersonMailingState = 'Valid State1';
            account.PersonMailingCity = 'Valid City1';        
            account.PersonEmail = 'test@test1.com';      
            account.Country_ISO_Code__c = 'JO';  
            account.Is_Primary__c = false;
            account.Phone = '12345678901';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            // Create an Asset
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset1';
            testasset.VIN__c = 'SALZA2AT5MH1234561';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id = p2.Id;
            testasset.Derivative__c = p2.Id;
            testasset.Status = Label.Asset_Status_List.split(', ')[0];
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            // Create an Opportunity
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name = 'Test Opp1' , 
                                                      StageName ='Vehicle Selection', 
                                                      Primary_Model_Interest__c = modelVehicle.Id, 
                                                      Brand__c = modelVehicle.Make__c, 
                                                      closedate = system.today().adddays(30), 
                                                      Purchase_Type__c = 'Used Vehicle', 
                                                      Type = 'Product', 
                                                      Sub_Type__c = 'Retail', 
                                                      CurrencyIsoCode = 'GBP', 
                                                      pricebook2id = standardPB.Id);
            insert opportunity;  
            
            Test.startTest();          
            List<String> AssetStatusList = Label.Asset_Status_List.split(', ');
            
            
            // Create Opportunity Wrapper
            AssetProductSearchController.OpportunityWrapper objOpportunityWrapper = new AssetProductSearchController.OpportunityWrapper();
            objOpportunityWrapper.opptyId = opportunity.Id;
            objOpportunityWrapper.opptyName = 'Test Opportunity';
            objOpportunityWrapper.opptyAccName = 'Test Account';
            objOpportunityWrapper.opptyCreatedBy = 'Test User';
            objOpportunityWrapper.opptyCreatedDate = system.today();
            objOpportunityWrapper.opptyPrimaryModelInt = 'Jaguar';
            objOpportunityWrapper.opptyLineItemAsset = 'VIP_Jaugar';
            
            try {
                AssetProductSearchController.getLineItem(opportunity.Id, testasset.Id, modelVehicle.Id, null);      
                AssetProductSearchController.sendAccountsForReview(new List < Account > {account});
                
                AssetProductSearchController.CustomException ex = new AssetProductSearchController.CustomException();
            } catch(Exception e){
                
            } 
            Test.stopTest(); 
        }
    }

    static TestMethod void AssetProductSearchControllerKoreaPt1(){
        Vehicle_specification__c makeVehicle = new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle = new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c = makeVehicle.Id, Is_Currently_Sold__c = true);
        insert modelVehicle;
        
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        Account accountForUpsert;
        
        User runningUser = new User();
        system.runAs(new user(id=userinfo.getUserId()))
        {
            runningUser.Phone = '07681102495';
            runningUser.Email = 'test@test1.test';
            runningUser.ProfileId = systemAdmin.Id;
            runningUser.UserName = 'test@test.test.admin';
            runningUser.Alias = 'TTT';
            runningUser.UserRoleId=[select id from UserRole where Name='System Administrator' Limit 1 ].Id;
            runningUser.FirstName = 'Test';
            runningUser.LastName = 'Test';
            runningUser.Country = 'South Korea';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            //runningUser.DefaultCurrencyIsoCode ='JOD';   
            runningUser.Market__c = 'Korea';
            runningUser.Country_ISO_Code__c='KR';
            Insert runningUser;
        }
        User portalUser1;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            insert retailerAccount;
            
            testCommContact.LastName = 'Test Name';
            testCommContact.AccountID = retailerAccount.Id;
            //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
            testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
            testCommContact.Email = 'test@test.test';
            insert testCommContact;
        }
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        portalUser1 = new User();
        portalUser1.Phone = '07681102495';
        portalUser1.Email = 'test@test.test';
        portalUser1.ProfileId = salesExecutiveProfile.Id;
        portalUser1.UserName = 'test@test.test.retailer';
        portalUser1.Alias = 'TTT';
        portalUser1.ContactID = testCommContact.Id;
        portalUser1.FirstName = 'Test';
        portalUser1.LastName = 'Test';
        portalUser1.Country = 'Korea';
        portalUser1.LanguageLocaleKey = 'en_US';
        portalUser1.LocaleSidKey = 'en_US';
        portalUser1.TimeZoneSidKey = 'America/Chicago';
        portalUser1.EmailEncodingKey = 'UTF-8';
        portalUser1.DefaultCurrencyIsoCode ='KRW';   
        portalUser1.Market__c = 'Korea';
        portalUser1.Country_ISO_Code__c='KR';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser1;
        }

        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Korea', Description = 'Korea', Region_or_Market__c = 'Korea', IsActive = true, CurrencyIsoCode = 'GBP');
        user u = TestUtility.CreateMarketSpecificUser('MENAUser', 'JLR System Administrator (Super)', 'Korea', 'KR', 'GBP', 'Korea');
        system.runAs(u){    
            insert standardPB;
        }
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y', Model_Alternative__c = 'F-Type', Family='Vehicle');
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry2;
        System.RunAs(portalUser1) {
            // Get logged in user 
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            // Create an Account
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test1', FirstName = 'Valid Firstname1', PersonMailingStreet = 'Valid Street1');
            account.PersonMailingPostalCode = 'Valid PostalCode1';
            account.PersonMailingState = 'Valid State1';
            account.PersonMailingCity = 'Valid City1';        
            account.PersonEmail = 'test@test1.com';      
            account.Country_ISO_Code__c = 'KR';  
            account.Is_Primary__c = false;
            account.Phone = '12345678901';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            // Create an Asset
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset1';
            testasset.VIN__c = 'SALZA2AT5MH1234561';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id = p2.Id;
            testasset.Derivative__c = p2.Id;
            testasset.Status = Label.Asset_Status_List.split(', ')[0];
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            // Create an Opportunity
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name = 'Test Opp1' , 
                                                      StageName ='Vehicle Selection', 
                                                      Primary_Model_Interest__c = modelVehicle.Id, 
                                                      Brand__c = modelVehicle.Make__c, 
                                                      closedate = system.today().adddays(30), 
                                                      Purchase_Type__c = 'Used Vehicle', 
                                                      Type = 'Product', 
                                                      Sub_Type__c = 'Retail', 
                                                      CurrencyIsoCode = 'GBP', 
                                                      pricebook2id = standardPB.Id);
            insert opportunity;  
            
            Test.startTest();          
            List<String> AssetStatusList = Label.Asset_Status_List.split(', ');
            AssetProductSearchController.getFieldLabel('Asset');
            AssetProductSearchController.searchModelList();
            AssetProductSearchController.getOpportunity(opportunity.Id);
            AssetProductSearchController.getAssetList(opportunity.Id, null, null);
            AssetProductSearchController.getAssetList(opportunity.Id, modelVehicle.Id, null);
            AssetProductSearchController.getAssetList(opportunity.Id, modelVehicle.Id, p2.Id);
            List<Map<String, String>> prodList =  AssetProductSearchController.searchProductList(opportunity.Id, modelVehicle.Id);
            AssetProductSearchController.saveproductLineItem(new OpportunityLineItem(), opportunity.Id, testasset.Id, modelVehicle.Id, null); 
            AssetProductSearchController.updateOpportunity(opportunity.Id, testasset.Id, modelVehicle.Id, null); 
            AssetProductSearchController.updateOpportunity(opportunity.Id, null, modelVehicle.Id, p2.Id);
            AssetProductSearchController.searchProductList(opportunity.Id, '');
            AssetProductSearchController.createOppProduct(opportunity.Id, p2.Id, modelVehicle.Id, testasset.Id);
            AssetProductSearchController.getFilteredListOfProducts(prodList, 'y');
            AssetProductSearchController.getAssetListUsingVIN(testasset.VIN__c);
            AssetProductSearchController.getRelatedAccAndOppty(testasset.Id);
            AssetProductSearchController.getAssetLinkedOpportunities(testasset.Id);
            
            
            Test.stopTest(); 
        }
    }

    static TestMethod void AssetProductSearchControllerKoreaPt2(){
        Vehicle_specification__c makeVehicle = new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle = new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c = makeVehicle.Id, Is_Currently_Sold__c = true);
        insert modelVehicle;
        
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        Account accountForUpsert;
        
        User runningUser = new User();
        system.runAs(new user(id=userinfo.getUserId()))
        {
            runningUser.Phone = '07681102495';
            runningUser.Email = 'test@test1.test';
            runningUser.ProfileId = systemAdmin.Id;
            runningUser.UserName = 'test@test.test.admin';
            runningUser.Alias = 'TTT';
            runningUser.UserRoleId=[select id from UserRole where Name='System Administrator' Limit 1 ].Id;
            runningUser.FirstName = 'Test';
            runningUser.LastName = 'Test';
            runningUser.Country = 'South Korea';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            //runningUser.DefaultCurrencyIsoCode ='JOD';   
            runningUser.Market__c = 'Korea';
            runningUser.Country_ISO_Code__c='KR';
            Insert runningUser;
        }
        User portalUser1;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.Primary_Dealer_Code__c='JLR';
            insert retailerAccount;
            
            testCommContact.LastName = 'Test Name';
            testCommContact.AccountID = retailerAccount.Id;
            //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
            testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
            testCommContact.Email = 'test@test.test';
            insert testCommContact;
        }
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        portalUser1 = new User();
        portalUser1.Phone = '07681102495';
        portalUser1.Email = 'test@test.test';
        portalUser1.ProfileId = salesExecutiveProfile.Id;
        portalUser1.UserName = 'test@test.test.retailer';
        portalUser1.Alias = 'TTT';
        portalUser1.ContactID = testCommContact.Id;
        portalUser1.FirstName = 'Test';
        portalUser1.LastName = 'Test';
        portalUser1.Country = 'Jordan';
        portalUser1.LanguageLocaleKey = 'en_US';
        portalUser1.LocaleSidKey = 'en_US';
        portalUser1.TimeZoneSidKey = 'America/Chicago';
        portalUser1.EmailEncodingKey = 'UTF-8';
        portalUser1.DefaultCurrencyIsoCode ='KRW';   
        portalUser1.Market__c = 'Korea';
        portalUser1.Country_ISO_Code__c='KR';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser1;
        }

        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Korea', Description = 'Korea', Region_or_Market__c = 'Korea', IsActive = true, CurrencyIsoCode = 'GBP');
        user u = TestUtility.CreateMarketSpecificUser('MENAUser', 'JLR System Administrator (Super)', 'Korea', 'KR', 'GBP', 'Korea');
        system.runAs(u){    
            insert standardPB;
        }
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y', Model_Alternative__c = 'F-Type', Family='Vehicle');
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.Id, unitprice = 1.0, isActive = true, UseStandardPrice = false, CurrencyIsoCode = 'GBP');
        insert PricebookEntry2;
        System.RunAs(portalUser1) {
            // Get logged in user 
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            // Create an Account
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test1', FirstName = 'Valid Firstname1', PersonMailingStreet = 'Valid Street1');
            account.PersonMailingPostalCode = 'Valid PostalCode1';
            account.PersonMailingState = 'Valid State1';
            account.PersonMailingCity = 'Valid City1';        
            account.PersonEmail = 'test@test1.com';      
            account.Country_ISO_Code__c = 'KR';  
            account.Is_Primary__c = false;
            account.Phone = '12345678901';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            // Create an Asset
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset1';
            testasset.VIN__c = 'SALZA2AT5MH1234561';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id = p2.Id;
            testasset.Derivative__c = p2.Id;
            testasset.Status = Label.Asset_Status_List.split(', ')[0];
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            // Create an Opportunity
            Opportunity opportunity = new Opportunity(AccountId = account.Id, 
                                                      Name = 'Test Opp1' , 
                                                      StageName ='Vehicle Selection', 
                                                      Primary_Model_Interest__c = modelVehicle.Id, 
                                                      Brand__c = modelVehicle.Make__c, 
                                                      closedate = system.today().adddays(30), 
                                                      Purchase_Type__c = 'Used Vehicle', 
                                                      Type = 'Product', 
                                                      Sub_Type__c = 'Retail', 
                                                      CurrencyIsoCode = 'GBP', 
                                                      pricebook2id = standardPB.Id);
            insert opportunity;  
            
            Test.startTest();          
            List<String> AssetStatusList = Label.Asset_Status_List.split(', ');
           
            
            // Create Opportunity Wrapper
            AssetProductSearchController.OpportunityWrapper objOpportunityWrapper = new AssetProductSearchController.OpportunityWrapper();
            objOpportunityWrapper.opptyId = opportunity.Id;
            objOpportunityWrapper.opptyName = 'Test Opportunity';
            objOpportunityWrapper.opptyAccName = 'Test Account';
            objOpportunityWrapper.opptyCreatedBy = 'Test User';
            objOpportunityWrapper.opptyCreatedDate = system.today();
            objOpportunityWrapper.opptyPrimaryModelInt = 'Jaguar';
            objOpportunityWrapper.opptyLineItemAsset = 'VIP_Jaugar';
            
            try {
                AssetProductSearchController.getLineItem(opportunity.Id, testasset.Id, modelVehicle.Id, null);      
                AssetProductSearchController.sendAccountsForReview(new List < Account > {account});
                AssetProductSearchController.getregionmarket();
                AssetProductSearchController.CustomException ex = new AssetProductSearchController.CustomException();
            } catch(Exception e){
                
            } 

            
            Test.stopTest(); 
        }
    }

    
}