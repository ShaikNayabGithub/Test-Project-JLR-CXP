public class Vista_BatchProcessor_F {
	public static Vista_BatchProcessor Create()
	{
		Vista_ExistingRecordRetriever_F recordRetrieverFactory = new Vista_ExistingRecordRetriever_F();
		Vista_EnhancedDbActor_Handler_F dbActorHandlerFactory = new Vista_EnhancedDbActor_Handler_F();
		Vista_OrderBuilder_F orderBuilderFactory = new Vista_OrderBuilder_F();
		Vista_AssetBuilder_F assetBuilderFactory = new Vista_AssetBuilder_F();

		Vista_EntityRetriever_I existingRecordRetriever = recordRetrieverFactory.Create();
    	Vista_EnhancedDbActor_Handler enhancedDbActorHandler = dbActorHandlerFactory.Create();
    	Vista_OrderBuilder orderBuilder = orderBuilderFactory.Create();
    	Vista_AssetBuilder assetBuilder = assetBuilderFactory.Create();
    	Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();

		return new Vista_BatchProcessor(existingRecordRetriever, enhancedDbActorHandler, orderBuilder,
				assetBuilder, orderItemBuilder);
	}
}