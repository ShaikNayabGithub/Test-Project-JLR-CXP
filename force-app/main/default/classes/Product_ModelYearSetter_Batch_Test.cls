@isTest
public class Product_ModelYearSetter_Batch_Test {
    @isTest
    static void testProductModelYearSetter() {
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        System.assertNotEquals(null, acc.RecordTypeId);
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        acc.LastName = 'TestAcc';
        acc.FirstName = 'Valid Firstname';
        acc.PersonMailingStreet = 'Valid Street';
        acc.PersonMailingPostalCode = 'Valid PostalCode';
        acc.PersonMailingState = 'Valid State';
        acc.PersonMailingCity = 'Valid City';        
        acc.PersonEmail = 'testurvora@rediffmail.com';
        acc.PersonOtherPhone = '1122334455';
        acc.Country_ISO_Code__pc = 'IN';
        acc.Country_ISO_Code__c = 'IN';
        insert acc;
        
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake(); //utility method saves Vehicle Spec
        Product2 model = new Product2(Name='TestModel');
        //if(requiredRecordTypes.containsKey('MODEL')) model.RecordTypeId = requiredRecordTypes.get('MODEL');
        model.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        model.Make__c = make.Id;
        insert model;
        
        Product2 derivative = new Product2(Name='TestDerivative',Model_Year__c='',Model_Year_Code__c='', isActive=true);
        derivative.Make__c = make.Id;
        derivative.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
        derivative.Model__c = model.Id;
        insert derivative;
        
        Asset vehicle = new Asset(Name='TestVehicle', AccountId=acc.Id, Brand__c=make.Id, Model__c=model.Id, Derivative__c=derivative.Id ,Model_Year__c='2022', Model_Year_Description__c = '2022MY' , Model_Year_code__c = '001BS');
        vehicle.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
        insert vehicle;
        
        Test.startTest();
        
        List<Product2> prodList = [SELECT Id, Model_Year__c, Model_Year_Code__c FROM Product2];
        Database.executeBatch(new Product_ModelYearSetter_Batch(), 5);
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('TestSchedule', CRON_EXP, new Product_ModelYearSetter_Batch());
        
        test.stopTest();
    }   
}