/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 30/08/2019.
 */

global with sharing class GetOpportunityLineItemsResponseDto {

    global GetOpportunityLineItemsResponseDto(){
        init();
    }

    private void init(){
        if (this.Data == null){
            this.Data = new List<OpportunityLineItemResourceDto>();
        }
    }

    global GetOpportunityLineItemsResponseDto(List<OpportunityLineItem> items){
        this();
        For(OpportunityLineItem item : items){
            OpportunityLineItemResourceDto dto = new OpportunityLineItemResourceDto(item);
            this.Data.add(dto);
        }
    }

    @AuraEnabled
    global List<OpportunityLineItemResourceDto> Data {get; set;}
}