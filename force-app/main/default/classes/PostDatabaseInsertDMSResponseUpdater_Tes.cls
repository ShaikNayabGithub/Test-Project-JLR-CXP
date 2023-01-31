@isTest(seeAllData=true)
public class PostDatabaseInsertDMSResponseUpdater_Tes {
    static testMethod void UpdateResponses_ThrowsCustomListExceptionMesage_GivenListsOfDifferentSizes() {
    	PostDatabaseInsertDMSResponseUpdater responseUpdater = new PostDatabaseInsertDMSResponseUpdater();
    	
    	List<Database.SaveResult> resultList = Database.insert(new List<Account>{new Account()}, false);
    	List<DMSInboundUpdateResponse> responseList = new List<DMSInboundUpdateResponse>();
    	
    	string result = '';
    	try
    	{
    		responseUpdater.UpdateResponses(resultList, responseList);
    	}
    	catch(ListException e)
    	{
    		result = e.getMessage();
    	}
    	
    	System.assertEquals('PostDatabaseInsertDMSResponseUpdater.UpdateResponses: results size does not match response size.', result);
    }
    
    static testMethod void UpdateResponses_DoesNotSetErrorCode_GivenSuccessfullSaveResultAndCorrespondingResponse() {
    	PostDatabaseInsertDMSResponseUpdater responseUpdater = new PostDatabaseInsertDMSResponseUpdater();
    	
    	Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
    	List<Database.SaveResult> resultList = Database.insert(new List<Opportunity>{opportunity}, false);
    	
    	List<DMSInboundUpdateResponse> responseList = new List<DMSInboundUpdateResponse>();
    	DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(opportunity.Id, opportunity.DMS_Opportunity_ID__c);
    	response.ErrorCode = 40;
    	responseList.add(response);
    	
    	responseUpdater.UpdateResponses(resultList, responseList);
    	
    	System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void UpdateResponses_DoesNotSetErrorMessage_GivenSuccessfullSaveResultAndCorrespondingResponse() {
    	PostDatabaseInsertDMSResponseUpdater responseUpdater = new PostDatabaseInsertDMSResponseUpdater();
    	
    	Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
    	List<Database.SaveResult> resultList = Database.insert(new List<Opportunity>{opportunity}, false);
    	
    	List<DMSInboundUpdateResponse> responseList = new List<DMSInboundUpdateResponse>();
    	DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(opportunity.Id, opportunity.DMS_Opportunity_ID__c);
    	response.ResponseMessage = 'pre-validation message';
    	responseList.add(response);
    	
    	responseUpdater.UpdateResponses(resultList, responseList);
    	
    	System.assertEquals('pre-validation message', response.ResponseMessage);
    }
    
    static testMethod void UpdateResponses_SetsErrorCodeTo5_GivenUnsuccessfullSaveResultAndCorrespondingResponse() {
    	PostDatabaseInsertDMSResponseUpdater responseUpdater = new PostDatabaseInsertDMSResponseUpdater();
    	
    	Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
    	opportunity.Name = null;
    	List<Database.SaveResult> resultList = Database.insert(new List<Opportunity>{opportunity}, false);
    	
    	List<DMSInboundUpdateResponse> responseList = new List<DMSInboundUpdateResponse>();
    	DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(opportunity.Id, opportunity.DMS_Opportunity_ID__c);
    	responseList.add(response);
    	
    	responseUpdater.UpdateResponses(resultList, responseList);
    	
    	System.assertEquals(10005, response.ErrorCode);
    }
    
    static testMethod void UpdateResponses_SetsErrorMessage_GivenUnsuccessfullSaveResultAndCorrespondingResponse() {
    	PostDatabaseInsertDMSResponseUpdater responseUpdater = new PostDatabaseInsertDMSResponseUpdater();
    	
    	Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
    	opportunity.Name = null;
    	List<Database.SaveResult> resultList = Database.insert(new List<Opportunity>{opportunity}, false);
    	
    	List<DMSInboundUpdateResponse> responseList = new List<DMSInboundUpdateResponse>();
    	DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(opportunity.Id, opportunity.DMS_Opportunity_ID__c);
    	responseList.add(response);
    	
    	responseUpdater.UpdateResponses(resultList, responseList);
    	
    	System.assertEquals(String.format(System.Label.DMSException_OpportunityUpdateFailure, new List<String> { response.DMSOpportunityID }), response.ResponseMessage);
    }
    
    static testMethod void UpdateResponses_SetsErrorMessage_GivenUnsuccessfullSaveResultAndCorrespondingResponse1() {
    	PostDatabaseInsertDMSResponseUpdater responseUpdater = new PostDatabaseInsertDMSResponseUpdater();
    	
    	Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
    	opportunity.Name = null;
    	List<Database.upsertResult> resultList = Database.upsert(new List<Opportunity>{opportunity}, false);
    	
    	List<DMSInboundUpdateResponse> responseList = new List<DMSInboundUpdateResponse>();
    	DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(opportunity.Id, opportunity.DMS_Opportunity_ID__c);
    	responseList.add(response);
    	
        responseUpdater.UpdateResponses(resultList, responseList);
    	
    	System.assertEquals(String.format(System.Label.DMSException_OpportunityUpdateFailure, new List<String> { response.DMSOpportunityID }), response.ResponseMessage);
    }
}