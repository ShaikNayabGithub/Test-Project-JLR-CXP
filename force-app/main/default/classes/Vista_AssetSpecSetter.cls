public class Vista_AssetSpecSetter {
    public void Set(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
    {
        if(request.VistaVehicleOrder.Specification == null) { return; }
        Product2 derivative = requestCollection.Derivatives.get(request.VistaVehicleOrder.Specification.DescriptionGroupId);
        List<KeyValuePair> availableColours = new List<KeyValuePair>();
        Interior_Colour interiorColourHelper= new Interior_Colour();
        map<String,Ordering_Market_Country_ISO_Code__mdt> orderingMapCodeMap = new map<String,Ordering_Market_Country_ISO_Code__mdt>();
        for(Ordering_Market_Country_ISO_Code__mdt orderIns : Ordering_Market_Country_ISO_Code__mdt.getAll().values()){
            if(orderIns.Country__c != null && orderIns.Country_Code__c != null){
                orderingMapCodeMap.put(orderIns.Country__c,orderIns);
            }
        }
         
        if(derivative != null) {
            asset.Derivative__c = derivative.Id;
            asset.Brand__c = derivative.Make__c;
            asset.Model__c = derivative.Model__c;
            
            asset.Body_Style__c = derivative.Body_Style__c;
            asset.Engine__c = derivative.Engine__c;
            asset.Wheel_Base__c = derivative.Wheel_Base__c;
            asset.Wheel_Driven__c = derivative.Wheel_Driven__c;
            if(String.isBlank(asset.Transmission__c)) {
                SObjectUtilities.SetIfNotBlank(asset, Schema.sObjectType.Asset.fields.Transmission__c, 
                                               derivative.Transmission__c);
            }
            if(derivative.Model__r != null && String.isNotBlank(derivative.Model__r.Model_Colours__c)) {
                availableColours = (List<KeyValuePair>)JSON.deserialize(derivative.Model__r.Model_Colours__c, 
                                                                        List<KeyValuePair>.class);
            }
        }
        
        if(request.VistaVehicleOrder.Specification.Features == null) { return; }       
        
        
        System.debug('market is: '+request.Request.Market__c); 
        
        if(asset != null 
           && asset.id == null){
               asset.New_or_Used__c = 'New';
           }
        
        if(request != null 
           && request.Request != null 
           && request.Request.Market_Description__c != null 
           && request.Request.Market__c != null
           && orderingMapCodeMap.containskey(request.Request.Market_Description__c)){
               Ordering_Market_Country_ISO_Code__mdt countryCodeIns = orderingMapCodeMap.get(request.Request.Market_Description__c);
               if(countryCodeIns.Country_Code__c == request.Request.Market__c || countryCodeIns.Vista_Country_Code__c == request.Request.Market__c){                       
                   if(asset != null 
                      && asset.id == null){
                          asset.Ordering_Market__c = orderingMapCodeMap.get(request.Request.Market_Description__c).Country_Code__c; 
                      } else if(asset != null 
                                && asset.id != null 
                                && asset.Ordering_Market__c == null){
                                    asset.Ordering_Market__c = orderingMapCodeMap.get(request.Request.Market_Description__c).Country_Code__c; 
                                }
               }
           }
        
        Interior_Colour__c intColour;
        
        for(Vista_OrderService.Feature feature : request.VistaVehicleOrder.Specification.Features) {
            
            if(feature.FeatureType == 'TRIM') {
                System.debug('inside if for TRIM');   
                //code from vista
                asset.Interior_Colour_Code_Vista__c=feature.FeatureCode;
                //it requires populating a map before
                //simplified code
                intColour= interiorColourHelper.GetCodeForMarket(feature.FeatureCode,request.Request.Market__c);
                
                if(intColour!=null)
                {
                    if(asset.Interior_colour_code__c==null){
                        asset.Interior_colour_code__c= intColour.cxp_code__c;
                        asset.Interior_Color__c= intColour.cxp_description__c;
                        asset.Interior_Colour_Code_Vista__c=intColour.source_code__c;
                        asset.Interior_colour_BRS__c=intColour.source_description__c;
                    }    
                }
                
                
            }
            
            if(feature.FeatureType == 'PCOL') {
                for(KeyValuePair colour : availableColours) {
                    if(feature.FeatureCode == colour.Key) {
                        asset.Exterior_Colour__c = colour.Value;
                        asset.Exterior_Colour_Code__c = colour.Key;
                        break;
                    }
                }
            } else if(feature.Featuretype == 'TRAN') {
                asset.Transmission__c = feature.FeatureCode;
            }
            
            if(feature.FeatureType == 'YEAR'){
                if(asset != null 
                   && asset.id != null  
                   && asset.Model_Year__c == null || asset.Model_Year_Code__c == null){
                       asset.Model_Year_Code__c = feature.FeatureCode;
                   }else if(asset != null 
                            && asset.id == null){
                                asset.Model_Year_Code__c = feature.FeatureCode;
                            }
            }
            
        }
    }
}