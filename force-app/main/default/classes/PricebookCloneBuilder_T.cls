@isTest
private class PricebookCloneBuilder_T 
{
	Private List<Pricebook2> pricebooks;
	Private List<Product2> products;	
	Private List<PricebookEntry> pricebookEntries;
		
	private void CreatePriceBooksHelper(Integer numPriceBooks){
		pricebooks = new List<Pricebook2>(); 

		Pricebook2 stdPricebook = new PriceBook2(
			Id = Test.getStandardPricebookId(),
			IsActive = true		
		);		
		pricebooks.add(stdPricebook);

		for(Integer i = 0; i < numPriceBooks; i++)
		{
			Pricebook2 pricebook = new PriceBook2();
			pricebook.Name = 'Pricebook ' + i;
			pricebooks.add(pricebook);
		}
		upsert pricebooks;		
	}

	private void CreateProductHelper(Integer numProducts)
	{		
		products = new List<Product2>(); 

		for(Integer i = 0; i < numProducts; i++)
		{
			Product2 product = new Product2();
			product.Name = 'Product ' + i;
			products.add(product);
		}
		insert products;
	}

	private void CreatePricebookEntries()
	{
		upsert pricebookEntries;
	}

	private void BuildPricebookEntry(Id productId, Id pricebookId, String currencyCode)
	{
		pricebookEntries = new List<PricebookEntry>();
		
		PricebookEntry stdPricebookEntry = new PricebookEntry();
		stdPricebookEntry.Pricebook2Id = pricebooks[0].id;
		stdPricebookEntry.Product2Id = productId;
		stdPricebookEntry.UnitPrice = 0;
		stdPricebookEntry.CurrencyIsoCode = currencyCode;
		pricebookEntries.add(stdPricebookEntry);

		if(pricebookId != null)
		{
			PricebookEntry pricebookEntry = new PricebookEntry();
			pricebookEntry.Pricebook2Id = pricebookId;
			pricebookEntry.Product2Id = productId;
			pricebookEntry.UnitPrice = 0;
			pricebookEntry.CurrencyIsoCode = currencyCode;
			pricebookEntries.add(pricebookEntry);
		}		
	}
	
	@isTest
	private static void CreateStandardPricebookEntry_Clones2Records_GivenUSDPricebookSettings() 
	{
		PricebookCloneBuilder_T testable = new PricebookCloneBuilder_T();
		testable.CreateProductHelper(1);
		testable.CreatePriceBooksHelper(3);
		testable.BuildPricebookEntry(testable.products[0].id, testable.pricebooks[1].id,'GBP');
		testable.CreatePricebookEntries();

		Pricebook_Clone__c cloneSetting = new Pricebook_Clone__c(
			Source_Pricebook__c = testable.pricebooks[1].Name,
			Destination_Pricebook__c = testable.pricebooks[2].Name,
			Destination_Currency__c = 'USD',
			Name = testable.pricebooks[1].Name +':' + testable.pricebooks[2].Name
		);
		insert cloneSetting;

		Test.startTest();
				
		PricebookCloneBuilder clone = new PricebookCloneBuilder(cloneSetting);
		List<PricebookEntry> createdEntries = clone.Build();
		insert createdEntries;
		Test.stopTest();

		System.assert(createdEntries.size() == 2); 			
	}

	@isTest
	private static void ProcessExistingRecords_CreatesNoRecords_GivenEntryWhichAlreadyExists() 
	{
		PricebookCloneBuilder_T testable = new PricebookCloneBuilder_T();
		testable.CreateProductHelper(2);
		testable.CreatePriceBooksHelper(3);
		testable.BuildPricebookEntry(testable.products[0].Id, testable.pricebooks[1].Id,'GBP');
		testable.BuildPricebookEntry(testable.products[0].Id, testable.pricebooks[2].Id,'GBP');
		testable.BuildPricebookEntry(testable.products[1].Id, testable.pricebooks[2].Id,'GBP');
		testable.CreatePricebookEntries();

		Pricebook_Clone__c cloneSetting = new Pricebook_Clone__c(
			Source_Pricebook__c = testable.pricebooks[1].Name,
			Destination_Pricebook__c = testable.pricebooks[2].Name,
			Destination_Currency__c = 'GBP',
			Name = testable.pricebooks[1].Name +':' + testable.pricebooks[2].Name
		);
		insert cloneSetting;

		Test.startTest();
				
		PricebookCloneBuilder clone = new PricebookCloneBuilder(cloneSetting);
		List<PricebookEntry> createdEntries = clone.Build();
		insert createdEntries;
		Test.stopTest();

		System.assert(createdEntries.size() == 0); 			
	}
	
	
	
	
}