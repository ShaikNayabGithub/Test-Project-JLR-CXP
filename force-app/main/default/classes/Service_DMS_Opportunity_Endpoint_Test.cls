@IsTest
public class Service_DMS_Opportunity_Endpoint_Test  {

	@TestSetup
	static void CreateData(){
		Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();

        List<DataUseLegalBasis> lbList = new List<DataUseLegalBasis>();
        lbList.add(new DataUseLegalBasis(Name = 'Jaguar', Translatable_Value__c = 'Jaguar'));
        lbList.add(new DataUseLegalBasis(Name = 'Land Rover', Translatable_Value__c = 'Land Rover'));
        insert lbList;

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;BR'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = 'Test DataUse', Translatable_Value__c = 'Events and Experiences', CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;BR'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[0].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;BR'));
        dupList.add(new DataUsePurpose(LegalBasisId = lbList[1].Id, Name = consentSettings.get('Purpose_Surveys').CXP_Name__c, Translatable_Value__c = consentSettings.get('Purpose_Surveys').CXP_Name__c, CanDataSubjectOptOut = true, Available_Channels__c = 'Email;Telephone;Post;SMS', Available_in_Markets__c = 'AE;BR'));
        insert dupList;

        User usrAdmin = [SELECT Id,DefaultCurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId()];
       
        Test.startTest();
		AssetHandler.IgnoreMMIT = true;// If we don't diable the MMIT code, we hit dml limits
		RecordSharer.DisableRecordSharing = true; //disable record sharing to reduce SOQL statements

		//create retailer
		Account retailer = TestClass_AccountCreator.BuildRetailer();
		retailer.Dealer_CI_Code__c = '1';
		retailer.Country_ISO_Code__c = 'BR';
		retailer.Queue_ID__c = 'x';
		insert retailer;

		//create retailer user
		Id p = [select id from profile where name='Partner Community User'].id;  
        Contact con = new Contact(LastName ='testCon',AccountId = retailer.Id, 
								FirstName = 'john', Phone = '0794', Gender__c = 'Male', 
								Birthdate = Date.newInstance(2000,1,30),
								Salutation = 'Mr', HasOptedOutOfEmail = true, DoNotCall = true,
								Email = 'test_unit@example.com.unittest');
        insert con;  
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con.Id,CurrencyIsoCode = usrAdmin.DefaultCurrencyIsoCode,
                timezonesidkey='America/Los_Angeles', username='tester1@noemail.com.unittest');
        System.runAs(usrAdmin) {       
        	insert user;
        }
       
		//create customer account
		Account acc = new Account();
		acc.OwnerId = user.id;
		acc.Preferred_Sales_Retailer__c = retailer.id;
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId() ;
		acc.FirstName = 'Tony';
		acc.LastName = 'Stark';
		acc.Salutation = 'Mr';
		acc.Gender__pc = 'Male';
		acc.BillingStreet = '1 Avengers HQ';
		acc.BillingCountry = 'USA';
		acc.BillingCity = 'Washington';
		acc.Country_ISO_Code__c = 'US';
		acc.BillingState = 'DC';
		acc.BillingPostalCode = 'AV1';
		acc.PersonMailingPostalCode = '789456';
		acc.PersonMailingStreet = '10880 Malibu Point';
		acc.PersonMailingCity = 'Malibu';
		acc.PersonMailingState = 'CA';
		acc.PersonMailingCountry = 'US';
		acc.Country_ISO_Code__pc = 'US';
		acc.Phone = '0121';
		acc.PersonEmail = 'tony.stark@example.com';
		acc.LegalEntityID__c = '1234567890';
		acc.PersonBirthdate = Date.newInstance(1970,5,29);
		acc.PersonDoNotCall = true;
		acc.PersonHasOptedOutOfEmail = true;
        acc.CurrencyIsoCode = usrAdmin.DefaultCurrencyIsoCode;
		insert acc;        
        Test.stopTest();
				
		//Create opportunity as the partner community user
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.StageName = 'HANDOVER';
		opp.CloseDate = Date.today();
		opp.Name = 'Opp 1';
		opp.OwnerId = user.Id;
        opp.CurrencyIsoCode = usrAdmin.DefaultCurrencyIsoCode;
		System.runAs(user){
			insert opp;
		}
        
		//Create pricebook	
		Pricebook2 priceBook = TestClass_PricebookCreator.CreatePricebook('test');

		//The Line item builder also creates brand, model and derivative records
		OpportunityLineItem item = TestClass_OpportunityProductBuilder.BuildLineItem(opp,pricebook);
		
		//update the product created above
		Product2 existingProd = [Select id, RecordTypeId, Name, ProductCode from product2 where Name='test'];
		existingProd.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId() ;
		existingProd.Name = 'test';
		existingProd.ProductCode = 'XX';
		update existingProd;		

		//create a second derivative for testing assets
		Product2 deriv = new Product2();
		deriv.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId() ;
		deriv.Make__c = TestClass_OpportunityProductBuilder.make.Id;
		deriv.Model__c = TestClass_OpportunityProductBuilder.model.Id;
		deriv.ProductCode = '50001234';
		deriv.Name = '50001234 Test Derivative';
		insert deriv;

		//Create asset
		Asset a = new Asset();
		a.VIN__c = 'JLR12345';
		a.Model__c = TestClass_OpportunityProductBuilder.model.id;
		a.Model_Year__c = '2018';
		a.Model_Description__c = 'Test Product Description';
		a.Brand__c = TestClass_OpportunityProductBuilder.make.Id;
		a.Derivative__c = deriv.Id;
		a.AccountId = acc.Id;
		a.Registration_Number__c = 'OV18JLR';
		a.name = a.VIN__c;
		a.Fuel_Type__c = 'Petrol';
		insert a;
		
		item.Asset__c = a.id;
		item.Product2Id = deriv.Id;
		insert item;
	}

	static Blob GetDealerCode(){
		Account a = [select id from account where name = 'test retailer' ];
		System_Settings__mdt setting = [select key__c from System_Settings__mdt 
										where DeveloperName = 'DMS_BR_Encryption_Key' ];

		Blob key = EncodingUtil.base64Decode(setting.key__c);
		Blob encypted = System.Crypto.encryptWithManagedIV('AES256', key , Blob.valueOf(a.Id));
		return encypted;
	}

	static Blob GetInvalidDealerCode(){		
		System_Settings__mdt setting = [select key__c from System_Settings__mdt 
										where DeveloperName = 'DMS_BR_Encryption_Key' ];

		Blob key = EncodingUtil.base64Decode(setting.key__c);
		Blob encypted = System.Crypto.encryptWithManagedIV('AES256', key , Blob.valueOf('0010E00000IPvfW'));//the value here is irelevant, just needs to not exist 
		return encypted;
	}

	static testmethod void GetOpportunities_Error_WhenDealerCodeMissing(){

		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'GET';

		RestContext.request = req;
        RestContext.response = res;
		Service_DMS_Opportunity_Data.GetOpportunities_Response response = Service_DMS_Opportunity_Endpoint.getWonOpportunities();
        
		System.assertEquals(response.Error, 'Please supply a dealer code');
		System.assert(response.OpportunityCount == 0);		
	}

	static testmethod void GetOpportunities_Error_WhenInvalidDealerCode(){	

		Test.startTest();
		String dealerCode = EncodingUtil.base64Encode(GetInvalidDealerCode());

		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders?dealerCode=2'; 
	    req.httpMethod = 'GET';
		req.addParameter('dealerCode',dealerCode);

		RestContext.request = req;
        RestContext.response = res;
		Service_DMS_Opportunity_Data.GetOpportunities_Response response = Service_DMS_Opportunity_Endpoint.getWonOpportunities();
        
		Test.stopTest();

		System.assertEquals('Invalid dealer code', response.Error);
		System.assert(response.OpportunityCount == 0);		
	}	

	static testmethod void GetOpportunity_Returns1Opportunity_WhenValidDealerCode(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'GET';
		req.addParameter('dealerCode', EncodingUtil.base64Encode(GetDealerCode()));

		RestContext.request = req;
        RestContext.response = res;
		Service_DMS_Opportunity_Data.GetOpportunities_Response response = Service_DMS_Opportunity_Endpoint.getWonOpportunities();
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals(response.Error, null);
		System.assert(response.OpportunityCount == 1);		
	}

	static testmethod void GetOpportunity_CheckFieldMapping_WhenValidDealerCode(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'GET';
		req.addParameter('dealerCode', EncodingUtil.base64Encode(GetDealerCode()));

		RestContext.request = req;
        RestContext.response = res;
		Service_DMS_Opportunity_Data.GetOpportunities_Response response = Service_DMS_Opportunity_Endpoint.getWonOpportunities();
        
		System.debug(response);


		System.assertEquals(response.Error, null);
		System.assert(response.OpportunityCount == 1);	
		
		Service_DMS_Opportunity_Data.OpportunityItem opp = response.CXPSalesOrders[0];
		Opportunity o = [Select id from Opportunity];

		
		User u = [select id from user where email = 'test123@noemail.com'];

		//System.assertEquals('Washington',opp.CreatedDate);//chec kdb
		System.assertEquals(u.id,opp.SFUSERID);
		//System.assertEquals(o.id,opp.DEALERCODE);//???
		System.assertEquals(1,opp.LineItemCount);
		System.assertEquals('Handover',opp.StageName);
		System.assertEquals(String.valueOf(o.id),opp.SFOpportunityId);
		
		Contact c = [SELECT id, FirstName, LastName, Birthdate, Email, Gender__c, Phone, Salutation,
					DoNotCall, HasOptedOutOfEmail
					 from Contact where LastName!='testCon' LIMIT 1];
		//Check Contact
		Service_DMS_Opportunity_Data.ContactItem contactItem = opp.Contacts[0];
		System.assertEquals(c.Id,contactItem.SFContactId);
		System.assertEquals('Tony',contactItem.FirstName);
		System.assertEquals('Stark',contactItem.LastName);
		System.assertEquals(Date.newInstance(1970,5,29),contactItem.DateOfBirth);
		System.assertEquals('tony.stark@example.com',contactItem.Email);
		System.assertEquals('Male',contactItem.Gender);
		System.assertEquals('0121',contactItem.Phone);
		System.assertEquals('MR',contactItem.Salutation);
		System.assertEquals('789456',contactItem.Address.PostalCode);
		System.assertEquals('Malibu',contactItem.Address.City);
		System.assertEquals('US',contactItem.Address.CountryISOCode);
		System.assertEquals('CA',contactItem.Address.State);
		System.assertEquals('10880 Malibu Point',contactItem.Address.Street);


		

		//Marketing prefs
		Service_DMS_Opportunity_Data.MarketingPreferences prefs = contactItem.MarketingPrefs;
		System.assertEquals(true,prefs.DoNotCall);
		System.assertEquals(true,prefs.HasOptedOutOfEmail);
		
		//Check account fields
		System.assertEquals('Tony Stark',opp.Account.Name);
		System.assertEquals('1234567890',opp.Account.NationalId);
		System.assertEquals('Individual',opp.Account.AccountType);
		System.assertEquals('0121',opp.Account.Phone);
		System.assertEquals('1 Avengers HQ',opp.Account.RegisteredAddress.Street);
		System.assertEquals('DC',opp.Account.RegisteredAddress.State);
		System.assertEquals('US',opp.Account.RegisteredAddress.CountryISOCode);
		System.assertEquals('Washington',opp.Account.RegisteredAddress.City);
		System.assertEquals('AV1',opp.Account.RegisteredAddress.PostalCode);

		//check vehicle
		System.assertEquals('JLR12345',opp.Vehicle.VIN);
		System.assertEquals('Jaguar',opp.Vehicle.Brand);
		System.assertEquals('Petrol',opp.Vehicle.FuelType);
		System.assertEquals('OV18JLR',opp.Vehicle.License);
		System.assertEquals('test model',opp.Vehicle.ModelDescription);
		System.assertEquals('50001234 Test Derivative',opp.Vehicle.ProductDescription);
		System.assertEquals('2018',opp.Vehicle.ModelYear);
		
	    OpportunityLineItem lineItem = [Select id from OpportunityLineItem limit 1];

		//product 
		Service_DMS_Opportunity_Data.LineItem item =  opp.LineItems[0];
		System.assertEquals('Jaguar',item.Brand);
		System.assertEquals(1,item.Cost.Amount);
		//System.assertEquals('GBP',item.Cost.CurrencyISOCode);
		System.assertEquals('test',item.Derivative);
		System.assertEquals('test model',item.Model);
		System.assertEquals('XX',item.ProductCode);
		System.assertEquals(lineItem.id,item.SFLineItemId);
	


		//System.assertEquals
		Test.stopTest();
			
	}



	static testmethod void UpdateOpportunity_ReturnsSuccess_WhenValidUpdate(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetDealerCode());
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = [select id from opportunity limit 1][0].id;
		request.CXPSalesOrders.add(item);


		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals(response.Error, null);
		System.assert(response.CXPSalesOrders[0].success == true);		
	}

	static testmethod void UpdateOpportunity_ReturnsSuccess_WhenValidUpdateWith(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetDealerCode());
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = [select id from opportunity limit 1][0].id;
		item.Status = 'OK';
		item.NBSorderID = '12345';
		request.CXPSalesOrders.add(item);


		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals(response.Error, null);
		System.assert(response.CXPSalesOrders[0].success == true);		
	}

	static testmethod void UpdateOpportunity_ReturnsSuccess_WhenValidUpdateWithReason(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetDealerCode());
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = [select id from opportunity limit 1][0].id;
		item.Status = 'NOK';
		item.Reason = 'test reason';
		request.CXPSalesOrders.add(item);


		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		

		System.assertEquals(response.Error, null);
		System.assert(response.CXPSalesOrders[0].success == true);	
		
		Opportunity  opp = [select id, Dms_reason__C from opportunity limit 1];
		Test.stopTest();
		System.assertEquals('test reason',opp.dms_reason__c);
			
	}


	static testmethod void UpdateOpportunity_ReturnsError_WhenNoDataPassed(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetDealerCode());


		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals('Opportunity data required',response.Error);		
	}

	static testmethod void UpdateOpportunity_ReturnsDuplicateError_WhenSameOpportunitySentTwice(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetDealerCode());
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = [select id from opportunity limit 1][0].id;
		request.CXPSalesOrders.add(item);
		request.CXPSalesOrders.add(item);

		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals('Duplicate Opportunity Id',response.Error);		
	}

	static testmethod void UpdateOpportunity_ReturnsError_WhenNoDealerCodePassed(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = [select id from opportunity limit 1][0].id;
		request.CXPSalesOrders.add(item);

		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals('DealerCode required',response.Error);		
	}

	static testmethod void UpdateOpportunity_ReturnsError_WhenRetailerCanNotBeFound(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetInvalidDealerCode());
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = [select id from opportunity limit 1][0].id;
		request.CXPSalesOrders.add(item);

		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals('Could not find retailer',response.Error);		
	}

	static testmethod void UpdateOpportunity_ReturnsError_WhenEncyptionIsInvalid(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetInvalidDealerCode()) + 'zz';
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = [select id from opportunity limit 1][0].id;
		request.CXPSalesOrders.add(item);

		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals('Error decrypting dealercode',response.Error);		
	}

	static testmethod void UpdateOpportunity_ReturnsInvalidOpportunity_WhenOpportunityIdDoesNotExist(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetDealerCode());
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = '0068E00000D5Q34';//Invalid oportunity id, it doesn't need to exist
		request.CXPSalesOrders.add(item);

		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals('Opportunity not found',response.CXPSalesOrders[0].Error);		
	}

	static testmethod void UpdateOpportunity_ReturnsInvalidId(){
		Test.startTest();
		RestRequest req = new RestRequest();		
		RestResponse res = new RestResponse();
	    req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/OpportunityOrders'; 
	    req.httpMethod = 'PATCH';
		RestContext.request = req;
        RestContext.response = res;		

		//Build request data
		Service_DMS_Opportunity_Data.UpdateOpportunityRequest request = new Service_DMS_Opportunity_Data.UpdateOpportunityRequest();
		request.DMSUSERID = '1';
		request.DealerCode = EncodingUtil.base64Encode(GetDealerCode());
		Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem item = new Service_DMS_Opportunity_Data.UpdateOpportunityRequestItem();
		item.SFOpportunityId = '0068E00000';//Invalid oportunity id, it doesn't need to exist
		request.CXPSalesOrders.add(item);

		Service_DMS_Opportunity_Data.UpdateOpportunityResponse response = Service_DMS_Opportunity_Endpoint.updateOpportunity(request);
        
		System.debug(response);
		Test.stopTest();

		System.assertEquals('Invalid Salesforce Id',response.CXPSalesOrders[0].Error);		
	}
	
	

}