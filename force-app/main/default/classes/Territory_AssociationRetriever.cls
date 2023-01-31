public class Territory_AssociationRetriever {
	public Map<Id, List<ObjectTerritory2Association>> RetrieveByAssociated(List<SObject> associatedRecords)
	{
		Map<Id, List<ObjectTerritory2Association>> territoryAssociationsBySObjectId = new Map<Id, List<ObjectTerritory2Association>>();

		Map<Id, SObject> associatedRecordMap = new Map<Id, SObject>(associatedRecords);
		List<ObjectTerritory2Association> objectAssociations = [SELECT ObjectId, Territory2Id 
				FROM ObjectTerritory2Association WHERE ObjectId IN: associatedRecordMap.keySet()];

		for(ObjectTerritory2Association objectAssociation : objectAssociations) {
			List<ObjectTerritory2Association> objectAssociationList = territoryAssociationsBySObjectId.get(objectAssociation.ObjectId);
			if(objectAssociationList == null) {
				objectAssociationList = new List<ObjectTerritory2Association>();
				territoryAssociationsBySObjectId.put(objectAssociation.ObjectId, objectAssociationList);
			}

			objectAssociationList.Add(objectAssociation);
		}

		return territoryAssociationsBySObjectId;
	}
}