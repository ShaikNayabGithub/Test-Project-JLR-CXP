@isTest
public class SearchFirst_AssetController_Test {
    static testmethod void Search_AddsTestAssetToKnownAssets_GivenTestAssetIsVisibleToUserAndVINIsEqualToAssetIdentifier()
    {
        SearchFirst_AssetController controller = new SearchFirst_AssetController();
        controller.pageController = new SearchFirst_HostController();
        controller.pageController.searchParameters = new SearchFirstSearchParameters();
        
        Asset asset = TestClass_AssetBuilder.BuildVehicle();
        asset.VIN__c = 'test';
        insert asset;
        controller.pageController.searchParameters.AssetIdentifier = asset.VIN__c;
        
        controller.Search();
        
        Map<Id, Asset> knownAssets = new Map<Id, Asset>(controller.knownAssets);
        System.assert(knownAssets.ContainsKey(Asset.Id));
    }
    
    static testmethod void Search_AddsTestAssetToKnownAssets_GivenTestAssetIsVisibleToUserAndShortVINIsEqualToAssetIdentifier()
    {
        SearchFirst_AssetController controller = new SearchFirst_AssetController();
        controller.pageController = new SearchFirst_HostController();
        controller.pageController.searchParameters = new SearchFirstSearchParameters();
        
        Asset asset = TestClass_AssetBuilder.BuildVehicle();
        asset.Short_VIN__c = 'test';
        insert asset;
        controller.pageController.searchParameters.AssetIdentifier = asset.Short_VIN__c;
        
        controller.Search();
        
        Map<Id, Asset> knownAssets = new Map<Id, Asset>(controller.knownAssets);
        System.assert(knownAssets.ContainsKey(Asset.Id));
    }
    
    static testmethod void Search_AddsTestAssetToKnownAssets_GivenTestAssetIsVisibleToUserAndRegistrationIsEqualToAssetIdentifier()
    {
        SearchFirst_AssetController controller = new SearchFirst_AssetController();
        controller.pageController = new SearchFirst_HostController();
        controller.pageController.searchParameters = new SearchFirstSearchParameters();
        
        Asset asset = TestClass_AssetBuilder.BuildVehicle();
        asset.Registration_Number__c = 'test';
        insert asset;
        controller.pageController.searchParameters.AssetIdentifier = asset.Registration_Number__c;
        
        controller.Search();
        
        Map<Id, Asset> knownAssets = new Map<Id, Asset>(controller.knownAssets);
        System.assert(knownAssets.ContainsKey(Asset.Id));
    }
    
    static testmethod void Reset_ClearsUnknownAssets_GivenPopulatedUnknownAssets()
    {
        SearchFirst_AssetController controller = new SearchFirst_AssetController();
        
        controller.unknownAssets.add(new Asset());
        
        controller.Reset();
        
        System.assertEquals(0, controller.unknownAssets.size());
    }
    
    static testmethod void Reset_ClearsKnownAssets_GivenPopulatedKnownAssets()
    {
        SearchFirst_AssetController controller = new SearchFirst_AssetController();
        
        controller.knownAssets.add(new Asset());
        
        controller.Reset();
        
        System.assertEquals(0, controller.knownAssets.size());
    }
}