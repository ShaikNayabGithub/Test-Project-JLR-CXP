@isTest
public with sharing class TestClass_Product2 {
    
    public static Product2 createAccessoryProduct(String name) {
        Id accessoryRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Accessories').getRecordTypeId();
        Product2 accessory = new Product2();
        accessory.RecordTypeId = accessoryRecordTypeId;
        accessory.Name = name;

        insert accessory;
        return accessory;
    }

    public static Product_Option_Mapping__c createProductOptionMapping(String derivativeId, String accessoryId, Boolean marketMandatory) {
        Product_Option_Mapping__c pom = new Product_Option_Mapping__c();
        pom.Market_Standard_Required__c = marketMandatory;
        pom.Option__c = accessoryId;
        pom.Product__c = derivativeId;

        insert pom;
        return pom;
    }
}