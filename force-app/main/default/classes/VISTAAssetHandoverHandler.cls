public class VISTAAssetHandoverHandler {
    public static Id dealerOwnedRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('Dealer_Owned').getRecordTypeId();
    public static Id OUVRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('OUV').getRecordTypeId();
    public static Id newRetailRecordTypeId = Schema.SObjectType.RDA__c.getRecordTypeInfosByDeveloperName().get('New_Retail').getRecordTypeId();
    
    @future(callout=true) 
    public static void VISTARequestSenderFuture(String RDAId){
        VISTARequestSender(RDAId);
    }
    public static void VISTARequestSender(String RDAId){
        RDA__c currentRDA = [SELECT Id,Asset__c,RecordtypeId, Handover_Date__c,VISTA_Response__c, Asset__r.Brand__r.Name,Asset__r.VIN__c,Asset__r.Order_Number__c, Submitted_Status__c,Account__r.Country_ISO_Code__c 
                             FROM RDA__c WHERE Id=:RDAId];
        
        
        if(currentRDA.RecordTypeId == dealerOwnedRecordTypeId ||currentRDA.RecordTypeId == OUVRecordTypeId || currentRDA.RecordTypeId == newRetailRecordTypeId ){
            String endPointURL = 'https://xmlservices52qa.jlrext.com:1115/Service/mss/IF-ORD27';    
            String getRequestBody = '<?xml version="1.0" encoding="UTF-8"?>'+
                '<PostBrandOccurrence releaseID="1.1" systemEnvironmentCode="Production" xmlns="http://www.ford.com/oagis"  xmlns:oa="http://www.openapplications.org/oagis/9" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
                '<oa:ApplicationArea> <oa:Sender> <oa:LogicalID>'+ currentRDA.Asset__r.Brand__r.Name+'</oa:LogicalID> <oa:ComponentID>CXP-'+ currentRDA.Account__r.Country_ISO_Code__c +'</oa:ComponentID> <oa:TaskID>Handover</oa:TaskID>'+
                ' <oa:AuthorizationID>CXP-'+ currentRDA.Account__r.Country_ISO_Code__c +'</oa:AuthorizationID>'+
                '</oa:Sender> <oa:CreationDateTime>'+string.valueof(currentRDA.Handover_Date__c).substring(0,10)+'T00:00:00</oa:CreationDateTime>';
            getRequestBody = getRequestBody+ ' <oa:BODID>'+RDAId+'</oa:BODID> </oa:ApplicationArea> <DataArea> <oa:Post/> <BrandOccurrence> <OrderTransactionCommonData>';
            if(currentRDA.Asset__r.Brand__r.Name.equalsIgnoreCase('Land Rover')){
                getRequestBody = getRequestBody+' <Brand>SAL</Brand> ';
            }else if(currentRDA.Asset__r.Brand__r.Name.equalsIgnoreCase('Jaguar')){               
                getRequestBody = getRequestBody+' <Brand>SAJ</Brand> '; 
            }            
            getRequestBody =getRequestBody+ ' <BrandProcessDateTime>'+string.valueof(currentRDA.Handover_Date__c).substring(0,10)+'T00:00:00</BrandProcessDateTime> </OrderTransactionCommonData> ';
            
            if(currentRDA.Asset__r.Order_Number__c != null){
                getRequestBody = getRequestBody+' <MetaOrderNumber>'+currentRDA.Asset__r.Order_Number__c +'</MetaOrderNumber>';
            }else{
                getRequestBody = getRequestBody+' <VIN>'+currentRDA.Asset__r.VIN__c +'</VIN> ';            
            }
            
            getRequestBody = getRequestBody+' <BrandEventDateTime>'+string.valueof(currentRDA.Handover_Date__c).substring(0,10)+'T00:00:00</BrandEventDateTime> <ChangeType>HANDOVER</ChangeType> </BrandOccurrence> </DataArea> </PostBrandOccurrence>';
            Http http= new Http();
            HttpRequest request=new HttpRequest(); 
            try{           
                request.setEndpoint('callout:VISTA');
                request.setMethod('POST');
                request.setTimeout(120000);
                // request.setClientCertificateName('sfxmlgw');
                request.setHeader('Content-Type','text/xml;charset=UTF-8');      
                request.setBody(getRequestBody);
                HttpResponse response = http.send(request);
                system.debug(response.getbody());
                if(response.getStatus().equalsIgnoreCase('OK') && response.getStatusCode() == 200){         
                    SaveLog(response, request,'Success',null);          
                    String jsonContent = XmlParser.xmlToJson(response.getbody());  
                    VISTAResponseWrapper responseWrapper = VISTAResponseWrapper.parse(jsonContent.replaceAll('\n','').replaceAll('\r',''));
                    if(responseWrapper.ConfirmPostBrandOccurrence.DataArea.PostBrandOccurrence.AcceptRejectIndicator.equalsIgnoreCase('A')){
                        currentRDA.Submitted_Status__c = 'Completed';
                        currentRDA.VISTA_Response__c = 'Success';
                    }else if(responseWrapper.ConfirmPostBrandOccurrence.DataArea.PostBrandOccurrence.AcceptRejectIndicator.equalsIgnoreCase('R')){
                        currentRDA.Submitted_Status__c = 'Failed';
                        currentRDA.VISTA_Response__c = responseWrapper.ConfirmPostBrandOccurrence.DataArea.PostBrandOccurrence.Messages.Message.Description;
                    }
                    update currentRDA;
                }else{   
                    SaveLog(response, request,'Error',null);  
                }            
            }catch(exception error){            
                SaveLog(null, request,'Error', error.getMessage());  
            }
            
            
        }else{
            currentRDA.Submitted_Status__c = 'Completed';
            currentRDA.VISTA_Response__c = '';
            currentRDA.Submitted_Date__c = null;
            update currentRDA;
        }
        
    }
    
    private static void SaveLog( HttpResponse response, HttpRequest request, String status, string exceptionError){
        Integration_Log__c log = new Integration_Log__c();   
        if(response != null) log.response__c = JSON.serialize(response.getBody()); 
        else log.System_Error__c = exceptionError;
        log.Request__c = JSON.serializePretty(' Request Header:- Content-Type:  '+request.getHeader('Content-Type') + '---- Request Body:  ' +request.getBody());
        log.status__c = status;
        log.Http_Method__c = 'POST';
        log.requestURI__c = System.Label.VISTA_URI; 
        log.Service__c = 'VISTA Service';
        insert log;
        system.debug(log);
    }
    
}