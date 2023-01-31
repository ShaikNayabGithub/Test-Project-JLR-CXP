/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/09/2019.
 */

global with sharing class GetContactLoyaltyStatusResponseDto extends BaseResponseDto{

    private static final String RESPONSE_MEMBER_NOT_FOUND = 'Member Not Found';

    global GetContactLoyaltyStatusResponseDto(){
        super();
        init();
    }

    private void init(){
        if (this.Data == null){
            this.Data = new ContactResourceDto();
        }
    }

    global GetContactLoyaltyStatusResponseDto(string jsonResponse){
        this();
        GetContactsLoyaltyStatusRequestWrapper wrapper = (GetContactsLoyaltyStatusRequestWrapper)JSON.deserialize(jsonResponse, GetContactsLoyaltyStatusRequestWrapper.class);
        this.Data = wrapper.Data;
        System.debug(this.Data);
        this.Errors = wrapper.Errors;
        System.debug(this.Data);


        //This is  just a little hack so something shows in the UI when  member is not found
        if (
                Errors != null
                && Errors.size() == 1
                && Errors[0].ErrorCode.equals('404')
                && Errors[0].ErrorMessage.equalsIgnoreCase(RESPONSE_MEMBER_NOT_FOUND)
                ){
            Errors = null;
            Data = new ContactResourceDto();
            Data.Attributes = new ContactAttributesDto();
            Data.Attributes.Message = RESPONSE_MEMBER_NOT_FOUND;

        }
    }

    @AuraEnabled
    global ContactResourceDto Data {get; set;}


}