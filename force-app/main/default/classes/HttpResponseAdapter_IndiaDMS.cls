public class HttpResponseAdapter_IndiaDMS implements I_HttpResponseAdapter{
    private final static string recordNamespace = 'http://www.siebel.com/xml/JLR%20SFA%20Contact%20Interface';
    public DMSOutboundResponse Adapt(HttpResponse response)
    {
        DMSOutboundResponse adaptedResponse = new DMSOutboundResponse();
        adaptedResponse.IsSuccess = true;
        
        Dom.Document responseDocument = response.getBodyDocument();
        Dom.XmlNode envelope = responseDocument.getRootElement();
        Dom.XmlNode bodyNode = envelope.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XmlNode actionNode = bodyNode.getChildElement('JLRSFAInsertOrUpdate_Output', 'http://siebel.com/asi/');
        Dom.XmlNode contactsNode = actionNode.getChildElement('ListOfContactInterface', recordNamespace);
        Dom.XmlNode contactNode = contactsNode.getChildElement('Contact', recordNamespace);
        
        adaptedResponse.DMSContactId = contactNode.getChildElement('DMSContactId', recordNamespace).getText();
        adaptedResponse.SFContactId = contactNode.getChildElement('IntegrationId', recordNamespace).getText();
        
        this.ProcessAccount(adaptedResponse, contactNode);
        
        Dom.XmlNode opportunitiesNode = contactNode.getChildElement('ListOfOpportunity', recordNamespace);
        Dom.XmlNode opportunityNode = opportunitiesNode.getChildElement('Opportunity', recordNamespace);
        
        adaptedResponse.DMSOpportunityId = opportunityNode.getChildElement('DMSOptyId', recordNamespace).getText();
        adaptedResponse.SFOpportunityId = opportunityNode.getChildElement('IntegrationId', recordNamespace).getText();
        
        return adaptedResponse;
    }

    private void ProcessAccount(DMSOutboundResponse adaptedResponse, Dom.XmlNode contactNode)
    {
        Dom.XmlNode accountsNode = contactNode.getChildElement('ListOfAccount2', recordNamespace);
        if(accountsNode == null){ return; }
        Dom.XmlNode accountNode = accountsNode.getChildElement('Account2', recordNamespace);
        
        adaptedResponse.DMSAccountId = accountNode.getChildElement('DMSAccountId', recordNamespace).getText();
        adaptedResponse.SFAccountId = accountNode.getChildElement('IntegrationId', recordNamespace).getText();
    }
}