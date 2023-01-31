public with sharing class VehicleOptionsController {
    
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityProductDerivatives(String opportunityId){
        return [
            SELECT Id, Product2Id, Name
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
            AND Product2.RecordType.DeveloperName = 'Derivative'
        ];
    }

    @AuraEnabled(cacheable=true)
    public static String getProductAddons(String opportunityId, String derivativeIdsJson){
        
        List<Id> derivativeIds = (List<Id>) JSON.deserialize(derivativeIdsJson, List<Id>.class);
        System.debug('derivativeIds');
        System.debug(derivativeIds);


        Map<Id, Product_Option_Mapping__c> derivativeProductOptions = new Map<Id, Product_Option_Mapping__c>([
            SELECT Id, Market_Standard_Required__c, Product__c, Product__r.Name, Option__c, Option__r.Name, Option__r.ProductCode, Option_Derivative_Price_Override__c
            FROM Product_Option_Mapping__c 
            WHERE Product__c IN :derivativeIds 
        ]);

        System.debug('derivativeProductOptions.values()');
        System.debug(derivativeProductOptions.values());

        Set<Id> productOptionIds = new Set<Id>();
        for(Product_Option_Mapping__c optionConfig : derivativeProductOptions.values()) {
            productOptionIds.add(optionConfig.Option__c);
        }

        System.debug('productOptionIds');
        System.debug(productOptionIds);


        Map<Id, OpportunityLineItem> selectedOptionsOppLineItems = new Map<Id, OpportunityLineItem>([
            SELECT Id, Product2Id, Quantity, UnitPrice
            FROM OpportunityLineItem 
            WHERE OpportunityId = :opportunityId AND product2Id NOT IN :derivativeIds
        ]);

        System.debug('opportunityId');
        System.debug(opportunityId);

        System.debug('selectedOptionsOppLineItems');
        System.debug(selectedOptionsOppLineItems);

        
        User currentUser = [SELECT Id, Country_ISO_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        System.debug('currentUser');
        System.debug(currentUser);

        Id countryPricebookId;
        for(CountryToPricebook__mdt meta : CountryToPricebook__mdt.getAll().values()) {
            if(meta.Country_ISO_Code__c == currentUser.Country_ISO_Code__c) {
                countryPricebookId = meta.PricebookId__c;
                break;
            }
        }
        System.debug('countryPricebookId');
        System.debug(countryPricebookId);

        List<PriceBookEntry> prices = [
            SELECT Id, Product2Id, UnitPrice
            FROM PriceBookEntry
            WHERE Pricebook2Id = :countryPricebookId AND IsActive = true AND Product2Id IN :productOptionIds
        ];

        System.debug('prices');
        System.debug(prices);

        Map<Id, Decimal> product2IdToPrice = new Map<Id, Decimal>();
        for(PriceBookEntry pbe : prices) {
            product2IdToPrice.put(pbe.Product2Id, pbe.UnitPrice);
        }

        System.debug('product2IdToPrice');
        System.debug(product2IdToPrice);

        Map<Id, Id> productIdToOppLineItemId = new Map<Id, Id>();
        for(OpportunityLineItem oli : selectedOptionsOppLineItems.values()) {
            productIdToOppLineItemId.put(oli.Product2Id, oli.Id);
        }

        

        System.debug('productIdToOppLineItemId');
        System.debug(productIdToOppLineItemId);

        
        

        List<OptionWrapper> availableOptions = new List<OptionWrapper>();
        for(Product_Option_Mapping__c optionMappingDefinition : derivativeProductOptions.values()) {
            OptionWrapper ow = new OptionWrapper();
            ow.id = optionMappingDefinition.Id;
            ow.optionId = optionMappingDefinition.Option__c;
            ow.optionName = optionMappingDefinition.Option__r.Name;
            ow.optionProductCode = optionMappingDefinition.Option__r.ProductCode; 
            ow.productId = optionMappingDefinition.Product__c;
            ow.productName = optionMappingDefinition.Product__r.Name;
            ow.marketMandatory = optionMappingDefinition.Market_Standard_Required__c;

            System.debug('optionMappingDefinition.Option__c');
            System.debug(optionMappingDefinition.Option__c);
            Id selctedOppLineItemId = productIdToOppLineItemId.get(optionMappingDefinition.Option__c);

            if(selctedOppLineItemId != null) {
                System.debug('Option already added to Opportunity');
                OpportunityLineItem selectedOppLineItem = selectedOptionsOppLineItems.get(selctedOppLineItemId);
                ow.selected = true;
                ow.opportunityProductId = selectedOppLineItem.Id;
                ow.quantity = selectedOppLineItem.Quantity;
                ow.unitPrice = selectedOppLineItem.UnitPrice;
            } else {
                System.debug('Option not yet added to Opportunity');
                ow.selected = false;

                if(optionMappingDefinition.Option_Derivative_Price_Override__c == null) {
                    ow.unitPrice = product2IdToPrice.get(optionMappingDefinition.Option__c);
                } else {
                    ow.unitPrice = optionMappingDefinition.Option_Derivative_Price_Override__c;
                }
                
            }
            System.debug('adding availabile option wrapper');
            System.debug(ow);
            availableOptions.add(ow);
        }

        System.debug('availableOptions');
        System.debug(availableOptions);

        AvailableOptionsWrapper aow = new AvailableOptionsWrapper();
        aow.options = availableOptions;

        return JSON.serialize(aow);
    }


    //Returns AvailableOptionsWrapper with set of Options with OpportunityLineItem.Id values. 
    //These are new/unknown to front end controller in the case of adding a new option
    // Options that are only updated are not returned (the controller already has these values);
    @AuraEnabled
    public static String changeProductOptions(String opportunityId, String productOptionJSON){
        System.debug('productOptionJSON');
        System.debug(productOptionJSON);

        OptionChangesWrapper changeData = (OptionChangesWrapper) JSON.deserialize(productOptionJSON, OptionChangesWrapper.class);
        AvailableOptionsWrapper returnedOptionWrapper = new AvailableOptionsWrapper();
        List<OptionWrapper> newlyCreatedOptions = new List<OptionWrapper>();

        System.debug(changeData);
        List<OpportunityLineItem> oppLineItemsToAdd = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oppLineItemsToRemove = new List<OpportunityLineItem>();
        if(changeData.toAdd != null) {
            for(OptionWrapper option : changeData.toAdd ) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Product2Id = option.optionId;
                oli.OpportunityId = opportunityId;
                oli.Quantity = option.quantity;
                oli.UnitPrice = option.unitPrice;
                oppLineItemsToAdd.add(oli);
            }
            System.debug('oppLineItemsToAdd');
            System.debug(oppLineItemsToAdd);
            insert oppLineItemsToAdd;

            for(OpportunityLineItem insertedLineItem : oppLineItemsToAdd) {
                OptionWrapper outputOption = new OptionWrapper();
                outputOption.opportunityProductId = insertedLineItem.Id;
                outputOption.optionId = insertedLineItem.Product2Id;
                newlyCreatedOptions.add(outputOption);
            }
        }

        if(changeData.toUpdate != null) {
            for(OptionWrapper option : changeData.toupdate ) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Id = option.opportunityProductId;
                if(option.quantity != null) {
                    oli.Quantity = option.quantity;
                }
                if(option.unitPrice != null) {
                    oli.UnitPrice = option.unitPrice;
                }
                
                oppLineItemsToUpdate.add(oli);
            }
            update oppLineItemsToUpdate;
        }

        if(changeData.toRemove != null) {
            for(OptionWrapper option : changeData.toRemove ) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Id = option.opportunityProductId;
                oppLineItemsToRemove.add(oli);
            }
            delete oppLineItemsToRemove;
        }

        returnedOptionWrapper.options = newlyCreatedOptions;
        return JSON.serialize(returnedOptionWrapper);
        
    }

    private class OptionChangesWrapper {
        List<Id> allChangedOptionIds = new List<Id>();
        List<OptionWrapper> toAdd = new List<OptionWrapper>();
        List<OptionWrapper> toUpdate= new List<OptionWrapper>();
        List<OptionWrapper> toRemove = new List<OptionWrapper>();
    }

    private class AvailableOptionsWrapper {
        List<OptionWrapper> options = new List<OptionWrapper>();
    }

    private class OptionWrapper {
        // Option Definition attributes - Mandatory Expected
        Id id;
        Id optionId; // product2 Id, such as "Accessory" record type. Child/Bundle Addon item
        String optionName;
        String optionProductCode;
        Id productId; // product2 Id, such as "Derivative" record type. Parent/Bundle definition
        String productName;
        Boolean selected;
        Boolean marketMandatory;

        // Opportunity Product attributes - Only set when Option is selected
        Id opportunityProductId;
        Decimal quantity;
        Decimal unitPrice;

        
        

    }

    
    
}