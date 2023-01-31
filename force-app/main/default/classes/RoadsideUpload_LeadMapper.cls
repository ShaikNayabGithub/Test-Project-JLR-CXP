public class RoadsideUpload_LeadMapper {
	public void AddToCollection(List<Lead> leads, RoadsideUpload_RecordCollection recordCollection)
	{
		if(recordCollection.LeadsByPhoneNumber == null) {
			recordCollection.LeadsByPhoneNumber = new Map<String, Lead>();
		}

		if(recordCollection.LeadsByEmail == null) {
			recordCollection.LeadsByEmail = new Map<String, Lead>();
		}

		for(Lead lead : leads) {
			if(String.isNotBlank(lead.Phone)) {
				recordCollection.LeadsByPhoneNumber.put(lead.Phone, lead);
			}

			if(String.isNotBlank(lead.Email)) {
				recordCollection.LeadsByEmail.put(lead.Email, lead);
			}

			if(String.isNotBlank(lead.MobilePhone)) {
				recordCollection.LeadsByPhoneNumber.put(lead.MobilePhone, lead);
			}

			if(String.isNotBlank(lead.Email_Address_2__c)) {
				recordCollection.LeadsByEmail.put(lead.Email_Address_2__c, lead);
			}
		}
	}
}