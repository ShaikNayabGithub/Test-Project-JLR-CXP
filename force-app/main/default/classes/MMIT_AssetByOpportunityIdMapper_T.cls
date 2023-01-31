@isTest
public class MMIT_AssetByOpportunityIdMapper_T {
	static testmethod void MapAssets_ReturnsEmptyMap_GivenEmptyList()
    {
    	MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();

    	List<Asset> assets = new List<Asset>();


    	Map<String, List<Asset>> outputMap = assetByOpportunityIdMapper.MapAssets(assets);


    	System.assertEquals(0, outputMap.size());
    }

    static testmethod void MapAssets_ReturnsEmptyMap_GivenAssetWithNoOrder()
    {
    	MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();

    	Asset asset1 = new Asset();
    	List<Asset> assets = new List<Asset>{ asset1 };


    	Map<String, List<Asset>> outputMap = assetByOpportunityIdMapper.MapAssets(assets);


    	System.assertEquals(0, outputMap.size());
    }

    static testmethod void MapAssets_ReturnsEmptyMap_GivenAssetWithNoOpportunityIdOnOrder()
    {
    	MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();

    	Asset asset1 = new Asset(Order__r = new Order());
    	List<Asset> assets = new List<Asset>{ asset1 };


    	Map<String, List<Asset>> outputMap = assetByOpportunityIdMapper.MapAssets(assets);


    	System.assertEquals(0, outputMap.size());
    }

    static testmethod void MapAssets_ReturnsAsset1ByOpportunity1_GivenAsset1WithOpportunity1()
    {
    	MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();

    	Opportunity opportunity1 = TestClass_ValidOpportunityBuilder.Build();
    	insert opportunity1;

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id));
    	List<Asset> assets = new List<Asset>{ asset1 };


    	Map<String, List<Asset>> outputMap = assetByOpportunityIdMapper.MapAssets(assets);


    	System.assertEquals(asset1, outputMap.get(opportunity1.Id)[0]);
    }

    static testmethod void MapAssets_ReturnsAsset2ByOpportunity2_GivenAsset1And2And3WithOpportunities1And2And3()
    {
    	MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();

    	Opportunity opportunity1 = TestClass_ValidOpportunityBuilder.Build();
    	Opportunity opportunity2 = TestClass_ValidOpportunityBuilder.Build();
    	Opportunity opportunity3 = TestClass_ValidOpportunityBuilder.Build();
    	insert new List<Opportunity> { opportunity1, opportunity2, opportunity3 };

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id));
    	Asset asset2 = new Asset(Order__r = new Order(OpportunityId = opportunity2.Id));
    	Asset asset3 = new Asset(Order__r = new Order(OpportunityId = opportunity3.Id));
    	List<Asset> assets = new List<Asset>{ asset1, asset2, asset3 };


    	Map<String, List<Asset>> outputMap = assetByOpportunityIdMapper.MapAssets(assets);


    	System.assertEquals(asset2, outputMap.get(opportunity2.Id)[0]);
    }

    static testmethod void MapAssets_ReturnsAsset3ByOpportunity2_GivenAsset1And2And3WithOpportunities1And2And2()
    {
    	MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();

    	Opportunity opportunity1 = TestClass_ValidOpportunityBuilder.Build();
    	Opportunity opportunity2 = TestClass_ValidOpportunityBuilder.Build();
    	insert new List<Opportunity> { opportunity1, opportunity2 };

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id));
    	Asset asset2 = new Asset(Order__r = new Order(OpportunityId = opportunity2.Id));
    	Asset asset3 = new Asset(Order__r = new Order(OpportunityId = opportunity2.Id));
    	List<Asset> assets = new List<Asset>{ asset1, asset2, asset3 };


    	Map<String, List<Asset>> outputMap = assetByOpportunityIdMapper.MapAssets(assets);


    	System.assertEquals(asset3, outputMap.get(opportunity2.Id)[1]);
    }
}