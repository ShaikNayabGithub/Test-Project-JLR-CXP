@isTest
public class AssetHandler_Test {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    public static Id prodModelRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    
    
    @IsTest
    static void updateAssetFromIndividualPopulatesToCorporatePreventForAUAccount(){
        //Arrange
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        Account acc2 = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        Boolean error = false;
        //createPersonAccount_Australia
        ass.accountId = acc.id;
        update ass;
        
        //Act
        Test.startTest();
        ass.accountId = acc2.id;
        try{
            update ass;
        }catch(Exception ex){
            system.debug('ex '+ex);
            error = true;
        }
        
        
        Test.stopTest();
        //Assert
        Asset assRet = [SELECT id, AccountId, key_Contact__c, Account.PersonContactId,  (Select Id, Role__c, Account__c, Contact__c FROM Roles__r) FROM Asset WHERE Id = :ass.Id];
        //System.assertEquals(assRet.AccountId, acc.id);
        //System.assertEquals(assRet.Key_Contact__c, assRet.Account.PersonContactId);
        //System.assert(error);
    }
    @IsTest
    static void updateAssetFromIndividualPopulatesToCorporateAllowForNonAUAccount(){
        //Arrange
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account acc = TestClass_AccountCreator.createPersonAccount();
        Account acc2 = TestClass_AccountCreator.GenerateCorporateAccount();
        
        //createPersonAccount_Australia
        ass.accountId = acc.id;
        update ass;
        
        //Act
        Test.startTest();
        ass.accountId = acc2.id;
        update ass;
        
        Test.stopTest();
        //Assert
        Asset assRet = [SELECT id, key_Contact__c, Account.PersonContactId,  (Select Id, Role__c, Account__c, Contact__c FROM Roles__r) FROM Asset WHERE Id = :ass.Id];
        System.assertEquals(assRet.Key_Contact__c, null);
        
    }
    @IsTest
    static void updateAssetOfIndividualPopulatesKeyContact(){
        //Arrange
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account acc = TestClass_AccountCreator.createPersonAccount();
        //Act
        Test.startTest();
        ass.accountId = acc.id;
        update ass;
        Test.stopTest();
        //Assert
        Asset assRet = [SELECT id, key_Contact__c, Account.PersonContactId,  (Select Id, Role__c, Account__c, Contact__c FROM Roles__r) FROM Asset WHERE Id = :ass.Id];
        // System.assertEquals(assRet.Key_Contact__c, assRet.Account.PersonContactId);
        
    }
    @IsTest
    static void updateAssetOfRetailerWipesKeyContactOfNonRetailerContact(){
        //Arrange
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        Account acc = TestClass_AccountCreator.CreateRetailer();
        
        //Act
        Test.startTest();
        ass.accountId = acc.id;
        update ass;
        Test.stopTest();
        //Assert
        Asset assRet = [SELECT id, key_Contact__c,   (Select Id, Role__c, Account__c, Contact__c FROM Roles__r) FROM Asset WHERE Id = :ass.Id];
        //System.assertEquals(assRet.Key_Contact__c, null);
    }
    @IsTest
    static void updateAssetOfRetailerDoesNotWipesKeyContactOfRetailerContact(){
        //Arrange
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Brian';
        con.Email = 'TopMarksFor@not.com';
        con.FirstName = 'Mr';
        con.Gender__c = 'Male';
        insert con;
        //Act
        Test.startTest();
        ass.accountId = acc.id;
        ass.Key_Contact__c = con.Id;
        
        update ass;
        Test.stopTest();
        //Assert
        Asset assRet = [SELECT id, key_Contact__c,   (Select Id, Role__c, Account__c, Contact__c FROM Roles__r) FROM Asset WHERE Id = :ass.Id];
        System.assertEquals(assRet.Key_Contact__c, con.id);
    }
    static testMethod void testAssets() {
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        
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
            runningUser.Country = 'Singapore';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            runningUser.DefaultCurrencyIsoCode ='SGD';   
            runningUser.Market__c = 'APIO';
            runningUser.Country_ISO_Code__c='SG';
            Insert runningUser;
        }
        User portalUser;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
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
        
        portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'Singapore';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'APIO';
        portalUser.Country_ISO_Code__c='SG';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser;
        }
        //Product2 p2;
        //Product2 servicePlan;
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Singapore', Description = 'IndiaTest', IsActive = true,Region_or_Market__c ='APIO', Country_ISO_Code__c='SG' );
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Complimentary Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle',
                                            IsActive=true);
        insert servicePlan;
        
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Service_Plan__c =servicePlan.id);
        insert p2;
        
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'SG';  
            account.Is_Primary__c = false;          
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            Asset testasset = new Asset();
            testasset.Name = 'TSTASSET';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Vin__c = 'TSTASSET';
            testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            testasset.Vista_Status__c='Customer Handover';
            testasset.Model_Year_Code__c = '001BS';
            
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            Test.startTest();
            insert testasset;
            
            Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
            spc.Vehicle_Id__c = testasset.Id; 
            spc.Start_Date__c = system.today()-10;
            spc.End_Date__c = system.today()+30;  
            spc.Contract_Term_Months__c = 30;
            
            spc.Service_Plan_Product__c =  servicePlan.Id;
            spc.Assignment_Type__c = 'Retail';  
            spc.Country_ISO_Code__c='TW';
            spc.Market__c='APIO';
            insert spc;
            AssetHandler handler = new AssetHandler();
            handler.CreateNewServiceContract(new map<Id,Asset>{testasset.Id=>testasset},null);
            test.stopTest();
        }   
    } 
    
    
    static testMethod void testCreateNewServiceContractNewMarket() {
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        
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
            runningUser.Country = 'Singapore';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            runningUser.DefaultCurrencyIsoCode ='SGD';   
            runningUser.Market__c = 'APIO';
            runningUser.Country_ISO_Code__c='SG';
            Insert runningUser;
        }
        User portalUser;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
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
        
        portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'Singapore';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'APIO';
        portalUser.Country_ISO_Code__c='JP';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser;
        }
        //Product2 p2;
        //Product2 servicePlan;
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Singapore', Description = 'IndiaTest', IsActive = true,Region_or_Market__c ='APIO', Country_ISO_Code__c='SG' );
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Complimentary Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle',
                                            IsActive=true);
        insert servicePlan;
        
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Service_Plan__c =servicePlan.id);
        insert p2;
        
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        retailerAccount.Country_ISO_Code__c = 'JP';  
        retailerAccount.Is_Primary__c = false;          
        retailerAccount.Phone = '1234567890';
        retailerAccount.OwnerId = portalUser.Id;
        insert retailerAccount;
        
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'JP';  
        account.Is_Primary__c = false;          
        account.Phone = '1234567890';
        account.OwnerId = portalUser.Id;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        
        Product2 compServicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                Months__c=43,
                                                Service_Plan_Type__c ='Complimentary Service',
                                                Model_Alternative__c= 'F-Type',Family='Vehicle',isactive = true);
        insert compServicePlan;
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
        model1.RecordTypeId = prodModelRecordType;
        update model1;
        
        Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
        spcModel.Auto_Add_Extended_Plan__c = true;
        spcModel.Brand__c = brand1.Id;
        spcModel.Model__c = model1.Id;
        spcModel.Region_or_Market__c = 'JP';
        spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
        spcModel.Extended_Service_Plan__c = exSp.Id;
        insert spcModel;
        
        Asset testasset = new Asset();
        testasset.Name = 'TSTASSET';
        testasset.AccountId = retailerAccount.Id;
        testasset.Brand__c = brand1.Id;
        testasset.Model__c = model1.Id;
        testasset.product2Id =p2.Id;
        testasset.Vin__c = 'TSTASSET';
        //testasset.Derivative__c  =p2.Id;
        testasset.Status = Label.Asset_Status_List.split(',')[0];
        testasset.Vista_Status__c='Created';
        testasset.Model_Year_Code__c = '001BS';
        testasset.Original_Handover_Date__c = system.today()+1;
        testasset.Vista_Status__c='Customer Handover';
        // testasset.ProductCode = '3762457362';
        testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        
        insert testasset;
        
        Test.startTest();      
        AssetHandler handler = new AssetHandler();
        handler.CreateNewServiceContractNewMarket(new map<Id,Asset>{testasset.Id=>testasset},null);
        test.stopTest();
    }
    
    
    static testMethod void testCreateNewServiceContractNewMarket1() {
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        
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
            runningUser.Country = 'Singapore';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            runningUser.DefaultCurrencyIsoCode ='SGD';   
            runningUser.Market__c = 'APIO';
            runningUser.Country_ISO_Code__c='SG';
            Insert runningUser;
        }
        User portalUser;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
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
        
        portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'Singapore';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'APIO';
        portalUser.Country_ISO_Code__c='SG';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser;
        }
        //Product2 p2;
        //Product2 servicePlan;
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Singapore', Description = 'IndiaTest', IsActive = true,Region_or_Market__c ='APIO', Country_ISO_Code__c='SG' );
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Complimentary Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle',
                                            IsActive=true);
        insert servicePlan;
        
        
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        
        
        
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        retailerAccount.Country_ISO_Code__c = 'SG';  
        retailerAccount.Is_Primary__c = false;          
        retailerAccount.Phone = '1234567890';
        retailerAccount.OwnerId = portalUser.Id;
        insert retailerAccount;
        
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'SG';  
        account.Is_Primary__c = false;          
        account.Phone = '1234567890';
        account.OwnerId = portalUser.Id;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        
        Product2 compServicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                Months__c=43,
                                                Service_Plan_Type__c ='Complimentary Service',
                                                Model_Alternative__c= 'F-Type',Family='Vehicle',isactive = true);
        insert compServicePlan;
        
        PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry = new PricebookEntry(pricebook2id = standardPB.Id, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
        model1.RecordTypeId = prodModelRecordType;
        update model1;
        
        Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId(); 
        make.Is_Currently_Sold__c = false;
        make.aop_JLR_Owned__c = true;
        make.Name = 'Land Rover';  
        insert make;
        //1 record for model 
        Product2 model = new Product2(
            make__c = make.id,
            productcode = 'AA',
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId(),
            IsActive = true,
            Family = 'Vehicle',
            Name = 'TestModel',
            Alternative_Name__c = 'TestModel',
            CurrencyIsoCode = 'GBP'
        );
        insert model; 
        
        //1 record for derivative 
        Product2 derivative = new Product2(
            make__c = make.id,
            model__c = model.id,
            productcode = '50000001',
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId(),
            IsActive = true,
            Family = 'Vehicle',
            Name = 'TestDerivative',
            Alternative_Name__c = 'TestDerivative',
            CurrencyIsoCode = 'GBP',
            Service_Plan__c = compServicePlan.Id
        );
        insert derivative; 
        
        Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
        spcModel.Auto_Add_Extended_Plan__c = true;
        spcModel.Brand__c = brand1.Id;
        spcModel.Model__c = model1.Id;
        spcModel.Region_or_Market__c = 'APIO';
        spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
        spcModel.Extended_Service_Plan__c = exSp.Id;
        insert spcModel;
        
        Asset testasset = new Asset();
        testasset.Name = 'TSTASSET';
        testasset.AccountId = retailerAccount.Id;
        testasset.Brand__c = make.Id;
        testasset.Model__c = model.Id;
        testasset.product2Id =derivative.Id;
        testasset.Derivative__c = derivative.Id;
        testasset.Vin__c = 'TSTASSET';
        //testasset.Derivative__c  =p2.Id;
        testasset.Status = Label.Asset_Status_List.split(',')[0];
        //  testasset.Vista_Status__c='Created';
        testasset.Model_Year_Code__c = '001BS';
        testasset.Original_Handover_Date__c = system.today()+1;
        testasset.Vista_Status__c='Customer Handover';
        // testasset.ProductCode = '3762457362';
        testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        
        insert testasset;
        
        Test.startTest();      
        AssetHandler handler = new AssetHandler();
        handler.CreateNewServiceContract(new map<Id,Asset>{testasset.Id=>testasset},null);
        test.stopTest();
    }
    
    
    static testMethod void testCreateNewServiceContractNewMarket2() {
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        
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
            runningUser.Country = 'Singapore';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            runningUser.DefaultCurrencyIsoCode ='SGD';   
            runningUser.Market__c = 'APIO';
            runningUser.Country_ISO_Code__c='SG';
            Insert runningUser;
        }
        User portalUser;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
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
        
        portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'Singapore';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'APIO';
        portalUser.Country_ISO_Code__c='SG';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser;
        }
        //Product2 p2;
        //Product2 servicePlan;
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Singapore', Description = 'IndiaTest', IsActive = true,Region_or_Market__c ='APIO', Country_ISO_Code__c='SG' );
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Complimentary Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle',
                                            IsActive=true);
        insert servicePlan;
        
        
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        
        
        
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        retailerAccount.Country_ISO_Code__c = 'SG';  
        retailerAccount.Is_Primary__c = false;          
        retailerAccount.Phone = '1234567890';
        retailerAccount.OwnerId = portalUser.Id;
        insert retailerAccount;
        
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'SG';  
        account.Is_Primary__c = false;          
        account.Phone = '1234567890';
        account.OwnerId = portalUser.Id;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        
        Product2 compServicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                Months__c=43,
                                                Service_Plan_Type__c ='Complimentary Service',
                                                Model_Alternative__c= 'F-Type',Family='Vehicle',isactive = true);
        insert compServicePlan;
        
        PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry = new PricebookEntry(pricebook2id = standardPB.Id, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
        model1.RecordTypeId = prodModelRecordType;
        update model1;
        
        Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId(); 
        make.Is_Currently_Sold__c = false;
        make.aop_JLR_Owned__c = true;
        make.Name = 'Land Rover';  
        insert make;
        //1 record for model 
        Product2 model = new Product2(
            make__c = make.id,
            productcode = 'AA',
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId(),
            IsActive = true,
            Family = 'Vehicle',
            Name = 'TestModel',
            Alternative_Name__c = 'TestModel',
            CurrencyIsoCode = 'GBP'
        );
        insert model; 
        
        //1 record for derivative 
        Product2 derivative = new Product2(
            make__c = make.id,
            model__c = model.id,
            productcode = '50000001',
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId(),
            IsActive = true,
            Family = 'Vehicle',
            Name = 'TestDerivative',
            Alternative_Name__c = 'TestDerivative',
            CurrencyIsoCode = 'GBP',
            Service_Plan__c = compServicePlan.Id
        );
        insert derivative; 
        
        Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
        spcModel.Auto_Add_Extended_Plan__c = true;
        spcModel.Brand__c = brand1.Id;
        spcModel.Model__c = model1.Id;
        spcModel.Region_or_Market__c = 'APIO';
        spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
        spcModel.Extended_Service_Plan__c = exSp.Id;
        insert spcModel;
        
        Product_Price_Service_Plan__c prodServPlan = new Product_Price_Service_Plan__c();
        prodServPlan.Derivative_Product_Code__c = '50000001';
        prodServPlan.Country_ISO_Code__c = 'SG';  
        prodServPlan.Service_Plan_Price__c = 10;
        prodServPlan.Product_Description__c = derivative.Id;
        prodServPlan.Derivative_Product_Code__c = '50000001';
        insert prodServPlan;
        
        Asset testasset = new Asset();
        testasset.Name = 'TSTASSET';
        testasset.AccountId = retailerAccount.Id;
        testasset.Brand__c = make.Id;
        testasset.Model__c = model.Id;
        testasset.product2Id =derivative.Id;
        testasset.Derivative__c = derivative.Id;
        testasset.Vin__c = 'TSTASSET';
        //testasset.Derivative__c  =p2.Id;
        testasset.Status = Label.Asset_Status_List.split(',')[0];
        //  testasset.Vista_Status__c='Created';
        testasset.Model_Year_Code__c = '001BS';
        testasset.Original_Handover_Date__c = system.today()+1;
        testasset.Vista_Status__c='Customer Handover';
        // testasset.ProductCode = '3762457362';
        testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        
        insert testasset;
        testasset.Original_Handover_Date__c = system.today()+10;
        update testasset;
        
        Test.startTest();      
        AssetHandler handler = new AssetHandler();
        handler.CreateNewServiceContract(new map<Id,Asset>{testasset.Id=>testasset},null);
        test.stopTest();
    }
    
    static testMethod void testCreateNewServiceContractNewMarket3() {
        Profile systemAdmin = [select Id from Profile where Name = 'system administrator' limit 1];
        Contact testCommContact = new Contact();
        
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
            runningUser.Country = 'Singapore';
            runningUser.LanguageLocaleKey = 'en_US';
            runningUser.LocaleSidKey = 'en_US';
            runningUser.TimeZoneSidKey = 'America/Chicago';
            runningUser.EmailEncodingKey = 'UTF-8';
            runningUser.DefaultCurrencyIsoCode ='SGD';   
            runningUser.Market__c = 'APIO';
            runningUser.Country_ISO_Code__c='SG';
            Insert runningUser;
        }
        User portalUser;
        system.runAs(runningUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
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
        
        portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'Singapore';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'APIO';
        portalUser.Country_ISO_Code__c='SG';
        
        system.runAs(new user(id=userinfo.getUserId()))
        {
            insert portalUser;
        }
        //Product2 p2;
        //Product2 servicePlan;
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Singapore', Description = 'IndiaTest', IsActive = true,Region_or_Market__c ='APIO', Country_ISO_Code__c='SG' );
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Complimentary Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle',
                                            IsActive=true);
        insert servicePlan;
        
        
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        
        
        
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        retailerAccount.Country_ISO_Code__c = 'SG';  
        retailerAccount.Is_Primary__c = false;          
        retailerAccount.Phone = '1234567890';
        retailerAccount.OwnerId = portalUser.Id;
        insert retailerAccount;
        
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'SG';  
        account.Is_Primary__c = false;          
        account.Phone = '1234567890';
        account.OwnerId = portalUser.Id;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        
        Product2 compServicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                Months__c=43,
                                                Service_Plan_Type__c ='Complimentary Service',
                                                Model_Alternative__c= 'F-Type',Family='Vehicle',isactive = true);
        insert compServicePlan;
        
        PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry = new PricebookEntry(pricebook2id = standardPB.Id, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
        model1.RecordTypeId = prodModelRecordType;
        update model1;
        
        Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId(); 
        make.Is_Currently_Sold__c = false;
        make.aop_JLR_Owned__c = true;
        make.Name = 'Land Rover';  
        insert make;
        //1 record for model 
        Product2 model = new Product2(
            make__c = make.id,
            productcode = 'AA',
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId(),
            IsActive = true,
            Family = 'Vehicle',
            Name = 'TestModel',
            Alternative_Name__c = 'TestModel',
            CurrencyIsoCode = 'GBP'
        );
        insert model; 
        
        //1 record for derivative 
        Product2 derivative = new Product2(
            make__c = make.id,
            model__c = model.id,
            productcode = '50000001',
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId(),
            IsActive = true,
            Family = 'Vehicle',
            Name = 'TestDerivative',
            Alternative_Name__c = 'TestDerivative',
            CurrencyIsoCode = 'GBP',
            Service_Plan__c = compServicePlan.Id
        );
        insert derivative; 
        
        Opportunity opp = new Opportunity();
        opp.name = 'Opp1';
        opp.stagename = 'Negotiation';
        opp.CloseDate = system.today()+30;
		opp.AccountId = account.Id;
        opp.Amount = 100;
        opp.Pricebook2Id = standardPB.id;
        insert opp;
        
        Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
        spcModel.Auto_Add_Extended_Plan__c = true;
        spcModel.Brand__c = brand1.Id;
        spcModel.Model__c = model1.Id;
        spcModel.Region_or_Market__c = 'APIO';
        spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
        spcModel.Extended_Service_Plan__c = exSp.Id;
        insert spcModel;
        
        Product_Price_Service_Plan__c prodServPlan = new Product_Price_Service_Plan__c();
        prodServPlan.Derivative_Product_Code__c = '50000001';
        prodServPlan.Country_ISO_Code__c = 'SG';  
        prodServPlan.Service_Plan_Price__c = 10;
        prodServPlan.Product_Description__c = derivative.Id;
        prodServPlan.Derivative_Product_Code__c = '50000001';
        insert prodServPlan;
          Test.startTest();  
        Asset testasset = new Asset();
        testasset.Name = 'TSTASSET';
        testasset.AccountId = retailerAccount.Id;
        testasset.Brand__c = make.Id;
        testasset.Model__c = model.Id;
        testasset.product2Id =derivative.Id;
        testasset.Derivative__c = derivative.Id;
        testasset.Vin__c = 'TSTASSET';
        //testasset.Derivative__c  =p2.Id;
        testasset.Status = Label.Asset_Status_List.split(',')[0];
        //  testasset.Vista_Status__c='Created';
        testasset.Model_Year_Code__c = '001BS'; 
        testasset.Original_Handover_Date__c = system.today()+1;
        testasset.Vista_Status__c='Customer Handover';
        // testasset.ProductCode = '3762457362';
        testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        
        insert testasset;
        
        opportunitylineitem oli = new opportunitylineitem();
        oli.opportunityid = opp.id;
        oli.Product2Id = compServicePlan.id;
        oli.Asset__c = testasset.Id;
        oli.Quantity = 2;
        oli.TotalPrice =10;
        insert oli; 
        
       
        testasset.Original_Handover_Date__c = system.today()+10;
        update testasset;
        test.stopTest();
    }
    
     static testMethod void testCreateNewServiceContractHandover() {
        
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
        Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
        
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false, Is_OppLineItem_Logic_Run__c = true);
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        user userIns = [select id,contactid,contact.accountid from user where id =:portalUser.Id];
        Account acc = new Account();
         acc.id = userIns.contact.accountid;
         acc.Country_ISO_Code__c = 'AZ';
         update acc;
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
            account.Country_ISO_Code__c = 'AZ';  
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
                                                      Country_ISO_Code__c = 'AZ',
                                                      VME_Trade_in_Type__c = 'Exchange JLR to JLR',
                                                      VME_Segment__c = 'Affinity Sales',
                                                      VME_Sub_Division__c = 'Certified Charted Accountant',
                                                      leadsource = 'OEM Web & Digital',
                                                      pricebook2id=priceBookId);
            insert opportunity;  
            opportunity oppIns = [select id,CurrencyIsoCode from opportunity where id =:opportunity.Id];
            //system.assertequals(oppIns.CurrencyIsoCode,null);
            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(Asset__c = testasset.Id, Product2Id = p2.Id,Brand__c = testasset.Brand__c,
                                                                                  OpportunityId = opportunity.Id, QUANTITY = 1, UnitPrice = 1233, PricebookEntryId = PricebookEntry.Id );
            Test.startTest();
            insert testOpportunityLineItem;
             testasset.Handover_Date__c = system.today()+1;
            testasset.Original_Handover_Date__c = system.today()+1;
            List<Asset>  assetList = new List<Asset>();
            assetList.add(testasset);
            Asset assetUpdateIns = testasset.clone(true, true, true, true);
            assetUpdateIns.Handover_Date__c = system.today()+2;
            assetUpdateIns.Original_Handover_Date__c = system.today()+2;
            map<id,Asset> assetMap = new  map<id,Asset>();
            assetMap.put(assetUpdateIns.id,assetUpdateIns);
            AssetOppUpdateHandler.ProcessOpportunityHandoverUpdate(assetList,assetMap);
            Test.stopTest();
        }
    }
    
    static testMethod void oppRetriever() {
        Opportunity opp = new Opportunity();
        opp = createOpportunityWithStageAndName('Test Drive', 'testTest Drive');
        MMIT_OpportunityRetriever oppRet = new MMIT_OpportunityRetriever();
        oppRet.Retrieve(new Set<String>{opp.Id});
    }
    @isTest 
    public static void createVehcileOption() {
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();

        Vehicle_Specification__c make = [SELECT id FROM Vehicle_Specification__c WHERE Name = 'Jaguar' LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Asset assetOption = new Asset();
        assetOption.Name = 'MyOption';
        assetOption.ParentId = ass.Id;
        assetOption.Brand__c = make.Id;
        assetOption.AccountId = acc.Id;
        assetOption.recordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle_Option').getRecordTypeId();

        Test.startTest();
        insert assetOption;
        Test.stopTest();
    }
    
    public static Opportunity createOpportunityWithStageAndName(String stageName, String name) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.StageName = stageName;
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'test@test.test';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }
}