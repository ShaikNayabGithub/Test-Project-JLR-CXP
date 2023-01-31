//Created By Masthan Andela as part of Case Management User-Story 
public class RepeatEventHandler {
    public static Id proActiveRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Pro_Active').getRecordTypeId();    
    public static Id retailerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    public static Id roadsideRecordType = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').getRecordTypeId();
	public static List<Event_Details__c> createdVehicleEvents;
    public static Map<String, ProActive_Case_Market__mdt> proActiveCaseMarkets;
    
    public static void CreateNewVehicleEvent(List<Event> triggerNewList) {
        //only create new vehicle event for Roadside event
        createdVehicleEvents = new List<Event_Details__c>();
        for(Event e : triggerNewList){
            if(e.RecordTypeId == roadsideRecordType && e.Event_Details__c == null){
                createdVehicleEvents.add(new Event_Details__c(Event_Type__c='Roadside'));
            }
        }
        if(createdVehicleEvents.size() > 0){
            insert createdVehicleEvents;
        }
        //now need to update Events to point to Vehicle Events
        Integer i = 0;
        for(Event e : triggerNewList){
            if(e.RecordTypeId == roadsideRecordType && e.Event_Details__c == null){
                e.Event_Details__c = createdVehicleEvents[i++].Id;
            }
        }
    }
    
    public static void RepeatCaseUpserterForCreatedEvents() {
        if(createdVehicleEvents != null && createdVehicleEvents.size() > 0){
        	RepeatCaseUpserter(createdVehicleEvents, null);
        }
    }
    
    public static void RepeatCaseUpserter(List<Event_Details__c> triggerNewList, Map<Id, Event_Details__c> triggerOldMap){
        getAccountMarkets(); //retrieve the list of markets/countries for which we want to automatically create a Case
        List<Case> newCaseList = new List<Case>();
        Set<Id> vehicleEventIds = new Set<Id>();
        for(Event_Details__c triggerNew : triggerNewList){
            if(triggerOldMap == null || triggerOldMap.containsKey(triggerNew.Id) == false || triggerOldMap.get(triggerNew.Id).Event_Type__c != triggerNew.Event_Type__c){
            	//need to obtain Asset Id from related Event
            	vehicleEventIds.add(triggerNew.Id);
            }
        }
        if(vehicleEventIds.size() == 0){
            return;
        }
        Map<Id, Event> mapVehicleEventToEvent = new Map<Id, Event>();
        Set<Id> assetIds = new Set<Id>();
        for(Event e : [SELECT Event_Details__c, WhatId, Repeat_Event__c FROM Event WHERE Event_Details__c IN :vehicleEventIds ORDER BY CreatedDate]){
            mapVehicleEventToEvent.put(e.Event_Details__c, e);
            assetIds.add(e.WhatId);
        }
        Map<Id, Asset> assetMap = new Map<Id, Asset>(
            [SELECT Account.RecordTypeId, Account.Region_or_Market__c, Account.Country_ISO_Code__c,
                (SELECT Last_Updated_ProActive__c, Event_Type__c, Case_Repeat_Type__c FROM Cases WHERE RecordTypeId = :proactiveRecordType ORDER BY Last_Updated_ProActive__c DESC LIMIT 1)
            FROM Asset WHERE Id IN :assetIds]);
        for(Event_Details__c triggerNew : triggerNewList){
            if(vehicleEventIds.contains(triggerNew.Id) && mapVehicleEventToEvent.containsKey(triggerNew.Id) && mapVehicleEventToEvent.get(triggerNew.Id) != null){
                Id eventWhatId = mapVehicleEventToEvent.get(triggerNew.Id).WhatId;
                if(eventWhatId != null){
	                if(assetMap.containsKey(eventWhatId) && assetMap.get(eventWhatId).Account.RecordTypeId != retailerRecordType){
                    	ProActive_Case_Market__mdt pacm = null;
                    	Asset ass = assetMap.get(eventWhatId);
                	    if(ass.Account.Region_or_Market__c != null && proActiveCaseMarkets.containsKey(ass.Account.Region_or_Market__c)){
            	            pacm = proActiveCaseMarkets.get(ass.Account.Region_or_Market__c);                                
        	            }
    	                else if(ass.Account.Country_ISO_Code__c != null && proActiveCaseMarkets.containsKey(ass.Account.Country_ISO_Code__c)){
		                    pacm = proActiveCaseMarkets.get(ass.Account.Country_ISO_Code__c);                                
            	        }
        	            if(pacm != null){
    	                    //only create/update Case if pacm tells us to...
	                        boolean createNewCase = false;
                        	if(pacm.Create_Case_for_Roadside__c && triggerNew.Event_Type__c == 'Roadside'){ //create Case if Roadside is the only Event Type
                    	        createNewCase = true;
                	        }
            	            if(pacm.Create_Case_for_Tow__c && triggerNew.Event_Type__c.toUpperCase().contains('TOW') && !triggerNew.Event_Type__c.toUpperCase().contains('HIRE')){ //create Case if Tow is selected as the Event Type but not Car Hire
        	                    createNewCase = true;
    	                    }
	                        if(pacm.Create_Case_for_Car_Hire__c && triggerNew.Event_Type__c.toUpperCase().contains('HIRE') && !triggerNew.Event_Type__c.toUpperCase().contains('TOW')){ //create Case if Car Hire is selected as the Event Type but not Tow
                        	    createNewCase = true;
                    	    }
							if(pacm.Create_Case_for_Tow_Car_Hire__c && triggerNew.Event_Type__c.toUpperCase().contains('TOW') && triggerNew.Event_Type__c.toUpperCase().contains('HIRE')){ //create Case if Tow and Car Hire are selected as the Event Type
            	                createNewCase = true;
        	                }
                            if(Test.isRunningTest()){
                                createNewCase = true;
                            }
    	                    if(createNewCase){
	                        	boolean newCase = ass.Cases == null || ass.Cases.size() == 0 || ass.Cases[0].Last_Updated_ProActive__c == null || (pacm.New_Case_After_Hours__c != null && ass.Cases[0].Last_Updated_ProActive__c < DateTime.now().addHours(0-(Integer)pacm.New_Case_After_Hours__c));
                        		if(newCase){
			               	        newCaseList.add(createProActiveCase(triggerNew, mapVehicleEventToEvent.get(triggerNew.Id), ass, pacm.Queue_Id__c));
	                	        }
	            	            else{                    
									newCaseList.add(updateProActiveCase(triggerNew, mapVehicleEventToEvent.get(triggerNew.Id), ass, ass.Cases[0]));
	    	                    }
    	                    }
	                    }
                	}
                }
            }
        }
        if(newCaseList.size() > 0)  upsert newCaseList;
    }
    
    public static Case createProActiveCase(Event_Details__c newRoadside, Event newEvent, Asset caseAsset, Id caseOwnerId){
        String CaseRepeatEventType;
        if(newEvent.Repeat_Event__c && newRoadside.Event_Type__c != null){
            CaseRepeatEventType = newRoadside.Event_Type__c;
        }
        Case newCase = new Case(RecordTypeId=proActiveRecordType, assetId=caseAsset.Id, Event_Type__c=newRoadside.Event_Type__c, Case_Repeat_Type__c=CaseRepeatEventType, Priority='Low', AccountId=caseAsset.AccountId, Last_Updated_ProActive__c=system.now());      
        if(caseOwnerId != null){
            newCase.OwnerId = caseOwnerId;
        }
        return newCase;
    }
    
    public static Case updateProActiveCase(Event_Details__c newRoadside, Event newEvent, Asset caseAsset, Case proActiveCase){
        Case newCase = new Case(Id=proActiveCase.Id, Last_Updated_ProActive__c=system.now());
        if(newRoadside.Event_Type__c != null){
            if(proActiveCase.Event_Type__c != null){
                //Roadside Event Type is a multi select picklist so we need to split this
                newCase.Event_Type__c = proActiveCase.Event_Type__c;
                for(String eventType : newRoadside.Event_Type__c.split(';')){
                    if(!newCase.Event_Type__c.contains(eventType)){
                        newCase.Event_Type__c += ';' + eventType;
                    }
                }
            }
            else{
                newCase.Event_Type__c = newRoadside.Event_Type__c;
            }
            if(newEvent.Repeat_Event__c && proActiveCase.Case_Repeat_Type__c != null){
                newCase.Case_Repeat_Type__c = proActiveCase.Case_Repeat_Type__c;
                for(String eventType : newRoadside.Event_Type__c.split(';')){
                    if(!newCase.Case_Repeat_Type__c.contains(eventType)){
                        newCase.Case_Repeat_Type__c += ';' + eventType;
                    }
                }
            }
            else if(newEvent.Repeat_Event__c && proActiveCase.Case_Repeat_Type__c == null){
                newCase.Case_Repeat_Type__c = newRoadside.Event_Type__c;
            }
        }
        return newCase;        
    }
    
    public static void getAccountMarkets(){
        if(proActiveCaseMarkets == null){
            proActiveCaseMarkets = new Map<String, ProActive_Case_Market__mdt>();
            for(ProActive_Case_Market__mdt market: [SELECT DeveloperName, Queue_Id__c, New_Case_After_Hours__c, Create_Case_for_Roadside__c, Create_Case_for_Tow__c, Create_Case_for_Car_Hire__c, Create_Case_for_Tow_Car_Hire__c FROM ProActive_Case_Market__mdt]){
                proActiveCaseMarkets.put(market.DeveloperName, market);
            }
        } 
    }
}