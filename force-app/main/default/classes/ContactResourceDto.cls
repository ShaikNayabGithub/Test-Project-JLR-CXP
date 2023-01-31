/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class ContactResourceDto extends BaseResourceDto{

    private void init(){
        if (this.Attributes == null){
            this.Attributes = new ContactAttributesDto();
        }
        this.Type = Constants.RESOURCE_TYPE_CONTACT;
    }
    @AuraEnabled
    global ContactAttributesDto Attributes {get; set;}

    global ContactResourceDto(){
        init();
    }
}