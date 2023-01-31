/**
 * Created by Ethan Sargent on 20/11/19.
 */

@IsTest
private class PicklesVehicleAssignmentControllerTest {
    private static final String ASSET_ROLE_RETAILER_OWNER = 'Retailer_Owner_ex_OUV';
    private static final String RETAILER_OWNER_RECORDTYPE_ID = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get(ASSET_ROLE_RETAILER_OWNER).getRecordTypeId();

    @TestSetup
    static void setup() {
        Account headOffice = TestClass_AccountCreator.CreateRetailer();
        Account dealerAccount = TestClass_AccountCreator.CreateRetailer();
        dealerAccount.Queue_ID__c = 'queueId';
        dealerAccount.Dealer_CI_Code__c = 'test1';
        dealerAccount.Dealer_CI_Code_2__c = 'test2';
        dealerAccount.Country_ISO_Code__c = 'AU';
        update dealerAccount;
        headOffice.Name = Constants.HEAD_OFFICE_ACCOUNT_NAME;
        update headOffice;
        List<Asset> newAssets = TestClass_AssetBuilder.createAssetList(3, headOffice.Id);
        newAssets[0].VIN__c = 'SALGA123456789012345';
        update newAssets[0];
        insert new RDA__c(Account__c = headOffice.Id, Asset__c = newAssets[0].Id, RecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('OUV').getRecordTypeId(),
                Handover_Date__c = Date.today(), Common_Sale_Type__c = 'test',
                Registration_Number__c = 'TEST123', Retail_Offer__c = 'Loyalty Program',
                Submitted_Date__c = System.today(), Submitted_Status__c = 'Completed',
                Common_Type_of_Sale_Code__c = 'CAM');
    }


    @IsTest
    static void getAssetsAssignedToHeadOfficeTest() {
        List<PicklesVehicleRequestDto> vehicles = PicklesVehicleAssignmentController.getAssetsAssignedToHeadOffice('', '');
        System.assertEquals(1, vehicles.size());
    }

    @IsTest
    static void getAssetsAssignedToHeadOfficeTest_matchVIN() {
        List<PicklesVehicleRequestDto> vehicles = PicklesVehicleAssignmentController.getAssetsAssignedToHeadOffice('SALGA123456789012345', '');
        System.assertEquals(1, vehicles.size());
    }

    @IsTest
    static void reassignAssetsTest() {
        List<Asset> assets = new List<Asset>([SELECT Id, Name, AccountId FROM Asset]);

        Account account = [SELECT Id, Name FROM Account WHERE Name LIKE '%test%' LIMIT 1];
        PicklesAssignmentRequestDto req = new PicklesAssignmentRequestDto();
        for (Asset ass : assets) {
            req.assetIds.add(ass.Id);
        }
        req.dealerId = account.Id;
        Test.startTest();
        System.assert(PicklesVehicleAssignmentController.reassignAssets(req) == true);
        Test.stopTest();

        List<Role__c> allRoles = [SELECT Id, RecordType.Name, Account__r.Name FROM Role__c];
        System.debug(JSON.serialize(allRoles));
        //System.assertEquals(3, allRoles.size(), 'No asset Roles created...');
        List<Role__c> assetRoles = [SELECT Id, RecordType.Name, Account__r.Name FROM Role__c WHERE RecordTypeId = :RETAILER_OWNER_RECORDTYPE_ID
        AND (
        (Account__r.Dealer_CI_Code__c != NULL AND Vehicle__r.Brand__r.Name = :Constants.MAKE_NAME_JAGUAR)
        OR
        (Account__r.Dealer_CI_Code_2__c != NULL AND Vehicle__r.Brand__r.Name = :Constants.MAKE_NAME_LAND_ROVER)
        )
                AND Account__r.Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA];
        System.assertEquals(3, assetRoles.size(), 'Created asset Roles not correct ex-OUV status after insertion');

    }

    @IsTest
    static void getDealersFromSearchKeyTest() {
        PicklesDealerRequestDto req = new PicklesDealerRequestDto();
        req.dealerSearchKey = 'test retailer';
        system.debug([SELECT Id,Name,Recordtype.developerName, Queue_ID__c,Record_Sub_Type__c FROM Account]);
        PicklesDealerResponseDto responseDto = PicklesVehicleAssignmentController.getDealersFromSearchKey(req);
        System.assert(responseDto.dealers != null);
        System.assert(responseDto.dealers.size() == 1);
    }

}