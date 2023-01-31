public class Vista_EnhancedDbActor {
	private final Vista_PairedListPopulator pairedListPopulator;
	private final Vista_EnhancedDbSaver_I databaseSaver;
	private final Vista_RequestCollectionRemover requestCollectionRemover;


	public Vista_EnhancedDbActor(Vista_PairedListPopulator pairedListPopulator,
		Vista_EnhancedDbSaver_I databaseSaver,
		Vista_RequestCollectionRemover requestCollectionRemover)
	{
		this.pairedListPopulator = pairedListPopulator;
		this.databaseSaver = databaseSaver;
		this.requestCollectionRemover = requestCollectionRemover;
	}


	public void Save(Map<String, SObject> recordMap, Vista_RequestCollection requestCollection)
	{
		if(recordMap == null || recordMap.Size() == 0) { return; }

		List<String> keys = new List<String>();
		List<SObject> records = new List<SObject>();
		this.pairedListPopulator.PopulatePairedLists(recordMap, keys, records);
		
		Set<String> erroneousKeys = this.databaseSaver.Save(keys, records, requestCollection);

		this.requestCollectionRemover.RemoveByVistaOrderNumber(erroneousKeys, requestCollection);
	}
}