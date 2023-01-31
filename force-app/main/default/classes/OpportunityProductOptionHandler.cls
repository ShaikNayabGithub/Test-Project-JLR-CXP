public with sharing class OpportunityProductOptionHandler {
    public static void setMandatoryProductOptions(List<OpportunityLineItem> opportunityLineItems) {
        System.debug('setting Mandatory PRoduct Options');
        System.debug('opportunityLineItems');
        System.debug(opportunityLineItems);
        Set<Id> productIds = new Set<Id>();
        // Opportunity - List<"Addon-enabled product Ids">. Eg Derivatives
        Map<Id, List<Id>> opportunityIdToProductsId = new Map<Id, List<Id>>();
        for (OpportunityLineItem oli : opportunityLineItems) {
            System.debug('SD33 oli');
            System.debug(JSON.serializePretty(oli));
            if(oli.Enable_Automatic_Product_Add_Ons__c) {
                productIds.add(oli.Product2Id);
                if(opportunityIdToProductsId.get(oli.opportunityId) == null) {
                    opportunityIdToProductsId.put(oli.opportunityId, new List<Id>() );
                }
                List<Id> addedProductIds = opportunityIdToProductsId.get(oli.opportunityId);
                addedProductIds.add(oli.Product2Id);
                opportunityIdToProductsId.put(oli.opportunityId, addedProductIds); 
            }
        }

        System.debug('opportunityIdToProductsId');
        System.debug(opportunityIdToProductsId);

        if(productIds.size() == 0) {
            System.debug('no relevant products');
            return;
        }

        System.debug('productIds');
        System.debug(productIds);

        Map<Id, Product_Option_Mapping__c> mandatoryProductOptionDefinitions = new Map<Id, Product_Option_Mapping__c>([
            SELECT Id, Option__c, product__c, Option_Derivative_Price_Override__c
            FROM Product_Option_Mapping__c
            WHERE product__c IN :productIds AND Market_Standard_Required__c = true
        ]);

        System.debug('mandatoryProductOptionDefinitions');
        System.debug(mandatoryProductOptionDefinitions);

        Set<Id> mandatoryOptionIds = new Set<Id>();
        Map<Id, Set<Id>> productsToMandatoryOptions = new Map<Id, Set<Id>>();
        Map<String, Id> productionOptionByUniqueKey = new Map<String, Id>();
        for(Product_Option_Mapping__c productOptionDef : mandatoryProductOptionDefinitions.values()) {
            mandatoryOptionIds.add(productOptionDef.Option__c);
            
            if(productsToMandatoryOptions.get(productOptionDef.product__c) == null) {
                productsToMandatoryOptions.put(productOptionDef.product__c, new Set<Id>());
            }
            Set<Id> mandatoryOptions = productsToMandatoryOptions.get(productOptionDef.product__c);
            mandatoryOptions.add(productOptionDef.Option__c);
            productsToMandatoryOptions.put(productOptionDef.product__c, mandatoryOptions);
            if(productOptionDef.product__c != null && productOptionDef.Option__c != null) {
                String productIdOptionId = productOptionDef.product__c + '-' + productOptionDef.Option__c;
                productionOptionByUniqueKey.put(productIdOptionId, productOptionDef.Id);
            }
        }

        System.debug('productsToMandatoryOptions');
        System.debug(productsToMandatoryOptions);

        System.debug('mandatoryOptionIds');
        System.debug(mandatoryOptionIds);


        User currentUser = [SELECT Id, Country_ISO_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        Id countryPricebookId;
        for(CountryToPricebook__mdt meta : CountryToPricebook__mdt.getAll().values()) {
            if(meta.Country_ISO_Code__c == currentUser.Country_ISO_Code__c) {
                countryPricebookId = meta.PricebookId__c;
                break;
            }
        }
        if(Test.isRunningTest()) {
            countryPricebookId = Test.getStandardPricebookId();
        }

        List<PriceBookEntry> prices = [
            SELECT Id, Product2Id, UnitPrice
            FROM PriceBookEntry
            WHERE Pricebook2Id = :countryPricebookId AND IsActive = true AND Product2Id IN :mandatoryOptionIds
        ];

        System.debug('prices');
        System.debug(prices);

        Map<Id, PriceBookEntry> productIdToPriceBookEntry = new Map<Id, PriceBookEntry>();
        for(PriceBookEntry pbe : prices) {
            productIdToPriceBookEntry.put(pbe.Product2Id, pbe);
        }

        System.debug('productIdToPriceBookEntry');
        System.debug(productIdToPriceBookEntry);



        List<OpportunityLineItem> oppLinesToAdd = new List<OpportunityLineItem>();

        //For Each Opportunity 
        // Expect 1 in normal use, bulkified for future requirements.
        for(Id opportunityId : opportunityIdToProductsId.keySet()) {
            System.debug('opportunityId: ' + opportunityId);

            List<Id> relatedProductIds = opportunityIdToProductsId.get(opportunityId);
            if(relatedProductIds == null) {
                continue;
            }

            //For each Product (derivative) in that Opportunity
            for(Id productId : relatedProductIds) {

                Set<Id> relatedMandatoryOptionIds = productsToMandatoryOptions.get(productId);
                if(relatedMandatoryOptionIds == null) {
                    continue;
                }

                // For each mandatory option
                for(Id mandatoryOptionId : relatedMandatoryOptionIds) {
                    OpportunityLineItem oli = new OpportunityLineItem();

                    String productIdOptionId = productId + '-' + mandatoryOptionId;
                    Id optionMappingId = productionOptionByUniqueKey.get(productIdOptionId);

                    PricebookEntry pbe = productIdToPriceBookEntry.get(mandatoryOptionId);

                    oli.opportunityId = opportunityId;
                    oli.Product2Id = mandatoryOptionId;
                    //oli.UnitPrice = pbe.UnitPrice;
                    oli.quantity = 1; 
                    oli.PricebookEntryId = pbe.Id;
                    oli.TotalPrice = pbe.UnitPrice;

                    // Price Overrides
                    if(optionMappingId != null) {
                        Product_Option_Mapping__c optionMapping = mandatoryProductOptionDefinitions.get(optionMappingId);
                        if(optionMapping.Option_Derivative_Price_Override__c != null) {
                            //oli.UnitPrice = optionMapping.Option_Derivative_Price_Override__c;
                            oli.TotalPrice = optionMapping.Option_Derivative_Price_Override__c;
                        }
                    }

                    oppLinesToAdd.add(oli);
                    System.debug('oli: ');
                    System.debug(oli);
                }
            }
        }

        System.debug('oppLinesToAdd');
        System.debug(oppLinesToAdd);

        if(oppLinesToAdd.size() > 0) {
            insert oppLinesToAdd;
        }
    }
    public static void removeProductOptionsOnDeleteOfParent(Map<Id, OpportunityLineItem> opportunityLineItems) {
        Set<Id> productIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>();
        for(OpportunityLineItem deleteLineItem : opportunityLineItems.values()) {
            if(deleteLineItem.Enable_Automatic_Product_Add_Ons__c) {
                productIds.add(deleteLineItem.product2Id);
                opportunityIds.add(deleteLineItem.opportunityId);
            }
        }

        if(productIds.size() == 0) {
            return;
        }

        List<Product_Option_Mapping__c> relatedOptions = [
            SELECT Id, Option__c
            FROM Product_Option_Mapping__c
            WHERE product__c IN :productIds
        ];

        Set<Id> relatedProductOptionIds = new Set<Id>();
        for(Product_Option_Mapping__c relatedOptionDefinition : relatedOptions) {
            relatedProductOptionIds.add(relatedOptionDefinition.Option__c);
        }

        List<OpportunityLineItem> childProductOptionsToDelete = [
            SELECT Id 
            FROM OpportunityLineItem
            WHERE opportunityId IN :opportunityIds 
            AND product2Id IN :relatedProductOptionIds 
            AND Id NOT IN :opportunityLineItems.keySet() 
        ];


        if(childProductOptionsToDelete.size() > 0) {
            //Set<Id> deleteIds = childProductOptionsToDelete.addAll();
            delete childProductOptionsToDelete;
        }
        

    }
}