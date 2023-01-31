/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/09/2019.
 */

global with sharing class GetOffersRequestDto {

    global GetOffersRequestDto(){

    }

    global GetOffersRequestDto(String variantId, List<String> typeNames, String corporatePartnerId){
        this.VariantId = variantId;
        this.CorporatePartnerId = corporatePartnerId;
        this.TypeNames = typeNames;
    }

    global GetOffersRequestDto(String variantId, List<String> typeNames){
        this.VariantId = variantId;
        if (typeNames.contains(Constants.SERVICE_PLAN_TYPE_CORPORATE)){
            typeNames.remove(typeNames.indexOf(Constants.SERVICE_PLAN_TYPE_CORPORATE));
        }
        this.TypeNames = typeNames;
    }

    @AuraEnabled
    global List<String> TypeNames {get; set;}

    @AuraEnabled
    global String VariantId {get; set;}

    @AuraEnabled
    global String CorporatePartnerId {get; set;}
}