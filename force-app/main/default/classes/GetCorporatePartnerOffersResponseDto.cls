/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/11/2019.
 */

global with sharing class GetCorporatePartnerOffersResponseDto extends BaseResponseDto{

    global GetCorporatePartnerOffersResponseDto(){
        super();
        init();
    }

    global GetCorporatePartnerOffersResponseDto(List<Offers__c> offers){
        this();
        for(Offers__c offer: offers){
            this.Data.add(new OfferResourceDto(offer));
        }
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<OfferResourceDto>();
        }
    }

    @AuraEnabled
    global List<OfferResourceDto> Data {get; set;}
}