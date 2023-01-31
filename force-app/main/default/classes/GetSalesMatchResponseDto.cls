/**
 * Created by Nick on 1/11/2019.
 */

global with sharing class GetSalesMatchResponseDto extends BaseResponseDto{

    global GetSalesMatchResponseDto(){
        super();
        init();
    }

    global GetSalesMatchResponseDto(List<RDA__c> rda_s,List<Opportunity> opportunies){
        this();
        for (RDA__c rda : rda_s){
            this.Data.add(new SalesMatchResourceDto(rda));
        }
        for (Opportunity opportunity : opportunies){
            this.Data.add(new SalesMatchResourceDto(opportunity));
        }
    }

    private void init(){
        if(this.Data == null){
            this.Data = new List<SalesMatchResourceDto>();
        }
    }

	@AuraEnabled
    public List<SalesMatchResourceDto> Data {get; set;}
}