/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 30/08/2019.
 */

global with sharing class SetVariantRequestDto extends BaseSetOpportunityLineItemRequestDto{


    @AuraEnabled
    global String VariantId { get; set; }

    @AuraEnabled
    global String CorporatePartnerId {get; set;}

}