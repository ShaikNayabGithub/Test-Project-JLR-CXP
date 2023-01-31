@isTest
public class TransferServicePlanController_Test {
    
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();  
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    public static Id prodModelRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    
    
    static TestMethod void TransferServicePlan_Test(){        
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
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert portalUser;
        }
        
        Id priceBookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Singapore', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c, Country_ISO_Code__c='JP' );
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
        
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType,
                                   Brochure_Model_Code__c = 'AC663',
                                   Model_Year__c  = '2023',
                                   name='y',
                                   Model_Alternative__c= 'F-Type',
                                   Family='Vehicle',
                                   Service_Plan__c =servicePlan.id);
        insert p2;
        
        Product2 exSp = new product2(RecordtypeId = ServiceplanrectypeId, name='TestEx',
                                     Service_Plan_Type__c='Extended',
                                     IsActive=True,
                                     Months__c=43,                                     
                                     Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert exSp;
        
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        
        PricebookEntry PricebookEntry3 = new PricebookEntry(pricebook2id = priceBookId, product2id = exSp.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry3; 
        
        PricebookEntry PricebookEntry4 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = exSp.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry4;
        
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
            account.Country_ISO_Code__c = 'JP';  
            account.Is_Primary__c = false;          
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            
            Wasp_Code_Mapping__c wspCode = new Wasp_Code_Mapping__c();
            wspCode.Name = 'WSP_Code';
            wspCode.BrochureModelCode__c = p2.Brochure_Model__c;
            wspCode.Model_Year_WCM__c = p2.Model_Year__c;
            insert wspCode;
            
            
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = brand1.Id;
            testasset.Model__c = model1.Id;
            testasset.product2Id =p2.Id;
            testasset.Vin__c = 'TestAsset';
            // testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            Test.startTest();
            insert testasset;
            
            Service_Plans_Model__c spcModel = new Service_Plans_Model__c();
            spcModel.Auto_Add_Extended_Plan__c = true;
            spcModel.Brand__c = brand1.Id;
            spcModel.Model__c = model1.Id;
            spcModel.Region_or_Market__c = 'JP';
            spcModel.Complementary_Service_Plan__c = compServicePlan.Id;
            spcModel.Extended_Service_Plan__c = exSp.Id;
            insert spcModel;
            
            Service_Plan_Contract__c spc = new Service_Plan_Contract__c();
            spc.Vehicle_Id__c = testasset.Id; 
            spc.Start_Date__c = system.today()+10;
            spc.End_Date__c = system.today()+30;  
            spc.Contract_Term_Months__c = 30;
            
            spc.Service_Plan_Product__c =  servicePlan.Id;
            spc.Assignment_Type__c = 'Retail';  
            spc.Country_ISO_Code__c='JP';
            spc.Market__c='JP';
            
            Insert spc;
            Test.stopTest();
            TransferServicePlanController.getAssetDetails(testasset.Id,p2.Id);
            TransferServicePlanController.getAssetVehicleDetails('TestAsset');
            TransferServicePlanController.transferServicePlan(testasset.Id,compServicePlan1.Id,spc.Id,System.today()+15,100,true);
        }
    }
}