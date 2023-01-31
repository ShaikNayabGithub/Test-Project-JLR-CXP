public class Vista_EnhancedDbActor_Handler_F {
	public Vista_EnhancedDbActor_Handler Create()
	{
		Vista_ErrorWriter errorWriter = new Vista_ErrorWriter();

		Vista_EnhancedDbSaver_I enhancedDbDeleter = new Vista_EnhancedDbDeleter(errorWriter);
		Vista_EnhancedDbSaver_I enhancedDbInserter = new Vista_EnhancedDbSaver_Insert(errorWriter);
		Vista_EnhancedDbSaver_I enhancedDbUpdater = new Vista_EnhancedDbSaver_Update(errorWriter);

		Vista_PairedListPopulator pairedListPopulator = new Vista_PairedListPopulator();
		Vista_RequestCollectionRemover requestCollectionRemover = new Vista_RequestCollectionRemover();

		Vista_EnhancedDbActor inserter = new Vista_EnhancedDbActor(pairedListPopulator, enhancedDbInserter, 
				requestCollectionRemover);
		Vista_EnhancedDbActor updater = new Vista_EnhancedDbActor(pairedListPopulator, enhancedDbUpdater, 
				requestCollectionRemover);
		Vista_EnhancedDbActor deleter = new Vista_EnhancedDbActor(pairedListPopulator, enhancedDbDeleter, 
				requestCollectionRemover);

		return new Vista_EnhancedDbActor_Handler(inserter, updater, deleter);
	}
}