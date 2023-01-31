public class ProcessSalesTargetCounts {
    
    public static void checkOppCount(List<Opportunity> oppList,map<id,Opportunity> oldOpp){
        set<String> handOverStageSet = new set<String>{'Handover & RDA'};
            set<String> orderStageSet = new set<String>{'Order','Order Taken'};
                set<id> salesPersonIdsSet = new set<id>();
        String changeType;
        
        for(Opportunity opp : oppList){
            if(opp.stageName != null
               && opp.ownerid != null 
               && opp.Purchase_Type__c == 'New Vehicle'
               && opp.stageName != oldOpp.get(opp.id).stageName){
                   if(opp.closeDate != null 
                      && (handOverStageSet.contains(opp.stageName) || handOverStageSet.contains(oldOpp.get(opp.id).stageName))
                      && !orderStageSet.contains(opp.stageName)){
                          salesPersonIdsSet.add(opp.ownerid);
                          changeType = 'Handover';
                          system.debug('1--> '+changeType);
                      }else if(opp.Date_To_Order_Stage__c != null
                               && (orderStageSet.contains(opp.stageName)  || orderStageSet.contains(oldOpp.get(opp.id).stageName))){
                                   salesPersonIdsSet.add(opp.ownerid);
                                   changeType = 'Order';
                                   system.debug('2--> '+changeType);
                               }
               }
        }
        
        if(!System.isFuture() 
           && !System.isBatch()
           && changeType != null
           && salesPersonIdsSet != null
           && !salesPersonIdsSet.isEmpty()){
               system.debug('changeType --> '+changeType);
               if(changeType == 'Handover'){
                   processCountsFuture(salesPersonIdsSet,handOverStageSet,changeType);
               }else if(changeType == 'Order'){
                   processCountsFuture(salesPersonIdsSet,handOverStageSet,changeType);
                   processCountsFuture(salesPersonIdsSet,handOverStageSet,'Handover');
               }
           }
    }
    
    @future
    public static void processCountsFuture(set<id> salesPersonsIdsSet,set<String> ValuesSet,String changeType){
        Date dat = System.today();
        Integer currentYear = dat.year();
        String currYearStr = String.valueOf(currentYear);
        processCounts(currYearStr,salesPersonsIdsSet,ValuesSet,changeType);
    }
    
    
    public static void processCounts(String currYearStr,set<id> salesPersonsIdsSet,set<String> stageValuesSet,String changeType){
        Integer currentYear = Integer.valueOf(currYearStr);
        System.debug('Year is ' + currYearStr);
        System.debug('changeType ' + changeType); 
        System.debug('salesPersonsIdsSet ' + salesPersonsIdsSet); 
        System.debug('stageValuesSet ' + stageValuesSet); 
        List<AggregateResult> aggResList;
        map<Id,Boolean> salesPersonMap = new map<Id,Boolean>();
        for(id idsIns : salesPersonsIdsSet){
            salesPersonMap.put(idsIns,false);
        }        
        
        
        
        if(changeType == 'Handover'){
            aggResList = [select 
                          count(id) cnt,ownerid owId,FISCAL_YEAR(closeDate) yr, FISCAL_MONTH(closeDate) mnth 
                          from 
                          opportunity 
                          where
                          ownerid in: salesPersonsIdsSet and FISCAL_YEAR(closeDate) =: currentYear
                          and StageName = 'Handover & RDA'
                          and Purchase_Type__c = 'New Vehicle'
                          and owner.isactive = true 
                          and closeDate != null
                          group by ownerid,FISCAL_YEAR(closeDate), FISCAL_MONTH(closeDate)
                          order by FISCAL_MONTH(closeDate)];
        }else if(changeType == 'Order' || changeType == 'Order Taken'){
            aggResList = [select 
                          count(id) cnt,ownerid owId,FISCAL_YEAR(Date_To_Order_Stage__c) yr, FISCAL_MONTH(Date_To_Order_Stage__c) mnth 
                          from 
                          opportunity 
                          where 
                          ownerid in: salesPersonsIdsSet and FISCAL_YEAR(Date_To_Order_Stage__c) =: currentYear
                          and (((StageName = 'Order' OR StageName = 'Order Taken') AND Date_To_Order_Stage__c != null) OR (StageName = 'Handover & RDA' AND Date_To_Order_Stage__c != null))
                          and Purchase_Type__c = 'New Vehicle'
                          and owner.isactive = true 
                          group by ownerid,FISCAL_YEAR(Date_To_Order_Stage__c), FISCAL_MONTH(Date_To_Order_Stage__c)
                          order by FISCAL_MONTH(Date_To_Order_Stage__c)];
        }
        system.debug('-->  '+json.serialize(aggResList));
        if(aggResList != null && !aggResList.isEmpty()){
            map<id,SalesTargetWrapper> salesTargetMap = new map<id,SalesTargetWrapper>();
            for(AggregateResult aggr  : aggResList){
                decimal recCnt = (decimal)aggr.get('cnt');
                Integer currYr = (Integer)aggr.get('yr');
                Integer mnth = (Integer)aggr.get('mnth');
                String salesPersonId = (String)aggr.get('owId');
                if(recCnt != null 
                   && currYr != null
                   && mnth != null
                   && salesPersonId != null){
                       if(!salesTargetMap.containsKey(salesPersonId)){
                           SalesTargetWrapper targetWrapIns =  SalesTargetProcessor.processTargets(null,salesPersonId,mnth,currYr,recCnt,changeType);
                           salesTargetMap.put(salesPersonId,targetWrapIns);
                       }else if(salesTargetMap.containsKey(salesPersonId) && salesTargetMap.get(salesPersonId) != null){
                           SalesTargetWrapper targetWrapIns =  salesTargetMap.get(salesPersonId);
                           SalesTargetWrapper targetUpdateWrapIns =  SalesTargetProcessor.processTargets(targetWrapIns,salesPersonId,mnth,currYr,recCnt,changeType);
                           salesTargetMap.put(salesPersonId,targetUpdateWrapIns);
                       }
                   }
            }
            system.debug('salesTargetMap --> '+json.serialize(salesTargetMap));
            if(salesTargetMap != null
               && !salesTargetMap.isEmpty()){
                   map<id,Sales_Target__c> salesTargetUpdateMap = new map<id,Sales_Target__c>();
                   String recordtypeId = Schema.SObjectType.Sales_Target__c.getRecordTypeInfosByName().get('Opportunity Sales Target').getRecordTypeId();
                   for(Sales_Target__c dataIns : [SELECT Id,  January_Order__c, February_Order__c, March_Order__c, April_Order__c, May_Order__c, June_Order__c, July_Order__c, August_Order__c, September_Order__c, October_Order__c, November_Order__c, December_Order__c,Salesperson__c 
                                                  FROM Sales_Target__c where Salesperson__c IN: salesTargetMap.keyset() AND Salesperson__r.isActive = true AND Target_Year__c = :currYearStr and recordtypeid = :recordtypeId]){
                                                      if(salesTargetMap.containskey(dataIns.Salesperson__c)
                                                         && salesTargetMap.get(dataIns.Salesperson__c) != null){
                                                             
                                                             SalesTargetWrapper targetWrapIns = salesTargetMap.get(dataIns.Salesperson__c);
                                                             Sales_Target__c salesTargetUpdateIns = new Sales_Target__c();
                                                             salesTargetUpdateIns.id = dataIns.Id;
                                                             
                                                             if(salesPersonMap.containskey(dataIns.Salesperson__c)){
                                                                 salesPersonMap.put(dataIns.Salesperson__c,true);
                                                             }
                                                             system.debug('changeType --> '+changeType); 
                                                             
                                                             if(changeType == 'Order' || changeType == 'Order Taken'){
                                                                 if(targetWrapIns.janOrder != null){
                                                                     salesTargetUpdateIns.January_Order__c = targetWrapIns.janOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.January_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.febOrder != null){
                                                                     salesTargetUpdateIns.February_Order__c = targetWrapIns.febOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.February_Order__c = 0;
                                                                 }
                                                                 
                                                                 
                                                                 if(targetWrapIns.marOrder != null){
                                                                     salesTargetUpdateIns.March_Order__c = targetWrapIns.marOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.March_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.aprOrder != null){
                                                                     salesTargetUpdateIns.April_Order__c = targetWrapIns.aprOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.April_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.mayOrder != null){
                                                                     salesTargetUpdateIns.May_Order__c = targetWrapIns.mayOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.May_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.junOrder != null){
                                                                     salesTargetUpdateIns.June_Order__c = targetWrapIns.junOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.June_Order__c = 0;
                                                                 }
                                                                 if(targetWrapIns.julOrder != null){
                                                                     salesTargetUpdateIns.July_Order__c = targetWrapIns.julOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.July_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.augOrder != null){
                                                                     salesTargetUpdateIns.August_Order__c = targetWrapIns.augOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.August_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.sepOrder != null){
                                                                     salesTargetUpdateIns.September_Order__c = targetWrapIns.sepOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.September_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.octOrder != null){
                                                                     salesTargetUpdateIns.October_Order__c = targetWrapIns.octOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.October_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.novOrder != null){
                                                                     salesTargetUpdateIns.November_Order__c = targetWrapIns.novOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.November_Order__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.decOrder != null){
                                                                     salesTargetUpdateIns.December_Order__c = targetWrapIns.decOrder;
                                                                 }else{
                                                                     salesTargetUpdateIns.December_Order__c = 0;
                                                                 }
                                                                 
                                                                 system.debug('133-->  '+json.serialize(salesTargetUpdateIns));
                                                                 salesTargetUpdateMap.put(salesTargetUpdateIns.id,salesTargetUpdateIns);
                                                                 
                                                             }  else if(changeType == 'Handover'){
                                                                 if(targetWrapIns.janHandover != null){
                                                                     salesTargetUpdateIns.January_Handover__c = targetWrapIns.janHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.January_Handover__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.febHandover != null){
                                                                     salesTargetUpdateIns.February_Handover__c = targetWrapIns.febHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.February_Handover__c = 0;
                                                                 }
                                                                 if(targetWrapIns.marHandover != null){
                                                                     salesTargetUpdateIns.March_Handover__c = targetWrapIns.marHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.March_Handover__c = 0;
                                                                 }
                                                                 if(targetWrapIns.aprHandover != null){
                                                                     salesTargetUpdateIns.April_Handover__c = targetWrapIns.aprHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.April_Handover__c = 0;
                                                                 }
                                                                 if(targetWrapIns.mayHandover != null){
                                                                     salesTargetUpdateIns.May_Handover__c = targetWrapIns.mayHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.May_Handover__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.junHandover != null){
                                                                     salesTargetUpdateIns.June_Handover__c = targetWrapIns.junHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.June_Handover__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.julHandover != null){
                                                                     salesTargetUpdateIns.July_Handover__c = targetWrapIns.julHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.July_Handover__c = 0;
                                                                 }
                                                                 if(targetWrapIns.augHandover != null){
                                                                     salesTargetUpdateIns.August_Handover__c = targetWrapIns.augHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.August_Handover__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.sepHandover != null){
                                                                     salesTargetUpdateIns.September_Handover__c = targetWrapIns.sepHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.September_Handover__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.octHandover != null){
                                                                     salesTargetUpdateIns.October_Handover__c = targetWrapIns.octHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.October_Handover__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.novHandover != null){
                                                                     salesTargetUpdateIns.November_Handover__c = targetWrapIns.novHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.November_Handover__c = 0;
                                                                 }
                                                                 
                                                                 if(targetWrapIns.decHandover != null){
                                                                     salesTargetUpdateIns.December_Handover__c = targetWrapIns.decHandover;
                                                                 }else{
                                                                     salesTargetUpdateIns.December_Handover__c = 0;
                                                                 }
                                                                 salesTargetUpdateMap.put(salesTargetUpdateIns.id,salesTargetUpdateIns);
                                                             }  
                                                         }
                                                  }
                   
                   system.debug('salesTargetUpdateMap --->  '+JSON.serialize(salesTargetUpdateMap)); 
                   system.debug('salesTargetUpdateMap --->  '+salesTargetUpdateMap.size()); 
                   if(salesTargetUpdateMap != null
                      && !salesTargetUpdateMap.isEmpty()){
                          Database.SaveResult[] saveResList = database.update(salesTargetUpdateMap.values(),false);
                          for (Database.SaveResult sr : saveResList) {
                              if (sr.isSuccess()) {
                              }else {
                                  for(Database.Error err : sr.getErrors()) {
                                      System.debug('The following error has occurred.');                    
                                      System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                      System.debug('fields that affected this error: ' + err.getFields());
                                  }
                              }
                          } 
                      }
               }
        }else{
            system.debug('salesPersonMap --->  '+salesPersonMap.size());
            system.debug('salesPersonMap --->  '+JSON.serialize(salesPersonMap)); 
            
            if(salesPersonMap != null 
               && !salesPersonMap.isEmpty()){
                   map<id,Sales_Target__c> salesTargetWithotValuesMap = new map<id,Sales_Target__c>();
                   for(Sales_Target__c sal : [select id,Salesperson__c from Sales_Target__c where Salesperson__c in:salesPersonMap.keyset()]){
                       if(salesPersonMap.containskey(sal.Salesperson__c)
                          && !salesPersonMap.get(sal.Salesperson__c)){
                              Sales_Target__c salesUp = new Sales_Target__c();
                              salesUp.id = sal.Id;
                              if(changeType == 'Order' || changeType == 'Order Taken'){
                                  salesUp.January_Order__c = 0;
                                  salesUp.February_Order__c = 0;
                                  salesUp.March_Order__c = 0;
                                  salesUp.April_Order__c = 0;
                                  salesUp.May_Order__c = 0;
                                  salesUp.June_Order__c = 0;
                                  salesUp.July_Order__c = 0;
                                  salesUp.August_Order__c = 0;
                                  salesUp.September_Order__c = 0;
                                  salesUp.October_Order__c = 0;
                                  salesUp.November_Order__c = 0;
                                  salesUp.December_Order__c = 0;
                                  
                              }
                              if(changeType == 'Handover'){
                                  salesUp.January_Handover__c = 0;
                                  salesUp.February_Handover__c = 0;
                                  salesUp.March_Handover__c = 0;
                                  salesUp.April_Handover__c = 0;
                                  salesUp.May_Handover__c = 0;
                                  salesUp.June_Handover__c = 0;
                                  salesUp.July_Handover__c = 0;
                                  salesUp.August_Handover__c = 0;
                                  salesUp.September_Handover__c = 0;
                                  salesUp.October_Handover__c = 0;
                                  salesUp.November_Handover__c = 0;
                                  salesUp.December_Handover__c = 0;
                              }
                              
                              salesTargetWithotValuesMap.put(salesUp.Id,salesUp);
                          }
                   }
                   
                   if(salesTargetWithotValuesMap != null
                      && !salesTargetWithotValuesMap.isEmpty()){
                          Database.SaveResult[] saveResList = database.update(salesTargetWithotValuesMap.values(),false);
                          for (Database.SaveResult sr : saveResList) {
                              if (sr.isSuccess()) {
                              }else {
                                  for(Database.Error err : sr.getErrors()) {
                                      System.debug('The following error has occurred.');                    
                                      System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                      System.debug('fields that affected this error: ' + err.getFields());
                                  }
                              }
                          } 
                      }
               }
        }
    }
}