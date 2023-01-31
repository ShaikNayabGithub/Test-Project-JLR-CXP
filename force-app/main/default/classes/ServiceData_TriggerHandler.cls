public class ServiceData_TriggerHandler {
    public static void updateUniqueServiceDataonAsset(List<Service_Data__c> newServices, Map<Id, Service_Data__c> oldServices){
        Set<Id> AssetIDs = new Set<Id>();
        for(Service_Data__c rec : newServices)
            AssetIDs.add(rec.Asset__c);
        
        if(oldServices != null){
            for(Service_Data__c rec : oldServices.values())
                AssetIDs.add(rec.Asset__c);
        }
        system.debug('AssetIDs:::'+AssetIDs);
        
        List<Asset> assetsToUpdate = new List<Asset>();
        for(Asset rec : [Select id, (Select id, Unique_Service_Data__c from Service_Data__r) from Asset where id in: AssetIDs]){
            Set<String> uniqueSDSet = new Set<String>();
            for(Service_Data__c SDrec : rec.Service_Data__r)
                uniqueSDSet.add(SDrec.Unique_Service_Data__c);
            assetsToUpdate.add(new Asset(id = rec.id, Unique_Record_Count__c = uniqueSDSet.size()));
        }
        system.debug('assetsToUpdate:::'+assetsToUpdate);
        
        if(assetsToUpdate.size()>0)
            update assetsToUpdate;
    }
    
    public void PostCreate(List<Service_Data__c> newServices){
        id retailerId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').GetRecordTypeId();
        Set<Id> accountIds = SObjectUtilities.GetFieldValuesId(newServices,'Account__c');
        List<Account> accsToBeUpdated = new List<Account>();
        List<Account> accs = [Select id, Customer_Journey_Stage__c FROM Account WHERE Id in :accountIds and RecordTypeId != :retailerId];
        For(Account acc : accs )
            if(acc.Customer_Journey_Stage__c == null || acc.Customer_Journey_Stage__c == 'Take the Keys' ||acc.Customer_Journey_Stage__c == 'Enjoy'||acc.Customer_Journey_Stage__c == 'Lapsed'){
                acc.Customer_Journey_Stage__c = 'Maintain';
                accsToBeUpdated.add(acc);
            } 
        if(!accsToBeUpdated.isEmpty()){
            update accsToBeUpdated;
        }
        
        
        
        Set<Id> allVehicleIds= new set<Id>();
        Set<Id> accountId= new set<Id>();
        Set<string> assetAcountKey = new set<string>();
        for(Service_Data__c SD:newServices){
            if(SD.Account__c !=null && SD.Service_Customer_Account__c!=null && SD.Account__c !=SD.Service_Customer_Account__c)
            {
                allVehicleIds.add(SD.Asset__c);
                accountId.add(SD.Service_Customer_Account__c);
                assetAcountKey.add(SD.Asset__c+'#'+SD.Service_Customer_Account__c);
            }
        }
        
        if(!assetAcountKey.isEmpty())
        {
            for(Role__c Role:[select id, Vehicle__c, Account__c from Role__c where Account__c IN:accountId AND Vehicle__c IN: allVehicleIds]) 
            {
                if(assetAcountKey.contains(Role.Vehicle__c+'#'+Role.Account__c))
                    assetAcountKey.remove(Role.Vehicle__c+'#'+Role.Account__c);
            }
        }
        
        List<Role__c> assetRoleLstForInsert= new List<Role__c>();
        if(!assetAcountKey.isEmpty())
        {
            for(string vehicelInfo:assetAcountKey)
            {
                list<string> vehicleDetails=vehicelInfo.split('#');
                Role__c role= new role__c();
                role.Vehicle__c=vehicleDetails[0];
                role.Account__c=vehicleDetails[1];
                role.Role__c='Service Customer';
                role.Effective_From__c=system.today();
                assetRoleLstForInsert.add(role);
            }
            
            insert assetRoleLstForInsert;
        }
        set<id> serviceDataIdsSet = new set<id>();
        for(Service_Data__c servData : newServices){
            if(servData.Asset__c != null){
                serviceDataIdsSet.add(servData.Id);
            }
        }
        if(serviceDataIdsSet != null && !serviceDataIdsSet.isEmpty()){
            map<id,asset> assetUpdateMap = new map<id,asset>();
            set<String> serviceCategoriesSet = new set<String>{'Repair','Body Shop','Warranty','Extended Warranty','Internal'};
                set<String> repairCategoriesSet = new set<String>{'Repair','Body Shop','Warranty','Extended Warranty'};
                    Boolean isMatched;
            for(Service_Data__c servData : [select id,SR_Type__c,Service_Date__c,Service_Repair_Date__c,Department__c,Mileage_Out__c,Mileage_Date__c,Asset__c,Dealer_Code_JLR__c,Asset__r.Vehicle_Last_Service_Date__c,Asset__r.Last_Repaired_Date__c,Asset__r.Mileage__c,Asset__r.Mileage_Checked_Date__c 
                                            from Service_Data__c where id in: serviceDataIdsSet and Asset__c != null]){
                                                isMatched = false;
                                                if(servData.Asset__c != null){
                                                    Asset assetIns = new Asset();
                                                    assetIns.id = servData.Asset__c;
                                                    if(!serviceCategoriesSet.contains(servData.SR_Type__c) 
                                                       && servData.Service_Date__c != null 
                                                       && servData.Department__c != 'Bodyshop'){
                                                           isMatched = true;
                                                           assetIns.Vehicle_Last_Service_Date__c = servData.Service_Date__c;
                                                       }else if(servData.SR_Type__c != null 
                                                                && servData.Department__c  != null 
                                                                && repairCategoriesSet.contains(servData.SR_Type__c) 
                                                                && servData.Service_Repair_Date__c != null 
                                                                && servData.Department__c == 'Bodyshop'){
                                                                    isMatched = true;
                                                                    assetIns.Last_Repaired_Date__c  = Date.valueOf(servData.Service_Repair_Date__c);
                                                                }else if(servData.SR_Type__c != null && servData.SR_Type__c =='Internal' && servData.Department__c != null){
                                                                    //CXPD-1875
                                                                    if(servData.Department__c == 'Bodyshop' && servData.Service_Repair_Date__c != null){
                                                                        isMatched = true;
                                                                        assetIns.Last_Repaired_Date__c = Date.valueOf(servData.Service_Repair_Date__c);
                                                                    }else if(servData.Department__c == 'Workshop' && servData.Service_Date__c != null){
                                                                        isMatched = true;
                                                                        assetIns.Vehicle_Last_Service_Date__c = servData.Service_Date__c;
                                                                    }else if(servData.Department__c == 'Undefined' && servData.Service_Date__c != null){
                                                                        isMatched = true;
                                                                        assetIns.Vehicle_Last_Service_Date__c = servData.Service_Date__c;
                                                                    }
                                                                }
                                                    
                                                    Decimal servdMileage =  servData.Mileage_Out__c != null ? servData.Mileage_Out__c : 0;
                                                    Decimal assetMileage = servData.Asset__r.Mileage__c != null ? servData.Asset__r.Mileage__c : 0;
                                                    if(!assetUpdateMap.containskey(assetIns.Id)
                                                       && assetMileage < servdMileage){
                                                           isMatched = true;
                                                           assetIns.Mileage__c = servdMileage;
                                                       }else if(assetUpdateMap.containskey(assetIns.Id)
                                                                && assetUpdateMap.get(assetIns.Id).Mileage__c < servdMileage){
                                                                    assetUpdateMap.get(assetIns.Id).Mileage__c = servdMileage;
                                                                }  
                                                    if(servData.Dealer_Code_JLR__c != null){
                                                        if(servData.Dealer_Code_JLR__c.length() > 5){
                                                            isMatched = true;
                                                            assetIns.Last_Servicing_Dealer__c =  servData.Dealer_Code_JLR__c.right(5);
                                                        }else if(servData.Dealer_Code_JLR__c.length() <= 5){
                                                            isMatched = true;
                                                            assetIns.Last_Servicing_Dealer__c =  servData.Dealer_Code_JLR__c;
                                                        }
                                                    }
                                                    if(isMatched != null && isMatched){
                                                        assetUpdateMap.put(assetIns.id,assetIns);
                                                    }
                                                }
                                            }
            system.debug('assetUpdateMap --> '+assetUpdateMap);
            if(assetUpdateMap != null 
               && !assetUpdateMap.isEmpty()){
                   update assetUpdateMap.values();
               }
        }
        AccountCustomerJourneyStatusHandler.SetMaintainCustomerStage(newServices);
    }
    
    public void PostUpdate(List<Service_Data__c> newServices,map<Id,Service_Data__c> serviceDataMap){
        AccountCustomerJourneyStatusHandler.SetMaintainCustomerStage(newServices);
        AccountCustomerJourneyStatusHandler.SetEnjoyCustomerStage(newServices,serviceDataMap);
    }
    
    public void PreCreate(List<Service_Data__c> newServices){
        
        //List of Assets to update
        //List<Asset> assetToUpdateList = new List<Asset>();
        Map<Id, Asset> assetToUpdateList = new Map<Id, Asset>();
        
        //Set containing all assets ID in the current Event Detail list
        Set<ID> assetIdSet = new Set<ID>();
        
        //Set of Roadside Event ID
        Set<String> serviceDataIDSet = new Set<String>();
        
        //Map of Vehicle ID_Vehicle
        MAP<ID,Asset> MAP_VehicleID_Vehicle = new MAP<ID,Asset>();
        
        //Map of exisiting ServiceData event in Salesforce
        MAP<String,service_Data__c> MAP_ServiceDataIDVehicleID_ServiceData = new MAP<String,service_Data__c>();
        
        set<ID> serviceDataAccIdSet = new set<ID>();
        Map<ID,Account> serviceAccConIdMap = new Map<ID,Account>();
        //Add the Asset IDs/ServiceData event ID  to the respective Sets
        for(service_Data__c e : newServices){
            String vin = e.Asset__c;
            String orderID = e.DMS_Repair_Order_ID__c ;
            
            if(vin != null & vin !=''){
                assetIdSet.add(vin);
                
                if(orderID != null & orderID !=''){
                    serviceDataIDSet.add(orderID);
                }   
            }
            
            if(e.Service_Customer_Account__c !=null && e.Service_Customer_Contact__c==null)
            {
                serviceDataAccIdSet.add(e.Service_Customer_Account__c);
            }
            
        }
        
        if(!serviceDataAccIdSet.isEmpty())
        {
            serviceAccConIdMap= new Map<Id,Account>([select Id, personContactId from account where ID IN:serviceDataAccIdSet AND ispersonAccount=true]);
        }
        /////////////////////////////////////////////////////Fetch the Assets
        //Get the Assets in SOQL
        List<Asset> listOfAssets = [Select ID,AccountId,Mileage__c from Asset where ID in: assetIdSet];
        
        //Fill the results in the MAP
        for(Asset a : listOfAssets){
            MAP_VehicleID_Vehicle.put(a.ID,a);
        }
        /////////////////////////////////////////////////////////////////////
        
        ///////////////////////////////////////////////////////Fetch the roadside event details
        //Get the Roadside Event in SOQL
        /*
List<service_Data__c> listOfExisitingServiceData = [Select ID,Account__c,Mileage_Out__c,DMS_Repair_Order_ID__c,Asset__c 
from service_Data__c 
where DMS_Repair_Order_ID__c in: serviceDataIDSet];

//Fill the results in the MAP
for(service_Data__c r : listOfExisitingServiceData){
MAP_ServiceDataIDVehicleID_ServiceData.put(r.DMS_Repair_Order_ID__c + ' - ' + r.Asset__c,r);
}
*/
        
        /////////////////////////////////////////////////////////////////////
        
        for(service_Data__c e : newServices){
            
            if(e.Service_Customer_Account__c !=null && e.Service_Customer_Contact__c==null && serviceAccConIdMap.containsKey(e.Service_Customer_Account__c))
                e.Service_Customer_Contact__c=serviceAccConIdMap.get(e.Service_Customer_Account__c).personContactId;
            /*
String repairOrderId = e.DMS_Repair_Order_ID__c;
String vehicleID = e.Asset__c;

//get the same service data event with the same ID - if it exists
service_Data__c existingServiceData = null;

if(String.isNotEmpty(repairOrderId) & String.isNotEmpty(vehicleID)){
if(String.isNotBlank(repairOrderId.Trim()) & String.isNotBlank(vehicleID.Trim())){
existingServiceData = MAP_ServiceDataIDVehicleID_ServiceData.get(repairOrderId + ' - ' + vehicleID);
}
}

//add the service data to the Map if there is no existing event with the same ID
if(existingServiceData == null & String.isNotEmpty(repairOrderId) & String.isNotBlank(repairOrderId)
& String.isNotEmpty(vehicleID) & String.isNotBlank(vehicleID)){
MAP_ServiceDataIDVehicleID_ServiceData.put(repairOrderId + ' - ' + vehicleID,e);
}
*/
            
            //Get the vehicle related to the service data
            Asset relatedVehicle = MAP_VehicleID_Vehicle.get(e.Asset__C);
            
            //check if the vehicle exist
            if(relatedVehicle != null){
                
                e.Account__c = relatedVehicle.Accountid;
                
                /*  String recordMileageString = String.ValueOf(e.Mileage_Out__c);

Decimal recordMileage =  recordMileageString != null ? Decimal.ValueOf(recordMileageString) : 0;
Decimal vehicleMileage = relatedVehicle.Mileage__c != null ? relatedVehicle.Mileage__c : 0;

//Check the record mileage - if > vehicle mileage -> update vehicle
if(recordMileage > vehicleMileage){
relatedVehicle.Mileage__c = recordMileage;
if(assetToUpdateList.containsKey(relatedVehicle.Id))
{
if(assetToUpdateList.get(relatedVehicle.Id).Mileage__c < relatedVehicle.Mileage__c)
{
assetToUpdateList.get(relatedVehicle.Id).Mileage__c = relatedVehicle.Mileage__c;
}
}
else
{
assetToUpdateList.put(relatedVehicle.Id,relatedVehicle);
}
} */
            }
            
            /*
if(e.Service_Repair_Date__c == null){
e.Error__c = true;
e.Error_Type__c = 'No service date provided';
}
else if(existingServiceData != null){
e.Error__c = true;
e.Error_Type__c = 'Service record already exists on asset with previous date';
}
else if(String.isEmpty(repairOrderId) | String.isBlank(repairOrderId)){
e.Error__c = true;
e.Error_Type__c = 'Missing Service Data';
}
*/
        }
        
        /* if(assetToUpdateList.size() > 0){
update assetToUpdateList.values();
} */
    }
}