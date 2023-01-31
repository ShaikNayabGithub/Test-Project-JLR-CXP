/**
 * Created by Ethan Sargent on 4/12/19.
 */

@IsTest
private class PicklesOuvServiceTest {

    public static final String getPicklesOUVServiceUrl = '/services/apexrest/v1/Pickles/Ouv/*';

    @TestSetup
    static void testSetup() {
        Account headOffice = TestClass_AccountCreator.CreateRetailer();
        Account dealerAccount = TestClass_AccountCreator.CreateRetailer();
        dealerAccount.Queue_ID__c = 'queueId';
        update dealerAccount;
        headOffice.Name = Constants.HEAD_OFFICE_ACCOUNT_NAME;
        update headOffice;
        List<Asset> assets = TestClass_AssetBuilder.createAssetList(3, headOffice.Id);

        Account account = [SELECT Id, Name FROM Account WHERE Name LIKE '%test%' LIMIT 1];
        PicklesAssignmentRequestDto req = new PicklesAssignmentRequestDto();
        for (Asset ass : assets) {
            req.assetIds.add(ass.Id);
        }
        req.dealerId = account.Id;
        System.assert(PicklesVehicleAssignmentController.reassignAssets(req) == true);
    }


    @IsTest
    static void testBehavior() {
        // ARRANGE
        Datetime dateFrom = System.today().addDays(-1);
        String requestDate = dateFrom.format('yyyy-MM-dd');
        RestRequest req = new RestRequest();
        req.requestURI = System.Url.getSalesforceBaseUrl().toExternalForm() + getPicklesOUVServiceUrl;

        req.params.put('dateFrom', requestDate);

        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf('{}');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        GetPicklesOuvResponseDto response = PicklesOuvService.getAssets();
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(response));
        System.assertNotEquals(null, response);
    }
}