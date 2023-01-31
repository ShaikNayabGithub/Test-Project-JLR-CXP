@isTest
public class CollectionUtilities_T {
	static testMethod void MergeSets_ReturnsEmptySet_GivenEmptyList()
	{
		List<Set<Id>> input = new List<Set<Id>>();

		Set<Id> output = CollectionUtilities.MergeSets(input);

		System.assertEquals(0, output.Size());
	}

	static testMethod void MergeSets_ReturnsSetSize3_GivenListOfSetsSize2And1And0()
	{
		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();
		Account account3 = TestClass_AccountCreator.CreatePersonAccount();

		Set<Id> set1 = new Set<Id>{ account1.Id, account2.Id };
		Set<Id> set2 = new Set<Id>{ account3.Id };
		Set<Id> set3 = new Set<Id>{};

		List<Set<Id>> input = new List<Set<Id>>{ set1, set2, set3 };

		Set<Id> output = CollectionUtilities.MergeSets(input);

		System.assertEquals(3, output.Size());
	}

	static testMethod void MergeSets_ReturnsSetSize1_Given3SetsWithSameId()
	{
		Account account1 = TestClass_AccountCreator.CreatePersonAccount();

		Set<Id> set1 = new Set<Id>{ account1.Id };
		Set<Id> set2 = new Set<Id>{ account1.Id };
		Set<Id> set3 = new Set<Id>{ account1.Id };

		List<Set<Id>> input = new List<Set<Id>>{ set1, set2, set3 };

		Set<Id> output = CollectionUtilities.MergeSets(input);

		System.assertEquals(1, output.Size());
	}

	static testMethod void Batch_ReturnsEmptyList_GivenEmptyListAnd1()
	{
		Integer batchSize = 1;
		List<SObject> input = new List<SObject>{ };

		List<List<SObject>> output = CollectionUtilities.Batch(input, batchSize);

		System.assertEquals(0, output.Size());
	}

	static testMethod void Batch_ReturnsListOf1_GivenListSize1And1()
	{
		Integer batchSize = 1;
		Integer recordCount = 1;
		List<SObject> input = CreateList(recordCount);

		List<List<SObject>> output = CollectionUtilities.Batch(input, batchSize);

		System.assertEquals(1, output.Size());
	}

	static testMethod void Batch_ReturnsSubListOf1_GivenListSize1And1()
	{
		Integer batchSize = 1;
		Integer recordCount = 1;
		List<SObject> input = CreateList(recordCount);

		List<List<SObject>> output = CollectionUtilities.Batch(input, batchSize);

		System.assertEquals(1, output[0].Size());
	}

	static testMethod void Batch_Returns2ndSubListOf50_GivenListSize100And50()
	{
		Integer batchSize = 50;
		Integer recordCount = 100;
		List<SObject> input = CreateList(recordCount);

		List<List<SObject>> output = CollectionUtilities.Batch(input, batchSize);

		System.assertEquals(50, output[1].Size());
	}

	static testMethod void Batch_Returns3rdSubListOf20_GivenListSize120And50()
	{
		Integer batchSize = 50;
		Integer recordCount = 120;
		List<SObject> input = CreateList(recordCount);

		List<List<SObject>> output = CollectionUtilities.Batch(input, batchSize);

		System.assertEquals(20, output[2].Size());
	}


	private static List<SObject> CreateList(Integer recordCount)
	{
		List<SObject> sobjectList = new List<SObject>();

		for(Integer i = 0; i < recordCount; i++) {
			sobjectList.add(new Lead());
		}

		return sobjectList;
	}
}