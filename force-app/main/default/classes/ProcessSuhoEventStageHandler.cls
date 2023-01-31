public class ProcessSuhoEventStageHandler {
    
    @future
    public static void ProcessSuhoEventStage(String oppStr,String oldOppStr){
        system.debug('oppStr --> '+oppStr);
        system.debug('oldOppStr --> '+oldOppStr);
        
        List<Opportunity> oppList = (List<Opportunity>)json.deserialize(oppStr, List<Opportunity>.class);
        map<id,Opportunity> oldOpp = (map<id,Opportunity>)json.deserialize(oldOppStr, map<id,Opportunity>.class);
        
        Map<id,String> testDriveMap = new Map<id,String>();
        Map<id,String> appraisalMap = new Map<id,String>();
        Map<id,String> quotationMap = new Map<id,String>();
        Map<id,String> orderMap = new Map<id,String>();
        Map<id,Date> registrationMap = new Map<id,Date>();
        Map<id,String> welcomeMap = new Map<id,String>();
        
        Map<id,Opportunity> updateOppMap = new Map<id,Opportunity>();
        
        map<String,String> testDriveStatusMap = new map<String,String>{
            'Completed'=>'Completed',
                'Not Required'=>'Not Required',
                'Planned'=>'Planned',
                'Approved'=>'Approved',
                'Finished'=>'Finished',
                'No Show'=>'No Show',
                'Cancelled'=>'Cancelled',
                'Walk-In'=>'Walk-In'
                };
                    
                    map<String,String> statusMap = new map<String,String>{
                        'Not Started'=>'Not Started',
                            'Not Required (by customer)'=>'Not Required (by customer)',
                            'In Progress'=>'In Progress',
                            'Waiting on someone else'=>'Waiting on someone else',
                            'Deferred'=>'Deferred',
                            'Completed'=>'Completed'
                            };
                                map<String,String> orderStatusMap = new map<String,String>{
                                    'Not Required (by customer)'=>'Not Required (by customer)',
                                        'In Progress'=>'In Progress',
                                        'Completed'=>'Completed'
                                        };
                                            
                                            map<String,List<Task>> taskUpdateMap = new map<String,List<Task>>();
        List<Task> taskInsertList = new List<Task>();
        List<event> eventInsertList = new List<event>();
        map<String,List<event>> eventUpdateMap = new map<String,List<event>>();
        String registrationName = Label.Shuho_Registration;
        String appraisalName = Label.Shuho_Appraisal;
        String orderName = Label.Shuho_Order;
        String quotationName = Label.Shuho_Quotation;
        String testDriveName = Label.Shuho_Test_Drive;
        system.debug('testDriveName --> '+testDriveName);
        String welcomeQueName = Label.Shuho_Welcome_Questionnaire;
        Id testDriveRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
        Id appRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Appraisal').getRecordTypeId();
        Id quoRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Quotation').getRecordTypeId();
        Id orderRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Id regRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Registration').getRecordTypeId();
        Id welComeRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Welcome_Questionnaire').getRecordTypeId();
        
        for(Opportunity opp: oppList){
            if(oldOpp != null 
               && opp.Shuho_Activity_Update_Type__c != oldOpp.get(opp.Id).Shuho_Activity_Update_Type__c 
               && (opp.Shuho_Activity_Update_Type__c == 'Event' || opp.Shuho_Activity_Update_Type__c == 'Task')){
                   continue;
               }
            if(opp.Test_Drive_Complete__c != null
               && testDriveStatusMap.containsKey(opp.Test_Drive_Complete__c)
               && opp.Test_Drive_Complete__c != oldOpp.get(opp.Id).Test_Drive_Complete__c){
                   testDriveMap.put(opp.Id,testDriveStatusMap.get(opp.Test_Drive_Complete__c));
               }
            system.debug('Appraisal --> '+opp.Appraisal__c);
            system.debug('Appraisal222 --> '+statusMap.containsKey(opp.Appraisal__c));
            system.debug('Appraisal333 --> '+oldOpp.get(opp.Id).Appraisal__c);
            if(opp.Appraisal__c != null
               && statusMap.containsKey(opp.Appraisal__c)
               && opp.Appraisal__c != oldOpp.get(opp.Id).Appraisal__c){
                   appraisalMap.put(opp.Id,statusMap.get(opp.Appraisal__c));
               }
            
            if(opp.Order__c != null
               && orderStatusMap.containsKey(opp.Order__c)
               && opp.Order__c != oldOpp.get(opp.Id).Order__c){
                   orderMap.put(opp.Id,orderStatusMap.get(opp.Order__c));
               }
            
            if(opp.Registration_Date__c != null
               && opp.Registration_Date__c != oldOpp.get(opp.Id).Registration_Date__c){
                   registrationMap.put(opp.Id,opp.Registration_Date__c);
               }
            
            if(opp.Quotation__c != null
               && statusMap.containsKey(opp.Quotation__c)
               && opp.Quotation__c != oldOpp.get(opp.Id).Quotation__c){
                   quotationMap.put(opp.Id,statusMap.get(opp.Quotation__c));
               }
            
            if(opp.Welcome_Questionnaire__c != null
               && statusMap.containsKey(opp.Welcome_Questionnaire__c)
               && opp.Welcome_Questionnaire__c != oldOpp.get(opp.Id).Welcome_Questionnaire__c){
                   welcomeMap.put(opp.Id,statusMap.get(opp.Welcome_Questionnaire__c));
               }
        }
        system.debug('testDriveMap --> '+testDriveMap);
        if(testDriveMap != null && !testDriveMap.isEmpty()){
            date todayDate = System.today();
            for(Event evIns : [select id,Test_Drive_Status__c,WhatId,IsAllDayEvent,ActivityDateTime,DurationInMinutes  from Event where recordTypeId =:testDriveRecTypeId 
                               and  WhatId in:testDriveMap.keyset() and IsAllDayEvent = false and EndDateTime >=: todayDate order by createddate desc]){
                                   Event eveUpIns = new Event();
                                   eveUpIns.id = evIns.Id;
                                   eveUpIns.IsAllDayEvent = false;
                                   eveUpIns.EndDateTime = system.now();
                                   eveUpIns.Test_Drive_Status__c = testDriveMap.get(evIns.WhatId);
                                   if(!eventUpdateMap.containskey(evIns.WhatId+'-'+testDriveRecTypeId)){
                                       eventUpdateMap.put(evIns.WhatId+'-'+testDriveRecTypeId,new List<Event>{eveUpIns});
                                   }else{
                                       //eventUpdateMap.get(evIns.WhatId+'-'+testDriveRecTypeId).add(eveUpIns);
                                   }
                                   
                                   Opportunity oppIns = new Opportunity();
                                   oppIns.id = evIns.WhatId;
                                   oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                                   updateOppMap.put(oppIns.Id,oppIns);
                               }
            for(id idSet : testDriveMap.keyset()){
                if(!eventUpdateMap.containskey(idSet+'-'+testDriveRecTypeId)){ 
                    Event eve = new Event();
                    eve.Subject = testDriveName; 
                    eve.recordtypeid = testDriveRecTypeId;
                    eve.WhatId = idSet; 
                    eve.StartDateTime = system.now();
                    eve.IsAllDayEvent = false;
                    eve.EndDateTime = system.now();
                    eve.Test_Drive_Status__c = testDriveMap.get(idSet);
                    eventInsertList.add(eve);
                    
                    Opportunity oppIns = new Opportunity();
                    oppIns.id = idSet;
                    oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                    updateOppMap.put(oppIns.Id,oppIns);
                    
                }
            }
        }
        
        system.debug('appraisalMap --> '+appraisalMap);
        if(appraisalMap != null && !appraisalMap.isEmpty()){
            for(Task evIns : [select id,status,WhatId,recordTypeId from Task where recordTypeId =:appRecTypeId 
                              and  WhatId in:appraisalMap.keyset() and isclosed = false order by createddate desc]){
                                  Task taskUpIns = new Task();
                                  taskUpIns.id = evIns.Id;
                                  taskUpIns.Status = appraisalMap.get(evIns.WhatId);
                                  if(!taskUpdateMap.containskey(evIns.WhatId+'-'+appRecTypeId)){
                                      taskUpdateMap.put(evIns.WhatId+'-'+appRecTypeId,new List<Task>{taskUpIns});
                                  }else{
                                      // taskUpdateMap.get(evIns.WhatId+'-'+appRecTypeId).add(taskUpIns);
                                  }
                                  
                                  
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = evIns.WhatId;
                                  oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                                  updateOppMap.put(oppIns.Id,oppIns);
                              }
            
            for(Opportunity opp : [select id,Current_Vehicle__r.Make_Text__c,Current_Vehicle__r.Name from opportunity where id in:appraisalMap.keyset()]){
                if(!taskUpdateMap.containskey(opp.Id+'-'+appRecTypeId)){
                    Task taskIns = new Task();
                    taskIns.Subject = appraisalName;
                    taskIns.recordtypeid = appRecTypeId;
                    taskIns.whatid = opp.Id;
                    taskIns.Status = appraisalMap.get(opp.Id);
                    if(opp.Current_Vehicle__r.Make_Text__c != null && opp.Current_Vehicle__r.Name != null){
                        taskIns.Description = opp.Current_Vehicle__r.Make_Text__c+' '+opp.Current_Vehicle__r.Name;
                    }
                    taskInsertList.add(taskIns);
                    
                    Opportunity oppIns = new Opportunity();
                    oppIns.id = opp.Id;
                    oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                    updateOppMap.put(oppIns.Id,oppIns);
                }
            }
        }
        
        system.debug('quotationMap --> '+quotationMap);
        if(quotationMap != null && !quotationMap.isEmpty()){
            for(Task evIns : [select id,status,WhatId from Task where recordTypeId =:quoRecTypeId 
                              and  WhatId in:quotationMap.keyset() and isclosed = false order by createddate desc]){
                                  Task taskUpIns = new Task();
                                  taskUpIns.id = evIns.Id;
                                  taskUpIns.Status = quotationMap.get(evIns.WhatId);
                                  
                                  if(!taskUpdateMap.containskey(evIns.WhatId+'-'+quoRecTypeId)){
                                      taskUpdateMap.put(evIns.WhatId+'-'+quoRecTypeId,new List<Task>{taskUpIns});
                                  }else{
                                      //taskUpdateMap.get(evIns.WhatId+'-'+quoRecTypeId).add(taskUpIns);
                                  }
                                  
                                  
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = evIns.WhatId;
                                  oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                                  updateOppMap.put(oppIns.Id,oppIns);
                              }
            
            for(id idSet : quotationMap.keyset()){
                if(!taskUpdateMap.containskey(idSet+'-'+quoRecTypeId)){
                    Task taskIns = new Task();
                    taskIns.Subject = quotationName;
                    taskIns.recordtypeid = quoRecTypeId;
                    taskIns.whatid = idSet;
                    taskIns.Status = quotationMap.get(idSet);
                    taskInsertList.add(taskIns);
                    
                    Opportunity oppIns = new Opportunity();
                    oppIns.id = idSet;
                    oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                    updateOppMap.put(oppIns.Id,oppIns);
                }
            }
        }
        
        system.debug('welcomeMap --> '+welcomeMap);
        if(welcomeMap != null && !welcomeMap.isEmpty()){
            for(Task evIns : [select id,status,WhatId from Task where recordTypeId =:welComeRecTypeId 
                              and  WhatId in:welcomeMap.keyset() and isclosed = false order by createddate desc]){
                                  Task taskUpIns = new Task();
                                  taskUpIns.id = evIns.Id;
                                  taskUpIns.Status = welcomeMap.get(evIns.WhatId);
                                  if(!taskUpdateMap.containskey(evIns.WhatId+'-'+welComeRecTypeId)){
                                      taskUpdateMap.put(evIns.WhatId+'-'+welComeRecTypeId,new List<Task>{taskUpIns});
                                  }else{
                                      //taskUpdateMap.get(evIns.WhatId+'-'+welComeRecTypeId).add(taskUpIns);
                                  }
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = evIns.WhatId;
                                  oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                                  updateOppMap.put(oppIns.Id,oppIns);
                              }
            
            for(id idSet : welcomeMap.keyset()){
                if(!taskUpdateMap.containskey(idSet+'-'+welComeRecTypeId)){
                    Task taskIns = new Task();
                    taskIns.Subject = welcomeQueName;
                    taskIns.recordtypeid = welComeRecTypeId;
                    taskIns.whatid = idSet;
                    taskIns.Status = welcomeMap.get(idSet);
                    taskInsertList.add(taskIns);
                    
                    Opportunity oppIns = new Opportunity();
                    oppIns.id = idSet;
                    oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                    updateOppMap.put(oppIns.Id,oppIns);
                }
            }
        }
        
        system.debug('orderMap --> '+orderMap);
        if(orderMap != null && !orderMap.isEmpty()){
            for(Task evIns : [select id,status,WhatId from Task where recordTypeId =:orderRecTypeId 
                              and  WhatId in:orderMap.keyset() and isclosed = false order by createddate desc]){
                                  Task taskUpIns = new Task();
                                  taskUpIns.id = evIns.Id;
                                  taskUpIns.Status = orderMap.get(evIns.WhatId);
                                  if(!taskUpdateMap.containskey(evIns.WhatId+'-'+orderRecTypeId)){
                                      taskUpdateMap.put(evIns.WhatId+'-'+orderRecTypeId,new List<Task>{taskUpIns});
                                  }else{
                                      //taskUpdateMap.get(evIns.WhatId+'-'+orderRecTypeId).add(taskUpIns);
                                  }
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = evIns.WhatId;
                                  oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                                  updateOppMap.put(oppIns.Id,oppIns);
                              }
            
            for(id idSet : orderMap.keyset()){
                if(!taskUpdateMap.containskey(idSet+'-'+orderRecTypeId)){
                    Task taskIns = new Task();
                    taskIns.Subject = orderName;
                    taskIns.recordtypeid = orderRecTypeId;
                    taskIns.whatid = idSet;
                    taskIns.Status = orderMap.get(idSet);
                    taskInsertList.add(taskIns);
                    
                    Opportunity oppIns = new Opportunity();
                    oppIns.id = idSet;
                    oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                    updateOppMap.put(oppIns.Id,oppIns);
                }
            }
        }
        
        system.debug('registrationMap --> '+registrationMap);
        if(registrationMap != null && !registrationMap.isEmpty()){
            for(Task evIns : [select id,status,WhatId from Task where recordTypeId =:regRecTypeId 
                              and  WhatId in:registrationMap.keyset() order by createddate desc]){
                                  Task taskUpIns = new Task();
                                  taskUpIns.id = evIns.Id;
                                  taskUpIns.Status = 'Completed';
                                  taskUpIns.Event_date_and_time__c = registrationMap.get(evIns.WhatId);
                                  if(!taskUpdateMap.containskey(evIns.WhatId+'-'+regRecTypeId)){
                                      taskUpdateMap.put(evIns.WhatId+'-'+regRecTypeId,new List<Task>{taskUpIns});
                                  }else{
                                      //taskUpdateMap.get(evIns.WhatId+'-'+regRecTypeId).add(taskUpIns);
                                  }
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = evIns.WhatId;
                                  oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                                  updateOppMap.put(oppIns.Id,oppIns);
                              }
            
            for(id idSet : registrationMap.keyset()){
                if(!taskUpdateMap.containskey(idSet+'-'+regRecTypeId)){
                    Task taskIns = new Task();
                    taskIns.Subject = registrationName;
                    taskIns.recordtypeid = regRecTypeId;
                    taskIns.whatid = idSet;
                    taskIns.Status = 'Completed';
                    taskIns.Event_date_and_time__c = registrationMap.get(idSet);
                    taskInsertList.add(taskIns);
                    
                    Opportunity oppIns = new Opportunity();
                    oppIns.id = idSet;
                    oppIns.Shuho_Activity_Update_Type__c = 'Opportunity';
                    updateOppMap.put(oppIns.Id,oppIns);
                }
            }
        }
        
        if(updateOppMap != null && !updateOppMap.isEmpty()){
            update updateOppMap.values();
        }
        
        system.debug('taskUpdateMap ===> '+json.serialize(taskUpdateMap));
        if(taskUpdateMap != null && !taskUpdateMap.isEmpty()){
            map<id,Task> taskDMlMap = new map<id,Task>();
            for(String idIns : taskUpdateMap.keyset()){
                for(Task taskIns : taskUpdateMap.get(idIns)){
                    taskDMlMap.put(taskIns.Id,taskIns);
                }
            }
            system.debug('taskDMlMap ===> '+json.serialize(taskDMlMap));
            update taskDMlMap.values();
        }
        
        system.debug('eventUpdateMap ===> '+json.serialize(eventUpdateMap));
        if(eventUpdateMap != null && !eventUpdateMap.isEmpty()){
            map<id,Event> evemtDMlMap = new map<id,Event>();
            for(String idIns : eventUpdateMap.keyset()){
                for(Event eveIns : eventUpdateMap.get(idIns)){
                    evemtDMlMap.put(eveIns.Id,eveIns);
                }
            }
            system.debug('evemtDMlMap ===> '+json.serialize(evemtDMlMap));
            update evemtDMlMap.values();
        }
         system.debug('taskInsertList --> '+taskInsertList);
        if(taskInsertList != null && !taskInsertList.isEmpty()){
            insert taskInsertList;
        }
        system.debug('eventInsertList --> '+eventInsertList);
        if(eventInsertList != null && !eventInsertList.isEmpty()){
            insert eventInsertList;
        }
        
    }
    
}