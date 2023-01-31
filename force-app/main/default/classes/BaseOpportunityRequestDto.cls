/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global virtual with sharing class BaseOpportunityRequestDto extends BaseRequestDto{

    @AuraEnabled
    public OpportunityResourceDto Data {get; set;}

}