@isTest
public class CustomSearchControllerTest {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    static TestMethod void searchModelListTest(){
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true,Sequence_Order__c=1);
        insert modelVehicle;
        
        User portaluser = TestUtility.createPortaluser('India','Sales Executive');
        
        
        System.RunAs(portaluser){
            List< Map<String,String>> modelOptions = CustomSearchController.searchModelList();
            CustomSearchController.getPriceBookList();
            CustomSearchController.getPurchaseTypePickListValues();
            CustomSearchController.getStageTypePickListValues();
            CustomSearchController.getFieldLabel('Account');
           // system.assertEquals(modelOptions.size(), 1);
        }
        
        
    }
    static TestMethod void searchForAccountsTest(){        
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (recordtypeId = modelRecordType, make__c =makeVehicle.Id);
        insert modelVehicle;    
        
        User portaluser = TestUtility.createPortaluser('India','Sales Executive');
        User currentPortalUser = [SELECT Id,Contact.AccountId FROM User WHERE Id=:portaluser.Id];
        update new Account(Id=currentPortalUser.Contact.AccountId, Is_Accounts_Not_Available_to_All__c = true);
        System.RunAs(portaluser){
            Account retailer = new Account();
            retailer.Name = 'retailer corporate';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            retailer.Dealer_CI_Code__c = 'test retailer';
            retailer.Primary_Dealer_Code__c = 'test retailer' ;
            retailer.Secondary_Dealer_Code__c = 'test retailer';
            retailer.Alternative_Key__c = 'test retailer';
            retailer.Phone = '1234567890';
            retailer.Country_ISO_Code__c = 'IN';
            insert retailer;  
            contact testContact = new Contact(LastName = 'test',FirstName = 'Valid Firstname',Phone = '1234567890',AccountId=retailer.Id);
            insert testContact;
            Test.startTest();
            Account account = new Account();        
            account.RecordTypeId = individualRecordType;
            account.LastName = 'test';
            account.FirstName = 'Valid Firstname';
            account.PersonMailingStreet = 'Valid Street';
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
            testasset.AccountId = account.Id;
            testasset.Brand__c = makeVehicle.Id;
            // testasset.CurrencyIsoCode = 'in';
            testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
            insert testasset;
            
            Id [] fixedSearchResults= new Id[]{account.Id,testContact.Id,testasset.Id};
                Test.setFixedSearchResults(fixedSearchResults);
            CustomSearchController.searchForAccounts('1234567890','customer');
            CustomSearchController.searchForAccounts('Test','vehicle');
            Test.stopTest();
        }
        
    }
    
    static TestMethod void getNavigationIdTest(){
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name ='Jaguar',recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;  
        User portaluser = TestUtility.createPortaluser('India','Sales Executive');
        Pricebook2 standardPB = new Pricebook2(Name = 'India', Description = 'India', IsActive = true);
        insert standardPB;
        
        System.RunAs(portaluser){
            
            Account account = new Account();        
            account.RecordTypeId = individualRecordType;
            account.LastName = 'test';
            account.FirstName = 'Valid Firstname';
            account.PersonMailingStreet = 'Valid Street';
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
            CustomSearchController.getNavigationId(account.Id);
            contact testContact = new Contact(LastName = 'test',FirstName = 'Valid Firstname',Phone = '1234567890');
            insert testContact;  
            Test.startTest();
            CustomSearchController.searchForAccounts('1234567890','customer');
            CustomSearchController.getNavigationId(testContact.Id);        
            Opportunity insertedOpp =  CustomSearchController.saveOpportunity(account.Id,'Test Drive',system.today(),modelVehicle.Id,'India', 'Used Vehicle');
            
            CustomSearchController.saveAccount(account.clone(false, false, false, false),null,'Test Drive',system.today(),modelVehicle.Id,'India','Used Vehicle','Individual','English');
            
            Account testaccount = new Account();    
            testaccount.LastName = 'Last Name';
            testaccount.FirstName = 'Firstname';        
            testaccount.PersonEmail = 'test@one.com';   
            testaccount.Phone = '987654312'; 
            CustomSearchController.saveAccount(new Account(LastName ='Bysample', FirstName='Bysample'),new Account(Name ='TestAccount', Phone='892346283'),'Test Drive',system.today(),modelVehicle.Id,'India','New Vehicle','Corporate','English');
           
            // system.assertEquals(2, [SELECT Id From Opportunity].size());
            Test.stopTest();
            
        }
        
    }
    static TestMethod void getNavigationIdTest2(){
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name ='Jaguar',recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;  
        User portaluser = TestUtility.createPortaluser('India','Sales Executive');
        Pricebook2 standardPB = new Pricebook2(Name = 'India', Description = 'India', IsActive = true);
        insert standardPB;
        
        System.RunAs(portaluser){
            
            Account account = new Account();        
            account.RecordTypeId = individualRecordType;
            account.LastName = 'test';
            account.FirstName = 'Valid Firstname';
            account.PersonMailingStreet = 'Valid Street';
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
            CustomSearchController.getNavigationId(account.Id);
            contact testContact = new Contact(LastName = 'test',FirstName = 'Valid Firstname',Phone = '1234567890');
            insert testContact; 
             
            CustomSearchController.getNavigationId(testContact.Id);        
            Opportunity insertedOpp =  CustomSearchController.saveOpportunity(account.Id,'Test Drive',system.today(),modelVehicle.Id,'India','New Vehicle');
           Test.startTest();
            //CustomSearchController.saveAccount(account.clone(false, false, false, false),'Test Drive',system.today(),modelVehicle.Id,'India');
            
            Account testaccount = new Account();    
            testaccount.LastName = 'Last Name';
            testaccount.FirstName = 'Firstname';        
            testaccount.PersonEmail = 'test@one.com';   
            testaccount.Phone = '987654312';
            CustomSearchController.getLanguagePickListValues();
            CustomSearchController.getRecordTypeList();
            CustomSearchController.saveAccount(testaccount,null,'Test Drive',system.today(),modelVehicle.Id,'India','New Vehicle','Individual','English');
            CustomSearchController.saveAccount(testaccount,new Account(Name ='TestAccount', Phone='892346283'),'Test Drive',system.today(),modelVehicle.Id,'India','New Vehicle','Corporate','English');
           // system.assertEquals(2, [SELECT Id From Opportunity].size());
            Test.stopTest();
            
        }
        
    }
}