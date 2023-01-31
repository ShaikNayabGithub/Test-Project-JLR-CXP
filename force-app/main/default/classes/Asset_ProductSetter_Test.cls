@IsTest
public class Asset_ProductSetter_Test  {
	private final static String PRODUCT2_READONLY_ERROR_MESSAGE = 'Changing Product2 field on Asset directly is not allowed. Please update Derivative instead';

	static testmethod void CreateAsset_PopulatesProduct2_GivenDirivative()
	{
		Asset_ProductSetter productSetter = new Asset_ProductSetter();
		Asset asset = TestClass_AssetBuilder.BuildVehicle(true);		
		insert asset;

		Asset fetchedAsset = [select id, product2id, Derivative__c from Asset where Id=:asset.id];
		System.assertEquals(fetchedAsset.Product2Id, fetchedAsset.Derivative__c);
	}

	static testmethod void CreateAsset_PopulatesProduct2_GivenDirivativeAndProductEmpty()
	{
		Asset_ProductSetter productSetter = new Asset_ProductSetter();
		Asset asset = TestClass_AssetBuilder.BuildVehicle(true);
		asset.product2id = null;		
		insert asset;

		Asset fetchedAsset = [select id, product2id, Derivative__c from Asset where Id=:asset.id];
		System.assertEquals(fetchedAsset.Product2Id, fetchedAsset.Derivative__c);
	}

	static testmethod void UpdateAsset_ThrowsError_WhenUpdatingProduct2()
	{
		Asset_ProductSetter productSetter = new Asset_ProductSetter();
		Asset newAsset = TestClass_AssetBuilder.BuildVehicle(true);		
		insert newAsset;

		newAsset.Product2Id = null;

		try{
			update newAsset;
		}catch(Exception ex){
			System.assert(ex.getMessage().contains(PRODUCT2_READONLY_ERROR_MESSAGE));

			//Assert field
            System.assertEquals(Asset.Product2Id, ex.getDmlFields(0)[0]);
            //Assert Status Code
            System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' ,
                                 ex.getDmlStatusCode(0) );
		}
	}
}