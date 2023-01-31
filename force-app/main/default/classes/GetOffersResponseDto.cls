/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/09/2019.
 */

global with sharing class GetOffersResponseDto {

    private void init(){
        if (this.Data == null){
            this.Data = new List<OfferResourceDto>();
        }
    }

    global GetOffersResponseDto(){
        init();
    }

    global GetOffersResponseDto(List<Offers__c> offers){
        this();
        For (Offers__c offer : offers){
            this.Data.add(new OfferResourceDto(offer));
        }

    }


    @AuraEnabled
    global List<OfferResourceDto> Data {get; set;}

}