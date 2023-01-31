@isTest
public class Asset_ColourGroupSetter_T {
	static testmethod void SetColourGroupAsset_DoesNothing_GivenEmptyList()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		List<Asset> assets = new List<Asset>{};

		colourGroupSetter.SetColourGroup(assets);

		System.assert(true);
	}

	static testmethod void SetColourGroupAssetAssetMap_DoesNothing_GivenEmptyListAndEmptyMap()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		List<Asset> assets = new List<Asset>{};
		Map<Id, Asset> oldMap = new Map<Id, Asset>{};

		colourGroupSetter.SetColourGroup(assets, oldMap);

		System.assert(true);
	}

	static testmethod void SetColourGroupAsset_DoesNotSetColourGroup_GivenAssetWithNoColour()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		Asset asset1 = new Asset();
		List<Asset> assets = new List<Asset>{ asset1 };

		colourGroupSetter.SetColourGroup(assets);

		System.assert(String.isBlank(asset1.Exterior_Colour_Group__c));
	}

	static testmethod void SetColourGroupAsset_DoesSetsColourGroupToOther_GivenAssetWithUnmappedColour()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		Asset asset1 = new Asset(Exterior_Colour__c = 'unknown');
		List<Asset> assets = new List<Asset>{ asset1 };


		colourGroupSetter.SetColourGroup(assets);


		System.assertEquals('Other', asset1.Exterior_Colour_Group__c);
	}

	static testmethod void SetColourGroupAsset_DoesSetsColourGroupToWhite_GivenAssetWithMappedColourFujiWhite()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		String colour = 'Fuji White';
		String colourGroup = 'White';

		Colour_Group_Mapping__c mapping = new Colour_Group_Mapping__c(Name = colour, 
				Colour_Group__c = colourGroup);
		insert mapping;

		Asset asset1 = new Asset(Exterior_Colour__c = colour);
		List<Asset> assets = new List<Asset>{ asset1 };


		colourGroupSetter.SetColourGroup(assets);


		System.assertEquals(colourGroup, asset1.Exterior_Colour_Group__c);
	}

	static testmethod void SetColourGroupAsset_DoesSetsColourGroupToOther_GivenAssetWithMappingColourIsBlank()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		String colour = 'Fuji White';
		String colourGroup = 'White';

		Colour_Group_Mapping__c mapping = new Colour_Group_Mapping__c(Name = colour);
		insert mapping;

		Asset asset1 = new Asset(Exterior_Colour__c = colour);
		List<Asset> assets = new List<Asset>{ asset1 };


		colourGroupSetter.SetColourGroup(assets);


		System.assertEquals('Other', asset1.Exterior_Colour_Group__c);
	}

	static testmethod void SetColourGroupAssetAssetMap_DoesSetsColourGroupToWhite_GivenChangedAssetWithMappedColourFujiWhite()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		String colour = 'Fuji White';
		String colourGroup = 'White';

		Colour_Group_Mapping__c mapping = new Colour_Group_Mapping__c(Name = colour, 
				Colour_Group__c = colourGroup);
		insert mapping;

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		insert asset1;
		asset1.Exterior_Colour__c = colour;
		List<Asset> assets = new List<Asset>{ asset1 };

		Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
		oldAssetMap.put(asset1.Id, new Asset(Exterior_Colour_Group__c = 'Other'));


		colourGroupSetter.SetColourGroup(assets, oldAssetMap);


		System.assertEquals(colourGroup, asset1.Exterior_Colour_Group__c);
	}

	static testmethod void SetColourGroupAssetAssetMap_DoesNotSetColourGroup_GivenChangedAssetColourUnchanged()
	{
		Asset_ColourGroupSetter colourGroupSetter = new Asset_ColourGroupSetter();

		String colour = 'Fuji White';
		String colourGroup = 'White';
		String oldColourGroup = 'Other';

		Colour_Group_Mapping__c mapping = new Colour_Group_Mapping__c(Name = colour, 
				Colour_Group__c = colourGroup);
		insert mapping;

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		insert asset1;
		asset1.Exterior_Colour__c = colour;
		asset1.Exterior_Colour_Group__c = oldColourGroup;
		List<Asset> assets = new List<Asset>{ asset1 };

		Map<Id, Asset> oldAssetMap = new Map<Id, Asset>();
		oldAssetMap.put(asset1.Id, new Asset(Exterior_Colour__c = colour,
				Exterior_Colour_Group__c = oldColourGroup));


		colourGroupSetter.SetColourGroup(assets, oldAssetMap);


		System.assertEquals(oldColourGroup, asset1.Exterior_Colour_Group__c);
	}
}