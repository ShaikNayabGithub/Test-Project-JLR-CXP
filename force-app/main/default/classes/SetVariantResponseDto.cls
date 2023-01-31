/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 30/08/2019.
 */

global with sharing class SetVariantResponseDto extends BaseResponseDto{

private void init(){

    if (this.Data == null){
        this.Data = new List<OpportunityLineItemResourceDto>();
    }
}

    global SetVariantResponseDto(){
        init();
    }

    global SetVariantResponseDto(GetOpportunityLineItemsResponseDto items){
        this();
        this.Data = items.Data;
    }


    global void addErrors(Exception ex){
        if (this.Errors == null){
            this.Errors = new List<ErrorDto>();
        }
        this.Errors.add(new ErrorDto(ex));
    }

    @AuraEnabled
    global List<OpportunityLineItemResourceDto> Data {get; set;}


}