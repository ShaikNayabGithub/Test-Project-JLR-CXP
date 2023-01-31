@IsTest(seeAllData=true)
public class TestClass_VehicleSpecificationBuilder {
    
    public static Vehicle_Specification__c Make{get;set;}
    public static Vehicle_Specification__c Model{get;set;}
    public static Vehicle_Specification__c Derivative{get;set;}
    
    public static Vehicle_Specification__c BuildMake()
    { 
        make = new Vehicle_Specification__c(); 
        //make.RecordTypeId = [select Id from RecordType where Name = 'Make' and SObjectType = 'Vehicle_Specification__c' limit 1].id; 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        make.Name = 'Jaguar'; 
        insert make; 
        return make; 
    }
    public static Vehicle_Specification__c BuildModel(Vehicle_Specification__c make)
    { 
        model = new Vehicle_Specification__c(); 
        //model.RecordTypeId = [select Id from RecordType where Name = 'Model' and SObjectType = 'Vehicle_Specification__c' limit 1].id;
        model.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        model.Name = 'Test Model';
        model.Make__c = make.Id;
        model.Is_Currently_Sold__c = true;
        model.Product_Code__c = 'M1';
        insert model;
        return model; 
    }
    public static Vehicle_Specification__c BuildDerivative()
    { 
        derivative = new Vehicle_Specification__c();
        if(make == null){
            make = BuildMake(); 
        }
        if(model == null){
            model = BuildModel(make);
        }       
        //derivative.RecordTypeId = [select Id from RecordType where Name = 'Derivative' and SObjectType = 'Vehicle_Specification__c' limit 1].id; 
        derivative.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Derivative').getRecordTypeId();
        derivative.Name = 'Test Derivative';
        derivative.Make__c = make.Id;
        derivative.Model__c = model.Id; 
        insert derivative;         
        return derivative; 
    }
    public static Vehicle_Specification__c BuildLandRoverMake()
    { 
        Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        //make.RecordTypeId = [select Id from RecordType where Name = 'Make' and SObjectType = 'Vehicle_Specification__c' limit 1].id; 
        make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        make.Name = 'Land Rover'; 
        insert make; 
        return make; 
    }
}