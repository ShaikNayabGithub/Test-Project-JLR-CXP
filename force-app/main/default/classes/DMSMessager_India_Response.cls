public class DMSMessager_India_Response implements I_DMSMessager_Response{
    private final I_HttpMessager_Siebel messager;
    private final SOAPXMLAttributeConstructor attributeConstructor;
    
    public DMSMessager_India_Response(I_HttpMessager_Siebel messager, SOAPXMLAttributeConstructor attributeConstructor)
    {
        this.messager = messager;
        this.attributeConstructor = attributeConstructor;
    }
    
    
    public void SendResponses(DMSInboundUpdateResponseCollection responseCollection)
    {
		string soapBody = this.BuildRequestMessageContent(responseCollection);
		HttpResponse response = this.messager.SendRequest(soapBody, false);
        this.ProcessResponse(response);
    }
    
    
    private string BuildRequestMessageContent(DMSInboundUpdateResponseCollection responseCollection)
    {
    	if(responseCollection.responses.size() == 0){throw new DMSOutbound_InvalidDataException('No responses were detected'); }
    	string responsesSOAPString = '';
    	for(DMSInboundUpdateResponse response : responseCollection.responses)
    	{
    		responsesSOAPString = responsesSOAPString + '<jlr:Opportunity>'+
    						attributeConstructor.AddAttribute('DMSOptyId', response.DMSOpportunityID)+
		                  	attributeConstructor.AddAttribute('SFOptyId', response.SFOpportunityID)+
		                  	attributeConstructor.AddAttribute('SFBatchid', responseCollection.batchId)+
		                  	attributeConstructor.AddAttribute('SFResponseMsg', response.ResponseMessage)+
		                  	attributeConstructor.AddAttribute('SFSuccessFlag', response.IsSuccess)+
		                  	attributeConstructor.AddAttribute('SFErrorCode', String.valueOf(response.ErrorCode))+
		               	'</jlr:Opportunity>';
    	}
    	return '<opp:JLR_spcSFA_spcUpdate_spcOpty><SiebelMessage>'+
		            '<jlr:ListOfJlrSfaOutboundOpportunity>'+
		               responsesSOAPString +
		            '</jlr:ListOfJlrSfaOutboundOpportunity>'+
		         '</SiebelMessage></opp:JLR_spcSFA_spcUpdate_spcOpty>';
    }
    
    private void ProcessResponse(HttpResponse response)
    {
        integer responseCode = response.getStatusCode();
        if(responseCode == 200){ return; }

        string dmsException = this.messager.GetDMSInnerException(response.getBody());
        if(String.isNotEmpty(dmsException)){
            throw new DMSOutbound_InvalidDataException('Siebel Exception: ' + dmsException);
        }
        throw new DMSOutbound_InvalidDataException(response.getBody());
    }
}