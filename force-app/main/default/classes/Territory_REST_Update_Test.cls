@IsTest
global class Territory_REST_Update_Test  {

	@TestSetup
	static void CreateData(){
		DMS_Connection__c credentials = new DMS_Connection__c();
        credentials.Name = 'Metadata';
        credentials.Username__c = 'test';
        credentials.Password__c = 'test';
        credentials.Endpoint_Address__c = 'https://test.salefsorce.com';
        insert credentials;  
	}

    static testmethod void Update_Territory_OnUpdate(){
		Territory_REST_Update.RunInTestContext = true;

        Account account = TestClass_AccountCreator.CreatePersonAccount();
        TerritoryMockHttpResponse mock = new TerritoryMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        Account.country_iso_code__C = 'BR';
        update Account;
		Test.stopTest();

		System.assertNotEquals(mock.messagesSent, 0);
    }

    static testmethod void DontUpdate_TerritoryAndCallService_OnUpdate(){
		Territory_REST_Update.RunInTestContext = true;
        Account account = TestClass_AccountCreator.CreatePersonAccount();
		TerritoryMockHttpResponse mock = new TerritoryMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            update Account;
        Test.stopTest();

        System.assertEquals(mock.messagesSent, 0);
    }

    static testmethod void Update_TerritoryAndCallService_OnUpdate(){
		Territory_REST_Update.RunInTestContext = true;
        Account account = TestClass_AccountCreator.CreatePersonAccount();

        TerritoryMockHttpResponse mock = new TerritoryMockHttpResponse();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
            Account.country_iso_code__C = 'BR'; 
            update Account;
        Test.stopTest();

        System.assertNotEquals(mock.messagesSent, 0);
    }



    global class TerritoryMockHttpResponse implements HttpCalloutMock {
        global Integer messagesSent = 0;

        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('<sessionId>12345</sessionId>');
            messagesSent++;
            res.setStatusCode(200);
            return res;
        }
    }
}