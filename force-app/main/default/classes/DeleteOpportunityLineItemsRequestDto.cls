/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 21/10/2019.
 */

public with sharing class DeleteOpportunityLineItemsRequestDto extends BaseRequestDto {

    @AuraEnabled
    public String OpportunityId {get; set;}
}