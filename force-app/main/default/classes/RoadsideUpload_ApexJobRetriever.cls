public class RoadsideUpload_ApexJobRetriever {
	public Apex_Job__c Retrieve(Id recordId)
	{
		return [SELECT File_Header__c FROM Apex_Job__c WHERE Id =: recordId];
	}
}