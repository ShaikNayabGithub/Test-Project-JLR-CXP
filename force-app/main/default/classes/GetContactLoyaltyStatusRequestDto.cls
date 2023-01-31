/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/09/2019.
 */

global with sharing class GetContactLoyaltyStatusRequestDto extends BaseRequestDto {

    private void init(){
        if (this.Contact == null){
            this.Contact = new ContactResourceDto();
        }
    }

    global GetContactLoyaltyStatusRequestDto(){
        init();
    }


    @AuraEnabled
    global ContactResourceDto Contact {get; set;}
}