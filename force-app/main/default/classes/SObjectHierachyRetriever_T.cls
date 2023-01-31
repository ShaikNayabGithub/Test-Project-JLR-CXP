@isTest
public class SObjectHierachyRetriever_T {
	static testMethod void RetrieveHierachy_RetrievesNoRecords_GivenEmptyCollection()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();


		hierachyRetriever.RetrieveHierachy(collection, idField, parentIdField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(0, collection.Size());
	}

	static testMethod void RetrieveHierachy_RetrievesParentAccount2ByAccount2Id_GivenAccount1AndParentIdFieldAndIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		update account1;

		collection.put(account1.Id, account1);


		hierachyRetriever.RetrieveHierachy(collection, parentIdField, idField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account2.Id, collection.get(account2.Id).RecordsById.get(account2.Id).Id);
	}

	static testMethod void RetrieveHierachy_RetrievesParentAccount2ByAccount1Id_GivenAccount1AndParentIdFieldAndIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		update account1;

		collection.put(account1.Id, account1);


		hierachyRetriever.RetrieveHierachy(collection, parentIdField, idField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account2.Id, collection.get(account1.Id).RecordsById.get(account2.Id).Id);
	}

	static testMethod void RetrieveHierachy_PreservesParentAccount1ByAccount1Id_GivenAccount1AndParentIdFieldAndIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		update account1;

		collection.put(account1.Id, account1);


		hierachyRetriever.RetrieveHierachy(collection, parentIdField, idField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account1.Id, collection.get(account1.Id).RecordsById.get(account1.Id).Id);
	}

	static testMethod void RetrieveHierachy_RetrievesChildAccount1ByAccount1Id_GivenParentAccount2AndIdFieldAndParentIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		update account1;

		collection.put(account2.Id, account2);


		hierachyRetriever.RetrieveHierachy(collection, idField, parentIdField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account1.Id, collection.get(account1.Id).RecordsById.get(account1.Id).Id);
	}

	static testMethod void RetrieveHierachy_RetrievesChildAccount1ByAccount2Id_GivenParentAccount2AndIdFieldAndParentIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		update account1;

		collection.put(account2.Id, account2);


		hierachyRetriever.RetrieveHierachy(collection, idField, parentIdField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account1.Id, collection.get(account2.Id).RecordsById.get(account1.Id).Id);
	}

	static testMethod void RetrieveHierachy_PreservesChildAccount2ByAccount2Id_GivenParentAccount2AndIdFieldAndParentIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		update account1;

		collection.put(account2.Id, account2);


		hierachyRetriever.RetrieveHierachy(collection, idField, parentIdField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account2.Id, collection.get(account2.Id).RecordsById.get(account2.Id).Id);
	}

	static testMethod void RetrieveHierachy_ReturnsParentAccount2ByAccount1Id_GivenAccount1AndParentAccount2And3ExistAndParentIdFieldAndIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		Account account3 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		account2.ParentId = account3.Id;
		update new List<Account>{ account1, account2 } ;

		collection.put(account1.Id, account1);


		hierachyRetriever.RetrieveHierachy(collection, parentIdField, idField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account2.Id, collection.get(account1.Id).RecordsById.get(account2.Id).Id);
	}

	static testMethod void RetrieveHierachy_ReturnsParentAccount3ByAccount1Id_GivenAccount1AndParentAccount2And3ExistAndParentIdFieldAndIdField()
	{
		SObjectHierachyRetriever hierachyRetriever = new SObjectHierachyRetriever();

		Schema.DescribeFieldResult idField = Schema.Account.Id.getDescribe();
		Schema.DescribeFieldResult parentIdField = Schema.Account.ParentId.getDescribe();

		SObjectHierachyCollection collection = new SObjectHierachyCollection();

		Account account1 = TestClass_AccountCreator.CreateRetailer();
		Account account2 = TestClass_AccountCreator.CreateRetailer();
		Account account3 = TestClass_AccountCreator.CreateRetailer();
		account1.ParentId = account2.Id;
		account2.ParentId = account3.Id;
		update new List<Account>{ account1, account2 } ;

		collection.put(account1.Id, account1);


		hierachyRetriever.RetrieveHierachy(collection, parentIdField, idField, new Set<Schema.DescribeFieldResult>());


		System.assertEquals(account3.Id, collection.get(account1.Id).RecordsById.get(account3.Id).Id);
	}
}