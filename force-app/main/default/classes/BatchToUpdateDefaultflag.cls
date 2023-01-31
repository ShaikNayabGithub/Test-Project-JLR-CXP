global class BatchToUpdateDefaultflag implements Database.Batchable<sObject>, Database.stateful {
    // Batch job to update the opportunity records as part of CXPD-611
    String name = '';
    global Database.queryLocator start(Database.BatchableContext bc){
        name += 'Start';
        System.debug('@@@Start'+name);
        return Database.getQueryLocator('SELECT Id, Name, owner.name, Owned_By_Default_User__c FROM Opportunity WHERE owner.country_ISO_Code__c = \'AU\' AND owner.name Like \'%Default%\'');
        
    } 
    
    global void execute(Database.BatchableContext bc, List<sObject> sObjLst){
        name += 'Execute';
        system.debug('@@@Execute: '+name);
        System.debug('sObjLst size'+sObjLst.size());
        List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity opp : (List<Opportunity>)sObjLst){
            opp.Owned_By_Default_User__c = true;
            oppList.add(opp);
        }
        if(oppList.size() >0){
            update oppList;
            system.debug('Number of Records Updated : '+oppList.size());
        }
    }
    
    global void finish(Database.BatchableContext bc){
        name =+ 'Finish';
        System.debug('@@@finish: '+name);
    }

}