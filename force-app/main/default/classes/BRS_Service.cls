global with sharing class BRS_Service { 
    webservice static void WsdlVersion_0_2(){}
    
    public static Type FeatureListType = Type.forName('List<BRS_Service.Feature>');
    public static Type DerivativeListType = Type.forName('List<BRS_Service.Derivative>');
    public static Type ModelListType = Type.forName('List<BRS_Service.Model>');
    
    
    webservice static Response UpsertBRSExport(BRSExport BRSExport, List<FeatureGroup> FeatureGroups, List<DisplayGroup> DisplayGroups, List<Feature> Features, 
        List<Model> Models, List<Derivative> Derivatives)
    {
        Response response = new Response();
        Integration_Log__c log= new Integration_Log__c();
        
        try
        {
            BRS_RequestCreator requestCreator = new BRS_RequestCreator();
            requestCreator.CreateRequests(BRSExport, Features, Models, Derivatives);
            log.status__c='Success';
        }
        catch(BRS_NoUsefulDataException e)
        {
            response.ErrorCode = System.Label.JLRBusinessErrorCode;
            response.ResponseMessage = System.Label.BRSNoUsefulDataMessage;
            log.status__c='Error';
        }
        catch(Exception e)
        {
            response.ErrorCode = System.Label.JLRTechnicalErrorCode;
            response.IsSuccess = false;  
            response.ResponseMessage = e.getMessage();
            log.status__c='Error';
        }
        finally{
      
        log.request__c=String.valueof(BRSExport)+'/n'+String.valueOf(FeatureGroups)+'/n'+string.valueOf(DisplayGroups)+'/n'+String.valueOf(Features)+'/n'+String.valueOf(Models)+'/n'+String.valueOf(Derivatives);
        log.Response__c=String.valueOf(response);
        log.service__c='BRS Service';
        insert log;
        }
        
        return response;
    }
    
    
    global class BRSExport
    {
        webservice Integer Serial;
        webservice String Market;
        webservice String MarketDescription;
        webservice String Brand;
        webservice String ShortBrand;
        webservice List<String> Currencies;
    }
    
    global class FeatureGroup//not used
    {
        webservice String Code;
        webservice String Description;
    }
    
    global class DisplayGroup//not used
    {
        webservice String Id;
        webservice String Language;
        webservice String Description;
    }
    
    global class Feature implements I_Serializable
    {
        webservice String Code;
        webservice String DisplayGroup;
        webservice String FeatureGroup;
        webservice List<Description> Descriptions;
        
        public Boolean IsEmpty()
        {
            return (String.isEmpty(Code));
        }
    }
    
    global class Description
    {
        webservice String Language;
        webservice String Text;
    }
    
    global class Model implements I_Serializable
    {
        webservice String Code;
        webservice String Description;
        
        public Boolean IsEmpty()
        {
            return (String.isEmpty(Code) && String.isEmpty(Description));
        }
    }
    
    global class Derivative implements I_Serializable
    {
        webservice String DescriptionGroupId;
        webservice String ModelCode;
        webservice String Name;
        webservice String Language;
        webservice String BodyStyle;
        webservice String Engine;
        webservice String WheelBase;
        webservice String Transmission;
        webservice String WheelDriven;
        webservice String Colour;
        webservice String FuelType;
        webservice String BrochureModel;
        
        public Boolean IsEmpty()
        {
            return (String.isEmpty(DescriptionGroupId) && String.isEmpty(Name));
        }
    }
    
    global class Response{
        webservice boolean IsSuccess;
        webservice string ErrorCode;
        webservice string ResponseMessage;
        
        
        public Response()
        {
            this.IsSuccess = true;
        }
    }
}