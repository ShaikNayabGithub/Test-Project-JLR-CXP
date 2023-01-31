@isTest
public class BatchIMSRequestCleanup_T  {

    @testSetup static void setup() {
        //Data needed:
        //1 records for vehicle spec (make)
        Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId(); 
        make.Is_Currently_Sold__c = false;
        make.aop_JLR_Owned__c = true;
        make.Name = 'Land Rover';  
        insert make;

        //1 record for migrated vehicles account
        Account ownerAccount = new Account(
            name = 'Singapore Migrated Vehicles',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId(),
            Country_Iso_code__c = 'SG' 
        );
        insert ownerAccount;

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
                                CurrencyIsoCode = 'GBP'
                                );
        insert derivative; 

        //1 record for asset
        Asset apoVehicle = new Asset( 
            APO__c = true,
            New_or_Used__c='Used',
            AccountId = OwnerAccount.id,
            Name = 'VIN000000000001',
            Vin__c = 'VIN000000000001',
            Brand__c = make.id,
            Model__c = Model.Id,
            Derivative__c = Derivative.Id,
            Product2id = Derivative.Id, 
            CurrencyIsoCode = 'GBP'
            
        );
        insert apoVehicle; 

        IMS_Request__c ims = new IMS_Request__c (asset__c = apoVehicle.id, Processed_Status__c = 'Processed',dealer_id__c='5000', vin__c='VIN000000000001');
        insert ims;

    }
    
    public static testmethod void testSchedule() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestBatchIMSRequestCleanup', CRON_EXP, new BatchIMSRequestCleanup() );   
        Test.stopTest();
    } 

    public static testMethod void testBatch() {

        Test.startTest();
        Database.executeBatch(new BatchIMSRequestCleanup(),1);
        Test.stopTest();

    }


}