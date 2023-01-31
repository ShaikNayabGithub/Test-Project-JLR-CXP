/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 18/11/2019.
 */

public with sharing class GetActivitiesRequestDto {

    @AuraEnabled
    public String OpportunityId {get; set;}

    @AuraEnabled
    public String ActivityId {get; set;}
}