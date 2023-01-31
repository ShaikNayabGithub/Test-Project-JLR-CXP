/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

public with sharing class ProductTransformer {

    public static VariantResourceDto transformVariant(Product2 product){


        VariantResourceDto variant = new VariantResourceDto();
        variant.Id = product.Id;
        variant.Attributes.Name = product.Product_Description__c;

        //Make
        variant.Attributes.Make = product.Make__c;

        //Model
        variant.Attributes.Model = product.Model__c;

        //Product Code
        variant.Attributes.ProductCode = product.ProductCode;
        variant.Attributes.TrimBadge = product.Specification_Pack_Alternative__c;
        variant.Attributes.Engine = product.Engine_Type_Alternative__c;
        variant.Attributes.BodyStyle = product.BodyStyle_Alternative__c;
        variant.Attributes.Transmission = product.Transmission_Alternative__c;
        variant.Attributes.ModelYear = product.Model_Year__c;
        variant.Attributes.ServicePlanId = product.Service_Plan__c;

        //Populate Engine
        /*
        if (product.Engine__c != null){
            SimpleResourceDto engine = new SimpleResourceDto();
            engine.Id = product.Engine__c;
            List<Schema.PicklistEntry> picklistEntries = Product2.Engine__c.getDescribe().getPicklistValues();
            For (Schema.PicklistEntry entry : picklistEntries){
                if (entry.value.equalsIgnoreCase(engine.Id)){
                    //Use Translated Value
                    engine.Attributes.Name = entry.label;
                    break;
                }
            }


            //Flatten attributes for Mulesoft
            variant.Attributes.Engine = engine;
            variant.Attributes.Engine_Id = engine.Id;
            variant.Attributes.Engine_Name = engine.Attributes.Name;
        }

      */

        return variant;
    }

    public static VariantResourceDto transformVariant(PricebookEntry entry){


        VariantResourceDto variant = new VariantResourceDto();
        variant.Id = entry.Product2Id;
        variant.Attributes.Pricebook2Id = entry.Pricebook2Id;
        variant.Attributes.PricebookEntryId  = entry.Id;
        variant.Attributes.Name = entry.Product2.Product_Description__c;
        variant.Attributes.TrimBadge = entry.Product2.Specification_Pack_Alternative__c;
        variant.Attributes.Engine = entry.Product2.Engine_Type_Alternative__c;
        variant.Attributes.BodyStyle = entry.Product2.BodyStyle_Alternative__c;
        variant.Attributes.Transmission = entry.Product2.Transmission_Alternative__c;
        variant.Attributes.ModelYear = entry.Product2.Model_Year_Alternative_CXP__c;
        variant.Attributes.ServicePlanId = entry.Product2.Service_Plan__c;
/**
        //Make
        variant.Attributes.Make_Name = entry.Product2.Make__c;

        //Model
        variant.Attributes.Model_Name = entry.Product2.Make__c;

        //Product Code
        variant.Attributes.ProductCode = entry.Product2.ProductCode;

        //Populate Engine
        if (entry.Product2.Engine__c != null){
            SimpleResourceDto engine = new SimpleResourceDto();
            engine.Id = entry.Product2.Engine__c;
            List<Schema.PicklistEntry> picklistEntries = Product2.Engine__c.getDescribe().getPicklistValues();
            For (Schema.PicklistEntry ple : picklistEntries){
                if (ple.value.equalsIgnoreCase(engine.Id)){
                    engine.Attributes.Name = ple.label;
                    break;
                }
            }

            //Flatten attributes for Mulesoft
            //variant.Attributes.Engine = engine;
            variant.Attributes.Engine_Id = engine.Id;
            variant.Attributes.Engine_Name = engine.Attributes.Name;
        }


**/
        return variant;
    }

    public static List<VariantResourceDto> transformVariants(List<Product2> products){

        List<VariantResourceDto> variants = new List<VariantResourceDto>();
        For(Product2 product : products){

            variants.add(transformVariant(product));
        }
        return variants;
    }

    public static List<VariantResourceDto> transformVariants(List<PricebookEntry> entries){

        List<VariantResourceDto> variants = new List<VariantResourceDto>();
        For(PricebookEntry entry : entries){

            variants.add(transformVariant(entry));
        }
        return variants;
    }
}