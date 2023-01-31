/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

global with sharing class CreateLeadRequestDto {

    private void init(){
        if (this.Data == null){
            this.Data = new LeadResourceDto();
        }
    }

    global CreateLeadRequestDto(){
        init();
    }

    @AuraEnabled
    global LeadResourceDto Data {get; set;}

}