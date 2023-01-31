public class VistaOSAImageController {
    
    @AuraEnabled
    public static VistaOSAImageWrapper getcurrentRecordData(String recordId,String baseUrl,String notAvailableUrl){
        VistaOSAImageWrapper imageIns = new VistaOSAImageWrapper();
        if(recordId == null 
           || baseUrl == null
           || notAvailableUrl == null){
               imageIns.hasError = true;
               imageIns.message = 'Invalid Asset Id';
               return imageIns;
           }
        
        Asset assetIns = getAssetData(recordId);
        if(assetIns == null){
            imageIns.hasError = true;
            imageIns.message = 'Order Number not available in Asset Record';
            return imageIns;
        }
        List<VistaOSAInteriorWrapper> VistaOSAInteriorWrapperList = new List<VistaOSAInteriorWrapper>();
        List<VistaOSAExteriorWrapper> VistaOSAExteriorWrapperList = new List<VistaOSAExteriorWrapper>();
        for(integer i=1;i<=5;i++){
            VistaOSAInteriorWrapper intWrap = new VistaOSAInteriorWrapper();
            
            String interiorUrl = baseUrl+'/'+assetIns.Order_Number__c+'/Int/'+i+'.jpg';
            Boolean validIntImage = checkImage(interiorUrl);
            system.debug('interiorUrl --> '+interiorUrl);
            system.debug('validIntImage --> '+validIntImage);
            if(validIntImage != null && validIntImage){
                intWrap.imageUrl = interiorUrl;
            }else{
                intWrap.imageUrl = notAvailableUrl;
            }
            
            intWrap.header = i;
            VistaOSAInteriorWrapperList.add(intWrap);
            
            VistaOSAExteriorWrapper extWrap = new VistaOSAExteriorWrapper();
            String exteriorUrl = baseUrl+'/'+assetIns.Order_Number__c+'/Ext/'+i+'.jpg';
            Boolean validExtImage = checkImage(exteriorUrl);
            system.debug('exteriorUrl --> '+exteriorUrl);
            system.debug('validExtImage --> '+validExtImage);
            if(validExtImage != null && validExtImage){
                extWrap.imageUrl = exteriorUrl;
            }else{
                extWrap.imageUrl = notAvailableUrl;
            }
            extWrap.header = i;
            VistaOSAExteriorWrapperList.add(extWrap);
        }
        imageIns.VistaOSAExteriorWrapperList = VistaOSAExteriorWrapperList;
        imageIns.VistaOSAInteriorWrapperList = VistaOSAInteriorWrapperList;
        imageIns.hasError = false;
        return imageIns;
    }
    
    public static Asset getAssetData(String recordId){
        List<Asset> assetList = [select id,VIN__c,Order_Number__c,Description_Group_ID__c,Product2Id from Asset where id =: recordId and Order_Number__c != null];
        if(assetList != null && !assetList.isEmpty()){
            return assetList.get(0);
        }
        return null;
    }
    
    public static Boolean checkImage(String imageurl){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(imageurl);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('Status Code --> '+res.getStatusCode());
        integer statusCode = res.getStatusCode();
        if(statusCode == 200){
            return true;
        }
        return false;
    }
    
    public class VistaOSAImageWrapper{
        @AuraEnabled  public List<VistaOSAInteriorWrapper> VistaOSAInteriorWrapperList;
        @AuraEnabled  public List<VistaOSAExteriorWrapper> VistaOSAExteriorWrapperList;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean hasError;
    }
    
    public class VistaOSAInteriorWrapper{
        @AuraEnabled  public String imageUrl;
        @AuraEnabled  public integer header;
    }
    public class VistaOSAExteriorWrapper{
        @AuraEnabled  public String imageUrl;
        @AuraEnabled  public integer header;
    }
}