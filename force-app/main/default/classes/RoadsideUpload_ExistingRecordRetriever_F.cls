public class RoadsideUpload_ExistingRecordRetriever_F {
	public RoadsideUpload_ExistingRecordRetriever Create()
	{
		RoadsideUpload_ContactRetriever contactRetriever = new RoadsideUpload_ContactRetriever();
		RoadsideUpload_ContactMapper contactMapper = new RoadsideUpload_ContactMapper();

		RoadsideUpload_LeadRetriever leadRetriever = new RoadsideUpload_LeadRetriever();
		RoadsideUpload_LeadMapper leadMapper = new RoadsideUpload_LeadMapper();

		RoadsideUpload_AssetRetriever assetRetriever = new RoadsideUpload_AssetRetriever();
		RoadsideUpload_AssetMapper assetMapper = new RoadsideUpload_AssetMapper();

		return new RoadsideUpload_ExistingRecordRetriever(contactRetriever, contactMapper, leadRetriever,
				leadMapper, assetRetriever, assetMapper);
	}
}