public class Vista_PairedListPopulator {
	public void PopulatePairedLists(Map<String, SObject> recordMap, List<String> out_keys, List<SObject> out_records)
	{
		for(String key : recordMap.keySet()){
			out_keys.add(key);
			out_records.add(recordMap.get(key));
		}
	}
}