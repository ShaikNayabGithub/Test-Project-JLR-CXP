@isTest
public class HttpResponseAdapter_IndiaDMS_Test {
	static testmethod void Adapt_ReturnsDMSContactId_GivenExampleResponse()
	{
		HttpResponseAdapter_IndiaDMS responseAdapter = new HttpResponseAdapter_IndiaDMS();
		
		HttpResponse input = BuildExampleResponse();
		
		DMSOutboundResponse result = responseAdapter.Adapt(input);
		
		System.assertEquals('1-JTAE9',result.DMSContactId);
	}
	
	static testmethod void Adapt_ReturnSFContactId_GivenExampleResponse()
	{
		HttpResponseAdapter_IndiaDMS responseAdapter = new HttpResponseAdapter_IndiaDMS();
		
		HttpResponse input = BuildExampleResponse();
		
		DMSOutboundResponse result = responseAdapter.Adapt(input);
		
		System.assertEquals('0038E000004b1hfQAA',result.SFContactId);
	}
	
	static testmethod void Adapt_ReturnDMSAccountId_GivenExampleResponse()
	{
		HttpResponseAdapter_IndiaDMS responseAdapter = new HttpResponseAdapter_IndiaDMS();
		
		HttpResponse input = BuildExampleResponse();
		
		DMSOutboundResponse result = responseAdapter.Adapt(input);
		
		System.assertEquals('1-JTAEC',result.DMSAccountId);
	}
	
	static testmethod void Adapt_ReturnSFAccountId_GivenExampleResponse()
	{
		HttpResponseAdapter_IndiaDMS responseAdapter = new HttpResponseAdapter_IndiaDMS();
		
		HttpResponse input = BuildExampleResponse();
		
		DMSOutboundResponse result = responseAdapter.Adapt(input);
		
		System.assertEquals('0018E000004yzSRQAY',result.SFAccountId);
	}
	
	static testmethod void Adapt_ReturnDMSOpportunityId_GivenExampleResponse()
	{
		HttpResponseAdapter_IndiaDMS responseAdapter = new HttpResponseAdapter_IndiaDMS();
		
		HttpResponse input = BuildExampleResponse();
		
		DMSOutboundResponse result = responseAdapter.Adapt(input);
		
		System.assertEquals('1-JTAEH',result.DMSOpportunityId);
	}
	
	static testmethod void Adapt_ReturnSFOpportunityId_GivenExampleResponse()
	{
		HttpResponseAdapter_IndiaDMS responseAdapter = new HttpResponseAdapter_IndiaDMS();
		
		HttpResponse input = BuildExampleResponse();
		
		DMSOutboundResponse result = responseAdapter.Adapt(input);
		
		System.assertEquals('0068E000002K5hyQAC',result.SFOpportunityId);
	}
	
	
    private static HttpResponse BuildExampleResponse()
    {
    	HttpResponse response = new HttpResponse();
    	
    	string responseBody = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
			'<SOAP-ENV:Body>'+
				'<ns:JLRSFAInsertOrUpdate_Output xmlns:ns="http://siebel.com/asi/">'+
					'<ListOfContactInterface xmlns="http://www.siebel.com/xml/JLR%20SFA%20Contact%20Interface">'+
						'<Contact Operation="update">'+
							'<DMSContactId>1-JTAE9</DMSContactId>'+
							'<IntegrationId>0038E000004b1hfQAA</IntegrationId>'+
							'<ListOfAccount2>'+
								'<Account2 Operation="update">'+
									'<DMSAccountId>1-JTAEC</DMSAccountId>'+
									'<IntegrationId>0018E000004yzSRQAY</IntegrationId>'+
								'</Account2>'+
							'</ListOfAccount2>'+
							'<ListOfOpportunity>'+
								'<Opportunity Operation="update">'+
									'<DMSOptyId>1-JTAEH</DMSOptyId>'+
									'<IntegrationId>0068E000002K5hyQAC</IntegrationId>'+
								'</Opportunity>'+
							'</ListOfOpportunity>'+
						'</Contact>'+
					'</ListOfContactInterface>'+
				'</ns:JLRSFAInsertOrUpdate_Output>'+
			'</SOAP-ENV:Body>'+
			'</SOAP-ENV:Envelope>';
    	
    	response.setBody(responseBody);
    	return response;
    }
}