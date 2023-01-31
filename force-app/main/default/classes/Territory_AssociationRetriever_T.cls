@isTest
public class Territory_AssociationRetriever_T {
	static testmethod void RetrieveByAssociated_ReturnsEmptyMap_GivenEmptyList()
	{
		Territory_AssociationRetriever associationRetriever = new Territory_AssociationRetriever();

		List<SObject> associatedRecords = new List<SObject>();

		Map<Id, List<ObjectTerritory2Association>> results = associationRetriever.RetrieveByAssociated(associatedRecords);

		System.assertEquals(0, results.Size());
	}

	static testmethod void RetrieveByAssociated_ReturnsAccount1ToTerritory1AssociationByAccount1Id_GivenAccount1ToTerritory1AssociationExistsAndAccount1()
	{
		Territory_AssociationRetriever associationRetriever = new Territory_AssociationRetriever();

		Territory2 territory = [SELECT Id FROM Territory2 LIMIT 1];
		
        Account account1 = TestClass_AccountCreator.CreateRetailer();

    	ObjectTerritory2Association territoryAssociation1 = TestClass_ObjectTerritory2Association.Create(account1, 
    			territory);

		List<SObject> associatedRecords = new List<SObject> { account1 };


		Map<Id, List<ObjectTerritory2Association>> results = associationRetriever.RetrieveByAssociated(associatedRecords);


		System.assertEquals(territoryAssociation1.Id, results.get(account1.Id)[0].Id);
	}

	static testmethod void RetrieveByAssociated_Returns2AssociationsByAccount1Id_GivenAccount1ToTerritory1And2AssociationsExistsAndAccount1()
	{
		Territory_AssociationRetriever associationRetriever = new Territory_AssociationRetriever();

		List<Territory2> territories = [SELECT Id FROM Territory2 LIMIT 2];
		
        Account account1 = TestClass_AccountCreator.CreateRetailer();
        
    	ObjectTerritory2Association territoryAssociation1 = TestClass_ObjectTerritory2Association.Build(account1, 
    			territories[0]);
    	ObjectTerritory2Association territoryAssociation2 = TestClass_ObjectTerritory2Association.Build(account1, 
    			territories[1]);
    	insert new List<ObjectTerritory2Association> { territoryAssociation1, territoryAssociation2 };

		List<SObject> associatedRecords = new List<SObject> { account1 };


		Map<Id, List<ObjectTerritory2Association>> results = associationRetriever.RetrieveByAssociated(associatedRecords);


		System.assertEquals(2, results.get(account1.Id).Size());
	}
}