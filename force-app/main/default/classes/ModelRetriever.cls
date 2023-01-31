public class ModelRetriever {
    public Vehicle_Specification__c RetrieveByName(string name, Vehicle_Specification__c brand)
    {
        List<Vehicle_Specification__c> makes = [Select Id From Vehicle_Specification__c 
            where Name=:name And Make__c=:brand.Id And RecordType.DeveloperName = 'Model' 
            And Is_Currently_Sold__c = true Limit 1];
        
        if(makes.size() > 0){ return makes[0]; }
        return null;
    }
    
    public Vehicle_Specification__c RetrieveByBrandCode(string brandName, Vehicle_Specification__c vehSpec)
    {
        List<Vehicle_Specification__c> makes = [Select Id From Vehicle_Specification__c 
            where Product_code__c  LIKE: '%' + brandName + '%' And Make__c=:vehSpec.Id And RecordType.DeveloperName = 'Model' 
            And Is_Currently_Sold__c = true Limit 1];
        
        if(makes.size() > 0){ return makes[0]; }
        return null;
    }
    
}