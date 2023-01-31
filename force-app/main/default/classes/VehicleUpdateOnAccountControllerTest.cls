@isTest
public class VehicleUpdateOnAccountControllerTest {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    static testmethod void getLoggedInUserAccountId_Test() {
        String returnValue = VehicleUpdateOnAccountController.getLoggedInUserAccountId();
        System.assertEquals('Not Community User', returnValue);
    }
    static testmethod void getAccountAssetRoles_Test() {
         Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        insert retailerAccount;
        Asset testAsset = new Asset(Name='test', AccountId=retailerAccount.Id, Brand__c =makeVehicle.Id);
        insert testAsset;
        VehicleUpdateOnAccountController.getAccountAssetRoles(retailerAccount.Id);
        try{
            VehicleUpdateOnAccountController.changeAssetOwner(testAsset.Id);
        }catch(exception e){
            
        }
       // System.assertEquals(0, rolesList.size());
    }
    static testmethod void getAssetRoleRecordTypeLists_Test() {
        List<recordType> rolesRecordTypeList = VehicleUpdateOnAccountController.getRoleRecordTypeList();
        System.assertNotEquals(0, rolesRecordTypeList.size());
    }
    
}