public class NextActivitySetter {

    private String activityType;
    
    public NextActivitySetter(String triggerActivityType) {
        activityType = triggerActivityType;
    }

    public void SetNextActivityFieldOnRecord(Set<Id> recordsToCheck) {
        if(recordsToCheck == null || recordsToCheck.isEmpty()){
            return;
        }
        List<SObject> recordsWithNewDate = new List<SObject>();
        Map<Id, Date> recordEarliestDateMap = new Map<Id, Date>();
        Set<Id> personAccountIds = new Set<Id>();
        Id personAccountRecordId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        //only want to add this for objects that have Next_Activity_Date__c on them
        Map<String, Schema.SObjectType> mapSchema = Schema.getGlobalDescribe();
        Set<String> allowedPrefixes = new Set<String>();
        allowedPrefixes.add(mapSchema.get('Account').getDescribe().getKeyPrefix());
        allowedPrefixes.add(mapSchema.get('Contact').getDescribe().getKeyPrefix());
        allowedPrefixes.add(mapSchema.get('Lead').getDescribe().getKeyPrefix());
        allowedPrefixes.add(mapSchema.get('Opportunity').getDescribe().getKeyPrefix());
        Set<Id> recordsToUpdate = new Set<Id>();
        for(Id recordId : recordsToCheck){
            if(allowedPrefixes.contains(String.valueOf(recordId).left(3))){
                recordsToUpdate.add(recordId);
            }
        }
        if(recordsToUpdate.size() == 0){
            return;
        }
        //get all Tasks/Events currently associated to these records
        for(Task t : [SELECT ActivityDate, WhatId, What.RecordTypeId, WhoId, Who.RecordTypeId FROM Task WHERE ActivityDate >= TODAY AND Completed_Task__c = false AND (WhatId IN :recordsToUpdate OR WhoId IN :recordsToUpdate)]){
            //for each related record determine the first occurring task (or event)
            if(t.WhatId != null){
                if(!recordEarliestDateMap.containsKey(t.WhatId) || recordEarliestDateMap.get(t.WhatId) > t.ActivityDate){
                    recordEarliestDateMap.put(t.WhatId, t.ActivityDate);
                }
                if(t.What.RecordTypeId == personAccountRecordId){
                    personAccountIds.add(t.WhatId);
                }
            }
            if(t.WhoId != null){
                if(!recordEarliestDateMap.containsKey(t.WhoId) || recordEarliestDateMap.get(t.WhoId) > t.ActivityDate){
                    recordEarliestDateMap.put(t.WhoId, t.ActivityDate);
                }
                if(t.Who.RecordTypeId == personAccountRecordId){
                    personAccountIds.add(t.WhoId);
                }
            }
        }
        for(Event e : [SELECT StartDateTime, WhatId, What.RecordTypeId, WhoId, Who.RecordTypeId FROM Event WHERE StartDateTime > YESTERDAY AND Event_Completed__c = false AND (WhatId IN :recordsToUpdate OR WhoId IN :recordsToUpdate)]){
            Date startDate = e.StartDateTime.date();
            if(e.WhatId != null){
                if(!recordEarliestDateMap.containsKey(e.WhatId) || recordEarliestDateMap.get(e.WhatId) > StartDate){
                    recordEarliestDateMap.put(e.WhatId, startDate);
                }
                if(e.What.RecordTypeId == personAccountRecordId){
                    personAccountIds.add(e.WhatId);
                }
            }
            if(e.WhoId != null){
                if(!recordEarliestDateMap.containsKey(e.WhoId) || recordEarliestDateMap.get(e.WhoId) > StartDate){
                    recordEarliestDateMap.put(e.WhoId, startDate);
                }
                if(e.Who.RecordTypeId == personAccountRecordId){
                    personAccountIds.add(e.WhoId);
                }
            }
        }
        //for each record updated, add the corresponding Next Activity Date field value
        for(Id recordId : recordsToUpdate){
            SObject record = recordId.getSObjectType().newSObject();
            record.put('Id', recordId);
            if(recordEarliestDateMap.containsKey(recordId)){
                record.put('Next_Activity_Date__c', recordEarliestDateMap.get(recordId));
                if(personAccountIds.contains(recordId)){
                    record.put('Next_Activity_Date__pc', recordEarliestDateMap.get(recordId));
                }
            }
            else{
                record.put('Next_Activity_Date__c', null);
                if(personAccountIds.contains(recordId)){
                    record.put('Next_Activity_Date__pc', null);
                }
            }
            recordsWithNewDate.add(record);
        }
        if(!recordsWithNewDate.isEmpty()){
            try{
                update recordsWithNewDate;
            }
            catch(Exception e){
                System.debug('Cannot update records: ' + e.getMessage());
            }
        }
    }

}