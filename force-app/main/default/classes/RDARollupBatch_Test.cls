@isTest(seeAllData=false)
public class RDARollupBatch_Test {
    public static Id individualRecordType = RecordTypeUtility.getRecordTypeId_Account_Individual();
    public static Id onSellRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('On_Sell').getRecordTypeId();
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    
    static TestMethod void RDATriggerHandler_Test(){
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Id accId;
        System.RunAs(portaluser){
            User loggedinUser = [SELECT Id, AccountId, Contact.AccountId,Contact.Country_ISO_Code__c,CurrencyIsoCode  FROM User WHERE Id = :userinfo.getUserId() 
                                 AND ContactId != null AND AccountId != null];
            accId = loggedinUser.AccountId;
        }
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
        
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        Asset testasset = new Asset();
        testasset.Name = 'TestAsset';
        testasset.AccountId = accId;
        testasset.Common_Sale_Type__c='Demonstrator';
        testasset.Brand__c = makeVehicle.Id;
        testasset.Status = Label.Asset_Status_List.split(',')[0];
        testasset.RecordTypeId =  Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        insert testasset;
        
        List<RDA__c> rdaList = new List<RDA__c>();
        
        rdaList.Add(new RDA__c(recordtypeId =onSellRecordTypeId,OwnerId=portalUser.id, account__c=account.Id, Asset__c=testasset.Id, 
                               Handover_Date__c=Date.today(), Common_Sale_Type__c='Demonstrator',
                               Registration_Number__c='TEST123', Retail_Offer__c='None',Add_Extended_Warranty__c = true,
                               Submitted_Date__c=system.today(), Submitted_Status__c='Submitted'));
        System.RunAs(portaluser){
            insert rdaList;
        }
        Test.startTest();  
        RDARollupBatch_Scheduler scheduler=new RDARollupBatch_Scheduler();
        string cronEx= '0 0 0/1 1/1 * ? *';
        system.schedule('Test Run', cronEx, scheduler);
        Test.stopTest();
        
    } 
}