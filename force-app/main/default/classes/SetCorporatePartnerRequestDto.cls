/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/11/2019.
 */

public with sharing class SetCorporatePartnerRequestDto {

    @AuraEnabled
    public String OpportunityId {get; set;}

    @AuraEnabled
    public String VariantId {get; set;}

    @AuraEnabled
    public String CorporatePartnerId {get; set;}

    @AuraEnabled
    public String PricebookId {get; set;}
}