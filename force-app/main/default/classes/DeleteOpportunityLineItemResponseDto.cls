/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 30/08/2019.
 */

public with sharing class DeleteOpportunityLineItemResponseDto extends BaseResponseDto{

    @AuraEnabled
    public String Message {get; set;}
}