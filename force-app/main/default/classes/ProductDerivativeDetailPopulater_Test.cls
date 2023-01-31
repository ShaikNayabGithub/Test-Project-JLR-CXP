@isTest
private class ProductDerivativeDetailPopulater_Test {

    @isTest
    static void ProductDerivativeDetailPopulater_PopulatesModelYear_GivenValidProductName() {
        Product2 prod = new Product2(Name='Test Product With Various Details, A100/B200, 2018', RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId());
        insert prod;
        
        prod = [SELECT Model_Year__c FROM Product2 WHERE Id = :prod.Id];
        
        System.assertEquals('2018', prod.Model_Year__c);
    }
    
    @isTest
    static void ProductDerivativeDetailPopulater_PopulatesDPCKCode_GivenValidProductName() {
        Product2 prod = new Product2(Name='Test Product With Various Details, A100/B200, 2018', RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId());
        insert prod;
        
        prod = [SELECT DPCK_Code__c FROM Product2 WHERE Id = :prod.Id];
        
        System.assertEquals('B200', prod.DPCK_Code__c);
    }
    
    @isTest
    static void ProductDerivativeDetailPopulater_PopulatesBrochureModelCode_GivenValidProductName() {
        Product2 prod = new Product2(Name='Test Product With Various Details, A100/B200, 2018', RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId());
        insert prod;
        
        prod = [SELECT Brochure_Model_Code__c FROM Product2 WHERE Id = :prod.Id];
        
        System.assertEquals('A100', prod.Brochure_Model_Code__c);
    }
    
    @isTest
    static void ProductDerivativeDetailPopulater_PopulatesModelVehicleSpec_GivenValidModelId() {
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        Vehicle_Specification__c vs = new Vehicle_Specification__c(Name='Test', Product_Code__c='abc,def', RecordTypeId=modelRecordType);
        insert vs;
        Product2 prod = new Product2(Name='Test', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId(), ProductCode='def');
        insert prod;
        
        prod = [SELECT Model_Vehicle_Spec__c FROM Product2 WHERE Id = :prod.Id];
        
        System.assertEquals(vs.Id, prod.Model_Vehicle_Spec__c);
    }
    
}