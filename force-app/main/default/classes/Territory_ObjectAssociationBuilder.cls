public class Territory_ObjectAssociationBuilder {
	private static final String ASSOCIATION_REASON = 'Territory2Manual';


	public List<ObjectTerritory2Association> Build(Id associatedId, Set<Id> territoryIds, 
			List<ObjectTerritory2Association> existingAssociations)
	{
		List<ObjectTerritory2Association> newTerritoryAssociations = new List<ObjectTerritory2Association>();

		Map<Id, ObjectTerritory2Association> existingAssociationsByTerritoryId = new Map<Id, ObjectTerritory2Association>();
		for(ObjectTerritory2Association existingAssociation : existingAssociations) {
			existingAssociationsByTerritoryId.put(existingAssociation.Territory2Id, existingAssociation);
		}

		for(Id territoryId : territoryIds) {
			if(existingAssociationsByTerritoryId.containsKey(territoryId)) continue;
			ObjectTerritory2Association newTerritoryAssociation = new ObjectTerritory2Association(
				ObjectId = associatedId,
				Territory2Id = territoryId,
				AssociationCause = ASSOCIATION_REASON
			);
			newTerritoryAssociations.add(newTerritoryAssociation);
		}

		return newTerritoryAssociations;
	}
}