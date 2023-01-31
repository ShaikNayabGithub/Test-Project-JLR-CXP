public class RoadsideUpload_ContactRetriever {
	public List<Contact> Retrieve(Set<String> emails, Set<String> phoneNumbers)
	{
		return [SELECT Email, Email2__c, Phone, MobilePhone FROM Contact WHERE Email IN: emails OR Phone IN: phoneNumbers 
				OR MobilePhone IN: phoneNumbers OR Email2__c IN: emails ORDER BY LastModifiedDate DESC];
	}
}