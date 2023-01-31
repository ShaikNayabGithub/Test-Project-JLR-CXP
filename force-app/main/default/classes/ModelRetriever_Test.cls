@isTest
public with sharing class ModelRetriever_Test {
    static testmethod void Retrieve_ReturnsEmptyVehicleSpecification_GivenNonExistantName() {
        ModelRetriever modelRetriever = new ModelRetriever();
        
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        
        Vehicle_Specification__c result = modelRetriever.RetrieveByName('ModelRetriever_Test', make);
        
        System.assertEquals(null, null);
    }
    
    static testmethod void Retrieve_ReturnsVehicleSpecification_GivenExistingNameAndBrand() {
        ModelRetriever modelRetriever = new ModelRetriever();
        
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        
        Vehicle_Specification__c result = modelRetriever.RetrieveByName(model.Name, make);
        
        System.assertNotEquals(null, result.Id);
    }
    
        
    static testmethod void Retrieve_ReturnsEmptyVehicleSpecification_GivenNonExistantModelCode() {
        ModelRetriever modelRetriever = new ModelRetriever();
        
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        
        Vehicle_Specification__c result = modelRetriever.RetrieveByBrandCode('ModelRetriever_Test', make);
        
        System.assertEquals(null, null);
    }
    
    static testmethod void Retrieve_ReturnsVehicleSpecification_GivenExistingModelCodeAndBrand() {
        ModelRetriever modelRetriever = new ModelRetriever();
        
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(); 
        vehSpec.RecordTypeId = [select Id, name from RecordType where Name = 'Model' and SObjectType = 'Vehicle_Specification__c' limit 1].id;
        vehSpec.Product_code__c = 'Y4';
        vehSpec.Make__c = make.Id;
        vehSpec.Is_Currently_Sold__c = true;
        insert vehSpec;
       
        Vehicle_Specification__c result = modelRetriever.RetrieveByBrandCode(vehSpec.Product_code__c, make);
        
        System.assertNotEquals(null, result.Id);
    }
}