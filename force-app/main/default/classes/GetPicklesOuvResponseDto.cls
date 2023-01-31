/**
 * Created by Nick on 16/10/2019.
 */

global with sharing class GetPicklesOuvResponseDto extends BaseResponseDto{

    global GetPicklesOuvResponseDto(){
        super();
        init();
    }

    global GetPicklesOuvResponseDto(List<Role__c> roles){
        this();
        for (Role__c role : roles){
            System.debug(JSON.serialize(role));
            this.Data.add(new PicklesOuvResourceDto(role));
        }
    }

    private void init(){
        if(this.Data == null){
            this.Data = new List<PicklesOuvResourceDto>();
        }
    }

	@AuraEnabled
    public List<PicklesOuvResourceDto> Data {get; set;}
}