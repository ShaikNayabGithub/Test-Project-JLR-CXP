global class BatchCountOpenCasesPerObject implements Database.batchable<sObject>, Database.Stateful {
    String query;
    String objectType; 
    List<Boolean> tfSettings;
    TriggerFramework__c tf = TriggerFramework__c.getInstance(UserInfo.getProfileId());
    
    global BatchCountOpenCasesPerObject(String oType) {   
    
        objectType = oType;
        tfSettings = new List<Boolean>();         
        
        if (objectType=='Account') {
            tfSettings.add(tf.Account_SkipValidations__c);
            tfSettings.add(tf.Account_PreInsert__c);
            tfSettings.add(tf.Account_PreUpdate__c);
            tfSettings.add(tf.Account_PostInsert__c);
            tfSettings.add(tf.Account_PostUpdate__c);
            tf.Account_SkipValidations__c = true;
            tf.Account_PreInsert__c = false;
            tf.Account_PreUpdate__c = false;
            tf.Account_PostInsert__c = false;
            tf.Account_PostUpdate__c = false;
        } else if (objectType=='Contact') {
            tfSettings.add(tf.Contact_SkipValidations__c);
            tfSettings.add(tf.Contact_PreInsert__c);
            tfSettings.add(tf.Contact_PreUpdate__c);
            tfSettings.add(tf.Contact_PostInsert__c);
            tfSettings.add(tf.Contact_PostUpdate__c);
            tf.Contact_SkipValidations__c = true;
            tf.Contact_PreInsert__c = false;
            tf.Contact_PreUpdate__c = false;
            tf.Contact_PostInsert__c = false;
            tf.Contact_PostUpdate__c = false;        
        }
        if (!Test.isRunningTest()) update tf;     
        
        query = 'SELECT Id, Number_of_Open_Cases__c FROM ' + objectType;
        query += ' WHERE Id IN (SELECT ' + objectType + 'Id FROM Case WHERE ' + objectType + 'Id != null AND LastModifiedDate = last_n_days:60)'; 
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (objectType != 'Account' && objectType != 'Contact') System.AbortJob(BC.getJobId());//failsafe in case someone passed in garbage to the contructor
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> Records) {
        
        if (objectType == 'Account') {
            Map < Id, Account > accountMap = new Map < Id, Account > ();
            List < Account > accounts = (List < Account >) Records;
            for (Account accObj : accounts) {
                if(!accountMap.containsKey(accObj.Id)) {
                    accountMap.put(accObj.Id, accObj);
                }
            }
            AggregateResult[] caseResults = [SELECT AccountId, Count(Id) FROM Case 
                                             WHERE AccountId IN :accountMap.keySet() 
                                             AND Status NOT IN ('Solved', 'Closed') GROUP BY AccountId];
            
            List < Account > updateAccountList = new List < Account > ();
            for (AggregateResult ar : caseResults)  {
                Id aId = (Id) ar.get('AccountId');
                if(accountMap.containsKey(aId)) {                    
                    Account accObj = accountMap.get(aId);
                    accObj.Number_of_Open_Cases__c = Integer.valueOf(ar.get('expr0'));
                    updateAccountList.add(accObj);
                }                
            }
            if(!updateAccountList.isEmpty()) update updateAccountList;
        } else if (objectType == 'Contact') {
            Map < Id, Contact > contactMap = new Map < Id, Contact > ();
            List < Contact > contacts = (List < Contact >) Records;
            for (Contact contactObj : contacts) {
                if(!contactMap.containsKey(contactObj.Id)) {
                    contactMap.put(contactObj.Id, contactObj);
                }
            }
            AggregateResult[] caseResults = [SELECT ContactId, Count(Id) FROM Case 
                                             WHERE ContactId IN :contactMap.keySet() 
                                             AND Status NOT IN ('Solved', 'Closed') GROUP BY ContactId];
            
            List < Contact > updateContactList = new List < Contact > ();
            for (AggregateResult ar : caseResults)  {
                Id cId = (Id) ar.get('ContactId');
                if(contactMap.containsKey(cId)) {                    
                    Contact contactObj = contactMap.get(cId);
                    contactObj.Number_of_Open_Cases__c = Integer.valueOf(ar.get('expr0'));
                    updateContactList.add(contactObj);
                }                
            }
            if(!updateContactList.isEmpty()) update updateContactList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        tf.Account_SkipValidations__c = tfSettings[0];
        tf.Account_PreInsert__c = tfSettings[1];
        tf.Account_PreUpdate__c = tfSettings[2];
        tf.Account_PostInsert__c = tfSettings[3];
        tf.Account_PostUpdate__c = tfSettings[4];
        if (!Test.isRunningTest()) update tf;     
    }
 
 }