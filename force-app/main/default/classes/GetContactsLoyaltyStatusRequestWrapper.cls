/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 5/09/2019.
 */

public with sharing class GetContactsLoyaltyStatusRequestWrapper {

    public GetContactsLoyaltyStatusRequestWrapper(){

    }

    public GetContactsLoyaltyStatusRequestWrapper(ContactResourceDto contact){
        this.Data = contact;
    }

    @AuraEnabled
    public ContactResourceDto Data {get; set;}

    @AuraEnabled
    public List<ErrorDto> Errors {get; set;}

    public String toJson(){
        String json = JSON.serialize(this, true);
        return json
                .replace('"Data"', '"data"')
                .replace('"Id"', '"id"')
                .replace('"Type"', '"type"')
                .replace('"Attributes"', '"attributes"')
                .replace('"Errors"', '"errors"')
                .replace('"ErrorMessage"','"errorMessage"')
                .replace('"ErrorCode"','"errorCode"');
    }
}