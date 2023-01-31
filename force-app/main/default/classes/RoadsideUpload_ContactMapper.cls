public class RoadsideUpload_ContactMapper {
	public void AddToCollection(List<Contact> contacts, RoadsideUpload_RecordCollection recordCollection)
	{
		if(recordCollection.ContactsByPhoneNumber == null) {
			recordCollection.ContactsByPhoneNumber = new Map<String, Contact>();
		}

		if(recordCollection.ContactsByEmail == null) {
			recordCollection.ContactsByEmail = new Map<String, Contact>();
		}

		for(Contact contact : contacts) {
			if(String.isNotBlank(contact.Phone)) {
				recordCollection.ContactsByPhoneNumber.put(contact.Phone, contact);
			}

			if(String.isNotBlank(contact.Email)) {
				recordCollection.ContactsByEmail.put(contact.Email, contact);
			}

			if(String.isNotBlank(contact.MobilePhone)) {
				recordCollection.ContactsByPhoneNumber.put(contact.MobilePhone, contact);
			}

			if(String.isNotBlank(contact.Email2__c)) {
				recordCollection.ContactsByEmail.put(contact.Email2__c, contact);
			}
		}
	}
}