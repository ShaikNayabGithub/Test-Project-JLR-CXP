@RestResource(urlMapping='/v1/osaUtility/convertLeads/*')
global with sharing class ConvertLead {
	
    @HttpPost
    global static void execute() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        System.debug(req.requestBody.toString());
		leadRequest leadRequestData = (leadRequest) JSON.deserialize(req.requestBody.toString(), leadRequest.class);
        System.debug(leadRequestData);
        
        LeadResponse responseMesage = new LeadResponse();
        responseMesage.message = 'Success';
        
        Lead thisLead = [SELECT Id, IsConverted  FROM Lead WHERE Id = :leadRequestData.leadId];
        System.debug(thisLead);
        if(thisLead.IsConverted != true) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(thisLead.id);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
//CXPD-2737 - If the lead information has an account information that already exist, only opportunities should be created 
//and the existing account should be mapped to opportunity            
            List<Account> checkAccount = [SELECT Id from Account where Country_ISO_Code__c = :leadRequestData.Country_ISO_Codec
                                         and PersonMobilePhone = :leadRequestData.PersonMobilePhone and LastName = :leadRequestData.LastName
                                         and Preferred_Sales_Retailer__c = :leadRequestData.Preferred_Sales_Retailerc];
            if(checkAccount.size() != 0) {
                lc.setAccountId(checkAccount[0].Id);
            }
            
//   end of CXPD-2737         
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            responseMesage.opportunityId = lcr.getOpportunityId();

            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :responseMesage.opportunityId];
            if(opp != null) {
                responseMesage.accountId = opp.AccountId;
            }
            
        } 
        
        res.responseBody = Blob.valueOf(JSON.serialize(responseMesage));
        res.addHeader('Content-Type', 'application/json');

    }
    
    private class LeadRequest {
        public String leadId;
//CXPD-2737 - If the lead information has an account information that already exist, only opportunities should be created 
//and the existing account should be mapped to opportunity. Below list added to check for existing account
        public String Country_ISO_Codec;
        Public String PersonMobilePhone;
        Public String LastName;
        Public String Preferred_Sales_Retailerc;
//end of CXPD-2737
    }
    
    private class LeadResponse {
        public String message;
        public String accountId;
        public String opportunityId;
        
    }
}