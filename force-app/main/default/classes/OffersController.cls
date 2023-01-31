/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/09/2019.
 */

global without sharing class OffersController {

    @AuraEnabled
    global static GetCorporatePartnerOffersResponseDto searchCorporateOffers(GetCorporatePartnerOffersRequest request){
        List<Offers__c> offers = getOffersFromDatabase(new List<String>{Constants.SERVICE_PLAN_TYPE_CORPORATE}, request.VariantId);
        List<Offers__c> filteredOffers = new List<Offers__c>();
        for (Offers__c offer : offers){
            if (offer.Corporate_Partner__r.Name.containsIgnoreCase(request.SearchKey)){
                filteredOffers.add(offer);
            }
        }
        return new GetCorporatePartnerOffersResponseDto(filteredOffers);
    }

    @AuraEnabled
    global static GetCorporatePartnersResponseDto searchCorporatePartners(GetCorporatePartnersRequest request){
        List<Offers__c> offers = getOffersFromDatabase(new List<String>{Constants.SERVICE_PLAN_TYPE_CORPORATE});
        Map<Id, String> partners = new Map<Id, String>();
        for (Offers__c offer : offers){
            Id partnerKey = offer.Corporate_Partner__c;
            String partnerName = offer.Corporate_Partner__r.Name;
            if (offer.Corporate_Partner__r.Name.containsIgnoreCase(request.SearchKey)){
                if (!partners.containsKey(partnerKey)){
                    partners.put(partnerKey, partnerName);
                }
            }
        }
        return new GetCorporatePartnersResponseDto(partners);
    }

    @AuraEnabled
    global static GetOffersResponseDto  get(GetOffersRequestDto request){
        System.debug('>> OffersController.get(request : ' + request + ')');
        List<Offers__c> offers = getOffersFromDatabase(request.TypeNames, Id.valueOf(request.VariantId));
        System.debug('List of Offers: ' + JSON.serialize(offers));
        //Refine Corporate Offers
        List<Offers__c> refinedOffers = new List<Offers__c>();
        for(Offers__c offer : offers){
            //If the offer is not a Corporate - then keep it
            if(offer.Type__c != Constants.SERVICE_PLAN_TYPE_CORPORATE){
                refinedOffers.add(offer);
            }
            //If the offer is a Corporate, and the corporatePartner is the same as the opportunity, keep it
            else if (offer.Corporate_Partner__c == request.CorporatePartnerId){
                refinedOffers.add(offer);
            }
        }
        GetOffersResponseDto response = new GetOffersResponseDto(refinedOffers);
        System.debug('<< GetOffersResponseDto.get() response: ' + JSON.serialize(response));
        return response;
    }

    private static List<Offers__c> getOffersFromDatabase(List<String> types) {

        List<Offers__c> offers = [
                SELECT
                        Id,
                        Name,
                        Derivative_Product2Id__c,
                        Service_Plan_Product2Id__r.Name,
                        Discount__c,
                        Corporate_Partner__c,
                        Corporate_Partner__r.Name,
                        Discount_Percent__c,
                        Eligible_Sale_Types__c,
                        Qantas_Points__c,
                        Service_Plan_Product2Id__c,
                        Minimum_Purchase_Price__c,
                        Type__c,
                        Make__c,
                        IsActive__c,
                        End_Date__c,
                        Start_Date__c
                FROM Offers__c
                WHERE Type__c IN :types
                AND (End_Date__c > TODAY OR End_Date__c = NULL)
                AND Start_Date__c < TODAY
                AND IsActive__c = TRUE
                ORDER BY Corporate_Partner__r.Name, Name
        ];
        return offers;
    }

    private static List<Offers__c> getOffersFromDatabase(List<String> types, Id variantProductId) {

        List<Offers__c> offers = [
                SELECT
                        Id,
                        Name,
                        Derivative_Product2Id__c,
                        Derivative_Product2Id__r.Service_Plan__c,
                        Service_Plan_Product2Id__r.Name,
                        Discount__c,
                        Corporate_Partner__c,
                        Corporate_Partner__r.Name,
                        Discount_Percent__c,
                        Eligible_Sale_Types__c,
                        Qantas_Points__c,
                        Service_Plan_Product2Id__c,
                        Minimum_Purchase_Price__c,
                        Type__c,
                        Make__c,
                        IsActive__c,
                        End_Date__c,
                        Start_Date__c
                FROM Offers__c
                WHERE Derivative_Product2Id__c = :variantProductId
                AND Type__c IN :types
                AND (End_Date__c > TODAY OR End_Date__c = NULL)
                AND Start_Date__c < TODAY
                AND IsActive__c = TRUE
                ORDER BY Corporate_Partner__r.Name, Name
        ];
        return offers;
    }

    public static Offers__c getComplimentaryServicePlanOffer(Id variantProduct2Id){
        List<String> types = new List<String>{Constants.SERVICE_PLAN_TYPE_COMPLIMENTARY};
        List<Offers__c> offers = getOffersFromDatabase(types, variantProduct2Id);
        if (offers.size() == 1){
            Offers__c offer =  offers[0];
            if (String.isBlank(offer.Type__c)){
                offer.Type__c = Constants.SERVICE_PLAN_TYPE_COMPLIMENTARY;
            }
            return offer;
        }
        return null;
    }

    public static Offers__c getCorporateServicePlanOffer(Id variantProduct2Id, Id corporatePartnerId){
        List<String> types = new List<String>{Constants.SERVICE_PLAN_TYPE_CORPORATE};
        List<Offers__c> offers = getOffersFromDatabase(types, variantProduct2Id);
        for (Offers__c offer : offers){
            if (offer.Corporate_Partner__c == corporatePartnerId){
                return offer;
            }
        }
        return null;
    }

    private static PricebookEntry getPricebookEntry(Offers__c offer, Id pricebookId){
        Id productId = offer.Derivative_Product2Id__r.Service_Plan__c;
        List<PricebookEntry> entries = [
                SELECT Id, Name, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2Id = :pricebookId
                AND Product2Id = :productId
                AND IsActive = true
                AND IsDeleted = FALSE
        ];

        if (ListUtils.isNotNullOrEmpty(entries)){
            // PriceBookEntry exists
            return entries[0];
        }
        return null;
    }


    public static List<OpportunityLineItemResourceDto> buildOpportunityLineItemResourceDto(List<Offers__c> offers, Id opportunityId, Id pricebook2Id){
        List<OpportunityLineItemResourceDto> resources = new List<OpportunityLineItemResourceDto>();
        for (Offers__c offer : offers){
            OpportunityLineItemResourceDto newItem = new OpportunityLineItemResourceDto();
            newItem.Attributes.Name = offer.Name;
            newItem.Attributes.OpportunityId = opportunityId;
            //todo - magic number
            Decimal qty = 1;
            newItem.Attributes.Quantity = qty;
            newItem.Attributes.Product2Id = offer.Derivative_Product2Id__r.Service_Plan__c;
            newItem.Attributes.ServicePlanName = offer.Service_Plan_Product2Id__r.Name;
            newItem.Attributes.ServicePlanType = offer.Type__c;
            newItem.Attributes.AssignmentType = offer.Type__c;

            //Get the pricebook entry
            PricebookEntry pbe = getPricebookEntry(offer, pricebook2Id);
            if (pbe != null){
                newItem.Attributes.TotalPrice = pbe.UnitPrice > 0 ?
                        pbe.UnitPrice * qty : 0;
                newItem.Attributes.PricebookEntryId = pbe.Id;
                resources.add(newItem);
            } else {
                System.debug('Pricebook not found for this offer, skipping');
            }
        }
        return resources;
    }

    public static GetPricebookEntryResponseDto getCorporateServicePlanPbe(Id variantId, Id pricebookId) {
        GetPricebookEntryResponseDto response = new GetPricebookEntryResponseDto();
        Product2 car = [
                SELECT Id, Service_Plan__c
                FROM Product2
                WHERE Id = :variantId
                LIMIT 1
        ];
        if (car == null) {
            response.addError(new JlrCustomException('No Matching Variant - ' + variantId));
        } else if (car.Service_Plan__c == null) {
            response.addError(new JlrCustomException('No Matching Service Plans For - ' + variantId));
        } else {
            List<PricebookEntry> entries = [
                    SELECT Id, Product2Id
                    FROM PricebookEntry
                    WHERE Pricebook2Id = :pricebookId
                    AND Product2Id = :car.Service_Plan__c
                    AND IsActive = TRUE
                    AND IsDeleted = FALSE
            ];
            if (entries.size() == 0) {
                response.addError(new JlrCustomException('No Pricebook Entries For - ' + car.Service_Plan__c));
            } else if (entries.size() > 1) {
                response.addError(new JlrCustomException('Multiple Pricebook Entries For - ' + car.Service_Plan__c));
            } else {
                PricebookEntry pbe = entries[0];
                response.PricebookEntry = pbe;
            }
        }
        return response;
    }
}