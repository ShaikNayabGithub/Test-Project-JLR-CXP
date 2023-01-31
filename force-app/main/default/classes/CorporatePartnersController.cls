/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/02/2020.
 */

public without sharing class CorporatePartnersController {

    @AuraEnabled
    public static SetCorporatePartnerResponseDto setOpportunityCorporatePartner(SetCorporatePartnerRequestDto request) {
        System.debug('>> setOpportunityCorporatePartner()');
        System.debug('request: ' + JSON.serialize(request));
        SetCorporatePartnerResponseDto response = new SetCorporatePartnerResponseDto();
        try {
            Opportunity op = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :request.OpportunityId LIMIT 1];
            op.Corporate_Partner_Account__c = request.CorporatePartnerId;
            update op;
            if (String.isBlank(request.PricebookId)){
                request.PricebookId = op.Pricebook2Id;
            }

            if (String.isNotBlank(request.VariantId)){
                //Get Pricebook Entry
                GetPricebookEntryResponseDto pbeResponse = OffersController.getCorporateServicePlanPbe(request.VariantId, request.PricebookId);

                //Add the new Op Line Item
                SetServicePlanRequestDto requestDto = new SetServicePlanRequestDto();
                requestDto.OpportunityId = request.OpportunityId;
                requestDto.ServicePlanId = pbeResponse.PricebookEntry.Product2Id;
                requestDto.PricebookEntryId = pbeResponse.PricebookEntry.Id;
                requestDto.ServicePlanType = Constants.SERVICE_PLAN_TYPE_CORPORATE;
                SetServicePlanResponseDto responseDto = OpportunitiesController.setServicePlan(requestDto);
                if (responseDto.IsSuccess) {
                    response.ServicePlanId = pbeResponse.PricebookEntry.Product2Id;
                    response.PricebookEntryId = pbeResponse.PricebookEntry.Id;
                    response.OpportunityLineItemId = responseDto.OpportunityLineItemId;
                } else {
                    response.Errors.addAll(responseDto.Errors);
                }
            }


        } catch (QueryException ex){
            System.debug('Exception: ' + JSON.serialize(ex.getStackTraceString()));
            response.addError(ex);
        } catch (Exception ex) {
            System.debug('Exception: ' + JSON.serialize(ex.getStackTraceString()));
            response.addError(ex);
        }
        System.debug('<< setOpportunityCorporatePartner()');
        return response;
    }


}