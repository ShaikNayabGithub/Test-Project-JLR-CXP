public class Helper_Event_Details {
    public static void onPreEventDetailsInsert(List<Event_Details__c> listOfEvents){
        
        //List of Assets to update
        List<Asset> assetToUpdateList = new List<Asset>();
        
        //Set containing all assets ID in the current Event Detail list
        Set<ID> assetIdSet = new Set<ID>();
        
        //Set of Roadside Event ID
        Set<String> roadsideEventIDSet = new Set<String>();
        
        //Map of Vehicle ID_Vehicle
        MAP<ID,Asset> MAP_VehicleID_Vehicle = new MAP<ID,Asset>();
        
        //Map of exisiting Roadsides event in Salesforce
        MAP<String,Event_Details__c> MAP_RoadsideIDVehicle_Roadside = new MAP<String,Event_Details__c>();
        
        //Add the Asset IDs/Roadside event ID  to the respective Sets
        for(Event_Details__c e : listOfEvents){
            String vin = e.VIN__c;
            String eventID = e.Roadside_Event_ID__c;
            
            if(vin != null & vin !=''){
                assetIdSet.add(vin);
                
                if(eventID != null & eventID !=''){
                    roadsideEventIDSet.add(e.Roadside_Event_ID__c);
                }
            }
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
        List<Event_Details__c> listOfExisitingEvents = [Select ID,Roadside_Event_ID__c,VIN__c
                                                        from Event_Details__c 
                                                        where Roadside_Event_ID__c in: roadsideEventIDSet];
        
        //Fill the results in the MAP
        for(Event_Details__c r : listOfExisitingEvents){
            MAP_RoadsideIDVehicle_Roadside.put(r.Roadside_Event_ID__c + ' - ' + r.VIN__c,r);
        }
        /////////////////////////////////////////////////////////////////////
        
        for(Event_Details__c e : listOfEvents){
            
            String eventID = e.Roadside_Event_ID__c;
            String vehicleID = e.VIN__c;
            
            //get the same roaside event with the same ID - and same Vin__c if it exists
            Event_Details__c existingRoadSide = null;
            
            if(String.isNotEmpty(eventID) & String.isNotEmpty(vehicleID)){
                if(String.isNotBlank(eventID.Trim()) & String.isNotBlank(vehicleID.Trim())){
                    existingRoadSide = MAP_RoadsideIDVehicle_Roadside.get(eventID + ' - ' + vehicleID);
                }
            }
            
            //add the Event to the Map if there is no existing event with the same ID and Vehicle
            if(existingRoadSide == null & String.isNotEmpty(eventID) & String.isNotBlank(eventID)
              & String.isNotEmpty(vehicleID) & String.isNotBlank(vehicleID)){
                MAP_RoadsideIDVehicle_Roadside.put(eventID + ' - ' + vehicleID,e);
            }
            
            //Get the vehicle related to the event
            Asset relatedVehicle = MAP_VehicleID_Vehicle.get(vehicleID);
            
            //check if the vehicle exist
            if(relatedVehicle != null){
                
                e.Account__c = relatedVehicle.Accountid;
                
                String recordMileageString = String.ValueOf(e.Current_Vehicle_Mileage__c);
                                
                Decimal recordMileage =  recordMileageString != null ? Decimal.ValueOf(recordMileageString) : 0;
                Decimal vehicleMileage = relatedVehicle.Mileage__c != null ? relatedVehicle.Mileage__c : 0;
                
                //Check the record mileage - if > vehicle mileage -> update vehicle
                if(recordMileage > vehicleMileage){
                    relatedVehicle.Mileage__c = recordMileage;
                    assetToUpdateList.add(relatedVehicle);
                }
            }
           
            e.Event_Type__c = 'Roadside';
			
			//need to create Event_DateTime__c from Event_DateTime_Text__c
            try{
                if(e.Event_DateTime_Text__c != null && e.Event_DateTime__c == null){
                    e.Event_DateTime__c = Datetime.newInstance(Integer.valueOf(e.Event_DateTime_Text__c.substring(0, 4)), Integer.valueOf(e.Event_DateTime_Text__c.substring(5, 7)), Integer.valueOf(e.Event_DateTime_Text__c.substring(8, 10)), Integer.valueOf(e.Event_DateTime_Text__c.substring(11, 13)), Integer.valueOf(e.Event_DateTime_Text__c.substring(14, 16)), Integer.valueOf(e.Event_DateTime_Text__c.substring(17, 19))); //year0, month5, day8, hour11, minute14, second17
                }
                if(e.Call_Received_DateTime_Text__c != null && e.Call_Received_DateTime__c == null){
                    e.Call_Received_DateTime__c = Datetime.newInstance(Integer.valueOf(e.Call_Received_DateTime_Text__c.substring(0, 4)), Integer.valueOf(e.Call_Received_DateTime_Text__c.substring(5, 7)), Integer.valueOf(e.Call_Received_DateTime_Text__c.substring(8, 10)), Integer.valueOf(e.Call_Received_DateTime_Text__c.substring(11, 13)), Integer.valueOf(e.Call_Received_DateTime_Text__c.substring(14, 16)), Integer.valueOf(e.Call_Received_DateTime_Text__c.substring(17, 19))); //year0, month5, day8, hour11, minute14, second17
                }
            }
            catch(Exception ex){}
            
            if(e.Event_DateTime__c == null){
                e.Error__c = true;
                e.Error_Type__c = 'No Roadside event date provided';
            }
            else if(existingRoadSide != null){
                e.Error__c = true;
                e.Error_Type__c = 'Roadside Event already exists on asset with previous date';  
            }
            else if(String.isEmpty(eventID) | String.isBlank(eventID)){
                e.Error__c = true;
                e.Error_Type__c = 'Missing Roadside Event Data';
            }
        }
        
        if(assetToUpdateList.size() > 0){
            update assetToUpdateList;
        }

    }

}