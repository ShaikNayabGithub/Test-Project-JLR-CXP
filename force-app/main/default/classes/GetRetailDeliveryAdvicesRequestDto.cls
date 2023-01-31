/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/11/2019.
 */

global with sharing class GetRetailDeliveryAdvicesRequestDto extends BaseRequestDto{

    global  GetRetailDeliveryAdvicesRequestDto(){
        super();
        init();
    }

    private void init(){

    }

    global  GetRetailDeliveryAdvicesRequestDto(Date startDate){
        this();
        this.DateStart = startDate;
    }

    global Date DateStart {get; set;}
}