@isTest(seeAllData=false)
global class JlrAPIEQuotationTest {
    
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
        
        //User testUser = createTestUser();
        //system.runAs(testUser)
        //{
           Opportunity opp = createOpportunity();
            
            JlrAPIEQuotation.QuoteValuesWrap QuoteValuesWrap=JlrAPIEQuotation.initQuote(opp.Id, null);
            JlrAPIEQuotation.getDerivatives('001sdjxj83uo0c7', 'SG');
            JlrAPIEQuotation.getTradeInVinApex('Test123',opp.Brand__c);
            Quote__c objQuote=QuoteValuesWrap.quoteObj;
            for(JlrAPIEQuotation.complementaryObj comObj:QuoteValuesWrap.complementaryProdLst)
            {
                comObj.isSelected=true;
            }
            objQuote.RRP__c=10000;
            objQuote.CurrencyIsoCode='SGD';
            objQuote.Opportunity__c=opp.Id;
            objQuote.Date__c=system.today();
            //string QuoteId=JlrAPIEQuotation.saveQuoteApex(objQuote,JSON.serialize(QuoteValuesWrap.complementaryProdLst));
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new congaComposerMock());
            //JlrAPIEQuotation.congaPdfBackgroundMode(QuoteId, 'autoGen', '0xbsjdsjskdj');
            Test.stopTest();            
        //}
    }
    
    static testmethod void testUpdateQuote(){
        Id devRecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        Vehicle_Specification__c vs=new Vehicle_Specification__c();
        vs.Name='Land Rover';
        vs.aop_JLR_Owned__c=true;
        vs.RecordTypeId=devRecordTypeId;
        //insert vs;
        
        Id devIdPrd = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        Product2 pro=new Product2();
        pro.name='L551 Brazil';
        pro.ProductCode='T5';
        //pro.Make__c=vs.Id;
        pro.Model_Alternative__c='Range Rover Evoque';
        pro.RecordTypeId=devIdPrd;
        insert pro;
        
        User testUser = createTestUser();
        //system.runAs(testUser)
        //{
        JlrAPIEQuotation.complementaryObj cim=new JlrAPIEQuotation.complementaryObj();
        cim.productName=null;
        cim.isSelected=null;
        cim.inputPrice=null;
        cim.inputtext=null;
        cim.inputType=null;
        cim.uniqueName=null;
        cim.orderNo=null;
        list<JlrAPIEQuotation.complementaryObj> listcim=new List<JlrAPIEQuotation.complementaryObj>();
        listcim.add(cim);
           Opportunity opp = createOpportunity();
             Test.startTest();
            JlrAPIEQuotation.QuoteValuesWrap QuoteValuesWrap=JlrAPIEQuotation.initQuote(opp.Id, null);
            Quote__c objQuote=QuoteValuesWrap.quoteObj;
            for(JlrAPIEQuotation.complementaryObj comObj:QuoteValuesWrap.complementaryProdLst)
            {
                comObj.isSelected=true;
            }
            objQuote.RRP__c=10000;
            objQuote.CurrencyIsoCode='SGD';
            objQuote.Opportunity__c=opp.Id;
            objQuote.Date__c=system.today();
            objQuote.Model__c=pro.Id;
            insert objQuote;
            
            Add_On_Accessories__c adOnA=new Add_On_Accessories__c();
        	adOnA.Quote__c=objQuote.id;
            adOnA.Sequence__c=12;
            adOnA.Category__c='Complementary';
            adOnA.Product_Name__c='Test';
            adOnA.Price__c=123;
            adOnA.Product_Id__c='servicePlan';
        	insert adOnA;
            //string QuoteId=JlrAPIEQuotation.saveQuoteApex(objQuote,JSON.serialize(QuoteValuesWrap.complementaryProdLst));
            JlrAPIEQuotation.initQuote(opp.id,objQuote.Id);
        	string allstring = '[{"inputPrice":0,"inputType":"Checkbox","isSelected":true,"orderNo":1,"productName":"Complimentary","uniqueName":"a4e1q000000Azh9AAC"},{"inputPrice":0,"inputType":"Currency","isSelected":false,"orderNo":2,"productName":"Fuel Coupons","uniqueName":"a4e1q000000AkSlAAK"},{"inputPrice":0,"inputType":"Currency","isSelected":false,"orderNo":2,"productName":"Service Coupons","uniqueName":"a4e1q000000AkSqAAK"},{"inputPrice":0,"inputType":"Currency","isSelected":false,"orderNo":2,"productName":"License & Inspection fee*","uniqueName":"a4e1q000000AkSbAAK"},{"inputPrice":0,"inputType":"Checkbox","isSelected":false,"orderNo":2,"productName":"Coating","uniqueName":"a4e1q000000AkSgAAK"}]';
            JlrAPIEQuotation.saveQuoteApex(objQuote,allstring,'Range Rover Evoque');
        	JlrAPIEQuotation.congaPdfBackgroundMode(objQuote.id,'Test',null,'English');
        	JlrAPIEQuotation.GetCountryLanguage(opp.id);
        	JlrAPIEQuotation.getSpDetails(pro.id);
        	//JlrAPIEQuotation.getSessionIdFrmVFPg(null);
            Test.stopTest();            
        //}
    }
    
    public static User createTestUser() {
        //User runningUser;
        //User testUser = createTestUser();
        //system.runAs(testUser)
        //{
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
        //Insert runningUser;
        
    //}
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
        //testAccount.Customer_Journey_Stage__c = 'Take Ownership';
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