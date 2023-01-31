public class VistaSubscriptionEventDataProcessor {
    
    public static void processVistaData(String orderNumber,List<Vista_Subscription_Event__c> eventList,Boolean isExistingAsset){
        map<Integer,Vista_Event_Subscription_Status_Code__mdt> statusCodeMap = new map<Integer,Vista_Event_Subscription_Status_Code__mdt>();
        for(Vista_Event_Subscription_Status_Code__mdt stCode : Vista_Event_Subscription_Status_Code__mdt.getall().values()){
            if(stCode.IsActive__c && stCode.Status_Code__c != null){
                statusCodeMap.put(integer.valueof(stCode.Status_Code__c),stCode);
            }
        }
        
        map<String,Vista_Subscription_Event_code__mdt> eventCodesMap = new map<String,Vista_Subscription_Event_code__mdt>();
        for(Vista_Subscription_Event_code__mdt stCode : Vista_Subscription_Event_code__mdt.getall().values()){
            if(stCode.IsActive__c){
                eventCodesMap.put(stCode.masterlabel,stCode);
            }
        } 
        
        map<String,String> vistaOrderMap = new map<String,String>();
        map<Id,Vista_Subscription_Event__c> subscriptionErrorEventMap = new map<Id,Vista_Subscription_Event__c>();
        map<Id,Vista_Subscription_Event__c> subscriptionEventMap = new map<Id,Vista_Subscription_Event__c>();
        
        
        for(Vista_Subscription_Event__c eveIns : eventList){
            if(eveIns.Event__c != null && eventCodesMap.containskey(eveIns.Event__c)){            
                map<String,String> eventDataMap = new map<String,String>();
                VistaSubscriptionEventWrapper eventResp = (VistaSubscriptionEventWrapper)JSON.deserialize(eveIns.Event_Data__c,VistaSubscriptionEventWrapper.class);
                if(eventResp.eventData != null && !eventResp.eventData.isEmpty()){
                    for(VistaSubscriptionEventWrapper.eventData evData : eventResp.eventData){
                        if(evData.key != null 
                           && evData.value != null
                           && evData.key == 'vin' 
                           && !evData.key.isWhitespace()){
                               vistaOrderMap.put(orderNumber,evData.value);
                           }
                    }
                }
            }else{
                system.debug('Event Name --> '+eveIns.Event__c);
                system.debug('OrderNo --> '+eveIns.OrderNo__c);
                system.debug('Status code not Matching...');
                subscriptionErrorEventMap.put(eveIns.Id,eveIns);
            }
        }
        
        
        system.debug('vistaOrderMap --> '+vistaOrderMap);
        system.debug('subscriptionErrorEventMap --> '+subscriptionErrorEventMap);            
        Asset assetIns = VistaSubscriptionEventDataHelper.getAsset(orderNumber);  
        system.debug('vistaOrderMap --> '+vistaOrderMap);
        AssetVehicleOrderApiWrapper.ResponseWrapper respWrap = VistaSubscriptionEventOrderApiHandler.performOrderApiHandler(orderNumber,vistaOrderMap.get(orderNumber),assetIns);
        system.debug('respWrap --> '+respWrap);
        if(respWrap != null && respWrap.assetIns != null){
            assetIns = respWrap.assetIns;
        }
        
        
        for(Vista_Subscription_Event__c eve : eventList){
            if(respWrap != null && respWrap.statusCode != 200){
                system.debug('respWrap.message --> '+respWrap.message);
                eve.Status__c = 'Invalid Response';
                eve.Error_Message__c = respWrap.callType+' '+respWrap.message;
                subscriptionErrorEventMap.put(eve.Id,eve);
            }  else if(assetIns.Current_Status_ID__c == null){
                system.debug('Current Status ID is null and It is required to match with the API call Data...');
                eve.Status__c = 'Not processing';
                eve.Error_Message__c = 'Current Status ID is null and It is required to match with the API call Data.';
                subscriptionErrorEventMap.put(eve.Id,eve);
            }else if(assetIns.Current_Status_ID__c != null && !statusCodeMap.containskey(integer.valueof(assetIns.Current_Status_ID__c))){
                system.debug('Status code not Matching...');
                eve.Status__c = 'Not processing';
                eve.Error_Message__c = 'Status code not Matching from the Vista API.';
                subscriptionErrorEventMap.put(eve.Id,eve);
            }else if(eve.Event__c != null && !eventCodesMap.containskey(eve.Event__c)){
                system.debug('Status code not Matching...');
                eve.Status__c = 'Not processing';
                eve.Error_Message__c = 'Event is not marked to process';
                subscriptionErrorEventMap.put(eve.Id,eve);
            }else{
                subscriptionEventMap.put(eve.Id,eve);
            }
        }
        
        system.debug('subscriptionErrorEventMap --> '+json.serialize(subscriptionErrorEventMap));
        if(subscriptionErrorEventMap != null && !subscriptionErrorEventMap.isEmpty()){
            update subscriptionErrorEventMap.values();
        }
        
        system.debug('subscriptionEventMap --> '+json.serialize(subscriptionEventMap));
        if(subscriptionEventMap != null && !subscriptionEventMap.isEmpty()){
            for(id eveId : subscriptionEventMap.keyset()){
                Vista_Subscription_Event__c eveIns = subscriptionEventMap.get(eveId);  
                processActiveVistaEventData(eveIns,respWrap,isExistingAsset); 
            } 
        }
    }
    
    public static void processActiveVistaEventData(Vista_Subscription_Event__c eveIns,AssetVehicleOrderApiWrapper.ResponseWrapper respWrap,Boolean isExistingAsset){
        try{
            map<String,String> eventDataMap = new map<String,String>();
            Asset assetIns = respWrap.assetIns;
            system.debug('assetIns --> '+assetIns);
            VistaSubscriptionEventWrapper eventResp = (VistaSubscriptionEventWrapper)JSON.deserialize(eveIns.Event_Data__c,VistaSubscriptionEventWrapper.class);
            if(eventResp.eventData != null && !eventResp.eventData.isEmpty()){
                for(VistaSubscriptionEventWrapper.eventData evData : eventResp.eventData){
                    if(evData.key != null 
                       && evData.value != null){
                           eventDataMap.put(evData.key,evData.value);
                       }
                }
                if(eventDataMap != null && !eventDataMap.isEmpty()){
                    processEventData(eveIns,assetIns,eventDataMap,isExistingAsset);                    
                    upsertAssetData(eveIns,assetIns);
                }
            }
        }catch(Exception ex){
            system.debug('Message --> '+ex.getMessage());
            system.debug('StackTrace --> '+ex.getStackTraceString());
            eveIns.Status__c = 'Error';
            eveIns.Error_Message__c = ex.getMessage()+'\n'+ex.getStackTraceString();
        }
        system.debug('eveUpdate --> '+json.serialize(eveIns));
        update eveIns;
    }
    
    public static void processEventData(Vista_Subscription_Event__c eve,Asset assetIns,map<String,String> eventDataMap,Boolean isExistingAsset){
        system.debug('assetIns --> '+assetIns);
        if(eventDataMap.containskey('placingOrganisationId') && eventDataMap.get('placingOrganisationId') != null){
            String placingOrganisationId = eventDataMap.get('placingOrganisationId');
            Account accIns = VistaSubscriptionEventDataHelper.getPrimaryDelaerCode(placingOrganisationId);
            if(accIns != null && isExistingAsset == false){
                assetIns.AccountId = accIns.ParentID;
                assetIns.ownerId = accIns.Parent.ownerid;
            }
        }
        
        if(eventDataMap.containskey('brand') && eventDataMap.get('brand') != null && !eventDataMap.get('brand').isWhitespace()){
            String brand = eventDataMap.get('brand');
            system.debug('brand --> '+brand);
            Vehicle_Specification__c vehSpec = VistaSubscriptionEventDataHelper.getBrandDetails(brand);
            if(vehSpec != null){
                assetIns.Brand__c = vehSpec.Id;
            }
        }
        
        if(eventDataMap.containskey('model') && eventDataMap.get('model') != null && assetIns.Brand__c != null && !eventDataMap.get('model').isWhitespace()){
            String model = eventDataMap.get('model');
            system.debug('Model --> '+model);
            system.debug('Brand --> '+assetIns.Brand__c);
            Product2 prodIns = VistaSubscriptionEventDataHelper.getProdData(model,assetIns.Brand__c);
            if(prodIns != null){
                assetIns.Model__c = prodIns.Id;
            }
        }
        
        if(eventDataMap.containskey('productId') && eventDataMap.get('productId') != null && assetIns.Model__c != null && !eventDataMap.get('productId').isWhitespace()){
            String productCode = eventDataMap.get('productId');	
            system.debug('productCode --> '+productCode);
            system.debug('Model --> '+assetIns.Model__c);
            Product2 prodIns = VistaSubscriptionEventDataHelper.getDerivativeProdData(productCode,assetIns.Model__c);
            if(prodIns != null){
                assetIns.Derivative__c = prodIns.Id;
            }
        }
        
        if(eventDataMap.containskey('orderMarket') && eventDataMap.get('orderMarket') != null && !eventDataMap.get('orderMarket').isWhitespace()){
            String orderMarket = eventDataMap.get('orderMarket');	
            system.debug('orderMarket --> '+orderMarket);
            Ordering_Market_Country_ISO_Code__mdt orderIns = VistaSubscriptionEventDataHelper.getOrderingMarket(orderMarket);
            if(orderIns != null && orderIns.Country_Code__c != null){
                assetIns.Ordering_Market__c = orderIns.Country_Code__c;
            }
        } 
        
        if(eventDataMap.containskey('modelYear') && eventDataMap.get('modelYear') != null && !eventDataMap.get('modelYear').isWhitespace()){
            String modelYear = eventDataMap.get('modelYear');
            system.debug('modelYear --> '+modelYear);
            List<Product_Code_Translations__mdt> codeTransList = [SELECT Id, MasterLabel, Feature_Description__c, Feature_Word__c, Group__c, Make__c FROM Product_Code_Translations__mdt where MasterLabel =: modelYear limit 1]; // Product_Code_Translations__mdt.getInstance(modelYear);
            if(codeTransList != null && !codeTransList.isEmpty()){
                Product_Code_Translations__mdt codeTrans = codeTransList.get(0);
                if(codeTrans != null 
                   && codeTrans.Feature_Description__c != null){
                       assetIns.Model_Year_Code__c = codeTrans.masterlabel;
                       assetIns.Model_Year__c = codeTrans.Feature_Word__c;
                       assetIns.Model_Year_Description__c = codeTrans.Feature_Description__c;
                   }
            }
        }
        
        if(eventDataMap.containskey('currentStatusTimestamp') && eventDataMap.get('currentStatusTimestamp') != null && !eventDataMap.get('currentStatusTimestamp').isWhitespace()){
            String currentStatusTimestamp = eventDataMap.get('currentStatusTimestamp');
            DateTime crDtTime = DateTime.parse(currentStatusTimestamp);
            system.debug('--> '+crDtTime.date());
            assetIns.Handover_Date__c = crDtTime.date();
        }
        
        if(eventDataMap.containskey('TypeOfSale') && eventDataMap.get('TypeOfSale') != null && !eventDataMap.get('TypeOfSale').isWhitespace()) assetIns.Type_Of_Sale_ID__c =  eventDataMap.get('TypeOfSale');
        if(eventDataMap.containskey('retailerReference') && eventDataMap.get('retailerReference') != null && !eventDataMap.get('retailerReference').isWhitespace()) assetIns.Retailer_Reference__c =  eventDataMap.get('retailerReference');
        if(eventDataMap.containskey('brandOrderType') && eventDataMap.get('brandOrderType') != null && !eventDataMap.get('brandOrderType').isWhitespace()) assetIns.Sale_Type_Code__c =  eventDataMap.get('brandOrderType');
        if(eventDataMap.containskey('vin') && eventDataMap.get('vin') != null && !eventDataMap.get('vin').isWhitespace()) assetIns.VIN__c =  eventDataMap.get('vin');
        if(eventDataMap.containskey('licenseNo') && eventDataMap.get('licenseNo') != null && !eventDataMap.get('licenseNo').isWhitespace()) assetIns.Registration_Number__c =  eventDataMap.get('licenseNo');
        if(eventDataMap.containskey('commonOrderNo') && eventDataMap.get('commonOrderNo') != null) assetIns.Order_Number__c =  eventDataMap.get('commonOrderNo');
        system.debug('1 assetIns --> '+assetIns);
    }
    
    public static void upsertAssetData(Vista_Subscription_Event__c eve,Asset assetIns){
        system.debug('assetIns --> '+json.serialize(assetIns));
        if(assetIns.name == null && assetIns.Order_Number__c != null){
            assetIns.name = assetIns.Order_Number__c;
        }
        if(assetIns.Id == null && assetIns.name == null){
            eve.Status__c = 'Error';
            eve.Error_Message__c = 'Name is not availble to create Asset';
        }else if(assetIns.Id == null && assetIns.Brand__c == null){
            eve.Status__c = 'Error';
            eve.Error_Message__c = 'Matching Brand was not found to create Asset';
        } else if(assetIns.Id == null && assetIns.accountId == null){
            eve.Status__c = 'Error';
            eve.Error_Message__c = 'Mathcing Account not found, Every asset needs an account, a contact, or both';
        }else{
            if(assetIns.id != null){
              assetIns.id = null;
            }
            upsert assetIns Order_Number__c;
            eve.Status__c = 'Processed';
            eve.Error_Message__c = null;
        } 
    }
    
    public static void updateVistaData(List<Vista_Subscription_Event__c> eventList,String status){
        
        for(Vista_Subscription_Event__c eve : eventList){
            eve.Status__c = status;
        }
        update eventList;
    }
}