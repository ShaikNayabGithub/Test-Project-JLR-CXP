@isTest
public class LC_OpportunityTradeIn_Test {

    @isTest
    static void Controller_ReturnsNullList_WhenGivenEmptyTypedText() {
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        Vehicle_Specification__c make = new Vehicle_Specification__c(Name='testMake', RecordTypeId=makeRecordType);
        insert make;
        Vehicle_Specification__c model = new Vehicle_Specification__c(Name='testModel', Make__c=make.Id, RecordTypeId=modelRecordType);
        insert model;
        List<Vehicle_Specification__c> res = LC_OpportunityTradeIn_Controller.getTradeInBrand('');
        System.assertEquals(null, res);
    }
    
    @isTest
    static void Controller_ReturnsMake_WhenGivenCorrespondingModelTypedText() {
        Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        Vehicle_Specification__c make = new Vehicle_Specification__c(Name='testMake', RecordTypeId=makeRecordType);
        insert make;
        Vehicle_Specification__c model = new Vehicle_Specification__c(Name='testModel', Make__c=make.Id, RecordTypeId=modelRecordType);
        insert model;
        List<Vehicle_Specification__c> res = LC_OpportunityTradeIn_Controller.getTradeInBrand('testModel');
        System.assertEquals('testMake', res[0].Make_Text__c);
    }

}