public class MakeRetriever {
    public Vehicle_Specification__c Retrieve(string makeName)
    {
    	List<Vehicle_Specification__c> makes = [Select Id From Vehicle_Specification__c 
    	where Name = :makeName And RecordType.DeveloperName = 'Make' Limit 1];//describe
    	
    	if(makes.Size() > 0){ return makes[0]; }
    	return new Vehicle_Specification__c();
    }
}