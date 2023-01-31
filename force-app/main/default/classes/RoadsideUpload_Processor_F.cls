public class RoadsideUpload_Processor_F {
	public RoadsideUpload_Processor Create()
	{
		RoadsideUpload_ExistingRecordRetriever_F existingRecordRetrieverFactory = new RoadsideUpload_ExistingRecordRetriever_F();
		RoadsideUpload_EventBuilder_F eventBuilderFactory = new RoadsideUpload_EventBuilder_F();
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();
		RoadsideUpload_ErrorProcessor errorProcessor = new RoadsideUpload_ErrorProcessor();

		RoadsideUpload_RowValidator validator = new RoadsideUpload_RowValidator();
		RoadsideUpload_ExistingRecordRetriever existingRecordRetriever = existingRecordRetrieverFactory.Create();
		RoadsideUpload_EventBuilder eventBuilder = eventBuilderFactory.Create();
		RoadsideUpload_AssetBuilder assetBuilder = new RoadsideUpload_AssetBuilder(assetGetter);
		RoadsideUpload_Upserter recordUpserter = new RoadsideUpload_Upserter(pairedListPopulator, errorProcessor);

		return new RoadsideUpload_Processor(validator, existingRecordRetriever, eventBuilder, assetBuilder, 
				recordUpserter);
	}
}