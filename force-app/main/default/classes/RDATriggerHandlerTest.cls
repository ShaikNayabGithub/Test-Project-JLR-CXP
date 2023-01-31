/*
*  @Name : RDATriggerHandlerTest 
*  @Author : Masthan Andela 
*  @JIRA Number: CXPDA-446
*  @Description : test class for RDATriggerHandlerTest

*/

@isTest
public class RDATriggerHandlerTest {
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
    
    
     static TestMethod void RDATriggerHandler_TestUpdateExtended(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
        }
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'IN';  
        account.Is_Primary__c = false;
        account.Loyalty_Scheme__c = lSheme.Id;
        account.Phone = '1234567890';
        account.OwnerId = portalUser.id;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
      Contact con = [Select id FROM contact limit 1];
         List<Asset> asets = new List<Asset>();
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
      //  insert testasset;
        asets.add(testasset);
         Asset testasset2 = new Asset();
        testasset2.Name = 'TestAsset2';
        testasset2.AccountId = accId;
        testasset2.Brand__c = makeVehicle.Id;
        testasset2.product2Id =p2.Id;
        testasset2.Derivative__c  =p2.Id;
        testasset2.Common_Sale_Type__c='Demonstrator';
        testasset2.Status = Label.Asset_Status_List.split(',')[0];
        // testasset.ProductCode = '3762457362';
        testasset2.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
       // insert testasset2;
            asets.add(testasset2);
         insert asets;
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
                                                  OwnerId=portalUser.id,
                                                  Handover_Date__c = system.today(),
                                                  Is_New_RDA_Process__c = true, Primary_Contact__c = con.Id);
         Test.startTest(); 
        insert opportunity;  
        //ensure RDA is not locked
        for(RDA_Locked__mdt rdal : [SELECT MasterLabel, RDA_Locked__c FROM RDA_Locked__mdt]){
            rdal.RDA_Locked__c = false;
        }
       
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
        List<RDA__c> rdaList = new List<RDA__c>();
        
        rdaList.Add(new RDA__c(recordtypeId =newRetailRecordTypeId, Opportunity__c=opportunity.Id,OwnerId=portalUser.id, account__c=account.Id, Asset__c=testasset.Id, 
                               Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                               Registration_Number__c='TEST123', Retail_Offer__c='',vin__c=testasset2.id,
                               Submitted_Date__c=system.today(), Submitted_Status__c='Submitted', Service_Plan_Type__c=servicePlan.Id));
        System.RunAs(portaluser){
        insert rdaList;
        // testRDA.Handover_Date__c = null;
        rdaList[0].Add_Extended_Warranty__c = true;
        update rdaList[0];
        }
        
        //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
        //  testRDA.Submitted_Status__c ='Submitted';
        // update testRDA;
        Test.stopTest();
        
    }
    
   
    /*static TestMethod void RDATriggerHandler_Test(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
        }
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = 'IN';  
        account.Is_Primary__c = false;
        account.Loyalty_Scheme__c = lSheme.Id;
        account.Phone = '1234567890';
        account.OwnerId = portalUser.id;
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
      Contact con = [Select id FROM contact limit 1];
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
                                                  OwnerId=portalUser.id,
                                                  Handover_Date__c = system.today(),
                                                  Is_New_RDA_Process__c = true, Primary_Contact__c = con.Id);
        insert opportunity;  
        //ensure RDA is not locked
        for(RDA_Locked__mdt rdal : [SELECT MasterLabel, RDA_Locked__c FROM RDA_Locked__mdt]){
            rdal.RDA_Locked__c = false;
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));
        List<RDA__c> rdaList = new List<RDA__c>();
        
        rdaList.Add(new RDA__c(recordtypeId =onSellRecordTypeId, Opportunity__c=opportunity.Id,OwnerId=portalUser.id, account__c=account.Id, Asset__c=testasset.Id, 
                               Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                               Registration_Number__c='TEST123', Retail_Offer__c='',Add_Extended_Warranty__c = true,
                               Submitted_Date__c=system.today(), Submitted_Status__c='Submitted', Service_Plan_Type__c=servicePlan.Id));
        System.RunAs(portaluser){
        insert rdaList;
        // testRDA.Handover_Date__c = null;
        rdaList[0].Submitted_Status__c ='Cancelled';
        update rdaList[0];
        }
        
        //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
        //  testRDA.Submitted_Status__c ='Submitted';
        // update testRDA;
        Test.stopTest();
        
    }*/

    static TestMethod void RDATriggerHandler_Test1(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle',Warranty_Length__c = 24);
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
            List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
            targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedInUser.Contact.AccountId));
            insert targeList;
        }
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
        rdaList.Add(new RDA__c(Opportunity__c=opportunity.Id, account__c=account.Id, Asset__c=testasset.Id, 
                               Handover_Date__c=Date.today(), Common_Sale_Type__c='test',
                               Registration_Number__c='TEST123', Retail_Offer__c='', Add_Extended_Warranty__c = true,
                               Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                               Common_Type_of_Sale_Code__c ='CAM'));
        
        
        insert rdaList;
        // testRDA.Handover_Date__c = null;
        rdaList[0].Submitted_Status__c ='Cancelled';
        update rdaList[0];
        //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
        //  testRDA.Submitted_Status__c ='Submitted';
        // update testRDA;
        Test.stopTest();
        
        delete rdaList[0];
        
    }
    static TestMethod void RDATriggerHandler_Test2(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
            testasset.Common_Sale_Type__c='Dealer Based Rental';
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
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Dealer Based Rental',
                                   Registration_Number__c='TEST123', Retail_Offer__c='',Add_Extended_Warranty__c = true,
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM'));
            
            insert rdaList;
            // testRDA.Handover_Date__c = null;
           rdaList[0].Add_Extended_Warranty__c = false;
            rdaList[0].Submitted_Status__c ='Cancelled';
            update rdaList[0];
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
        }
    }
    static TestMethod void RDATriggerHandler_Test3(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
                                   Registration_Number__c='TEST123', Retail_Offer__c='',
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
    
    static TestMethod void RDATriggerHandler_Test4_TestSalesTypeWhenNoCode(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
            testasset.Common_Sale_Type__c='Private Individual';
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
                                   Handover_Date__c=Date.today(), Common_Type_of_Sale_Code__c='AAA',
                                   Registration_Number__c='TEST123', Retail_Offer__c='',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'
                                  ));  insert rdaList;
            // testRDA.Handover_Date__c = null;
            
            // Common_Type_of_Sale_Code__c ='CAM'
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
            
            RDA__c rda = [Select id,  Common_Type_of_Sale_Code__c,Common_Sale_Type__c, Buyer_Type_Number__c  from RDA__C limit 1];
            
            System.assertEquals(rda.Common_Sale_Type__c, 'Private Individual');
            System.assertEquals(rda.Buyer_Type_Number__c, 21);
            
        }
        
    }
    static TestMethod void RDATriggerHandler_Test4_TestSalesTypeWhenJUstCodeAndAsset(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
            testasset.Common_Sale_Type__c='Private Individual';
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
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                   Registration_Number__c='TEST123', Retail_Offer__c='',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'
                                  ));  insert rdaList;
            // testRDA.Handover_Date__c = null;
            
            // Common_Type_of_Sale_Code__c ='CAM'
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
            
            RDA__c rda = [Select id,  Common_Type_of_Sale_Code__c, Buyer_Type_Number__c  from RDA__C limit 1];
            
            System.assertEquals(rda.Common_Type_of_Sale_Code__c, 'AAA');
            System.assertEquals(rda.Buyer_Type_Number__c, 21);
            
        }
        
    }
    static TestMethod void RDATriggerHandler_Tes64_TestSalesTypeWhenJUstCode(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                   Registration_Number__c='TEST123', Retail_Offer__c='',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Completed'
                                  ));  insert rdaList;
            // testRDA.Handover_Date__c = null;
            
            // Common_Type_of_Sale_Code__c ='CAM'
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
            
            RDA__c rda = [Select id,  Common_Type_of_Sale_Code__c, Buyer_Type_Number__c  from RDA__C limit 1];
            
            System.assertEquals(rda.Common_Type_of_Sale_Code__c, 'AAA');
            System.assertEquals(rda.Buyer_Type_Number__c, 21);
            
        }
        
    }
    
    static TestMethod void RDATriggerHandler_Test4_TestSalesTypeWhenJUstCode(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
                                   Handover_Date__c=Date.today(), Common_Sale_Type__c='Private',
                                   Registration_Number__c='TEST123', Retail_Offer__c='',
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted', Service_Plan_Type__c=servicePlan.id
                                  ));  insert rdaList;
            // testRDA.Handover_Date__c = null;
            
            // Common_Type_of_Sale_Code__c ='CAM'
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
            
            RDA__c rda = [Select id,  Common_Type_of_Sale_Code__c, Buyer_Type_Number__c  from RDA__C limit 1];
            
            System.assertEquals(rda.Common_Type_of_Sale_Code__c, 'AAA');
            System.assertEquals(rda.Buyer_Type_Number__c, 21);
            
        }
        
    }
    
    
    static TestMethod void RDATriggerHandler_TestThatPassesVistaValidationWheninsideDateRange(){
        
        RDA__c NewRDA = new RDA__C();
        newRDA.Handover_Date__c =  System.today();             
        Boolean result = RDATriggerHandler.validateEnteredHandoverDate(NewRDA,null,'AE');        
        System.assert(!result);
        
    }
    static TestMethod void RDATriggerHandler_TestThatFailesVistaValidationWhenOutsideDateRange(){
        RDA__c NewRDA = new RDA__C();
        newRDA.Handover_Date__c =  System.today().addDays((integer)50);             
        Boolean result = RDATriggerHandler.validateEnteredHandoverDate(NewRDA,null,'AE');        
        System.assert(result);
    }
    static TestMethod void RDATriggerHandler_TestThatFailesVistaValidationWhenOutsideDateRangeAndNotValidCountryIsoCode(){
        RDA__c NewRDA = new RDA__C();
        newRDA.Handover_Date__c =  System.today().addDays((integer)5000);          
        Boolean result = RDATriggerHandler.validateEnteredHandoverDate(NewRDA,null,'zz');    
        System.assert(result);
    }
    
   
      static TestMethod void RDATriggerHandler_Test_DL(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
                                   Registration_Number__c='TEST123', Retail_Offer__c='',
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
          
            static TestMethod void RDATriggerHandler_Test_D2L(){
        insert new TriggerFramework__c(Is_Loyalty_Points_Calculation_Disabled__c = false);
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
         
        Account ret = [select id, name from Account limit 1 ];
        AccountShare ash = new AccountShare(AccountId=ret.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        insert standardPB;
        Product2 p2 = new product2(RecordtypeId = derivativeRecordType, name='y',Model_Alternative__c= 'F-Type',Family='Vehicle', Warranty_Length__c = 24);
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
            testasset.Warranty_Start_Date__c = System.today(); 
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
                                   Registration_Number__c='TEST123', Retail_Offer__c='',Add_Extended_Warranty__c = false,
                                   Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                                   Common_Type_of_Sale_Code__c ='CAM'));  insert rdaList;
            // testRDA.Handover_Date__c = null;
            rdaList[0].Add_Extended_Warranty__c = true;
            update rdaList[0];
            //  LC_RDACancellation_Controller.CancelRDA(testRDA.Id);
            //  testRDA.Submitted_Status__c ='Submitted';
            // update testRDA;
            Test.stopTest();
        }
        
   
    
            }
    
}