/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global virtual with sharing class BaseOpportunityResponseDto extends BaseResponseDto{

    global BaseOpportunityResponseDto(){
        init();
    }

    global BaseOpportunityResponseDto(OpportunityResourceDto opp){
        init();
        this.Data.add(opp);
    }

    global BaseOpportunityResponseDto(List<OpportunityResourceDto> opps){
        init();
        this.Data.addAll(opps);
    }

    @AuraEnabled
    global List<OpportunityResourceDto> Data {get; set;}

    private void init(){
        if (this.Data == null){
            this.Data = new List<OpportunityResourceDto>();
        }
    }

}