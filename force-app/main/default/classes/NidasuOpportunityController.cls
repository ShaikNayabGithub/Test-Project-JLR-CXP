/**
 * Created by caleb on 23/10/2019.
 */

public with sharing class NidasuOpportunityController
{
    public static final String NIDASU_STATUS_SUCCESS = 'Synced';
    public static final String NIDASU_STATUS_ERROR = 'Error';
    public static final String PRODUCT_SOBJECT_TYPE = 'Product2';

    public static GetNidasuOpportunitiesResponseDto getOpportunity(GetNidasuOpportunityRequestDto request)
    {
        GetNidasuOpportunitiesResponseDto response = new GetNidasuOpportunitiesResponseDto();
        Opportunity opp = [SELECT
                Id,
                AccountId,
                ContactId,
                Account.Type,
                Account.IsPersonAccount,
                Sale_Type__c,
                Owner.Contact.AccountId,
                Primary_Contact__r.Id,
                Primary_Contact__r.FirstName,
                Primary_Contact__r.LastName,
                Primary_Contact__r.MobilePhone,
                Primary_Contact__r.Phone,
                Primary_Contact__r.HomePhone,
                Primary_Contact__r.MailingStreet,
                Primary_Contact__r.MailingCity,
                Primary_Contact__r.MailingState,
                Primary_Contact__r.MailingPostalCode,
                Primary_Contact__r.MailingCountry,
                Primary_Contact__r.Email,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingState,
                Account.BillingPostalCode,
                Account.BillingCountry,
                Brand__r.Name,
                Primary_Model_Interest__r.Name,
                (
                    SELECT
                            Id,
                            Product2.Name,
                            Product2.Model__r.Name,
                            Product2.Make__r.Name
                    FROM OpportunityLineItems
                    WHERE Product2.RecordType.DeveloperName = :Constants.RECORD_TYPE_NAME_PRODUCT2_VARIANT
                ),
                VIN__c,
                Retailer__c,
                Retailer_Name__c,
                OwnerId,
                Owner.DMS_ID__c,
                Owner.FirstName,
                Owner.LastName,
                Owner.Email
        FROM Opportunity WHERE Id = :request.opportunityId];
        NidasuOpportunityResourceDto resourceDto = new NidasuOpportunityResourceDto(opp);
        resourceDto.Id = opp.Id;
        resourceDto.Type = 'RetailUpdate';
        response.Data = new List<NidasuOpportunityResourceDto> { resourceDto };
        return response;
    }

    @AuraEnabled
    public static string sendOpportunity(GetNidasuOpportunityRequestDto request)
    {
        System.debug('>> sendOpportunity(request = ' + JSON.serialize(request) + ')');

        BaseMulesoftConnector connector = new BaseMulesoftConnector(Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_RETAIL_UPDATE);
        GetNidasuOpportunitiesResponseDto muleRequest = getOpportunity(request);

        string body = JSON.serialize(muleRequest);
        // replace attribute casing
        body = body.replace('\"Data\"', '\"data\"');
        body = body.replace('\"Type\"', '\"type\"');
        body = body.replace('\"Id\"', '\"id\"');
        body = body.replace('\"Attributes\"', '\"attributes\"');
        // replace nulls with empty strings
        body = body.replace('null', '\"\"');

        System.debug('callout request = ' + body);
        String calloutResult = connector.doCallout(HttpMethods.POST, body);

        // turn IsSuccess to a bool
        calloutResult = calloutResult.replace('\"true\"', 'true');
        calloutResult = calloutResult.replace('\"false\"', 'false');
        System.debug('callout result = ' + calloutResult);
        try
        {
            UpdateNidasuOpportunitiesRequestDto muleResponse = (UpdateNidasuOpportunitiesRequestDto)JSON.deserialize(calloutResult, UpdateNidasuOpportunitiesRequestDto.class);
            UpdateNidasuOpportunitiesResponseDto result = updateOpportunity(muleResponse);

            System.debug('<< sendOpportunity()');
            return 'Sync Success';
        }
        catch (Exception e)
        {
            JlrCustomException ex = new JlrCustomException();
            ex.setMessage(calloutResult);
            throw ex;
        }
    }

    public static UpdateNidasuOpportunitiesResponseDto updateOpportunity(UpdateNidasuOpportunitiesRequestDto request)
    {
        // generate list of Opportunities and map from Salesforce to Nidasu Ids
        List<String> oppIds = new List<String>();
        for (UpdateNidasuOpportunitiesResourceDto resourceDto : request.Data)
        {
            oppIds.add(resourceDto.Id);
        }
        // update all Opportunities to either successfully converted synced or error
        Map<Id, Opportunity> oppsToUpdate = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Id IN :oppIds]);
        for (UpdateNidasuOpportunitiesResourceDto resourceDto : request.Data)
        {
            if (!oppsToUpdate.containsKey(resourceDto.Id))
            {
                JlrCustomException ex = new JlrCustomException();
                ex.setMessage('Opportunity no longer exists Id = ' + resourceDto.Id);
                throw ex;
            }
            Opportunity opp = oppsToUpdate.get(resourceDto.Id);
            if (resourceDto.Attributes.IsSuccess) opp.Nidasu_Status__c = NIDASU_STATUS_SUCCESS;
            else opp.Nidasu_Status__c = NIDASU_STATUS_ERROR;
        }
        update oppsToUpdate.values();
        UpdateNidasuOpportunitiesResponseDto response = new UpdateNidasuOpportunitiesResponseDto();
        return new UpdateNidasuOpportunitiesResponseDto();
    }
}