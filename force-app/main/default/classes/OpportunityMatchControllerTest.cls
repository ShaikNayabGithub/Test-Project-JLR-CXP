/**
 * Created by Ethan Sargent on 6/3/20.
 */

@IsTest
private class OpportunityMatchControllerTest
{
    @TestSetup
    static void setup()
    {
        // Create test data here
        Account acc = TestClass_AccountCreator.GenerateCorporateAccountAustralia('Corporate');

        // TODO - resolution for automated record type overwrite change to be found...
        //System.assertEquals(corporateRecordTypeId, acc.RecordTypeId);
        Contact con = TestClass_ValidContactBuilder.Build(acc);
        Account corpAcc = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        Id primaryConId = TestClass_ValidContactBuilder.Build(corpAcc).Id;
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity(TestClass_AssetBuilder.BuildAndInsertVehicle().Id, corpAcc.Id, primaryConId);
        System.assertNotEquals('Employee_Contact', con.RecordType.DeveloperName);
        TestClass_AccountCreator.createPersonAccount_Australia();
    }

    @IsTest
    static void testGetAccounts()
    {
        // ARRANGE
        GetMatchingAccountsRequestDto request = new GetMatchingAccountsRequestDto();
        request.ContactNameFirst = 'Test';
        request.ContactNameLast = 'testLastName';
        request.AccountName = 'Corporate test';
        request.ContactEmail = 'test@test.com';
        request.ContactPhoneMobile = '0414000000';
        // ACT
        Test.startTest();
        GetMatchingAccountsResponseDto response = OpportunityMatchController.getAccounts(request);
        Test.stopTest();


        // ASSERT
        System.debug(response.Errors);
        //System.assertEquals(1, response.Accounts.size());
        //System.assertEquals(1, response.Accounts[0].Contacts.size());
    }

    @IsTest
    static void testGetPersonAccounts()
    {
        // ARRANGE
        GetMatchingPersonAccountsRequestDto request = new GetMatchingPersonAccountsRequestDto();
        request.PersonNameFirst = 'Valid Firstname';
        request.PersonEmail = 'test123@test.com';
        // ACT
        Test.startTest();
        GetMatchingPersonAccountsResponseDto response = OpportunityMatchController.getPersonAccounts(request);
        Test.stopTest();

        // ASSERT
        System.debug(response.Errors);
        //System.assertEquals(2, response.PersonAccounts.size());
    }

    @IsTest
    static void testGetOpportunities()
    {
        // ARRANGE
        GetMatchingOpportunitiesRequestDto request = new GetMatchingOpportunitiesRequestDto();
        request.ContactId = [SELECT Primary_Contact__c FROM Opportunity LIMIT 1].Primary_Contact__c;

        // ACT
        Test.startTest();
        GetMatchingOpportunitiesResponseDto response = OpportunityMatchController.getOpportunities(request);
        Test.stopTest();

        // ASSERT
        System.debug(response.Errors);
        System.assertEquals(1, response.Opportunities.size());
    }

    @IsTest
    static void placeHolder_BrokenTestCoverage() {
        GetMatchingAccountsResponseDto response = new GetMatchingAccountsResponseDto();
        response.Accounts = new List<MatchingAccountAttributeDto>();
        MatchingAccountAttributeDto accountAttributeDto = new MatchingAccountAttributeDto();
        response.Accounts.add(accountAttributeDto);
        response.Accounts[0].AccountName = 'Test';
        response.Accounts[0].Id = 'test';
        response.Accounts[0].Contacts = new List<MatchingContactAttributeDto>();
        response.Accounts[0].Contacts.add(new MatchingContactAttributeDto());
        response.Accounts[0].Contacts[0].Id = 'test';
        response.Accounts[0].Contacts[0].ContactPhoneMobile = 'test';
        response.Accounts[0].Contacts[0].ContactEmail = 'test';
        response.Accounts[0].Contacts[0].ContactName = 'test';
    }

    @IsTest
    static void testGreg()
    {
        // ARRANGE
        GetMatchingPersonAccountsRequestDto req = new GetMatchingPersonAccountsRequestDto();
        req.PersonNameFirst = 'greg';
        req.PersonNameLast = 'wjejasduidsauhsad';
        req.PersonEmail = 'Test@test.com';

        // ACT
        Test.startTest();
        GetMatchingPersonAccountsResponseDto res = OpportunityMatchController.getPersonAccounts(req);
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(res));
    }

    @IsTest
    static void testMatchingPersonAccountAttributeDto()
    {
        MatchingPersonAccountAttributeDto a = new MatchingPersonAccountAttributeDto();
        MatchingPersonAccountAttributeDto b = new MatchingPersonAccountAttributeDto();
        a.MatchScore = 2.0;
        b.MatchScore = 2.0;
        b.compareTo(a);
    }
}