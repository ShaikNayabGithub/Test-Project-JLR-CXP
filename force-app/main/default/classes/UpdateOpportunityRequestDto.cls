/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

public with sharing class UpdateOpportunityRequestDto extends BaseOpportunityRequestDto {

    @AuraEnabled
    public String OpportunityId {get; set;}


    @AuraEnabled
    public String SaleType {get; set;}
}