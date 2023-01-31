@isTest
public class LC_AssetRoleExtract_Test {

    @isTest
    static void Controller_ReturnsEmptyList_WhenAssetHasNoAssetRoles() {
        Asset asset = TestClass_AssetBuilder.BuildVehicle();
        insert asset;
        List<Role__c> res = LC_AssetRoleExtract_Controller.getAssetRoles(asset.Id);
        System.assertEquals(0, res.size());
    }
    
    @isTest
    static void Controller_ReturnsListWithOneItem_WhenOpportunityAssetHasOneAssetRole() {
        Role__c ar = TestClass_AssetRoleCreator.Create('Current Owner');
        List<Role__c> res = LC_AssetRoleExtract_Controller.getAssetRoles(ar.Vehicle__c);
        System.assertEquals(1, res.size());
    }
    
}