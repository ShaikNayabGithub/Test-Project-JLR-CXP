@isTest
public class SObjectHierachyCollection_T {
	static testMethod void Put_AddsObjectToCollection_GivenAccount1KeyAndAccount1()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();


		collection.put(account1.Id, account1);


		SObjectHierachy containingHierachy = collection.get(account1.Id);

		System.assertEquals(account1, containingHierachy.RecordsById.get(account1.Id));
	}

	static testMethod void Put_AddsAccount1ToCollectionWithAccount2AsKey_GivenAccount2KeyAndAccount1()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();


		collection.put(account2.Id, account1);


		SObjectHierachy containingHierachy = collection.get(account2.Id);

		System.assertEquals(account1, containingHierachy.RecordsById.get(account1.Id));
	}

	static testMethod void Put_AddsAccount1ToCollectionWithAccount1AsKey_GivenAccount2KeyAndAccount1()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();


		collection.put(account2.Id, account1);


		SObjectHierachy containingHierachy = collection.get(account1.Id);

		System.assertEquals(account1, containingHierachy.RecordsById.get(account1.Id));
	}

	static testMethod void Put_AddsAccount1ToSameCollectionAsAccount2_GivenAccount2AddedAndAccount1AddedWithAccount2Key()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();


		collection.put(account2.Id, account2);
		collection.put(account2.Id, account1);


		SObjectHierachy containingHierachy1 = collection.get(account1.Id);
		SObjectHierachy containingHierachy2 = collection.get(account2.Id);

		System.assertEquals(containingHierachy1, containingHierachy2);
	}

	static testMethod void PutAll_AddsAccount1_GivenAccount1AndAccount2()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		SObjectHierachy containingHierachy = collection.get(account1.Id);

		System.assertEquals(account1, containingHierachy.RecordsById.get(account1.Id));
	}

	static testMethod void PutAll_AddsAccount2_GivenAccount1AndAccount2()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		SObjectHierachy containingHierachy = collection.get(account2.Id);

		System.assertEquals(account2, containingHierachy.RecordsById.get(account2.Id));
	}	

	static testMethod void PutAll_DoesNotAddAccount1ToAccount2Hierachy_GivenAccount1AndAccount2()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		SObjectHierachy containingHierachy = collection.get(account2.Id);

		System.assertEquals(null, containingHierachy.RecordsById.get(account1.Id));
	}

	static testMethod void Values_ReturnsAccount1_GivenAccount1AndAccount2Added()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		List<SObject> accounts = collection.values();
		Map<Id, SObject> resultMap = new Map<Id, SObject>(accounts);

		System.assert(resultMap.containsKey(account1.Id));
	}

	static testMethod void Values_ReturnsAccount2_GivenAccount1AndAccount2Added()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		List<SObject> accounts = collection.values();
		Map<Id, SObject> resultMap = new Map<Id, SObject>(accounts);

		System.assert(resultMap.containsKey(account2.Id));
	}

	static testMethod void KeySet_ReturnsAccount1Id_GivenAccount1AndAccount2Added()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		Set<Id> results = collection.keySet();

		System.assert(results.contains(account1.Id));
	}

	static testMethod void KeySet_ReturnsAccount2Id_GivenAccount1AndAccount2Added()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		Set<Id> results = collection.keySet();

		System.assert(results.contains(account2.Id));
	}

	static testMethod void Size_Returns2_GivenAccount1AndAccount2Added()
	{
		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreatePersonAccount();
		Account account2 = TestClass_AccountCreator.CreatePersonAccount();

		Map<Id, Account> accountMap = new Map<Id, Account>{
			account1.Id => account1,
			account2.Id => account2 };


		collection.putAll(accountMap);


		Integer result = collection.Size();

		System.assertEquals(2, result);
	}
}