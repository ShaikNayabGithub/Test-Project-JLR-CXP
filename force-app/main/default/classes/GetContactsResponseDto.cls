/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class GetContactsResponseDto extends BaseResponseDto{

    global GetContactsResponseDto(){
        super();
        init();
    }

    global GetContactsResponseDto(List<ContactResourceDto> contacts){
        this();
        this.Data.addAll(contacts);
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<ContactResourceDto>();
        }
    }

    @AuraEnabled
    global List<ContactResourceDto> Data {get; set;}
}