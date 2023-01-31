/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		01/06/2021			CXPD-1005: Test class for DeleteCancelledAssetBatch and ScheduleDeleteCancelledAssetBatch
* 
*/
@isTest
public class DeleteCancelledAssetBatchTest {
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();

    public static testMethod void deleteAsset(){
        User portalUser = TestUtility.createPortaluser('India','Sales Executive');
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Product2 p2 = new product2(name = 'TestProduct',Model_Alternative__c = 'F-Type',Family = 'Vehicle');
        insert p2;
        Asset objAsset = new Asset(Name = 'Test', Registration_Number__c ='REG321', Brand__c = makeVehicle.Id, Product2Id = p2.Id, Vista_Status__c = 'Order Cancelled');
        System.RunAs(portalUser){
            User loggedinUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id = :userinfo.getUserId()];
            objAsset.AccountId = loggedinUser.AccountId;
            objAsset.ContactId = loggedinUser.ContactId;
            insert objAsset;
        }
        
        DeleteCancelledAssetBatch deleteAssetOrderBatch = new DeleteCancelledAssetBatch();
        Test.startTest();        
        Database.executeBatch(deleteAssetOrderBatch, 200);
        Test.stopTest();
        
        List<Asset> cancelledAssets = [SELECT Id FROM Asset WHERE Vista_Status__c = 'Order Cancelled'];
        System.assertEquals(0, cancelledAssets.size());
    }   
    
    public static testMethod void scheduleDeleteAsset(){
        Test.startTest();
        ScheduleDeleteCancelledAssetBatch scheduleDelete = new ScheduleDeleteCancelledAssetBatch();
        String cronExp = '0 0 2 * * ?'; 
        system.schedule('Test ScheduleDeleteCancelledAssetBatch', cronExp, scheduleDelete); 
        Test.stopTest();
    }
}