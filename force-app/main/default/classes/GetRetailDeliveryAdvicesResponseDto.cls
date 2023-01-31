/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/11/2019.
 */

global with sharing class GetRetailDeliveryAdvicesResponseDto extends BaseResponseDto {

    global GetRetailDeliveryAdvicesResponseDto(){
        super();
        init();
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<RetailDeliveryResourceDto>();
        }
    }


    global GetRetailDeliveryAdvicesResponseDto(ErrorDto errorDto){
        this();
        if( this.Errors == null){
            this.Errors = new List<ErrorDto>();
        }
        this.Errors.add(errorDto);
    }

    global GetRetailDeliveryAdvicesResponseDto(List<RetailDeliveryResourceDto> resources){
        this();
        this.Data = resources;
    }

    global List<RetailDeliveryResourceDto> Data {get; set;}
}