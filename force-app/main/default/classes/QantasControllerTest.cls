/**
 * Created by Ethan Sargent on 16/10/19.
 */

@IsTest
private class QantasControllerTest {

    @IsTest
    static void QantasFrequentFlyerGetOneRecord()
    {
        // Arrange
        // Set Mock Because some trigger from a different region makes a web service callout
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        Account personAccount = TestClass_AccountCreator.createPersonAccount_Australia();
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        Test.startTest(); // solution to too many soql querys
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity();
        RDA__c rda = TestClass_RDACreater.CreateRDA(opp.Id, null, personAccount.Id, ass.Id);
        Loyalty_Scheme__c scheme = TestClass_LoyaltySchemeCreator.createQantasScheme();
        Loyalty_Points__c points = TestClass_LoyaltyPoints.createLoyaltyPointsQFF(scheme.Id);
        Loyalty_Points_Transaction__c trans = TestClass_LoyaltyPointsTransaction.createTransaction(points.Id, rda.Id);

        GetQantasFrequentFlyerRequestDto req = new GetQantasFrequentFlyerRequestDto();
        req.StartDatetime = Datetime.now().addDays(-1);

        // Act
        //Test.startTest();
        QantasFrequentFlyerResponseDto res = QantasController.FetchQantasFrequentFlyerTransactions(req);
        Test.stopTest();
        // Assert
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.assertEquals(1, res.Data.size());
    }

    @IsTest
    static void QantasBusinessRewardsGetOneRecord() {
        // Arrange
        // Set Mock Because some trigger from a different region makes a web service callout
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        Account corpAccount = TestClass_AccountCreator.GenerateCorporateAccount();
        Contact con = TestClass_ValidContactBuilder.Build(corpAccount);
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle(true);
        Test.startTest(); // solution to too many soql querys
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity();
        RDA__c rda = TestClass_RDACreater.CreateRDA(opp.Id, null, corpAccount.Id, ass.Id, con.Id);
        Loyalty_Scheme__c scheme = TestClass_LoyaltySchemeCreator.createQantasScheme();
        Loyalty_Points__c points = TestClass_LoyaltyPoints.createLoyaltyPointsQBR(scheme.Id);
        Loyalty_Points_Transaction__c trans = TestClass_LoyaltyPointsTransaction.createTransaction(points.Id, rda.Id);

        GetQantasBusinessRewardsRequestDto req = new GetQantasBusinessRewardsRequestDto();
        req.StartDatetime = Datetime.now().addDays(-1);

        // Act
        //Test.startTest();
        QantasBusinessRewardsResponseDto res = QantasController.FetchQantasBusinessRewardsTransactions(req);
        Test.stopTest();
        // Assert
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.assertEquals(1, res.Data.size());
    }

    @IsTest
    public static void createLoyaltyProgramVerificationTest()
    {
        // Arrange
        String body = '{"Data": [{"Type": "BusinessVerificationResult","Id": "","Attributes": {"BusinessTaxationNumber": "12345678901","CardSequenceNumber": 0,"BusinessName": "KV & Sons Pty Ltd","TransactionId": "a3E0Q0000001cJyUAI","BusinessAccountNumber": "0010Q00000lcfqKQAQ","BannerBrand": "","Location": "","TransactionDateStart": "2019-11-28","TransactionDateEnd": "2019-11-28","AmountGross": 0,"DiscountBase": 0,"DiscountBonus": 0,"RebateBase": 0,"RebateBonus": 0,"AmountNet": 0,"PointsEarnedBase": 80000,"PointsEarnedBonus": 0,"PointsEarnedBonusBasis": "","PointsEarnedTotal": 80000,"RecordNumber": 1,"AcceptReject": "R","ReasonForRejection": "INVALID ABN"}},{"Type": "LoyaltyVerificationResult","Id": "","Attributes": {"BusinessTaxationNumber": "12345678901","CardSequenceNumber": 0,"BusinessName": "KV & Sons Pty Ltd","TransactionId": "a3E0Q0000001cJyUAI","BusinessAccountNumber": "0010Q00000lcfqKQAQ","BannerBrand": "","Location": "","TransactionDateStart": "2019-11-28","TransactionDateEnd": "2019-11-28","AmountGross": 0,"DiscountBase": 0,"DiscountBonus": 0,"RebateBase": 0,"RebateBonus": 0,"AmountNet": 0,"PointsEarnedBase": 80000,"PointsEarnedBonus": 0,"PointsEarnedBonusBasis": "","PointsEarnedTotal": 80000,"RecordNumber": 1,"AcceptReject": "R","ReasonForRejection": "INVALID ABN"}}]}';
        CreateLoyaltyVerificationRequestDto req = (CreateLoyaltyVerificationRequestDto)JSON.deserialize(body, CreateLoyaltyVerificationRequestDto.class);

        // Act
        Test.startTest();
        CreateLoyaltyVerificationResponseDto res = QantasController.createLoyaltyProgramVerification(req);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
    }

    @IsTest
    public static void loyaltyVerificationInvalidDate()
    {
        // Arrange
        String body = '{"Data":[{"Type":"BusinessVerificationResult","Id":"","Attributes":{"BusinessTaxationNumber":"12345678901","CardSequenceNumber":0,"BusinessName":"KV&SonsPtyLtd","TransactionId":"a3E0Q0000001cJyUAI","BusinessAccountNumber":"0010Q00000lcfqKQAQ","BannerBrand":"","Location":"","TransactionDateStart":"asdas","TransactionDateEnd":"asdsda","AmountGross":0,"DiscountBase":0,"DiscountBonus":0,"RebateBase":0,"RebateBonus":0,"AmountNet":0,"PointsEarnedBase":80000,"PointsEarnedBonus":0,"PointsEarnedBonusBasis":"","PointsEarnedTotal":80000,"RecordNumber":1,"AcceptReject":"R","ReasonForRejection":"INVALIDABN"}}]}';
        CreateLoyaltyVerificationRequestDto req = (CreateLoyaltyVerificationRequestDto)JSON.deserialize(body, CreateLoyaltyVerificationRequestDto.class);

        // Act
        Test.startTest();
        CreateLoyaltyVerificationResponseDto res = QantasController.createLoyaltyProgramVerification(req);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
    }

    @IsTest
    public static void createLoyaltyProgramVerificationTestService()
    {
        // Arrange
        String body = '{"Data": [{"Type": "BusinessVerificationResult","Id": "","Attributes": {"BusinessTaxationNumber": "12345678901","CardSequenceNumber": 0,"BusinessName": "KV & Sons Pty Ltd","TransactionId": "a3E0Q0000001cJyUAI","BusinessAccountNumber": "0010Q00000lcfqKQAQ","BannerBrand": "","Location": "","TransactionDateStart": "2019-11-28","TransactionDateEnd": "2019-11-28","AmountGross": 0,"DiscountBase": 0,"DiscountBonus": 0,"RebateBase": 0,"RebateBonus": 0,"AmountNet": 0,"PointsEarnedBase": 80000,"PointsEarnedBonus": 0,"PointsEarnedBonusBasis": "","PointsEarnedTotal": 80000,"RecordNumber": 1,"AcceptReject": "R","ReasonForRejection": "INVALID ABN"}},{"Type": "LoyaltyVerificationResult","Id": "","Attributes": {"BusinessTaxationNumber": "12345678901","CardSequenceNumber": 0,"BusinessName": "KV & Sons Pty Ltd","TransactionId": "a3E0Q0000001cJyUAI","BusinessAccountNumber": "0010Q00000lcfqKQAQ","BannerBrand": "","Location": "","TransactionDateStart": "2019-11-28","TransactionDateEnd": "2019-11-28","AmountGross": 0,"DiscountBase": 0,"DiscountBonus": 0,"RebateBase": 0,"RebateBonus": 0,"AmountNet": 0,"PointsEarnedBase": 80000,"PointsEarnedBonus": 0,"PointsEarnedBonusBasis": "","PointsEarnedTotal": 80000,"RecordNumber": 1,"AcceptReject": "R","ReasonForRejection": "INVALID ABN"}}]}';
        CreateLoyaltyVerificationRequestDto req = (CreateLoyaltyVerificationRequestDto)JSON.deserialize(body, CreateLoyaltyVerificationRequestDto.class);

        // Set up a test request
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = new RestResponse();

        // Act
        Test.startTest();
        CreateLoyaltyVerificationResponseDto res = LoyaltyProgramVerificationService.create(req);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
    }
}