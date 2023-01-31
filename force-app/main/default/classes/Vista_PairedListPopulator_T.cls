@isTest
public class Vista_PairedListPopulator_T {
	static testmethod void PopulatePairedLists_AddsNothingToObjectList_GivenEmptyMap()
	{
		Vista_PairedListPopulator pairedListPopulator = new Vista_PairedListPopulator();


		Map<String, SObject> recordMap = new Map<String, SObject>();
		List<String> out_keys = new List<String>();
		List<SObject> out_records = new List<SObject>();


		pairedListPopulator.PopulatePairedLists(recordMap, out_keys, out_records);

		System.assertEquals(0, out_records.Size());
	}

	static testmethod void PopulatePairedLists_AddsNothingToKeyList_GivenEmptyMap()
	{
		Vista_PairedListPopulator pairedListPopulator = new Vista_PairedListPopulator();


		Map<String, SObject> recordMap = new Map<String, SObject>();
		List<String> out_keys = new List<String>();
		List<SObject> out_records = new List<SObject>();


		pairedListPopulator.PopulatePairedLists(recordMap, out_keys, out_records);

		System.assertEquals(0, out_keys.Size());
	}

	static testmethod void PopulatePairedLists_AddsK1ToKeyList_GivenMapContainingKeyK1()
	{
		Vista_PairedListPopulator pairedListPopulator = new Vista_PairedListPopulator();


		String key1 = 'k1';
		SObject contact1 = new Contact();

		Map<String, SObject> recordMap = new Map<String, SObject>{
			key1 => contact1 };
		List<String> out_keys = new List<String>();
		List<SObject> out_records = new List<SObject>();


		pairedListPopulator.PopulatePairedLists(recordMap, out_keys, out_records);

		System.assertEquals(key1, out_keys[0]);
	}

	static testmethod void PopulatePairedLists_AddsContact1ToObjectList_GivenMapContainingContact1()
	{
		Vista_PairedListPopulator pairedListPopulator = new Vista_PairedListPopulator();


		String key1 = 'k1';
		String name1 = 'c1';
		SObject contact1 = new Contact(FirstName=name1);

		Map<String, SObject> recordMap = new Map<String, SObject>{
			key1 => contact1 };
		List<String> out_keys = new List<String>();
		List<SObject> out_records = new List<SObject>();


		pairedListPopulator.PopulatePairedLists(recordMap, out_keys, out_records);

		System.assertEquals(name1, ((Contact)out_records[0]).FirstName);
	}
}