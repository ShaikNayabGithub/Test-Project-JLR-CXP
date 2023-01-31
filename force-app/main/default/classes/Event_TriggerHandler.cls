public class Event_TriggerHandler {
    
    public static Id testDriveRecordtypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
    public static Id testDriveDetailsRecordtypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive_Details').getRecordTypeId();
    
    public void PreCreate(List<Event> events) {
        if(!AccountHandler.IgnoreCaseValidation) {
            checkModifyClosedCaseRelatedItemsPermission(events);
            /*Set<Id> eventIdSet = new Set<Id>();
            for(Event eve : events) {
                if(eve.WhatId != null && eve.WhatId.getsObjectType() == Case.sObjectType){
                    eventIdSet.add(eve.WhatId);    
                }
            }
            if(!eventIdSet.isEmpty()){
                Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: eventIdSet]);
                for(Event e : events){
                    if(e.WhatId != null && e.WhatId.getsObjectType() == Case.sObjectType ){
                        Case c = caseMap.get(e.WhatId);
                        if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                            if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                                e.addError(Label.Error_Edit_Closed_Cases);
                            }
                        }
                    }
                }
            }*/
        }
        
        ActivityLocalFieldSetter activityLocalFieldSetter = new ActivityLocalFieldSetter();
        Event_WhoContactSetter whoContactSetter = new Event_WhoContactSetter();
        Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();
        
        activityLocalFieldSetter.SetLocalFields(events);
        whoContactSetter.SetWhoContact(events);
        vehicleDetailsSetter.SetVehicleDetails(events);
        
        //Added By Masthan Andela as part of Case Management User-Story
        RepeatEventHandler.CreateNewVehicleEvent(events);
        //Added By Masthan Andela as part of feedBack update
        setDefaultRecordType(events);
    }
    
    public void PreUpdate(List<Event> newEvents, List<Event> oldEvents) {
        if(!AccountHandler.IgnoreCaseValidation) {
            checkModifyClosedCaseRelatedItemsPermission(newEvents);
            /* Set<Id> eventIdSet = new Set<Id>();
            for(Event eve : newEvents) {
                if(eve.WhatId != null && eve.WhatId.getsObjectType() == Case.sObjectType){
                    eventIdSet.add(eve.WhatId);    
                }
            }
            if(!eventIdSet.isEmpty()){
                Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: eventIdSet]);
                for(Event e : newEvents){
                    if(e.WhatId != null && e.WhatId.getsObjectType() == Case.sObjectType ){
                        Case c = caseMap.get(e.WhatId);
                        if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                            if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                                e.addError(Label.Error_Edit_Closed_Cases);
                            }
                        }
                    }
                }
            } */
        }        
        
        ActivityLocalFieldSetter activityLocalFieldSetter = new ActivityLocalFieldSetter();
        Event_WhoContactSetter whoContactSetter = new Event_WhoContactSetter();
        Activity_VehicleDetailsSetter vehicleDetailsSetter = new Activity_VehicleDetailsSetter();
        
        activityLocalFieldSetter.SetLocalFields(newEvents, oldEvents);
        whoContactSetter.SetWhoContact(newEvents);
        vehicleDetailsSetter.SetVehicleDetails(newEvents, oldEvents);
    }
    
    public void checkModifyClosedCaseRelatedItemsPermission(List < Event > eventList) {
        if(eventList != null && !eventList.isEmpty()) {
            Set<Id> eventIdSet = new Set<Id>();
            for(Event eve : eventList) {
                if(eve.WhatId != null && eve.WhatId.getsObjectType() == Case.sObjectType){
                    eventIdSet.add(eve.WhatId);    
                }
            }
            if(!eventIdSet.isEmpty()){
                Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: eventIdSet]);
                for(Event e : eventList){
                    if(e.WhatId != null && e.WhatId.getsObjectType() == Case.sObjectType ){
                        Case c = caseMap.get(e.WhatId);
                        if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                            if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                                e.addError(Label.Error_Edit_Closed_Cases);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void PostCreate(List<Event> newEvents) {
        
        Id roadsideId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Roadside').GetRecordTypeId();
        List<Event> applicableEvents = new List<Event>();
        for(Event evt : newEvents){
            if( evt.WhatId != null && evt.VIN_number__c != null && evt.VIN_number__c == evt.WhatId && evt.RecordTypeId == roadsideId){
                system.debug('found applicaple JKL');
                applicableEvents.add(evt);
            }
            
        }
        if(!applicableEvents.isEmpty()){
            CustomerJourneySetterStatusAccount CJSSA = new CustomerJourneySetterStatusAccount();
            CJSSA.setMaintainFromRoadsideEvent(applicableEvents);
        }
        //Added By Masthan Andela as part of Case Management User-Story 
        RepeatEventHandler.RepeatCaseUpserterForCreatedEvents();
        
    }
    
    public void SetNextActivityField(List<Event> events, Map<Id, Event> oldMap) {
        NextActivitySetter recordNextActivity = new NextActivitySetter('Event');
        Set<Id> affectedRecordIds = new Set<Id>();
        for(Event e : events){
            if(oldMap == null || !oldMap.containsKey(e.Id)){ //new Event
                if(e.WhatId != null){
                    affectedRecordIds.add(e.WhatId);
                }
                if(e.WhoId != null) { affectedRecordIds.add(e.WhoId); }
            }
            else if(oldMap.get(e.Id).StartDateTime != e.StartDateTime || oldMap.get(e.Id).Event_Completed__c != e.Event_Completed__c){
                if(e.WhatId != null){
                    affectedRecordIds.add(e.WhatId);
                }
                if(e.WhoId != null){ affectedRecordIds.add(e.WhoId); }
            }
        }
        if(!affectedRecordIds.isEmpty()){
            recordNextActivity.SetNextActivityFieldOnRecord(affectedRecordIds);
        }
    }
    
    public void setDefaultRecordType(List<Event> triggerNewList) {
        for(Event newEvent: triggerNewList){
            if(newEvent.RecordTypeId == testDriveDetailsRecordtypeId) {
                newEvent.RecordTypeId = testDriveRecordtypeId;
            }
        }
    }
    
    public void PreDelete(List<Event> oldEvents) {
        if(!AccountHandler.IgnoreCaseValidation) {
            checkModifyClosedCaseRelatedItemsPermission(oldEvents);
            /* Set<Id> eventIdSet = new Set<Id>();
            for(Event eve : oldEvents) {
                if(eve.WhatId.getsObjectType() == Case.sObjectType){
                    eventIdSet.add(eve.WhatId);    
                }
            }
            if(!eventIdSet.isEmpty()){
                Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, Status from Case where Id =: eventIdSet]);
                for(Event e : oldEvents){
                    if(e.WhatId.getsObjectType() == Case.sObjectType ){
                        Case c = caseMap.get(e.WhatId);
                        if(c != null && (c.Status == 'Closed' || c.Status == 'Cancelled' || c.Status == 'Solved')){
                            if(!FeatureManagement.checkPermission('Modify_closed_case_related_items')){
                                e.addError(Label.Error_Edit_Closed_Cases);
                            }
                        }
                    }
                }
            } */
        }
    }
    
    public void updateVINBrandFromAsset(Map<id,Event> newMap,Map<id,Event> oldMap){
        SurveyHandler.updateVINBrandFromAsset(newMap, oldMap);
    }
    
    public void updateOpportunityShuhoStatus(List<Event> newEvents, Map<Id, Event> taskOldMap){
        Id testDriveRecId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
        map<id,Opportunity> oppUpdateMap = new map<id,Opportunity>();
        map<String,String> testDriveStatusMap = new map<String,String>{
            'Completed'=>'Completed',
                'Not Required'=>'Not Required',
                'Planned'=>'Planned',
                'Approved'=>'Approved',
                'Finished'=>'Finished',
                'No Show'=>'No Show',
                'Cancelled'=>'Cancelled',
                'Walk-In'=>'Walk-In'};
                    for(Event ev : newEvents){
                        if(ev.Test_Drive_Status__c != null
                           && ev.WhatId != null
                           && String.valueof(ev.WhatId).startsWith('006')
                           && ev.recordtypeid == testDriveRecId
                           && testDriveStatusMap.containsKey(ev.Test_Drive_Status__c)
                           && ((taskOldMap != null && ev.Test_Drive_Status__c != taskOldMap.get(ev.Id).Test_Drive_Status__c) || taskOldMap == null)){
                               Opportunity oppIns = new Opportunity(Id = ev.WhatId, Shuho_Activity_Update_Type__c = 'Event', Test_Drive_Complete__c = testDriveStatusMap.get(ev.Test_Drive_Status__c));
                               // oppIns.id = ev.WhatId;
                               // oppIns.Shuho_Activity_Update_Type__c = 'Event';
                               // oppIns.Test_Drive_Complete__c = testDriveStatusMap.get(ev.Test_Drive_Status__c);
                               oppUpdateMap.put(oppIns.Id,oppIns);
                           }
                    } 
        if(oppUpdateMap != null && !oppUpdateMap.isEmpty()) {
            update oppUpdateMap.values();
        }
    }
}