/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/11/2019.
 */

public with sharing class SetServicePlanResponseDto extends BaseResponseDto{

    @AuraEnabled
    public String Message {get;set;}

    @AuraEnabled
    public String OpportunityLineItemId {get; set;}
}