/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/12/2019.
 */

public with sharing class SetOpportunityAssetRequestDto {

    @AuraEnabled
    public String OpportunityId {get; set;}
    @AuraEnabled
    public String AssetId {get; set;}

}