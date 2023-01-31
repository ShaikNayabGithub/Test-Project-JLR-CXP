@isTest
public class TestClass_RequestCreator{
    public static Request__c Build()
    {
        Account preferredRetailer = TestClass_AccountCreator.CreateRetailer();
        Campaign campaign = BuildCampaign();
        return BuildRequest(preferredRetailer, campaign);
        
    }
    
    private static Request__c BuildRequest(Account retailer, Campaign campaign)
    {
        String makeName = 'Jaguar';
        String modelName = 'XE';

        List<Vehicle_Specification__c> existingJaguars = [Select Id From Vehicle_Specification__c Where Name='Jaguar' Limit 1];
        if(existingJaguars.size() == 0){
            Vehicle_Specification__c brand = new Vehicle_Specification__c();
            brand.Name = 'Jaguar';
            brand.RecordTypeId = [Select Id From RecordType where DeveloperName ='Make' and SobjectType ='Vehicle_Specification__c'  limit 1].Id;
            insert brand;
            existingJaguars.add(brand);
        }

        List<Vehicle_Specification__c> existingModels = [Select Id From Vehicle_Specification__c Where Name=:modelName And Make__c=:existingJaguars[0].Id And Is_Currently_Sold__c = true Limit 1];
        if(existingModels.size() == 0){
            Vehicle_Specification__c model = new Vehicle_Specification__c();
            model.Name = modelName;
            model.Make__c = existingJaguars[0].Id;
            model.Is_Currently_Sold__c = true;
            model.RecordTypeId = [Select Id From RecordType where DeveloperName ='Model' and SobjectType ='Vehicle_Specification__c'  limit 1].Id;
            insert model;
        }
        
        List<RecordType> recordTypes = [Select Id From RecordType where DeveloperName ='Avoka_Request' and SobjectType ='Request__c'  limit 1];
        
        Request__c request = new Request__c();
        if(recordTypes.size() > 0){
        	request.RecordTypeId = recordTypes[0].Id;
        }//needs aop/some RT
        request.Request_Source__c = 'jag-tdsf-in-en';
        request.Last_Name__c = UniqueString.CreateNew();
        request.Campaign__c = campaign.Id;
        request.Purchase_Type__c = 'New Vehicle';
        request.Email__c = 't.t@t.com';
        request.Primary_Model_Of_Interest_Text__c = modelName;
        request.Preferred_Retailer__c = retailer.Id;
        
        return request;
    }

    private static Campaign BuildCampaign()
    {
        Campaign existingCampaign = new Campaign();
        existingCampaign.Name = 'Test 1';
        existingCampaign.Campaign_ID__c = 'test id';
        existingCampaign.ExpectedResponse = 10;
        existingCampaign.Market_ID__c = 'IN';
        insert existingCampaign;
        return existingCampaign;
    }
}