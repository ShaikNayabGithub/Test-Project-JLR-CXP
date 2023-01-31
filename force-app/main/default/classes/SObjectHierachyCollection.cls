public class SObjectHierachyCollection {
	private Map<Id, SObjectHierachy> SObjectHierachyByChildIds = new Map<Id, SObjectHierachy>();


	public void PutAll(Map<Id, SObject> recordMap)
	{
		for(Id key : recordMap.keySet()) {
			this.Put(key, recordMap.get(key));
		}
	}

	public void Put(Id key, SObject record)
	{
		SObjectHierachy hierachy = this.SObjectHierachyByChildIds.get(key);

		if(hierachy == null) {
			hierachy = new SObjectHierachy();
			this.SObjectHierachyByChildIds.put(key, hierachy);
		}

		hierachy.RecordsById.put(record.Id, record);
		this.SObjectHierachyByChildIds.put(record.Id, hierachy);
	}
	
	public SObjectHierachy Get(Id recordId)
	{
		return this.SObjectHierachyByChildIds.get(recordId);
	}

	public List<SObject> Values()
	{
		List<SObject> values = new List<SObject>();

		for(Id key : this.SObjectHierachyByChildIds.keySet()) {
			SObjectHierachy sObjectHierachy = this.SObjectHierachyByChildIds.get(key);
			SObject record = sObjectHierachy.RecordsById.get(key);
			if(record == null) { continue; }
			values.add(record);
		}

		return values;
	}

	public Set<Id> KeySet()
	{
		return SObjectHierachyByChildIds.keySet();
	}

	public Integer Size()
	{
		return SObjectHierachyByChildIds.Size();
	}
}