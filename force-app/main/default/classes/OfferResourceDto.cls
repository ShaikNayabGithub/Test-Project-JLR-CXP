/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/09/2019.
 */

global with sharing class OfferResourceDto extends BaseResourceDto {

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new OfferAttributesDto();
        }
    }

    global OfferResourceDto(){
        init();
    }

    global OfferResourceDto(Offers__c offer){
        this();
        this.Attributes.Name = offer.Name;
        this.Attributes.Product2Id = offer.Service_Plan_Product2Id__c;
    }

    @AuraEnabled
    global OfferAttributesDto Attributes {get; set;}
}