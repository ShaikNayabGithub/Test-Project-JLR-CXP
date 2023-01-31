/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class GetOpportunitiesRequestDto extends BaseOpportunityRequestDto{

    global GetOpportunitiesRequestDto(){
        super();
        init();
    }

    private void init(){
        if (this.Data == null){
            this.Data = new OpportunityResourceDto();
        }
    }

    global GetOpportunitiesRequestDto(OpportunityResourceDto opp){
        this();
        this.Data = opp;
    }
}