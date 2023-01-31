public class Task_TriggerHandler {
    public void PreCreate(List<Task> tasks)
    {
        //Set the task IsVisibleInSelfService aka public field to true to enable visibility across users in the partner community.
        
        for(Task task : tasks)
        {
            if(task.RecordType.DeveloperName != 'Private_Task')
                task.IsVisibleInSelfService = true;
        }
        ActivityLocalFieldSetter activityLocalFieldSetter = new ActivityLocalFieldSetter();
        activityLocalFieldSetter.SetLocalFields(tasks);
        populateModelAndMake(tasks,null);
    }
    
    public void PreUpdate(List<Task> newTasks, List<Task> oldTasks,map<id,Task> taskOldMap)
    {
        ActivityLocalFieldSetter activityLocalFieldSetter = new ActivityLocalFieldSetter();
        activityLocalFieldSetter.SetLocalFields(newTasks, oldTasks);
        populateModelAndMake(newTasks,taskOldMap);
    }
    
    public void PostUpdate(List<Task> newTasks, List<Task> oldTasks,map<id,Task> taskOldMap){
        
        if(newTasks.size() == 1){
            Task_Ownership_Emailer ownershipEmailer = new Task_Ownership_Emailer(oldTasks[0],newTasks[0]);
            ownershipEmailer.Process_Update();
        }
        updateOpportunityModelAndMake(newTasks,taskOldMap);
        updateOpportunityShuhoStatus(newTasks,taskOldMap);
    }
    
    
    public void PostCreate(List<Task> Tasks)
    {
        if (tasks.size()==1) { 
            List<User> users = [select name, email, contact.account.name, usertype from user 
                                where contactid!=null and usertype='PowerPartner' and isactive=true and id = : tasks[0].ownerid]; 
            List<Case> cases = [select casenumber, createddate, account.name, description, asset.registration_number__c,
                                asset.name, asset.model__r.name, asset.model_year__c, asset.warranty_start_date__c 
                                from case where id = : tasks[0].whatid];
            if ( !users.isEmpty() && !cases.isEmpty() ) { 
                String BrazilEmailNotification = String.Format(Label.taskEmailNotification,new List<String>{users[0].name,'https://retailers.force.com/'+tasks[0].id,
                    cases[0].casenumber,cases[0].createddate.format('dd/MM/yyyy'),cases[0].account.name,users[0].contact.account.name, 
                    (cases[0].asset.registration_number__c==null?'':cases[0].asset.registration_number__c),cases[0].asset.name, 
                    cases[0].asset.model__r.name, (cases[0].asset.model_year__c==null?'':cases[0].asset.model_year__c),
                    (cases[0].asset.warranty_start_date__c==null?'':String.ValueOf(cases[0].asset.warranty_start_date__c)), 
                    cases[0].description, 
                    (tasks[0].internal_description__c==null?'':tasks[0].internal_description__c), 
                    (tasks[0].description==null?'':tasks[0].description)});
                EmailUtility.SendEmail(new List<String>{users[0].email}, 'JLR CXP Notification', Label.taskEmailNotificationSubject, BrazilEmailNotification.replaceAll('\n','<br/>'),
                                       null,users[0].email,false,null,false);
            }
            
            
            //SendEmail(List<String> toAddresses, String senderName, String Subject, 
            //                   String bodyHTML, String bodyText, String replyToEmail, Boolean insertTask, Id TaskParentId) { 
            
            
            
            Task_Ownership_Emailer ownershipEmailer = new Task_Ownership_Emailer(tasks[0]);
            ownershipEmailer.Process_Insert();            
        }  
        updateOpportunityModelAndMake(Tasks,null);
        updateOpportunityShuhoStatus(Tasks,null);      
    }
    public static Boolean AllowDelete = false;
    public void PreDelete(List<Task> OldTasks){
        
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        if(profileName != 'JLR System Administrator (Super)') {
            Object_CRUD_Permissions__c canDelete = Object_CRUD_Permissions__c.getInstance(UserInfo.getUserId());      
            system.debug('UserInfo.getUserId() '+UserInfo.getUserId());
            system.debug('canDelete '+canDelete);
            if(canDelete != null && canDelete.Able_to_Delete_Task__c != null && !canDelete.Able_to_Delete_Task__c)
            {
                aop_AOPException permissionException= new aop_AOPException();
                permissionException.setMessage(Label.Prevent_Task_Deletion_Error_Message);
                throw permissionException;
            }else{
                if(canDelete != null && canDelete.Able_to_Delete_Task__c ){
                    AllowDelete = true;  
                }
                
            }
            
            For(Task tsk : OldTasks){
                if(tsk.createdbyId != UserInfo.getUserId() &&  !AllowDelete)
                {
                    aop_AOPException permissionException= new aop_AOPException();
                    permissionException.setMessage('#####   '+Label.Prevent_Task_Deletion_Owner_Error_Message+'   #####');
                    throw permissionException;
                }
            }
            
        }       
    }
    
    public void PostDelete(List<Task> OldTasks) {
        SetNextActivityField(OldTasks, null);
    }
    
    public void SetNextActivityField(List<Task> tasks, Map<Id, Task> oldMap) {
        NextActivitySetter recordNextActivity = new NextActivitySetter('Task');
        Set<Id> affectedRecordIds = new Set<Id>();
        for(Task t : tasks){
            if(oldMap == null || !oldMap.containsKey(t.Id)){ //new Task
                if(t.WhatId != null){
                    affectedRecordIds.add(t.WhatId);
                }
                if(t.WhoId != null){
                    affectedRecordIds.add(t.WhoId);
                }
            }
            else if(oldMap.get(t.Id).ActivityDate != t.ActivityDate || oldMap.get(t.Id).Completed_Task__c != t.Completed_Task__c){
                if(t.WhatId != null){
                    affectedRecordIds.add(t.WhatId);
                }
                if(t.WhoId != null){
                    affectedRecordIds.add(t.WhoId);
                }
            }
        }
        if(!affectedRecordIds.isEmpty()){
            recordNextActivity.SetNextActivityFieldOnRecord(affectedRecordIds);
        }
    }
    
    public void populateModelAndMake(List<Task> tasks, Map<Id, Task> taskOldMap){
        set<id> modelIdSSet = new set<id>();
        map<id,String> modelMap = new map<id,String>();
        Id taskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Appraisal').getRecordTypeId();
        for(Task taskIns : tasks) {
            if(taskIns.Vehicle_Model__c != null 
               && taskIns.recordtypeid == taskRecTypeId
               && (taskOldMap == null || taskIns.Vehicle_Model__c != taskOldMap.get(taskIns.Id).Vehicle_Model__c)){
                   modelIdSSet.add(taskIns.Vehicle_Model__c);
               }
        }
        
        if(modelIdSSet != null && !modelIdSSet.isEmpty()){
            for(Vehicle_Specification__c vehiSpec : [select Id, Name, Make__c, Make_Text__c FROM Vehicle_Specification__c WHERE id in: modelIdSSet]){
                modelMap.put(vehiSpec.Id,vehiSpec.Make_Text__c);
            }
            for(Task task : tasks){
                if(task.Vehicle_Model__c != null 
                   && modelMap.containskey(task.Vehicle_Model__c)
                   && modelMap.get(task.Vehicle_Model__c) != null){
                       task.Vehicle_Brand__c = modelMap.get(task.Vehicle_Model__c);
                   }
            }
        }
    }
    
    public void updateOpportunityModelAndMake(List<Task> newTasks, Map<Id, Task> taskOldMap){
        map<id,Opportunity> opportunityUpdateMap = new map<id,Opportunity>();
        set<id> modelIdSet = new set<id>();
        Id taskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Appraisal').getRecordTypeId();
        map<id,Vehicle_Specification__c> modelNameMap = new map<id,Vehicle_Specification__c>();
        for(Task task : newTasks){
            if(task.WhatId != null 
               && task.recordtypeid == taskRecTypeId
               && String.valueof(task.WhatId).startsWith('006')
               && task.Vehicle_Model__c != null
               && task.Vehicle_Brand__c != null
               && (taskOldMap == null || ((task.Vehicle_Model__c != taskOldMap.get(task.Id).Vehicle_Model__c)
                                          || (task.Vehicle_Brand__c != taskOldMap.get(task.Id).Vehicle_Brand__c)))){
                                              Opportunity oppIns = new Opportunity();
                                              oppIns.Id = task.WhatId;
                                              oppIns.Revised_Trade_in_Model__c = task.Vehicle_Model__c;
                                              oppIns.Revised_Trade_in_Brand__c = task.Vehicle_Brand__c;
                                              opportunityUpdateMap.put(oppIns.Id,oppIns);
                                              modelIdSet.add(task.Vehicle_Model__c);
                                          }
        }
        if(modelIdSet != null && !modelIdSet.isempty()){
            for(Vehicle_Specification__c vehSpec : [select id,name,Make_Text__c from Vehicle_Specification__c where id in:modelIdSet]){
                modelNameMap.put(vehSpec.id,vehSpec);
            }
            
            
            system.debug('opportunityUpdateMap--> '+opportunityUpdateMap);
            if(opportunityUpdateMap != null && !opportunityUpdateMap.isEmpty()){
                for(id oppId : opportunityUpdateMap.keyset()){
                    if(opportunityUpdateMap.containskey(oppId) && opportunityUpdateMap.get(oppId).Revised_Trade_in_Model__c != null){                    
                        String tradeModel = opportunityUpdateMap.get(oppId).Revised_Trade_in_Model__c;
                        if(modelNameMap.containskey(tradeModel)){
                            opportunityUpdateMap.get(oppId).Revised_Trade_in_Model__c = modelNameMap.get(tradeModel).name;
                            opportunityUpdateMap.get(oppId).Revised_Trade_in_Brand__c = modelNameMap.get(tradeModel).Make_Text__c;
                        }
                    }
                }
                update opportunityUpdateMap.values();
            }
        }
    }
    
    public void updateOpportunityShuhoStatus(List<Task> newTasks, Map<Id, Task> taskOldMap){
        Id appRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Appraisal').getRecordTypeId();
        Id quoRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Quotation').getRecordTypeId();
        Id orderRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Order').getRecordTypeId();
        Id welComeRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Welcome_Questionnaire').getRecordTypeId();
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
                                
                                map<id,Opportunity> oppUpdateMap = new map<id,Opportunity>();
        for(Task taskIns : newTasks){
            if(taskIns.WhatId != null
               && String.valueof(taskIns.WhatId).startsWith('006')
               && ((taskOldMap != null && taskIns.Status != taskOldMap.get(taskIns.Id).Status) || taskOldMap == null)){
                   
                   if(statusMap.containskey(taskIns.Status) 
                      && (taskIns.RecordTypeId == appRecTypeId 
                          ||taskIns.RecordTypeId == quoRecTypeId
                          ||taskIns.RecordTypeId == welComeRecTypeId)){
                              
                              
                              if(taskIns.RecordTypeId == appRecTypeId){
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = taskIns.WhatId;
                                  oppIns.Appraisal__c = statusMap.get(taskIns.Status);
                                  oppIns.Shuho_Activity_Update_Type__c = 'Task';
                                  oppUpdateMap.put(oppIns.Id,oppIns);
                              }
                              
                              if(taskIns.RecordTypeId == quoRecTypeId){
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = taskIns.WhatId;
                                  oppIns.Quotation__c = statusMap.get(taskIns.Status);
                                  oppIns.Shuho_Activity_Update_Type__c = 'Task';
                                  oppUpdateMap.put(oppIns.Id,oppIns);
                              }
                              
                              if(taskIns.RecordTypeId == welComeRecTypeId){
                                  Opportunity oppIns = new Opportunity();
                                  oppIns.id = taskIns.WhatId;
                                  oppIns.Welcome_Questionnaire__c = statusMap.get(taskIns.Status);
                                  oppIns.Shuho_Activity_Update_Type__c = 'Task';
                                  oppUpdateMap.put(oppIns.Id,oppIns);
                              }
                              
                              
                          }else  if(orderStatusMap.containskey(taskIns.Status)
                                    && taskIns.RecordTypeId == orderRecTypeId){
                                            
                                            if(taskIns.RecordTypeId == orderRecTypeId){
                                                Opportunity oppIns = new Opportunity();
                                                oppIns.id = taskIns.WhatId;
                                                oppIns.Order__c = orderStatusMap.get(taskIns.Status);
                                                oppIns.Shuho_Activity_Update_Type__c = 'Task';
                                                oppUpdateMap.put(oppIns.Id,oppIns);
                                            }
                                        }
               }
        }
        if(oppUpdateMap != null && !oppUpdateMap.isEmpty()){
            update oppUpdateMap.values();
        }
    }
}