/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/08/2019.
 */

global with sharing class CreateOpportunityLineItemRequestDto extends BaseRequestDto{

    private void init(){
        if (this.Data == null){
            this.Data = new List<OpportunityLineItemResourceDto>();
        }
    }
    global CreateOpportunityLineItemRequestDto(){
        super();
        init();
    }

    global CreateOpportunityLineItemRequestDto(SetVariantRequestDto request){
        this();
        OpportunityLineItemResourceDto dto = new OpportunityLineItemResourceDto();
        dto.Attributes.OpportunityId = request.OpportunityId;
        dto.Attributes.Quantity = request.Qty;
        dto.Attributes.Product2Id = request.VariantId;
        dto.Attributes.TotalPrice = request.TotalPrice;
        dto.Attributes.PricebookEntryId = request.PricebookEntryId;
        this.Data.add(dto);
    }

    global CreateOpportunityLineItemRequestDto(SetServicePlanRequestDto request){
        this();
        OpportunityLineItemResourceDto dto = new OpportunityLineItemResourceDto();
        dto.Attributes.OpportunityId = request.OpportunityId;
        dto.Attributes.Quantity = 1;
        dto.Attributes.TotalPrice = request.TotalPrice;
        dto.Attributes.Product2Id = request.ServicePlanId;
        dto.Attributes.PricebookEntryId = request.PricebookEntryId;
        dto.Attributes.AssignmentType = request.ServicePlanType;
        this.Data.add(dto);
    }

    public void addItems(List<OpportunityLineItemResourceDto> resources){
        this.Data.addAll(resources);
    }


    global List<OpportunityLineItemResourceDto> Data { get; set; }
}