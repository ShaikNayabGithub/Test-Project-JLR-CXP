/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

global with sharing class LeadResourceDto extends BaseResourceDto {

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new LeadAttributesDto();
        }
    }

    global LeadResourceDto(){
        init();
    }

    @AuraEnabled
    global LeadAttributesDto Attributes {get; set;}
}