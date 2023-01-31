/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/08/2019.
 */

global with sharing class CreateOpportunityLineItemResponseDto extends BaseResponseDto{

    global CreateOpportunityLineItemResponseDto(){
        super();
        init();
    }

    private void init(){
        if(this.Data == null){
            this.Data = new List<SimpleResourceDto>();
        }

    }

    global CreateOpportunityLineItemResponseDto( List<OpportunityLineItem> items){
        this();
        For(OpportunityLineItem item : items){
            SimpleResourceDto dto = new SimpleResourceDto();
            dto.Id = item.Id;
            dto.Attributes.Name = item.Name;
            this.Data.add(dto);
        }

    }

    @AuraEnabled
    global List<SimpleResourceDto> Data {get; set;}
}