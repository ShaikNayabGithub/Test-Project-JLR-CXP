@isTest(seeAllData=true)
public class DMSMessager_India_Response_Test {
	static testmethod void SendResponses_CallsMessagerSendRequestOnce_GivenNonEmptyResponseCollection()
	{
		Dummy_Messager messager = new Dummy_Messager();
		SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
		DMSMessager_India_Response responseMessager = new DMSMessager_India_Response(messager, attributeConstructor);

		DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(TestClass_ValidOpportunityBuilder.Build().Account.Id, '');
		DMSInboundUpdateResponseCollection input = new DMSInboundUpdateResponseCollection(new DMSInboundUpdateResponse[]{response}, '');

		try
		{
			responseMessager.SendResponses(input);
		}
		catch(Exception e){}

		System.assertEquals(1, messager.sendRequestCallCount);
	}

	static testmethod void SendResponses_ThrowsException_GivenEmptyResponseCollection()
	{
		Dummy_Messager messager = new Dummy_Messager();
		SOAPXMLAttributeConstructor attributeConstructor = new SOAPXMLAttributeConstructor();
		DMSMessager_India_Response responseMessager = new DMSMessager_India_Response(messager, attributeConstructor);

		DMSInboundUpdateResponseCollection input = new DMSInboundUpdateResponseCollection(new DMSInboundUpdateResponse[]{}, '');

		boolean result = false;
		try
		{
			responseMessager.SendResponses(input);
		}
		catch(DMSOutbound_InvalidDataException e)
		{
			result = true;
		}

		System.assert(result);
	}


	private class Dummy_Messager implements I_HttpMessager_Siebel{
		public integer sendRequestCallCount = 0;
		public string GetSiebelDMLAction(string dmsRecordId){
			return dmsRecordId;
		}
		public string GetDMSInnerException(string soapBody){
			return soapBody;
		}
		public HttpResponse SendRequest(string soapBody, boolean isOutbound){
			sendRequestCallCount++;
			return new HttpResponse();
		}
	}
}