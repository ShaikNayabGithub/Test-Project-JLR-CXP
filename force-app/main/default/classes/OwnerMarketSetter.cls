public class OwnerMarketSetter {
	public MarketByOwnerIdRetriever marketByOwnerIdRetriever = new MarketByOwnerIdRetriever();
	
	private static final String OWNER_ID_FIELD_NAME = Schema.sObjectType.Lead.fields.OwnerId.getName();
	
	
    public void SetMarketFromOwner(List<SObject> records, Schema.SObjectField fieldToSet)
    {
    	Set<String> ownerIds = SObjectUtilities.GetFieldValues(records, OWNER_ID_FIELD_NAME);
    	
    	Map<Id, String> marketsByOwnerId = marketByOwnerIdRetriever.Retrieve(ownerIds);
    	
    	for(SObject record : records) {
    		Id ownerId = (Id)record.get(OWNER_ID_FIELD_NAME);
    		record.put(fieldToSet, marketsByOwnerId.get(ownerId));
    	}
    }
}