/*
* S.No.		Name		Date(DD/MM/YYYY)	Change
* 1.0		Ashwin		05/05/2021			CXPD-1218: added TestMethod to cover getExistingSP()
* 
*/

@isTest
public class NewRDA_LC_Controller_Test {
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id derivativeRecordType = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
    public static Id corporateRecordType = RecordTypeUtility.getRecordTypeId_Account_Corporate();
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();     
    public static Id ServiceplanrectypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Service_Plans').getRecordTypeId(); 
    public static Id DemoOrLoanRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Demonstrator_Loan_Quota').getRecordTypeId();
    public static Id salestargetRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Sales_Target').getRecordTypeId();
    public static Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
    public static Id dealerOwnedRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Dealer_Owned').getRecordTypeId();
    public static Id OUVRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('OUV').getRecordTypeId();
    public static Id newRetailRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    public static Id onSellRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    
    static TestMethod void GetFieldLabelReturnsMapWhenValidObjectQueried() {
        System.assert(NewRDA_LC_Controller.getFieldLabel('Account') != null);
    }
    
    static TestMethod void GetAssetReturnsAssetWhenValidIdQueried() {
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        user u = TestUtility.CreateMarketSpecificUser('INRUser','JLR System Administrator (Super)','India','IN','INR','IN');
        system.runAs(u){
        	insert standardPB;
        }
        Product2 p2 = new product2(name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Asset ass = new Asset(Name='Test', Registration_Number__c='TEST123', Brand__c=makeVehicle.Id, Product2Id=prod.Id);
        System.RunAs(portalUser){
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
            ass.AccountId = loggedinUser.AccountId;
            ass.ContactId = loggedinUser.ContactId;
            insert ass;
        }
        System.assert(NewRDA_LC_Controller.getAsset(ass.Id).Registration_Number__c == 'TEST123');
    }
    
    static TestMethod void GetTradeInReturnsAssetWhenValidIdQueried() {
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'IndiaTest', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        user u = TestUtility.CreateMarketSpecificUser('INRUser','JLR System Administrator (Super)','India','IN','INR','IN');
        system.runAs(u){
            insert standardPB;
        }
        Product2 p2 = new product2(name='y',Model_Alternative__c= 'F-Type',Family='Vehicle');
        insert p2;
        PricebookEntry PricebookEntry = new PricebookEntry(pricebook2id = priceBookId, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry; 
        PricebookEntry PricebookEntry2 = new PricebookEntry(pricebook2id = standardPB.Id, product2id = p2.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert PricebookEntry2;
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        Asset ass = new Asset(Name='Test', Brand__c=makeVehicle.Id, Product2Id=prod.Id);
        System.RunAs(portalUser){
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
            ass.AccountId = loggedinUser.AccountId;
            ass.ContactId = loggedinUser.ContactId;
            insert ass;
        }
        NewRDA_LC_Controller.getTradeIn(ass.Id);
        NewRDA_LC_Controller.refreshServicePlan(prod.Id,null);
        NewRDA_LC_Controller.getTradeInAssets('Test');
        try{
            NewRDA_LC_Controller.getRDA(null);
        }catch(exception exp){
            
        }
        NewRDA_LC_Controller.getLoyaltyTransaction( ass.AccountId, ass.Id, null);
        NewRDA_LC_Controller.getContactLoyaltyStatus(ass.AccountId);
        NewRDA_LC_Controller.getChangedContactLoyaltyStatus('test','test');
        System.assert(NewRDA_LC_Controller.getTradeIn(ass.Id).Brand__r.Name == 'Land Rover');
        
    }
    
    static TestMethod void GetOpportunityReturnsOpportunityWhenValidOpportunityIdQueried() {
        Account acc = new Account(Name='Test', RecordTypeId=corporateRecordType);
        insert acc;
        Opportunity opp = new Opportunity(Name='Test', StageName='Qualified', CloseDate=Date.today()+4, AccountId=acc.Id);
        insert opp;
        try{
            NewRDA_LC_Controller.getServicePlan(opp.Id);
            
        }catch(exception exp){           
        }
        NewRDA_LC_Controller.getAccount(acc.Id);
        System.assert(NewRDA_LC_Controller.getOpportunity(opp.Id).Id == opp.Id);
    }
    
    static TestMethod void GetLocationsReturnsCorrectAULocation() {
        Account acc = new Account(Firstname='Test', Lastname='Test', PersonEmail='test@test.com', RecordTypeId=individualRecordType);
        acc.BillingCity = 'Test';
        acc.BillingPostalCode = '1234';
        insert acc;
        PMA_Postcode__c pp = new PMA_Postcode__c(Name='1234');
        insert pp;
        List<AU_Locality__c> locs = new List<AU_Locality__c>();
        locs.add(new AU_Locality__c(Name='Test', PMA_Postcode__c=pp.Id));
        locs.add(new AU_Locality__c(Name='Test1', PMA_Postcode__c=pp.Id));
        insert locs;
        List<AU_Locality__c> alllocs = NewRDA_LC_Controller.getLocations(acc.Id, null);
        System.assertEquals(alllocs.size(), 1);
        NewRDA_LC_Controller.refreshLocations('1234','Test');
    }
    
    static TestMethod void GetLocationsReturnsAULocations() {
        Account acc = new Account(Firstname='Test', Lastname='Test', PersonEmail='test@test.com', RecordTypeId=individualRecordType);
        acc.BillingCity = 'Test';
        acc.BillingPostalCode = '1234';
        insert acc;
        PMA_Postcode__c pp = new PMA_Postcode__c(Name='1234');
        insert pp;
        List<AU_Locality__c> locs = new List<AU_Locality__c>();
        locs.add(new AU_Locality__c(Name='Test1', PMA_Postcode__c=pp.Id));
        locs.add(new AU_Locality__c(Name='Test2', PMA_Postcode__c=pp.Id));
        insert locs;
        List<AU_Locality__c> alllocs = NewRDA_LC_Controller.getLocations(acc.Id, null);
        System.assertEquals(alllocs.size(), 2);
        NewRDA_LC_Controller.searchServicePlan('Test');
    }
    static TestMethod void GetLocationsReturnsAULocationsForContact() {
        Account acc = new Account(Name='Test', Retailer_Email__c ='test@test.com', RecordTypeId=corporateRecordType);
        acc.BillingCity = 'Test';
        acc.BillingPostalCode = '1234';
        insert acc;
        Contact con = new Contact(FirstName = 'Joe', LastName = 'Pacman', Email = 'Joe@Pacman.com');
        con.AccountId = acc.id;
        con.MailingCity = 'Test';
        con.MailingPostalCode = '1234';
        insert con;
        Opportunity opp = new Opportunity(Name='Test', StageName='Qualified', CloseDate=Date.today()+4, AccountId=acc.Id, Primary_Contact__c = con.id);
        insert opp;
        PMA_Postcode__c pp = new PMA_Postcode__c(Name='1234');
        insert pp;
        List<AU_Locality__c> locs = new List<AU_Locality__c>();
        locs.add(new AU_Locality__c(Name='Test1', PMA_Postcode__c=pp.Id));
        locs.add(new AU_Locality__c(Name='Test2', PMA_Postcode__c=pp.Id));
        insert locs;
        List<AU_Locality__c> alllocs = NewRDA_LC_Controller.getLocations(acc.Id, opp.Id);
        System.assertEquals(alllocs.size(), 2);
        NewRDA_LC_Controller.searchServicePlan('Test');
    }
    static TestMethod void GetLocationsReturnsAULocationsForJustContact() {
        Account acc = new Account(Name='Test', Retailer_Email__c ='test@test.com', RecordTypeId=corporateRecordType);
        acc.BillingCity = 'Test';
        acc.BillingPostalCode = '1234';
        insert acc;
        Contact con = new Contact(FirstName = 'Joe', LastName = 'Pacman', Email = 'Joe@Pacman.com');
        con.AccountId = acc.id;
        con.MailingCity = 'Test';
        con.MailingPostalCode = '1234';
        insert con;
        Opportunity opp = new Opportunity(Name='Test', StageName='Qualified', CloseDate=Date.today()+4, AccountId=acc.Id, Primary_Contact__c = con.id);
        insert opp;
        PMA_Postcode__c pp = new PMA_Postcode__c(Name='1234');
        insert pp;
        List<AU_Locality__c> locs = new List<AU_Locality__c>();
        locs.add(new AU_Locality__c(Name='Test1', PMA_Postcode__c=pp.Id));
        locs.add(new AU_Locality__c(Name='Test2', PMA_Postcode__c=pp.Id));
        insert locs;
        List<AU_Locality__c> alllocs = NewRDA_LC_Controller.getLocations(null, opp.Id);
        System.assertEquals(alllocs.size(), 2);
        NewRDA_LC_Controller.searchServicePlan('Test');
    }
    static TestMethod void getContactLoyaltyStatusTest(){
        Account acc = new Account(Firstname='Test', Lastname='Test', PersonEmail='test@test.com', RecordTypeId=individualRecordType, Loyalty_Scheme_Reference__c = '1234' );
        Test.setMock(HttpCalloutMock.class, new FrequentFlyerNumberVerificationMock());
        insert acc;
        
        Map<String,String> am= NewRDA_LC_Controller.getContactLoyaltyStatus(acc.id);
        
        
        System.assert(am != null);
        
        
        
    }
    
    static TestMethod void GetServicePlanReturnsComplimentaryServicePlanWhenQueried() {
        
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Asset testasset = new Asset();
        
        Id priceBookId = Test.getStandardPricebookId();
        Pricebook2 standardPB = new Pricebook2(Name = 'Australia', Description = 'IndiaTest', IsActive = true,Region_or_Market__c =portaluser.Market__c );
        user u = TestUtility.CreateMarketSpecificUser('INRUser','JLR System Administrator (Super)','India','IN','INR','IN');
        system.runAs(u){
            insert standardPB;
        }
        
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
        off.Derivative_Product2Id__c = p2.id;
        off.Start_Date__c = system.today().AddDays(-1);
        off.Type__c = 'Complimentary';
        off.IsActive__c = true;
        insert off;
        
        System.RunAs(portalUser){
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
            // Asset testasset = new Asset();
            testasset.Name = 'TestAsset';
            testasset.AccountId = loggedinUser.AccountId;
            testasset.Brand__c = makeVehicle.Id;
            testasset.product2Id =p2.Id;
            
            testasset.Derivative__c  =p2.Id;
            testasset.Status = Label.Asset_Status_List.split(',')[0];
            // testasset.ProductCode = '3762457362';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
        }
        System.assert(NewRDA_LC_Controller.getComplimentaryOffer(testasset.Id) != null);
    }
    
    @isTest
    Static void FetchFMOMetadata(){
        Common_Type_of_Sale_Code__mdt[] PrivateLessemeta = [SELECT MasterLabel,Default_FMO__c FROM Common_Type_of_Sale_Code__mdt WHERE Default_FMO__c = true ];
        NewRDA_LC_Controller.getTrueFMOList();
        NewRDA_LC_Controller.getAffinityProgramStatus();
        NewRDA_LC_Controller.getDropdownCommonSaleType();
    }
    
    //1.0 - CXPD-1218
    @isTest static void getExistingSPTest(){
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Product2 p2 = new product2(name = 'TestProduct',Model_Alternative__c = 'F-Type',Family = 'Vehicle');
        insert p2;
        Asset objAsset = new Asset(Name = 'Test', Registration_Number__c ='REG321', Brand__c = makeVehicle.Id, Product2Id = p2.Id);
        System.RunAs(portalUser){
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
            objAsset.AccountId = loggedinUser.AccountId;
            objAsset.ContactId = loggedinUser.ContactId;
            insert objAsset;
        }
        Service_Plan_Contract__c objServicePlan = new Service_Plan_Contract__c(Vehicle_Id__c = objAsset.Id, Start_Date__c = System.today().addDays(-1), End_Date__c = System.today().addDays(10));
        insert objServicePlan;
        List<Service_Plan_Contract__c> fetchedSPList = new List<Service_Plan_Contract__c>();
        fetchedSPList = NewRDA_LC_Controller.getExistingSP(objAsset.Id);
        System.assertNotEquals(0, fetchedSPList.size());
    }
    
}