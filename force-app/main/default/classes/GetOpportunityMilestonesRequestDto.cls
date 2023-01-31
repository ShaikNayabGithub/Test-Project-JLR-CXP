/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 14/10/2019.
 */

public with sharing class GetOpportunityMilestonesRequestDto {

    @AuraEnabled
    public String OpportunityId {get; set;}
}