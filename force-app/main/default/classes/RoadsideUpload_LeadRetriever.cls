public class RoadsideUpload_LeadRetriever {
	public List<Lead> Retrieve(Set<String> emails, Set<String> phoneNumbers)
	{
		return [SELECT Email, Email_Address_2__c, Phone, MobilePhone FROM Lead WHERE Email IN: emails OR Phone IN: phoneNumbers
				OR MobilePhone IN: phoneNumbers OR Email_Address_2__c IN: emails ORDER BY LastModifiedDate DESC];
	}
}