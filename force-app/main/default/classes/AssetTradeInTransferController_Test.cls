@isTest
public class AssetTradeInTransferController_Test {
	public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
    
    @isTest
    static void TransferAndTradeInAsset() {
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        User portalUser;
        System.runAs(new User(id = UserInfo.getUserId())){
            portalUser = TestUtility.createPortaluser('Australia','Sales Executive');
        }

        Asset ass = new Asset(Name='Test', Brand__c=makeVehicle.Id, VIN__c='1234567890', Traded_In__c=false);
        System.RunAs(portalUser){
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
            ass.AccountId = loggedinUser.AccountId;
            ass.ContactId = loggedinUser.ContactId;
            insert ass;
        }
        AssetTradeInTransferController.tradeInAsset('1234567890','Trade In & Transfer');
        ass = [SELECT Traded_In__c FROM Asset WHERE Id = :ass.Id];
        System.assertEquals(true, ass.Traded_In__c);
    }
    
    @isTest
    static void TradedInAssets() {
        List<Asset> AssetList = new List<Asset>();
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        User portalUser;
        System.runAs(new User(id = UserInfo.getUserId())){
            portalUser = TestUtility.createPortaluser('India','Sales Executive');
        }
       
        Asset ass = new Asset(Name='Test', Brand__c=makeVehicle.Id, VIN__c='1234567890', Traded_In__c=true);
        
        System.RunAs(portalUser){
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
			ass.AccountId = loggedinUser.AccountId;
            ass.ContactId = loggedinUser.ContactId;
            insert ass;
            AssetTradeInTransferController.tradeInAsset('1234567890','Trade In & Transfer');
        }
        
        List<Asset> QueryAsset = new List<Asset>([SELECT Traded_In__c FROM Asset WHERE VIN__c = '1234567890']);
        System.assertEquals(true, QueryAsset[0].Traded_In__c);
    }
}