@isTest
public class RDAControllerTest {    
    
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    
    static testmethod void RDAControllerReturnsAssetsGivenCorrectAssetCriteriaWithoutOpp() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Courtesy / Loan Car';
        vehicle.Sale_Type_Code__c = 'CLO';
        insert vehicle; 
        User portalUser;
        System.runAs(new User(id = UserInfo.getUserId())){
            portalUser = TestUtility.createPortaluser('India','Sales Executive');
            
        }
        Account TestAccount = [SELECT Id,Country_ISO_Code__c FROM Account WHERE Id =:vehicle.AccountId];
        TestAccount.Country_ISO_Code__c = portalUser.Country_ISO_Code__c;
        update TestAccount;
        RDAController.InitWrapper inwrap = RDAController.initAssets();
         list<RDAController.RDADetail> rdas = RDAController.searchAssets();
        RDAController.getAvailableQuota(''+TestAccount.Id+'-'+vehicle.Id);
        //System.assertEquals(1, .size());
    } 
    
    static testmethod void RDAControllerCreatesNewRDAWithLinkedOpportunity() {
        //create an Asset with the correct criteria
        List<Asset> vehiclesList = TestClass_AssetBuilder.BuildVehicles(1, True);
        List<Asset> vehicles = new List<Asset>();
        Id vehicleId;
        for(Asset vehicle: vehiclesList){
            vehicle.Vista_Status__c = 'Arrived at Dealer';
            vehicle.Common_Sale_Type__c = 'Market Stock';
            vehicle.Sale_Type_Code__c = 'WHS';
            vehicles.add(vehicle);
            vehicleId = vehicle.Id;
        }
        insert vehicles;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicleId;
        insert oli;
        //createRDA method takes a unique key AssetId-OpportunityId-AccountId-RDARecordTypeId
        String uniqueKey = vehicleId + '-' + opp.Id + '-' + opp.AccountId + '-New_Retail';
        RDA__c rda = RDAController.createRDA(uniqueKey);
        //RDA__c rda = [SELECT Opportunity__c FROM RDA__c ORDER BY CreatedDate DESC LIMIT 1];
        
        RDAController.getAvailableQuota(uniqueKey);
    }
    
    static testmethod void RDAControllerCreatesNewRDAWithLinkedOpportunityOnsell() {
        //create an Asset with the correct criteria
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'WHS';
        insert vehicle;
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.Purchase_Type__c = 'New Vehicle';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        //createRDA method takes a unique key AssetId-OpportunityId-AccountId-RDARecordTypeId
        String uniqueKey = vehicle.Id + '-' + opp.Id + '-' + opp.AccountId + '-On_Sell';
        RDA__c rda = RDAController.createRDA(uniqueKey);
        //RDA__c rda = [SELECT Opportunity__c FROM RDA__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(opp.Id, rda.Opportunity__c);
    }
    
    static testmethod void TradeInMethodSetsAssetToTradeInGivenValidVin() {
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        User portalUser;
        System.runAs(new User(id = UserInfo.getUserId())){
            portalUser = TestUtility.createPortaluser('India','Sales Executive');
            
        }
        
        Asset ass = new Asset(Name='Test', Brand__c=makeVehicle.Id, VIN__c='1234567890', Traded_In__c=false);
        System.RunAs(portalUser){
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
            ass.AccountId = loggedinUser.AccountId;
            ass.ContactId = loggedinUser.ContactId;
            insert ass;
        }
        RDAController.tradeInAsset('1234567890');
        ass = [SELECT Traded_In__c FROM Asset WHERE Id = :ass.Id];
        System.assertEquals(true, ass.Traded_In__c);
        
        
    }
    
    static testmethod void TradeInMethodSetsAssetToTradeInGivenValidVin1() {
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        User portalUser;
        System.runAs(new User(id = UserInfo.getUserId())){
            portalUser = TestUtility.createPortaluser('India','Sales Executive');
            
        }
        
        Asset ass = new Asset(Name='Test', Brand__c=makeVehicle.Id, VIN__c='1234567890', Traded_In__c=true);
        System.RunAs(portalUser){
            List<Asset> assetList = new List<Asset>();
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
            ass.AccountId = loggedinUser.AccountId;
            ass.ContactId = loggedinUser.ContactId;
            assetList.add(ass);
            insert assetList;
        }
        RDAController.tradeInAsset('1234567890');
         RDAController.getCommonTypeOfSale(null);
        RDAController.getBuyerType(null);
        RDAController.getDefaultFMO(null);
        ass = [SELECT Traded_In__c FROM Asset WHERE Id = :ass.Id];
        System.assertEquals(true, ass.Traded_In__c);
        
        
    }
    
    static testmethod void GetVehicleTypeSetterReturnsLabelGivenCommonSaleType() {
        List<Vehicle_Type_Setter__mdt> vts = [SELECT MasterLabel,Common_Sale_Type_Code_List__c FROM Vehicle_Type_Setter__mdt];
        String commonSalesType = vts[0].Common_Sale_Type_Code_List__c;
        List<String> separated = commonSalesType.split(';');
        System.assertEquals(vts[0].MasterLabel, RDAController.getVehicleTypeSetter(separated[0]));
    }
    
    static testmethod void RDAControllerReturnsAssetsGivenCorrectAssetCriteriaWithoutOpp1() {
        Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
       User portalUser;
        System.runAs(new User(id = UserInfo.getUserId())){
            portalUser = TestUtility.createPortaluser('India','Sales Executive');
            
        }
        Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
        account.PersonMailingPostalCode = 'Valid PostalCode';
        account.PersonMailingState = 'Valid State';
        account.PersonMailingCity = 'Valid City';        
        account.PersonEmail = 'test@test.com';      
        account.Country_ISO_Code__c = portalUser.Country_ISO_Code__c;  
        account.Is_Primary__c = false;
        account.Phone = '1234567890';
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(account, dml);
        Id newRetailRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
        Asset vehicle = TestClass_AssetBuilder.BuildVehicle();
        vehicle.Vista_Status__c = 'Arrived at Dealer';
        vehicle.Common_Sale_Type__c = 'Market Stock';
        vehicle.Sale_Type_Code__c = 'WHS';
        insert vehicle;
        test.startTest();
        //create Opportunity to add Asset to
        Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
        opp.asset__c = vehicle.Id;
        opp.Purchase_Type__c = 'New Vehicle';
        insert opp;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
        oli.Asset__c = vehicle.Id;
        insert oli;
        List<RDA__c> rdaList = new List<RDA__c>();
        rdaList.Add(new RDA__c(recordtypeId =newRetailRecordTypeId, Opportunity__c=opp.Id, account__c=account.Id, Asset__c=vehicle.Id, 
                               Handover_Date__c=Date.today(), Common_Sale_Type__c='Dealer Based Rental',
                               Registration_Number__c='TEST123', Retail_Offer__c='',Add_Extended_Warranty__c = true,
                               Submitted_Date__c=system.today(), Submitted_Status__c='Submitted',
                               Common_Type_of_Sale_Code__c ='CAM'));
        
        insert rdaList;
        
        RDAController.InitWrapper inwrap = RDAController.initAssets();
        test.stopTest();
       // list<RDAController.RDADetail> rdas = RDAController.searchAssets();
        //List<RDAController.RDADetail> rdas = inwrap.assets;        
    }
    
    /*
static testmethod void RDAControllerCreatesNewRDAWithLinkedOpportunity12() {
Id DemoOrLoanRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Demonstrator_Loan_Quota').getRecordTypeId();
Id salestargetRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Sales_Target').getRecordTypeId();
Id maximumStockRecordTypeId = Schema.SObjectType.Target_Quota__c.getRecordTypeInfosByDeveloperName().get('Maximum_Stock').getRecordTypeId();
Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();

//create an Asset with the correct criteria
List<Asset> vehiclesList = TestClass_AssetBuilder.BuildVehicles(1, True);
List<Asset> vehicles = new List<Asset>();
Id vehicleId;
for(Asset vehicle: vehiclesList){
vehicle.Vista_Status__c = 'Arrived at Dealer';
vehicle.Common_Sale_Type__c = 'Market Stock';
vehicle.Sale_Type_Code__c = 'WHS';
vehicles.add(vehicle);
vehicleId = vehicle.Id;
}
insert vehicles;
vehicleId = vehicles.get(0).Id;
//create Opportunity to add Asset to
Opportunity opp = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
opp.Purchase_Type__c = 'New Vehicle';
insert opp;
Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
OpportunityLineItem oli = TestClass_OpportunityProductBuilder.BuildLineItem(opp, pb);
oli.Asset__c = vehicleId;
insert oli;
user  portalUser = TestUtility.createPortaluser('India','Sales Executive');
System.RunAs(portalUser){
Test.startTest();
Account account = new Account(RecordTypeId = individualRecordType, LastName = 'test',FirstName = 'Valid Firstname',PersonMailingStreet = 'Valid Street');
account.PersonMailingPostalCode = 'Valid PostalCode';
account.PersonMailingState = 'Valid State';
account.PersonMailingCity = 'Valid City';        
account.PersonEmail = 'test@test.com';      
account.Country_ISO_Code__c = 'IN';  
account.Is_Primary__c = false;
account.Phone = '1234567890';
account.OwnerId = portalUser.id;
Database.DMLOptions dml = new Database.DMLOptions(); 
dml.DuplicateRuleHeader.AllowSave = true;
Database.insert(account, dml);

User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
AND ContactId != null AND AccountId != null];

Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
insert makeVehicle;
Vehicle_specification__c   modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
insert modelVehicle;

List<Target_Quota__c>  targeList = new List<Target_Quota__c>();
targeList.add(new Target_Quota__c(RecordTypeId=maximumStockRecordTypeId,Make__c =makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedinUser.accountId));
targeList.add( new Target_Quota__c(RecordTypeId=DemoOrLoanRecordTypeId, Make__c =makeVehicle.Id, Model__c=modelVehicle.id, Year__c ='2020',Retailer__c =loggedinUser.accountId));
targeList.add( new Target_Quota__c(RecordTypeId=salestargetRecordTypeId, Make__c=makeVehicle.Id, Model__c =modelVehicle.id, Year__c ='2020',Retailer__c =loggedinUser.accountId));
insert targeList;
Asset ass = new Asset(Name='Test', Brand__c=makeVehicle.Id, VIN__c='1234567890', Traded_In__c=false);

//createRDA method takes a unique key AssetId-OpportunityId-AccountId-RDARecordTypeId
String uniqueKey = vehicleId + '-' + opp.Id + '-' + opp.AccountId + '-New_Retail';
system.debug('==> '+uniqueKey);
RDAController.getAvailableQuota(uniqueKey);
Test.stopTest();
}
}*/
    
    
    
    
}