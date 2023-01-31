@isTest
public class MakeRetriever_Test {
    @isTest
    static void Retrieve_ReturnsEmptyVehicleSpecification_GivenNonExistantName() {
        MakeRetriever makeRetriever = new MakeRetriever();
        
        string nonExistantName = UniqueString.CreateNew();
        Vehicle_Specification__c result = makeRetriever.Retrieve(nonExistantName);
        
        System.assertEquals(null, result.Id);
    }
    
    @isTest
    static void Retrieve_ReturnsNonEmptyVehicleSpecification_GivenExistingName() {
        MakeRetriever makeRetriever = new MakeRetriever();
        
        Vehicle_Specification__c existingMake = new Vehicle_Specification__c();
        existingMake.Name = 'Test 1';
        existingMake.RecordTypeId = [Select Id From RecordType where DeveloperName ='Make' and SobjectType ='Vehicle_Specification__c'  limit 1].Id;
        insert existingMake;
        
        Vehicle_Specification__c result = makeRetriever.Retrieve(existingMake.Name);
        
        System.assertNotEquals(null, result.Id);
    } 
}