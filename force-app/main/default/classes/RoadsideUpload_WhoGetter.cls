public class RoadsideUpload_WhoGetter {
	public SObject GetWho(List<String> rowData, RoadsideUpload_RecordCollection recordCollection)
	{
		String email = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVData, 
					RoadsideUpload_Constants.EMAIL_COLUMN_HEADER, rowData);

		if(String.isNotBlank(email)) {
			Contact contact = recordCollection.ContactsByEmail.get(email);
			if(contact != null) return contact;
		}

		String phone = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVData, 
					RoadsideUpload_Constants.PHONE_COLUMN_HEADER, rowData);

		if(String.isNotBlank(phone)) {
			Contact contact = recordCollection.ContactsByPhoneNumber.get(phone);
			if(contact != null) return contact;
		}

		if(String.isNotBlank(email)) {
			Lead lead = recordCollection.LeadsByEmail.get(email);
			if(lead != null) return lead;
		}

		if(String.isNotBlank(phone)) {
			Lead lead = recordCollection.LeadsByPhoneNumber.get(phone);
			if(lead != null) return lead;
		}

		return null;
	}
}