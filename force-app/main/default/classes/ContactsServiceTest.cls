/**
 * Created by caleb on 29/08/2019.
 */

@IsTest
private class ContactsServiceTest {

    public static final string getContactsServiceUrl = '/services/apexrest/v1/contacts/';

    @TestSetup
    static void setupContacts()
    {
        TestClass_ValidContactBuilder.createContactsList();
    }

    @IsTest
    static void getContactsTest()
    {
        //ARRANGE
        RestRequest req = new RestRequest();
        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE FirstName = 'Test0'];
        req.requestURI = System.Url.getSalesforceBaseUrl().toExternalForm() + getContactsServiceUrl;

        req.params.put('id', con.Id);
        req.params.put('nameFirst', con.FirstName);
        req.params.put('nameLast', con.LastName);
        req.params.put('email', con.Email);
        req.params.put('priority', 'High');

        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');

        RestContext.request = req;

        //ACT
        Test.startTest();
        GetContactsResponseDto response = ContactsService.getContacts();
        Test.stopTest();

        //ASSERT
        System.debug(Json.serialize(response));
        System.assertNotEquals(null, response);
    }

    @IsTest
    static void getContactsTest2()
    {
        // ARRANGE
        GetContactsRequestDto req = new GetContactsRequestDto();
        req.PersonAccountId = TestClass_AccountCreator.createPersonAccount_Australia().Id;

        //ACT
        Test.startTest();
        GetContactsResponseDto response = ContactsController.getContacts(req);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
    }

    @IsTest
    static void getContactsTest3()
    {
        // ARRANGE
        GetContactsRequestDto req = new GetContactsRequestDto();
        TestClass_AccountCreator.createPersonAccount_Australia();

        //ACT
        Test.startTest();
        GetContactsResponseDto response = ContactsController.getContacts(req);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
    }

    @IsTest
    static void verifyContactLoyaltyStatusTest()
    {
        //ARRANGE
        RestRequest req = new RestRequest();
        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE FirstName = 'Test0'];
        req.requestURI = System.Url.getSalesforceBaseUrl().toExternalForm() + getContactsServiceUrl;

        req.params.put('id', con.Id);
        req.params.put('nameFirst', con.FirstName);
        req.params.put('nameLast', con.LastName);
        req.params.put('email', con.Email);
        req.params.put('priority', 'High');

        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');

        RestContext.request = req;

        ContactAttributesDto attributes = new ContactAttributesDto();
        attributes.NameLast ='Test FirstName';
        attributes.NameFirst ='Test LastName';
        attributes.QantasFrequentFlyerNumber ='785222';
        attributes.Message ='Member Not Found';
        attributes.Status='Error';
        ContactResourceDto  resource = new ContactResourceDto();
        resource.Attributes = attributes;
        GetContactLoyaltyStatusRequestDto  request = new GetContactLoyaltyStatusRequestDto();
        request.Contact = resource;

        Test.setMock(HttpCalloutMock.class, new FrequentFlyerNumberVerificationMock());

        //ACT
        Test.startTest();
        GetContactLoyaltyStatusResponseDto response = ContactsService.verifyContactLoyaltyStatus(request);
        Test.stopTest();

        //ASSERT
        System.debug(Json.serialize(response));
        System.assertNotEquals(null, response);
    }
}