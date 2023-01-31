public class BRS_FeatureExtractor {
    private final JSONDeserializer deserializer;
    
    
    public BRS_FeatureExtractor(JSONDeserializer deserializer)
    {
        this.deserializer = deserializer;
    }
    
    
    public Map<BRS_Service.Feature, BRS_Request__c> Extract(List<BRS_Request__c> requests)
    {
        Map<BRS_Service.Feature, BRS_Request__c> featureMap = new Map<BRS_Service.Feature, BRS_Request__c>();
        
        for(BRS_Request__c request : requests) {
            Map<String, BRS_Service.Feature> featureByCodeMap = new Map<String, BRS_Service.Feature>();
            
            List<BRS_Service.Feature> requestFeatures = (List<BRS_Service.Feature>)this.deserializer.DeserializeSingle(request.Features__c, BRS_Service.FeatureListType);
            List<BRS_Service.Derivative> derivatives = (List<BRS_Service.Derivative>)this.deserializer.DeserializeSingle(request.Derivatives__c, BRS_Service.DerivativeListType);
            
            this.AddFeaturesToMap(requestFeatures, featureByCodeMap);
            this.AddDerivativeFeaturesToMap(derivatives, featureByCodeMap);
            
            this.MapRequestByFeatures(featureByCodeMap.Values(), request, featureMap);
        }
        
        return featureMap;
    }
    
    
    private void AddFeaturesToMap(List<BRS_Service.Feature> requestFeatures, Map<String, BRS_Service.Feature> featureByCodeMap)
    {
        for(BRS_Service.Feature feature : requestFeatures){
            featureByCodeMap.put(feature.Code, feature);
        }
    }
    
    private void AddDerivativeFeaturesToMap(List<BRS_Service.Derivative> derivatives, Map<String, BRS_Service.Feature> featureByCodeMap)
    {
        for(BRS_Service.Derivative derivative : derivatives) {
            this.AddNewFeature(derivative.BodyStyle, ProductUtilities.BodyStyleFieldName, featureByCodeMap);
            this.AddNewFeature(derivative.Engine, ProductUtilities.EngineFieldName, featureByCodeMap);
            this.AddNewFeature(derivative.WheelBase, ProductUtilities.WheelBaseFieldName, featureByCodeMap);
            this.AddNewFeature(derivative.Transmission, ProductUtilities.TransmissionFieldName, featureByCodeMap);
            this.AddNewFeature(derivative.WheelDriven, ProductUtilities.WheelDrivenFieldName, featureByCodeMap);
            //this.AddNewFeature(derivative.FuelType, ProductUtilities.FuelTypeFieldName, featureByCodeMap);
        }
    }
    
    private void MapRequestByFeatures(List<BRS_Service.Feature> requestFeatures, BRS_Request__c request, Map<BRS_Service.Feature, BRS_Request__c> featureMap)
    {
        for(BRS_Service.Feature feature : requestFeatures) {
            featureMap.put(feature, request);
        }
    }
    
    private void AddNewFeature(String code, String fieldName, Map<String, BRS_Service.Feature> featureMap)
    {
        if(String.isEmpty(code) || featureMap.ContainsKey(code)) { return; }
        
        BRS_FeatureGroupFieldMappingByCode__c fieldSetting = BRS_FeatureUtilities.FeatureGroupFieldMappingByFieldName.get(fieldName.left(fieldName.length() -3));
        if(fieldSetting == null) { return; }
        
        BRS_Service.Feature newFeature = new BRS_Service.Feature();
        newFeature.Code = code;
        newFeature.FeatureGroup = fieldSetting.Name;
        featureMap.put(code, newFeature);
    }
}