@isTest
public class AddServicePlanController_Test {
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
    public static Id prodModelRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    
    static TestMethod void RDATriggerHandler_TeswhencorpateupdatedAddsOneServicePlanContract(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        ret.NSC_Supported__c = true;
        update ret;
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Australia', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Service_Plan__c =servicePlan.id);
        insert p2;
        
        
        System.RunAs(portaluser){
            
            PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
            insert PricebookEntry; 
            PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
            insert PricebookEntry2;
            
            
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
            testasset.product2Id =p2.Id;
            
            testasset.Derivative__c  =p2.Id;
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
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
            RDA__c rdaList = new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                        Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                        Registration_Number__c='TEST123', Retail_Offer__c='Loyalty Program',
                                        Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'
                                       ); 
            insert rdaList;
            
            
            // testRDA.Handover_Date__c = null;
            AddServicePlanController.addForServicePlanContract( True, false,null, testasset.id,null,false);
            //   system.debug('x marks the spot '+x);
            
            AddServicePlanController.addForServicePlanContract( false, false,null, testasset.id,system.today(),true);            
            Test.stopTest();
            
            List<Service_Plan_Contract__c> spcs = [Select id  from Service_Plan_Contract__c ];
            
            System.assert(spcs.size() == 2);
            
        }
    }
    
    static TestMethod void test_addCorporate(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        ret.NSC_Supported__c = true;
        update ret;
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Australia', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Service_Plan__c =servicePlan.id);
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        Offers__c off = new Offers__c();
        off.Corporate_Partner__c = ret.id;
        off.Service_Plan_Product2Id__c = servicePlan.id;
        off.Start_Date__c = System.today().AddDays(-1);
        insert off;
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
            testasset.product2Id =p2.Id;
            
            testasset.Derivative__c  =p2.Id;
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
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
            RDA__c rdaList = new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                        Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                        Registration_Number__c='TEST123', Retail_Offer__c='Loyalty Program',
                                        Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'
                                       ); 
            insert rdaList;
            
            
            // testRDA.Handover_Date__c = null;
            AddServicePlanController.addForServicePlanContract( false, true,off.Id, testasset.id,null,false);
            //  system.debug('x marks the spot '+x);
            Test.stopTest();
            
            List<Service_Plan_Contract__c> spcs = [Select id  from Service_Plan_Contract__c ];
            System.assert(spcs.size() == 1);
            
        }
    }
    
    
    static TestMethod void test_addCorporate2(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.Country_ISO_Code__c = 'JP';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        
        User portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'JP';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'JP';
        portalUser.Country_ISO_Code__c = 'JP';
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert portalUser;
        }
        Account ret = [select id, name from Account limit 1 ];
        ret.NSC_Supported__c = true;
        update ret;
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Australia', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        
        
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        
        Product2 compServicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                Months__c=43,
                                                Service_Plan_Type__c ='Complimentary Service',
                                                Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert compServicePlan;
        
        Product2 compServicePlan1 = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                 Months__c=43,
                                                 Service_Plan_Type__c ='Complimentary Service',
                                                 Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert compServicePlan1;
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Service_Plan__c =servicePlan.id);
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        Offers__c off = new Offers__c();
        off.Corporate_Partner__c = ret.id;
        off.Service_Plan_Product2Id__c = servicePlan.id;
        off.Start_Date__c = System.today().AddDays(-1);
        insert off;
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
            Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
            model1.RecordTypeId = prodModelRecordType;
            update model1;
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
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = brand1.Id;
            testasset.Model__c = model1.Id;
            testasset.product2Id =p2.Id;
            
            //testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
            spcModel.Auto_Add_Extended_Plan__c = true;
            spcModel.Brand__c = brand1.Id;
            spcModel.Model__c = model1.Id;
            spcModel.Region_or_Market__c = 'JP';
            spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
            spcModel.Extended_Service_Plan__c = exSp.Id;
            insert spcModel;
            
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
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
            RDA__c rdaList = new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                        Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                        Registration_Number__c='TEST123', Retail_Offer__c='Loyalty Program',
                                        Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'
                                       ); 
            insert rdaList;
            
            
            AddServicePlanController.getServicePlans(testasset.id);
            Test.stopTest();
            
            
        }
    }
    
    static TestMethod void test_addCorporate3(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.Country_ISO_Code__c = 'JP';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        
        User portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'JP';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'JP';
        portalUser.Country_ISO_Code__c = 'JP';
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert portalUser;
        }
        Account ret = [select id, name from Account limit 1 ];
        ret.NSC_Supported__c = true;
        update ret;
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Australia', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        
        
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        
        Product2 compServicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                Months__c=43,
                                                Service_Plan_Type__c ='Complimentary Service',
                                                Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert compServicePlan;
        
        Product2 compServicePlan1 = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                 Months__c=43,
                                                 Service_Plan_Type__c ='Complimentary Service',
                                                 Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert compServicePlan1;
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Service_Plan__c =servicePlan.id);
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        Offers__c off = new Offers__c();
        off.Corporate_Partner__c = ret.id;
        off.Service_Plan_Product2Id__c = servicePlan.id;
        off.Start_Date__c = System.today().AddDays(-1);
        insert off;
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
            Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
            model1.RecordTypeId = prodModelRecordType;
            update model1;
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
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = brand1.Id;
            testasset.Model__c = model1.Id;
            testasset.product2Id =p2.Id;
            
            //testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
            spcModel.Auto_Add_Extended_Plan__c = true;
            spcModel.Brand__c = brand1.Id;
            spcModel.Model__c = model1.Id;
            spcModel.Region_or_Market__c = 'JP';
            spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
            spcModel.Extended_Service_Plan__c = exSp.Id;
            insert spcModel;
            
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
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
            RDA__c rdaList = new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                        Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                        Registration_Number__c='TEST123', Retail_Offer__c='Loyalty Program',
                                        Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'
                                       ); 
            insert rdaList;
            
            
            AddServicePlanController.addForServicePlanContract( false, false,null, testasset.id,system.today(),true);         
            Test.stopTest();
            
            
        }
    }
    
    static TestMethod void test_addCorporate5(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.Country_ISO_Code__c = 'MN';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        
        User portalUser = new User();
        portalUser.Phone = '07681102495';
        portalUser.Email = 'test@test.test';
        portalUser.ProfileId = salesExecutiveProfile.Id;
        portalUser.UserName = 'test@test.test.retailer';
        portalUser.Alias = 'TTT';
        portalUser.ContactID = testCommContact.Id;
        portalUser.FirstName = 'Test';
        portalUser.LastName = 'Test';
        portalUser.Country = 'MN';
        portalUser.LanguageLocaleKey = 'en_US';
        portalUser.LocaleSidKey = 'en_US';
        portalUser.TimeZoneSidKey = 'America/Chicago';
        portalUser.EmailEncodingKey = 'UTF-8';
        portalUser.DefaultCurrencyIsoCode ='GBP';   
        portalUser.Market__c = 'APIO';
        portalUser.Country_ISO_Code__c = 'MN';
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert portalUser;
        }
        Account ret = [select id, name from Account limit 1 ];
        ret.NSC_Supported__c = true;
        update ret;
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'APIO', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c,Country_ISO_Code__c = 'MN');
        insert standardPB;
        
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        
        Product2 compServicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                Months__c=43,
                                                Service_Plan_Type__c ='Complimentary Service',
                                                Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert compServicePlan;
        
        Product2 compServicePlan1 = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                                 Months__c=43,
                                                 Service_Plan_Type__c ='Complimentary Service',
                                                 Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert compServicePlan1;
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Service_Plan__c =servicePlan.id);
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        
        PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;
        PricebookEntry = new PricebookEntry(pricebook2id = standardPB.Id, product2id = servicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;
        
        PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;        
        PricebookEntry = new PricebookEntry(pricebook2id = standardPB.Id, product2id = compServicePlan.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;
        
        PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = compServicePlan1.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;
        PricebookEntry = new PricebookEntry(pricebook2id = standardPB.Id, product2id = compServicePlan1.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;
        
        PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = exSp.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;
        PricebookEntry = new PricebookEntry(pricebook2id = standardPB.Id, product2id = exSp.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry;
        
        Offers__c off = new Offers__c();
        off.Corporate_Partner__c = ret.id;
        off.Service_Plan_Product2Id__c = servicePlan.id;
        off.Start_Date__c = System.today().AddDays(-1);
        insert off;
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
            Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
            model1.RecordTypeId = prodModelRecordType;
            update model1;
            
            p2.Model__c = model1.Id;
            p2.make__c =brand1.Id;
            update p2;           
            
            
            
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'MN';  
            account.Is_Primary__c = false;          
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = brand1.Id;
            testasset.Model__c = model1.Id;
            testasset.product2Id =p2.Id;
            
            testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
            spcModel.Auto_Add_Extended_Plan__c = true;
            spcModel.Brand__c = brand1.Id;
            spcModel.Model__c = model1.Id;
            spcModel.Region_or_Market__c = 'APIO';
            spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
            spcModel.Extended_Service_Plan__c = exSp.Id;
            insert spcModel;
            
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
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
            RDA__c rdaList = new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                        Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                        Registration_Number__c='TEST123', Retail_Offer__c='Loyalty Program',
                                        Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'
                                       ); 
            insert rdaList;
            
            
            AddServicePlanController.addForServicePlanContract( false, false,null, testasset.id,system.today(),true);         
            Test.stopTest(); 
            
            
        }
    }
}