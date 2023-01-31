@isTest
public class TargetAndQuotaUpdater_Test {
    
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
    
    
   static TestMethod void RDATriggerHandler_Test_DL(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Product__c  = p2.Id,Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
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
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'IN';  
            account.Is_Primary__c = false;
            account.Loyalty_Scheme__c = lSheme.Id;
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Common_Sale_Type__c='Dealer Loan';
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
            List<RDA__c> rdaList = new List<RDA__c>();
            rdaList.Add(new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Dealer Loan',
                                   Registration_Number__c='TEST123', Retail_Offer__c='None',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM'));  insert rdaList;
            // testRDA.Handover_Date__c = null;
            rdaList[0].Submitted_Status__c ='Cancelled';
            update rdaList[0];
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
        }
        
    }
     static TestMethod void RDATriggerHandler_Test_Demonstrator(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Product__c  = p2.Id,Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
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
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'IN';  
            account.Is_Primary__c = false;
            account.Loyalty_Scheme__c = lSheme.Id;
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Common_Sale_Type__c='Demonstrator';
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
            List<RDA__c> rdaList = new List<RDA__c>();
            rdaList.Add(new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                                   Registration_Number__c='TEST123', Retail_Offer__c='None',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM'));  insert rdaList;
            // testRDA.Handover_Date__c = null;
            rdaList[0].Submitted_Status__c ='Cancelled';
            update rdaList[0];
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
        }
        
    }
       static TestMethod void RDATriggerHandler_Test_Demonstrator_Onsell(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Product__c  = p2.Id,Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
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
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'IN';  
            account.Is_Primary__c = false;
            account.Loyalty_Scheme__c = lSheme.Id;
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Common_Sale_Type__c='Demonstrator';
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
            List<RDA__c> rdaList = new List<RDA__c>();
            rdaList.Add(new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                                   Registration_Number__c='TEST123', Retail_Offer__c='None',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM'));  
              RDA__c rda1 = new RDA__c(recordtypeId =dealerOwnedRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                                   Registration_Number__c='TEST123', Retail_Offer__c='None',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM');
            insert rda1;
            RDA__c rda2 = new RDA__c(recordtypeId =onSellRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                                   Registration_Number__c='TEST123', Retail_Offer__c='None',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM');
            insert rda2;
            // testRDA.Handover_Date__c = null;
            
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
        }
        
    }
      static TestMethod void RDATriggerHandler_Test_New_Retailer(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        Product2 servicePlan = new product2(RecordtypeId = ServiceplanrectypeId, name='y',
                                            Product__c  = p2.Id,Months__c=43,
                                            Service_Plan_Type__c ='Free Service',
                                            Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert servicePlan;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
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
        System.RunAs(portaluser){
            Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
            insert makeVehicle;
            Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
            insert modelVehicle;
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
            Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'IN';  
            account.Is_Primary__c = false;
            account.Loyalty_Scheme__c = lSheme.Id;
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            testasset.Common_Sale_Type__c='Demonstrator';
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
            List<RDA__c> rdaList = new List<RDA__c>();
            rdaList.Add(new RDA__c(recordtypeId =newRetailRecordTypeId, Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                                   Registration_Number__c='TEST123', Retail_Offer__c='None',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM'));  
            
            
            
            insert rdaList;
          
            // testRDA.Handover_Date__c = null;
            
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
        }
        
    }
}