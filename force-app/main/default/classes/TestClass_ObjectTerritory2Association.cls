@isTest
public class TestClass_ObjectTerritory2Association {
	private static final String ASSOCIATION_REASON = 'Territory2Manual';


	public static ObjectTerritory2Association Build(SObject associatedRecord, Territory2 territory)
	{
		return new ObjectTerritory2Association(
			ObjectId = associatedRecord.Id,
			Territory2Id = territory.Id,
			AssociationCause = ASSOCIATION_REASON
		);
	}

	public static ObjectTerritory2Association Create(SObject associatedRecord, Territory2 territory)
	{
		ObjectTerritory2Association association = Build(associatedRecord, territory);
		insert association;
		return association;
	}
}