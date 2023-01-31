/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

global with sharing class CreateLeadResponseDto extends BaseResponseDto{

    @AuraEnabled
    global LeadResourceDto Data {get; set;}

}