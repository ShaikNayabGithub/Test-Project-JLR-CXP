public class BRS_ModelToProduct_Adapter implements BRS_Product_Adapter_I{
    private final JSONDeserializer deserializer;
    private final BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor;
    
    private static final Id RecordTypeId = ProductUtilities.RecordTypes.get('Model').Id;


    public BRS_ModelToProduct_Adapter(JSONDeserializer deserializer,
            BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor)
    {
        this.deserializer = deserializer;
        this.secondaryKeyExtractor = secondaryKeyExtractor;
    }
    
    
    public List<Product2> Convert(BRS_Request__c request, Map<String, Product2> productByProductCodeMap) 
    {
        List<Product2> products = new List<Product2>();
        Map<String,Interior_Colour_Map__c> InteriorColourMapForUpdate= New Map<String,Interior_Colour_Map__c>();
        Vehicle_Specification__c brand = VehicleSpecificationUtilities.Brands.get(request.Brand__c.toLowerCase());
        List<BRS_Service.Model> models = (List<BRS_Service.Model>)this.deserializer.DeserializeSingle(request.Models__c, BRS_Service.ModelListType);
        
        Map<String, KeyValuePair_LanguageSpecific> colourPairs = this.MapFeatures('PCOL', request);

        for(BRS_Service.Model model : models){
            Map<String, KeyValuePair_LanguageSpecific> modelColourPairs = colourPairs.clone();
            Product2 existingProduct = productByProductCodeMap.get(model.Code);

            if(existingProduct != null) {
                List<KeyValuePair_LanguageSpecific> existingColourPairs = (List<KeyValuePair_LanguageSpecific>)JSON.deserialize(existingProduct.Model_Colours__c, 
                        List<KeyValuePair_LanguageSpecific>.class);
                for(KeyValuePair_LanguageSpecific oldPair : existingColourPairs) {
                    if(!modelColourPairs.containsKey(oldPair.Key) ||
                            (oldPair.LanguageCode == 'EN' && 
                            modelColourPairs.get(oldPair.Key).LanguageCode != 'EN')) {
                        modelColourPairs.put(oldPair.Key, oldPair);
                    }
                }
            }

            String modelColoursString = JSON.serialize(modelColourPairs.values());

            if(existingProduct != null) {
                existingProduct.Model_Colours__c = modelColoursString;
            }
           
           //Interior colour 
           Map<String,String> interiorColourPairs=new Map<String,String>();
           interiorColourPairs=featuresToStringMap('TRIM', request);
           
           //Interior_Colour intColourHelper= new Interior_Colour();
           InteriorColourMapForUpdate.putAll(interior_Colour.UpdateSourceDescription(interiorColourPairs));
            
            Product2 product = new Product2(RecordTypeId = RecordTypeId,
                Name = model.Description,
                ProductCode = model.Code,
                Make__c = brand.Id,
                Model_Colours__c = modelColoursString);
            products.add(product);
        }
        
        upsert InteriorColourMapForUpdate.values();
        return products;
    }
    

    private Map<String, KeyValuePair_LanguageSpecific> MapFeatures(String featureGroup, BRS_Request__c request)
    {
        List<BRS_Service.Feature> requestFeatures = (List<BRS_Service.Feature>)this.deserializer.DeserializeSingle(request.Features__c, BRS_Service.FeatureListType);

        Map<String, KeyValuePair_LanguageSpecific> keyValuePairs = new Map<String, KeyValuePair_LanguageSpecific>();

        for(BRS_Service.Feature feature : requestFeatures) {
            if(feature.FeatureGroup != featureGroup) { continue; }

            KeyValuePair_LanguageSpecific keyValuePair = this.secondaryKeyExtractor.ConvertToKeyValuePair(feature);

            if(!keyValuePairs.containsKey(keyValuePair.Key) || 
                    (keyValuePairs.get(keyValuePair.Key).LanguageCode != 'EN' && 
                    keyValuePair.LanguageCode == 'EN')) {
                keyValuePairs.put(keyValuePair.Key, keyValuePair);
            }
        }

        return keyValuePairs;
    }
    
     private Map<String, String> featuresToStringMap(String featureGroup, BRS_Request__c request)
    {
        List<BRS_Service.Feature> requestFeatures = (List<BRS_Service.Feature>)this.deserializer.DeserializeSingle(request.Features__c, BRS_Service.FeatureListType);

        Map<String, String> keyValuePairs = new Map<String, String>();

        for(BRS_Service.Feature feature : requestFeatures) {
            if(feature.FeatureGroup != featureGroup) { continue; }

            KeyValuePair_LanguageSpecific keyValuePair = this.secondaryKeyExtractor.ConvertToKeyValuePair(feature);

           if(keyValuePair.LanguageCode=='EN')
               keyValuePairs.put(keyValuePair.Key, keyValuePair.value);
            
        }

        return keyValuePairs;
    }
    
    
}