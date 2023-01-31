/**
 * Created by caleb on 4/09/2019.
 */

public with sharing class GetServicePlansResponseDto extends BaseResponseDto {
    public GetServicePlansResponseDto() {
        super();
        init();
    }

    private void init() {
        if (this.Data == null) {
            this.Data = new List<ServicePlanResourceDto>();
        }
    }

    public GetServicePlansResponseDto(List<OfferResourceDto> offers, List<PricebookEntry> pricebookEntries) {
        this();
        System.debug('>> GetServicePlansResponseDto()');
        System.debug('offers: ' + JSON.serialize(offers));
        System.debug('pricebookEntries: ' + JSON.serialize(pricebookEntries));


        for (OfferResourceDto offer : offers) {
            this.Data.add(new ServicePlanResourceDto(offer));
        }

        for (PricebookEntry pbe : pricebookEntries){
            this.Data.add(new ServicePlanResourceDto(pbe));
        }
        System.debug('<< GetServicePlansResponseDto()');
    }


    @AuraEnabled
    public List<ServicePlanResourceDto> Data { get; set; }
}