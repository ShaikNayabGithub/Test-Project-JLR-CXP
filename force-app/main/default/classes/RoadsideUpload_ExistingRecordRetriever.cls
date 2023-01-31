public class RoadsideUpload_ExistingRecordRetriever {
	private final RoadsideUpload_ContactRetriever contactRetriever;
	private final RoadsideUpload_ContactMapper contactMapper;

	private final RoadsideUpload_LeadRetriever leadRetriever;
	private final RoadsideUpload_LeadMapper leadMapper;

	private final RoadsideUpload_AssetRetriever assetRetriever;
	private final RoadsideUpload_AssetMapper assetMapper;


	public RoadsideUpload_ExistingRecordRetriever(RoadsideUpload_ContactRetriever contactRetriever,
			RoadsideUpload_ContactMapper contactMapper, RoadsideUpload_LeadRetriever leadRetriever,
			RoadsideUpload_LeadMapper leadMapper, RoadsideUpload_AssetRetriever assetRetriever,
			RoadsideUpload_AssetMapper assetMapper) 
	{
		this.contactRetriever = contactRetriever;
		this.contactMapper = contactMapper;
		this.leadRetriever = leadRetriever;
		this.leadMapper = leadMapper;
		this.assetRetriever = assetRetriever;
		this.assetMapper = assetMapper;
	}


	public void Retrieve(RoadsideUpload_RecordCollection recordCollection)
	{
		Set<String> emails = CSVDataCollectionUtilities.GetUniqueValues(RoadsideUpload_Constants.EMAIL_COLUMN_HEADER,
				recordCollection.CSVData);
		Set<String> phoneNumbers = CSVDataCollectionUtilities.GetUniqueValues(RoadsideUpload_Constants.PHONE_COLUMN_HEADER,
				recordCollection.CSVData);
		Set<String> vins = CSVDataCollectionUtilities.GetUniqueValues(RoadsideUpload_Constants.VIN_COLUMN_HEADER,
				recordCollection.CSVData);
		Set<String> registrationNumbers = CSVDataCollectionUtilities.GetUniqueValues(RoadsideUpload_Constants.REGISTRATION_COLUMN_HEADER,
				recordCollection.CSVData);

		List<Contact> contacts = this.contactRetriever.Retrieve(emails, phoneNumbers);		
		List<Lead> leads = this.leadRetriever.Retrieve(emails, phoneNumbers);
		List<Asset> assets = this.assetRetriever.Retrieve(vins, registrationNumbers);

		this.contactMapper.AddToCollection(contacts, recordCollection);
		this.leadMapper.AddToCollection(leads, recordCollection);
		this.assetMapper.AddToCollection(assets, recordCollection);
	}
}