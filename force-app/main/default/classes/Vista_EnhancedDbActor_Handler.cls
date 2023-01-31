public class Vista_EnhancedDbActor_Handler {
	private final Vista_EnhancedDbActor inserter;
	private final Vista_EnhancedDbActor updater;
	private final Vista_EnhancedDbActor deleter;


	public Vista_EnhancedDbActor_Handler(Vista_EnhancedDbActor inserter, Vista_EnhancedDbActor updater,
			Vista_EnhancedDbActor deleter)
	{
		this.inserter = inserter;
		this.updater = updater;
		this.deleter = deleter;
	}


	//Salesforce cannot handle upsert of SObject collection, hence the slightly expanded logic here
	public void UpsertRecords(Map<String, SObject> recordMap, Vista_RequestCollection requestCollection)
	{
		Map<String, SObject> insertMap = new Map<String, SObject>();
		Map<String, SObject> updateMap = new Map<String, SObject>();

		for(String key : recordMap.keySet()) {
			SObject record = recordMap.get(key);
			if(String.isEmpty(record.Id)) {
				insertMap.put(key, record);
			} else {
				updateMap.put(key, record);
			}
		}

		this.CreateRecords(insertMap, requestCollection);
		this.UpdateRecords(updateMap, requestCollection);
	}

	public void CreateRecords(Map<String, SObject> recordMap, Vista_RequestCollection requestCollection)
	{
		this.inserter.Save(recordMap, requestCollection);
	}

	public void UpdateRecords(Map<String, SObject> recordMap, Vista_RequestCollection requestCollection)
	{
		this.updater.Save(recordMap, requestCollection);
	}

	public void DeleteRecords(Map<String, SObject> recordMap, Vista_RequestCollection requestCollection)
	{
		this.deleter.Save(recordMap, requestCollection);
	}
}