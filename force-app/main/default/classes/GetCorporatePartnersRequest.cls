/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/11/2019.
 */

global with sharing class GetCorporatePartnersRequest extends BaseRequestDto{

    @AuraEnabled
    global String OpportunityId {get; set;}

    @AuraEnabled
    global String SearchKey {get; set;}

}