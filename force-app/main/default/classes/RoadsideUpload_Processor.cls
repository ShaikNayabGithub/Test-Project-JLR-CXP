public class RoadsideUpload_Processor {
	private final RoadsideUpload_RowValidator validator;
	private final RoadsideUpload_ExistingRecordRetriever existingRecordRetriever;
	private final RoadsideUpload_EventBuilder eventBuilder;
	private final RoadsideUpload_AssetBuilder assetBuilder;
	private final RoadsideUpload_Upserter recordUpserter;


	public RoadsideUpload_Processor(RoadsideUpload_RowValidator validator,
			RoadsideUpload_ExistingRecordRetriever existingRecordRetriever,
			RoadsideUpload_EventBuilder eventBuilder,
			RoadsideUpload_AssetBuilder assetBuilder,
			RoadsideUpload_Upserter recordUpserter)
	{
		this.validator = validator;
		this.existingRecordRetriever = existingRecordRetriever;
		this.eventBuilder = eventBuilder;
		this.assetBuilder = assetBuilder;
		this.recordUpserter = recordUpserter;
	}


	public void Process(RoadsideUpload_RecordCollection recordCollection)
	{
		this.validator.Validate(recordCollection.CSVData);
		this.existingRecordRetriever.Retrieve(recordCollection);
		
		this.eventBuilder.Build(recordCollection);
		this.assetBuilder.Build(recordCollection);

		this.recordUpserter.InsertEvents(recordCollection);
		this.recordUpserter.UpdateAssets(recordCollection);
	}
}