public class VistaSubscriptionEventOrderApiHandler {
    
    public static AssetVehicleOrderApiWrapper.ResponseWrapper performOrderApiHandler(String ordernumber,String vin,Asset assetIns){
        AssetVehicleOrderApiWrapper.ResponseWrapper respWrap = new AssetVehicleOrderApiWrapper.ResponseWrapper();
        if(ordernumber != null || vin != null){
            respWrap = getAccessToken();
            if(ordernumber != null){
                assetIns.Order_Number__c = ordernumber;  
            }else  if(vin != null){
                assetIns.vin__c = vin;  
            }
            
            if(respWrap.statusCode == 200 && respWrap.accessToken != null){
                respWrap = makeVehicleOrderApiCall(assetIns,respWrap.accessToken);
                if(respWrap.statusCode == 200 && respWrap.message != null){
                    respWrap.assetIns = processAssetData(assetIns,respWrap.message);
                }
            }
        }else{
            respWrap.message = 'Orderno or Vin is null';
            respWrap.callType = 'Orderno or Vin is null';
        }
        system.debug('respWrap --> '+respWrap);
        return respWrap;
    }
    
    public static AssetVehicleOrderApiWrapper.ResponseWrapper getAccessToken(){
        AssetVehicleOrderApiWrapper.ResponseWrapper respWrap = new AssetVehicleOrderApiWrapper.ResponseWrapper();
        try{
            String accesstoken;
            
            map<String,Vehicle_Order_Api_Config__mdt> vehicleMap = Vehicle_Order_Api_Config__mdt.getall();
            Vehicle_Order_Api_Config__mdt vehIns = vehicleMap.get('Vehicle_Order_Api');
            system.debug('Endpoint --> '+vehIns.End_Point__c);
            system.debug('Auth Code --> '+vehIns.Auth_Code__c);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(vehIns.End_Point__c+'/token?grant_type=client_credentials');
            req.setHeader('Authorization','Basic '+vehIns.Auth_Code__c);
            req.setHeader('Content-Length','0');
            req.setMethod('POST');
            req.setTimeout(120000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Status Code '+res.getstatuscode());
            System.debug('Body '+res.getBody());
            String respBody = res.getBody();
            integer statuscode = res.getstatuscode();
            if(statuscode == 200 
               && respBody != null){
                   Map<String,Object> accessTokenMap = (Map<String,Object>)JSON.deserializeUntyped(respBody);
                   system.debug('accessTokenMap --> '+accessTokenMap);
                   if(accessTokenMap != null && accessTokenMap.get('access_token') != null){
                       respWrap.accesstoken = (String)accessTokenMap.get('access_token');
                       respWrap.statusCode = statuscode;
                       respWrap.message = respBody;
                       respWrap.callType = 'Access Token Call';
                   }
               }else{
                   respWrap.accesstoken = null;
                   respWrap.statusCode = statuscode;
                   respWrap.message = respBody;
                   respWrap.callType = 'Access Token Call';
               }
        }catch(Exception ex){
            respWrap.statusCode = null;
            respWrap.message = ex.getMessage();
            respWrap.callType = 'Access Token Call';
        }
        return respWrap;
    }
    public static AssetVehicleOrderApiWrapper.ResponseWrapper makeVehicleOrderApiCall(Asset assetIns,String accessToken){
        AssetVehicleOrderApiWrapper.ResponseWrapper respWrap = new AssetVehicleOrderApiWrapper.ResponseWrapper();
        try{
            map<String,Vehicle_Order_Api_Config__mdt> vehicleMap = Vehicle_Order_Api_Config__mdt.getall();
            Vehicle_Order_Api_Config__mdt vehIns = vehicleMap.get('Vehicle_Order_Api');
            system.debug('Endpoint --> '+vehIns.End_Point__c);
            system.debug('Auth Code --> '+vehIns.Auth_Code__c);
            system.debug('Cert Name --> '+vehIns.Certificate_Name__c);
            system.debug('accessToken --> '+accessToken);            
            String endPoint;
            if(assetIns.Order_Number__c != null){
                endPoint = vehIns.End_Point__c+'/VehicleOrders/v3/orders/'+assetIns.Order_Number__c+'?id-type=orderNo&expand=true&include=distribution&include=prices&include=vehicle'; 
            }else if(assetIns.VIN__c != null){
                endPoint = vehIns.End_Point__c+'/VehicleOrders/v3/orders/'+assetIns.VIN__c+'?id-type=vin&expand=true&include=distribution&include=prices&include=vehicle';
            }
            system.debug('endPoint --> '+endPoint);
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('GET');
            req.setTimeout(120000);
            req.setHeader('Accept-Language','en-EN');
            req.setClientCertificateName(vehIns.Certificate_Name__c);
            req.setHeader('Authorization','Bearer '+accessToken);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug('Status Code '+res.getstatuscode());
            System.debug('Body '+res.getBody());
            String respBody = res.getBody();
            integer statuscode = res.getstatuscode();
            if(statuscode == 200 && respBody != null){
                respWrap.statusCode = statuscode;
                respWrap.message = respBody;
                respWrap.callType = 'Vehicle Order Api Call';
            }else{
                respWrap.statusCode = statuscode;
                respWrap.message = respBody;
                respWrap.callType = 'Vehicle Order Api Call';
            }
        } catch(Exception ex){
            respWrap.statusCode = null;
            respWrap.message = ex.getMessage();
            respWrap.callType = 'Vehicle Order Api Call';
        }
        return respWrap;
    }
    public static Asset processAssetData(asset assetUpdateIns,String respBody){
        system.debug('respBody --> '+respBody);
        respBody = respBody.replaceAll('"_embedded":','"x_embedded":');
        respBody = respBody.replaceAll('"group":','"group_Z":');
        respBody = respBody.replaceAll('"desc":','"desc_Z":');
        system.debug('respBody --> '+respBody);
        AssetVehicleOrderApiWrapper orderWrapIns = new AssetVehicleOrderApiWrapper();
        orderWrapIns = (AssetVehicleOrderApiWrapper)JSON.deserialize(respBody,AssetVehicleOrderApiWrapper.class);
        if(orderWrapIns != null){
            assetUpdateIns.Last_Vista_API_Update__c = System.today();
            
            if(orderWrapIns.commonOrderNo != null
               && assetUpdateIns.Order_Number__c == null){
                   assetUpdateIns.Order_Number__c = orderWrapIns.commonOrderNo;
               }
            
            if(assetUpdateIns.VIN__c == null
               && orderWrapIns.vin != null){
                   assetUpdateIns.VIN__c = orderWrapIns.vin;
               }
            
            // CXPD- 2323 -changes begin
            if(orderWrapIns.handoverDate != null){
                assetUpdateIns.Handover_Date__c = Date.valueOf(orderWrapIns.handoverDate);
                assetUpdateIns.Original_Handover_Date__c = Date.valueOf(orderWrapIns.handoverDate);
                assetUpdateIns.Warranty_Start_Date__c = Date.valueOf(orderWrapIns.handoverDate);
                Date newDate = Date.valueOf(orderWrapIns.handoverDate);
                if (assetUpdateIns.Product2.Warranty_Length__c > 0 ){
                    Date newDate1 = Date.valueof(newDate.addMonths(Integer.valueof(assetUpdateIns.Product2.Warranty_Length__c)));
                    assetUpdateIns.Warranty_End_Date__c = Date.valueof(newDate1.addDays(-1));  }
                else{
                    Date newDate1 = Date.valueof(newDate.addYears(3));
                    assetUpdateIns.Warranty_End_Date__c = Date.valueof(newDate1.addDays(-1));  }
            }			
            // CXPD- 2323 -changes end
            
            //CXPD-2338 changes begin
            if(orderWrapIns.svoIndicator != null){
                assetUpdateIns.Svo_Indicator__c = orderWrapIns.svoIndicator;
            }
            if(orderWrapIns.currentPlannedBuildDate != null){
                assetUpdateIns.Current_Planned_Build_Date__c = Date.valueOf(orderWrapIns.currentPlannedBuildDate);
            }
            if(orderWrapIns.firstPlannedDeliveryDate != null){
                assetUpdateIns.First_Planned_Delivery_Date__c = Date.valueOf(orderWrapIns.firstPlannedDeliveryDate);
            }
            if(orderWrapIns.currentPlannedDeliveryDate != null){
                assetUpdateIns.Current_Planned_Delivery_Date__c = Date.valueOf(orderWrapIns.currentPlannedDeliveryDate);
            }
            if(orderWrapIns.acceptedDeliveryDate != null){
                assetUpdateIns.Accepted_Delivery_Date__c = Date.valueOf(orderWrapIns.acceptedDeliveryDate);
            }
            if(orderWrapIns.plannedHandoverDate != null){
                assetUpdateIns.Vista_Planned_Handover_Date__c = Date.valueOf(orderWrapIns.plannedHandoverDate);
            }
            if(orderWrapIns.intermediateDestinationDate != null){
                assetUpdateIns.Intermediate_Destination_Date__c = Date.valueOf(orderWrapIns.intermediateDestinationDate);
            }
            if(orderWrapIns.deliveryDate != null && assetUpdateIns.Arrived_at_Dealer_Date__c == NULL){
                assetUpdateIns.Arrived_at_Dealer_Date__c = Date.valueOf(orderWrapIns.deliveryDate);
            }
            if(orderWrapIns.factoryCompleteDate != null && assetUpdateIns.Built_Date__c == NULL){
                assetUpdateIns.Built_Date__c = Date.valueOf(orderWrapIns.factoryCompleteDate);
            }
            if(orderWrapIns.retailerRef != null){
                assetUpdateIns.Retailer_Reference__c = orderWrapIns.retailerRef;
            }
            
            if(orderWrapIns.x_embedded != null){
                if(orderWrapIns.x_embedded.Distribution != null){
                    if(orderWrapIns.x_embedded.Distribution.actualVesselName != null){
                        assetUpdateIns.Actual_Vessel_Name__c = orderWrapIns.x_embedded.Distribution.actualVesselName;
                    }
                    if(orderWrapIns.x_embedded.Distribution.plannedSailDate != null){
                        assetUpdateIns.Planned_Sail_Date__c = Date.valueOf(orderWrapIns.x_embedded.Distribution.plannedSailDate);
                    }
                    if(orderWrapIns.x_embedded.Distribution.plannedIntermediateDestinationDate != null){
                        assetUpdateIns.Planned_Intermediate_Destination_Date__c = Date.valueOf(orderWrapIns.x_embedded.Distribution.plannedIntermediateDestinationDate);
                    }
                    if(orderWrapIns.x_embedded.Distribution.requestedDeliveryDate != null){
                        assetUpdateIns.Requested_Delivery_Date__c = Date.valueOf(orderWrapIns.x_embedded.Distribution.requestedDeliveryDate);
                    }
                    if(orderWrapIns.x_embedded.Distribution.plannedDeliveryDate != null){
                        assetUpdateIns.Planned_Delivery_Date__c = Date.valueOf(orderWrapIns.x_embedded.Distribution.plannedDeliveryDate);
                    }
                }
                
                if(orderWrapIns.x_embedded.Vehicle != null){
                    if(orderWrapIns.x_embedded.Vehicle.exteriorColour != null){
                        if(orderWrapIns.x_embedded.Vehicle.exteriorColour.id != NULL){
                            assetUpdateIns.Exterior_colour_code__c = orderWrapIns.x_embedded.Vehicle.exteriorColour.id;
                        }
                        if(orderWrapIns.x_embedded.Vehicle.exteriorColour.descr != NULL){
                            assetUpdateIns.Exterior_Colour__c = orderWrapIns.x_embedded.Vehicle.exteriorColour.descr;
                        }
                    }
                    if(orderWrapIns.x_embedded.Vehicle.trim != null){
                        if(orderWrapIns.x_embedded.Vehicle.trim.id != NULL){
                            assetUpdateIns.Interior_Colour_Code_Vista__c = orderWrapIns.x_embedded.Vehicle.trim.id;
                        }
                        if(orderWrapIns.x_embedded.Vehicle.trim.descr != NULL){
                            assetUpdateIns.Interior_colour_BRS__c = orderWrapIns.x_embedded.Vehicle.trim.descr;
                        }
                    }
                    if(orderWrapIns.x_embedded.Vehicle.engineNo != NULL && assetUpdateIns.Engine_Number__c == NULL){
                        assetUpdateIns.Engine_Number__c = orderWrapIns.x_embedded.Vehicle.engineNo;
                    }
                    if(orderWrapIns.x_embedded.Vehicle.registrationNo != NULL && assetUpdateIns.Registration_Number__c == NULL){
                        assetUpdateIns.Registration_Number__c = orderWrapIns.x_embedded.Vehicle.registrationNo;
                    }
                }
            }
            //CXPD-2338 changes end
            
            if(orderWrapIns.x_embedded != null
               && orderWrapIns.x_embedded.vehicle != null
               && orderWrapIns.x_embedded.vehicle.product != null
               && orderWrapIns.x_embedded.vehicle.product.Id != null){
                   
                   if(assetUpdateIns.Description_Group_ID__c == null){
                       assetUpdateIns.Description_Group_ID__c = orderWrapIns.x_embedded.vehicle.product.Id;
                       
                       if(assetUpdateIns.Product2Id == null){
                           List<Product2> prodList = [select id from Product2 where ProductCode =: orderWrapIns.x_embedded.vehicle.product.Id];
                           if(prodList != null && !prodList.isEmpty()){
                               assetUpdateIns.Product2Id = prodList.get(0).Id;
                           }
                       }
                   }  
               } 
            
            if(orderWrapIns.currentStatus != null){
                if(orderWrapIns.currentStatus.Id != null){
                    assetUpdateIns.Current_Status_ID__c = orderWrapIns.currentStatus.Id;
                    assetUpdateIns.Current_Vista_Status_ID__c = orderWrapIns.currentStatus.Id;
                }
                
                if(orderWrapIns.currentStatus.descr != null){
                    assetUpdateIns.Vista_Status__c = orderWrapIns.currentStatus.descr;
                }
            }
            
            
            if(orderWrapIns.brandOrderStatus != null){
                if(orderWrapIns.brandOrderStatus.Id != null){
                    assetUpdateIns.Brand_Order_Status_ID__c = orderWrapIns.brandOrderStatus.Id;
                }
                if(orderWrapIns.brandOrderStatus.descr != null){
                    assetUpdateIns.Brand_Order_Status__c = orderWrapIns.brandOrderStatus.descr;
                }
            }
            
            if(orderWrapIns.brandOrderType != null
               && orderWrapIns.brandOrderType.Id != null){
                   assetUpdateIns.Sale_Type_Code__c = orderWrapIns.brandOrderType.Id;
               }
            
            if(orderWrapIns.globalSalesType != null
               && orderWrapIns.globalSalesType.Id != null){
                   assetUpdateIns.Global_Sales_Type__c = orderWrapIns.globalSalesType.Id;
               }
            
            if(orderWrapIns.commonOrderType != null){
                if(orderWrapIns.commonOrderType.Id != null){
                    assetUpdateIns.Common_Order_Type__c = orderWrapIns.commonOrderType.Id;
                }
                if(orderWrapIns.commonOrderType.descr != null){
                    //assetUpdateIns.Common_Sale_Type__c = orderWrapIns.commonOrderType.descr;
                    assetUpdateIns.Type_of_Sale__c = orderWrapIns.commonOrderType.descr;
                }
            }
            if(orderWrapIns.typeOfSale != null){
                if(orderWrapIns.typeOfSale.Id != null){
                    assetUpdateIns.Type_Of_Sale_ID__c = orderWrapIns.typeOfSale.Id;
                }
                if(orderWrapIns.typeOfSale.descr != null){
                    // assetUpdateIns.Type_of_Sale__c = orderWrapIns.typeOfSale.descr;
                    assetUpdateIns.Common_Sale_Type__c = orderWrapIns.typeOfSale.descr;
                }
            }
        }
        return assetUpdateIns;
    }
    
}