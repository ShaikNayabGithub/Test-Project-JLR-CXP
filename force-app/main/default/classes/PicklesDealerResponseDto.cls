/**
 * Created by Ethan Sargent on 6/11/19.
 */

public with sharing class PicklesDealerResponseDto extends BaseResponseDto {

    @AuraEnabled
    public List<PicklesDealerDetailsDto> dealers {get; set;}

    public PicklesDealerResponseDto(){
        init();
    }

    private void init(){
        dealers = new List<PicklesDealerDetailsDto>();
    }
}