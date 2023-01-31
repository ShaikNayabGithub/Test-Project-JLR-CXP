@isTest(SeeAllData=true)
public class DMSOutbound_ResponseProcessor_Test {
    static testmethod void ProcessResponse_UpdatesAccount_GivenIsSuccessIsTrue()
    {
        DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('');
        DMSOutbound_ResponseProcessor responseProcessor = new DMSOutbound_ResponseProcessor(prefixHandler);
        DMSOutboundResponse input = BuildResponse();
        string updatedId = 'updatedDMSId';
        input.DMSAccountId = updatedId;
        
        responseProcessor.ProcessResponse(input);
        
        Account account = [Select DMS_Identifier__c From Account where Id =: input.SFAccountId];
        
        System.assertEquals(updatedId, account.DMS_Identifier__c);
    }
    
    static testmethod void ProcessResponse_UpdatesContact_GivenIsSuccessIsTrue()
    {
        DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('');
        DMSOutbound_ResponseProcessor responseProcessor = new DMSOutbound_ResponseProcessor(prefixHandler);
        DMSOutboundResponse input = BuildResponse();
        string updatedId = 'updatedDMSId';
        input.DMSContactId = updatedId;
        
        responseProcessor.ProcessResponse(input);
        
        Contact contact = [Select DMS_Identifier__c From Contact where Id =: input.SFContactId];
        
        System.assertEquals(updatedId, contact.DMS_Identifier__c);
    }
    
    static testmethod void ProcessResponse_UpdatesOpportunity_GivenIsSuccessIsTrue()
    {
        DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('');
        DMSOutbound_ResponseProcessor responseProcessor = new DMSOutbound_ResponseProcessor(prefixHandler);
        DMSOutboundResponse input = BuildResponse();
        string updatedId = 'updatedDMSId';
        input.DMSOpportunityId = updatedId;
        
        responseProcessor.ProcessResponse(input);
        
        Opportunity opportunity = [Select DMS_Opportunity_ID__c From Opportunity where Id =: input.SFOpportunityId];
        
        System.assertEquals(updatedId, opportunity.DMS_Opportunity_ID__c);
    }
    
    
    static testmethod void ProcessResponse_ThrowsDMSOutboundInvalidDataException_GivenIsSuccessIsFalse()
    {
        DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('');
        DMSOutbound_ResponseProcessor responseProcessor = new DMSOutbound_ResponseProcessor(prefixHandler);
        DMSOutboundResponse input = BuildResponse();
        input.IsSuccess = false;
        
        boolean result = false;
        
        try
        {
        	responseProcessor.ProcessResponse(input);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
        	result = true;
        }
        
        System.assert(result);
    }
    
    private static DMSOutboundResponse BuildResponse()
    {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        
        DMSOutboundResponse response = new DMSOutboundResponse();
        response.IsSuccess = true;
        response.SFOpportunityId = opportunity.Id;
        response.DMSOpportunityId = 'testDMSOpportunityId';
        
        response.SFAccountId = opportunity.AccountId;
        response.DMSAccountId = 'testDMSAcountId';
        
        response.SFContactId = TestClass_ValidContactBuilder.Build(opportunity.Account).Id;
        response.DMSContactId = 'testDMSContactId';
        
        return response;
    }
}