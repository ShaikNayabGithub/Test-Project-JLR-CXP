@RestResource(urlMapping='/VistaSubscriptionEvent/*')
global  class VistaSubscriptionEventHandler {
    
    @HttpPost
    global static void doPost() {
        String respString;
        RestResponse response = RestContext.response;
        try{
            RestRequest req = RestContext.request;
            String apiKey = req.headers.get('x-api-key');
            system.debug('apiKey--> '+apiKey);          
            Vehicle_Order_Api_Config__mdt configIns = [select id,Private_Key__c from Vehicle_Order_Api_Config__mdt where DeveloperName = 'Vehicle_Order_Api'];
            system.debug('configIns --> '+configIns.Private_Key__c);
            set<String> eventSet = new  set<String>();
            set<String> statusCodeSet = new  set<String>();
            for(Vista_Subscription_Event_code__mdt stCode : Vista_Subscription_Event_code__mdt.getall().values()){
                if(stCode.IsActive__c){
                    eventSet.add(stCode.masterlabel);
                }
            }
            for(Vista_Event_Subscription_Status_Code__mdt stCode : Vista_Event_Subscription_Status_Code__mdt.getall().values()){
                if(stCode.IsActive__c && stCode.Status_Code__c != null){
                    statusCodeSet.add(String.valueof(stCode.Status_Code__c));
                }
            }
            
            Blob body = req.requestBody;
            String requestString = body.toString();
            if(requestString != null){
                VistaSubscriptionEventWrapper eventResp = new VistaSubscriptionEventWrapper();
                eventResp = (VistaSubscriptionEventWrapper)JSON.deserialize(requestString,VistaSubscriptionEventWrapper.class);
                if(eventResp != null){
                    Vista_Subscription_Event__c eventIns = new Vista_Subscription_Event__c();
                    if(apiKey != null 
                       && configIns.Private_Key__c != null 
                       && apiKey == configIns.Private_Key__c){
                           eventIns.Status__c = 'Unprocessed';
                       }else{
                           eventIns.Status__c = 'Invalid';
                       }                    
                    if(eventResp.event != null){
                        eventIns.Event__c = eventResp.event;
                    }
                    if(eventResp.source != null){
                        eventIns.Source__c = eventResp.source;
                    }
                    if(eventResp.sourceId != null){
                        eventIns.Source_Id__c = eventResp.sourceId;
                    }
                    if(eventResp.subscription != null){
                        eventIns.Subscription__c = eventResp.subscription;
                    }
                    if(eventResp.subscriptionType != null){
                        eventIns.Subscription_Type__c = eventResp.subscriptionType;
                    }
                    if(eventResp.timestamp != null){
                        System.Debug('DateValue is '+DateTime.ValueofGmt(eventResp.timestamp.replace('T', ' ')));
                        eventIns.Time_Stamp__c  = DateTime.ValueofGmt(eventResp.timestamp.replace('T', ' '));
                    }
                    if(eventResp.uri != null){
                        eventIns.URL__c = eventResp.uri;
                    } 
                    
                    eventIns.Event_Data__c = requestString;
                    if(eventResp.eventData != null && !eventResp.eventData.isEmpty()){
                        for(VistaSubscriptionEventWrapper.EventData eveData: eventResp.eventData){
                            if(eveData != null 
                               && eveData.key != null 
                               && eveData.value != null){
                                   if(eveData.key == 'commonOrderNo'){
                                       eventIns.OrderNo__c = eveData.value;
                                   }
                                   if(eveData.key == 'orderMarket'){
                                       eventIns.orderMarket__c = eveData.value;
                                   }
                                   if(eveData.key == 'iso3Country'){
                                       eventIns.iso3Country__c = eveData.value;
                                   }
                                   if(eveData.key == 'currentStatus'){
                                       eventIns.Current_Status__c = eveData.value;
                                   }
                                   if(eveData.key == 'placingOrganisationId'){
                                       eventIns.Placing_Organisation_Id__c = eveData.value;
                                   }
                                   if(eveData.key == 'brandOrderType'){
                                       eventIns.Brand_Order_Type__c = eveData.value;
                                   }
                                   if(eveData.key == '_orderEventNo'){
                                       eventIns.Order_Event_No__c = eveData.value;
                                   }
                                   if(eveData.key == 'productId'){
                                       eventIns.Product_Id__c = eveData.value;
                                   }
                                   if(eveData.key == 'programCode'){
                                       eventIns.Program_Code__c = eveData.value;
                                   }
                                   if(eveData.key == 'year'){
                                       eventIns.Year__c = eveData.value;
                                   }
                                   if(eveData.key == 'createdTs'){
                                       eventIns.createdTs__c = eveData.value;
                                   }
                               }
                        }
                    }
                    
                    if(eventIns.Status__c == 'Unprocessed' 
                       && (!eventSet.contains(eventIns.Event__c) || !statusCodeSet.contains(eventIns.Current_Status__c))){
                           eventIns.Status__c = 'Ignored';
                       }
                    
                    insert eventIns;
                    response.statusCode = 201;
                    response.responseBody = Blob.valueOf(eventIns.Id);
                }
            }
        }Catch(DMLException dmx){
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(dmx.getDmlMessage(0));
        }
        Catch(Exception ex){
            response.statusCode = 400;
            response.responseBody = Blob.valueOf(ex.getMessage()); 
        }
    }
}