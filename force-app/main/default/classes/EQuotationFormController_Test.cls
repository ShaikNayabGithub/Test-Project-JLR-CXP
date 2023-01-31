@isTest(seeAllData=false)
global class EQuotationFormController_Test {
    
    @testSetup static void testSetup(){
        Id sectionConfigRecTypeId= Schema.SObjectType.E_Quotation_Master_Config__c.getRecordTypeInfosByDeveloperName().get('Section_Visibility_Configuration').getRecordTypeId();
        Id complimentaryConfigRecTypeId= Schema.SObjectType.E_Quotation_Master_Config__c.getRecordTypeInfosByDeveloperName().get('Complimentary_Configuration').getRecordTypeId();
        list<E_Quotation_Master_Config__c> eQuoteMasterConfigLstForInsert = New list<E_Quotation_Master_Config__c>();
        E_Quotation_Master_Config__c objMasterConfig1;
        E_Quotation_Master_Config__c objMasterConfig2;
        
        for(integer i=0; i<5; i++) 
        {
            objMasterConfig1= new E_Quotation_Master_Config__c();
            objMasterConfig1.Country_ISO_Code__c='SG';
            objMasterConfig1.Section_Name__c='Test'+i;
            objMasterConfig1.RecordTypeId= sectionConfigRecTypeId;
            eQuoteMasterConfigLstForInsert.add(objMasterConfig1); 
            
            objMasterConfig2= new E_Quotation_Master_Config__c();
            objMasterConfig2.Country_ISO_Code__c='SG';
            objMasterConfig2.Product_Name__c='Test'+i;
            objMasterConfig2.RecordTypeId= complimentaryConfigRecTypeId;
            objMasterConfig2.Order_Number__c=i;
            objMasterConfig2.Type__c='checkbox';
            eQuoteMasterConfigLstForInsert.add(objMasterConfig2);  
        }
        
        insert eQuoteMasterConfigLstForInsert;
    }
    
    static testmethod void testNewQuote(){
        User testUser = createTestUser();
        system.runAs(testUser)
        {
           Opportunity opp = createOpportunity();
            
            EQuotationFormController.QuoteValuesWrap QuoteValuesWrap=EQuotationFormController.initQuote(opp.Id, null);
            EQuotationFormController.getDerivatives('001sdjxj83uo0c7', 'SG');
            EQuotationFormController.getTradeInVinApex('Test123',opp.Brand__c);
            Quote__c objQuote=QuoteValuesWrap.quoteObj;
            for(EQuotationFormController.complementaryObj comObj:QuoteValuesWrap.complementaryProdLst)
            {
                comObj.isSelected=true;
            }
            objQuote.RRP__c=10000;
            objQuote.CurrencyIsoCode='SGD';
            objQuote.Opportunity__c=opp.Id;
            objQuote.Date__c=system.today();
            string QuoteId=EQuotationFormController.saveQuoteApex(objQuote,JSON.serialize(QuoteValuesWrap.complementaryProdLst));
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new congaComposerMock());
            EQuotationFormController.congaPdfBackgroundMode(QuoteId, 'autoGen', '0xbsjdsjskdj');
            Test.stopTest();            
        }
    }
    
    static testmethod void testUpdateQuote(){
        User testUser = createTestUser();
        system.runAs(testUser)
        {
           Opportunity opp = createOpportunity();
             Test.startTest();
            EQuotationFormController.QuoteValuesWrap QuoteValuesWrap=EQuotationFormController.initQuote(opp.Id, null);
            Quote__c objQuote=QuoteValuesWrap.quoteObj;
            for(EQuotationFormController.complementaryObj comObj:QuoteValuesWrap.complementaryProdLst)
            {
                comObj.isSelected=true;
            }
            objQuote.RRP__c=10000;
            objQuote.CurrencyIsoCode='SGD';
            objQuote.Opportunity__c=opp.Id;
            objQuote.Date__c=system.today();
            string QuoteId=EQuotationFormController.saveQuoteApex(objQuote,JSON.serialize(QuoteValuesWrap.complementaryProdLst));
            EQuotationFormController.initQuote(null,QuoteId);
            Test.stopTest();            
        }
    }
    
    public static User createTestUser() {
        User runningUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last Name',
            Email = 'testUser@gmail.com',
            Username = 'tester@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Alias = 'alias',
            CommunityNickname='test_@123',
            Market__c='APIO',
            Country_ISO_Code__c='SG',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [select Id from UserRole where Name='System Administrator' ].Id
        );
        Insert runningUser;
        return runningUser;
    }
    
    public static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.LastName = 'Testrec Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'testrec@test.test';
        testAccount.Customer_Journey_Stage__c = 'Take Ownership';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }
    
    global class congaComposerMock implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('');
            res.setStatusCode(200);
            return res;
        }
    }
}