public class RoadsideUpload_AssetRetriever {
	public List<Asset> Retrieve(Set<String> vins, Set<String> registrationNumbers)
	{
		return [SELECT VIN__c, Registration_Number__c FROM Asset WHERE VIN__c IN: vins OR 
				Registration_Number__c IN: registrationNumbers];
	}
}