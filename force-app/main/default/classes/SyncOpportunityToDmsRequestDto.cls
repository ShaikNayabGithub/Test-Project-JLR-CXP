/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/12/2019.
 */

public with sharing class SyncOpportunityToDmsRequestDto extends BaseRequestDto{

    @AuraEnabled
    public String OpportunityId {get; set;}
}