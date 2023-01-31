/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 30/08/2019.
 */

public with sharing class DeleteOpportunityLineItemRequestDto {
    private void init(){
        if (this.Data ==  null){
            this.Data = new List<SimpleResourceDto>();
        }
    }
    public DeleteOpportunityLineItemRequestDto(){
    init();
}
    public DeleteOpportunityLineItemRequestDto(Id opportunityLineItemId){
        this();
        addResourceForItemId(opportunityLineItemId);
    }

    public void addItem(Id anId){
        addResourceForItemId(anId);
    }

    private void addResourceForItemId(Id opportunityLineItemId) {
        SimpleResourceDto dto = buildResourceDto(opportunityLineItemId);
        this.Data.add(dto);
    }

    private SimpleResourceDto buildResourceDto(Id opportunityLineItemId) {
        SimpleResourceDto dto = new SimpleResourceDto();
        dto.Id = opportunityLineItemId;
        return dto;
    }

    public DeleteOpportunityLineItemRequestDto(List<String> lineItemIds) {
        for (String itemId : lineItemIds){
            addResourceForItemId(itemId);
        }
    }

    @AuraEnabled
    public List<SimpleResourceDto> Data {get; set;}
}