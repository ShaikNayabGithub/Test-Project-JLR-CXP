/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 28/08/2019.
 */

public with sharing class OpportunityLineItemsController {


    @AuraEnabled
    public static CreateOpportunityLineItemResponseDto create(CreateOpportunityLineItemRequestDto request) {
        System.debug('>> OpportunityLineItemsController.create(Request : ' + JSON.serialize(request) + ')');

        List<OpportunityLineItem> items = new List<OpportunityLineItem>();

        for (OpportunityLineItemResourceDto dto : request.Data) {
            OpportunityLineItem item = new OpportunityLineItem();
            item.Product2Id = dto.Attributes.Product2Id;
            item.Quantity = dto.Attributes.Quantity;
            item.OpportunityId = dto.Attributes.OpportunityId;
            item.TotalPrice = dto.Attributes.TotalPrice;
            item.PricebookEntryId = dto.Attributes.PricebookEntryId;
            item.Assignment_Type__c = dto.Attributes.AssignmentType;
            items.add(item);
        }

        insert items;

        CreateOpportunityLineItemResponseDto response = new CreateOpportunityLineItemResponseDto(items);
        System.debug('Response: ' + JSON.serialize(response));
        System.debug('<< OpportunityLineItemsController.create()');
        return response;
    }

    @AuraEnabled(Cacheable=false)
    public static DeleteOpportunityLineItemsResponseDto deleteAll(DeleteOpportunityLineItemsRequestDto request) {

        DeleteOpportunityLineItemsResponseDto response = new DeleteOpportunityLineItemsResponseDto();
        try {
            List<OpportunityLineItem> items = [
                    SELECT Id
                    FROM OpportunityLineItem
                    WHERE OpportunityId = :request.OpportunityId
            ];

            delete items;
        } catch (Exception e) {
            response.Errors.add(new ErrorDto(e));
        }
        return response;

    }

    @AuraEnabled
    public static DeleteOpportunityLineItemResponseDto remove(DeleteOpportunityLineItemRequestDto request) {
        System.debug('>> DeleteOpportunityLineItemResponseDto');
        System.debug('Request: ' + JSON.serialize(request));
        DeleteOpportunityLineItemResponseDto response = new DeleteOpportunityLineItemResponseDto();
        try {
            Set<Id> idList = new Set<Id>();
            for (SimpleResourceDto item : request.Data) {
                idList.add(item.Id);
            }
            List<Database.DeleteResult> results = Database.delete(new List<Id>(idList), false);
            response.Message = 'Item Count : ' + results.size();
            for (Database.DeleteResult r : results) {
                if (!r.isSuccess()) {
                    for (Database.Error error : r.getErrors()) {
                        response.addError(error);
                    }

                }
            }


        } catch (Exception ex) {
            response.addError(ex);
            System.debug('Response: ' + JSON.serialize(response));
            System.debug('<< DeleteOpportunityLineItemResponseDto');
        }
            return response;
    }

    @AuraEnabled
    public static GetOpportunityLineItemsResponseDto get(GetOpportunityLineItemsRequestDto request){
        System.debug('>> OpportunityLineItemsController.get(Request : ' + JSON.serialize(request) + ')');
        List<OpportunityLineItem> items = [
        SELECT
        Id,
        Assignment_Type__c,
        OpportunityId,
        Product2Id,
        Product2.Model_Alternative__c,
        Product2.Specification_Pack_Alternative__c,
        Product2.Engine_Type_Alternative__c,
        Product2.Model_Year__c,
        Product2.Service_Plan__c,
        Product2.Product_Description__c,
        ProductCode,
        Name,
        PricebookEntryId,
        PricebookEntry.Pricebook2Id,
        Discount,
        TotalPrice,
        UnitPrice,
        ListPrice,
        ServiceDate,
        Subtotal,
        Quantity,
        Brand__c,
        Model__c,
        Product_Brand_Hidden__c,
        Product_Derivative_Hidden__c,
        Product_Model_Code_Hidden__c,
        Asset__c,
        Asset__r.VIN__c,
        Asset__r.Name,
        Asset__r.Exterior_Colour__c,
        Status__c,
        Vista_Order_Number__c,
        Line_Items__c,
        Licence_Plate__c,
        Has_Asset__c,
        Has_VIN__c,
        Model_Family__c,
        Product_Description__c,
        Product2.Name,
        Product2.RecordTypeId,
        Product2.RecordType.DeveloperName
        FROM OpportunityLineItem
        WHERE OpportunityId = :request.OpportunityId
        ];

        GetOpportunityLineItemsResponseDto response = new GetOpportunityLineItemsResponseDto(items);
        System.debug('<< OpportunityLineItemsController.get() Response : ' + JSON.serialize(response) );
        return response;
    }
}