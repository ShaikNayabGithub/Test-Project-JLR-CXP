/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class GetContactsRequestDto extends BaseRequestDto{

    @AuraEnabled
    global String ContactId {get; set;}

    @AuraEnabled
    global String PersonAccountId {get; set;}

}