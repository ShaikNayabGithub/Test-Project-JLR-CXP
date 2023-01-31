/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		TCS			21/03/2022			CXPD-1785: As a Retailer I need Account contact details (email) to be verified if the Customer has opened an email sent to their email address.
* 2.0       NTTData     01/08/2022          CXPD-2100: Changed email verification when email is delivered.
* 
*/
public class VerifyContactDataBatch implements Database.Batchable<sObject>, Schedulable {
    
    Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    Id individualGoldenRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new VerifyContactDataBatch(), 25);
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC) {
        Integer days = 1;
        try {
            days = Integer.valueOf(Label.Days_In_Past);
        } catch(Exception ex) { }
        String query = 'SELECT Id, et4ae5__Email__c, et4ae5__DateSent__c, et4ae5__Opened__c, et4ae5__DateOpened__c, LastModifiedById, LastModifiedDate FROM et4ae5__IndividualEmailResult__c WHERE LastModifiedDate = Last_N_Days:' + days + ' AND Delivered__c = true AND et4ae5__Email__c != null AND et4ae5__Email__c != \'\' Order By et4ae5__Email__c';
        return Database.getQueryLocator(query);
    }
    
    // the execute method of the batch class which executes the delete  operations
    public void execute(Database.BatchableContext BC, List < et4ae5__IndividualEmailResult__c > scope) {
        Map < String, et4ae5__IndividualEmailResult__c > individualEmailResultMap = new Map < String, et4ae5__IndividualEmailResult__c > ();
        for(et4ae5__IndividualEmailResult__c record : scope) {
            if(individualEmailResultMap.containsKey(record.et4ae5__Email__c)) {
                et4ae5__IndividualEmailResult__c exisingRecord = individualEmailResultMap.get(record.et4ae5__Email__c);
                if(record.et4ae5__DateSent__c > exisingRecord.et4ae5__DateSent__c) {
                    individualEmailResultMap.put(record.et4ae5__Email__c, record);
                }
            } else {
                individualEmailResultMap.put(record.et4ae5__Email__c, record);
            }
        }
        System.debug('### Inside Execute Method ###');
        
        // Account Record Type Ids
        Set < Id > accountRecordTypeIds = new Set < Id > ();
        accountRecordTypeIds.add(individualRecordTypeId);
        accountRecordTypeIds.add(individualGoldenRecordTypeId);
        
        // Store all ORed filter records into Set 
        Set < Account > accountSet = new Set < Account > ();
        
        List < Account > accountList1 = [SELECT Id, PersonEmail, PersonEmail_Verified_Date__c, PersonEmail_Verified_By__c, 
                                        Email2__pc, Email2_Verified_Date__c, Email2_Verified_By__c, 
                                        Email3__pc, Email3_Verified_Date__c, Email3_Verified_By__c 
                                        FROM Account 
                                        WHERE RecordTypeId IN :accountRecordTypeIds 
                                        AND   PersonEmail IN :individualEmailResultMap.keySet() ];
        
        if(accountList1 != null && !accountList1.isEmpty()) {
            accountSet.addAll(accountList1);
        }
        
        List < Account > accountList2 = [SELECT Id, PersonEmail, PersonEmail_Verified_Date__c, PersonEmail_Verified_By__c, 
                                        Email2__pc, Email2_Verified_Date__c, Email2_Verified_By__c, 
                                        Email3__pc, Email3_Verified_Date__c, Email3_Verified_By__c 
                                        FROM Account 
                                        WHERE RecordTypeId IN :accountRecordTypeIds 
                                        AND Email2__pc IN :individualEmailResultMap.keySet() ];
                                            
        
        if(accountList2 != null && !accountList2.isEmpty()) {
            accountSet.addAll(accountList2);
        }
        
        List < Account > accountList3 = [SELECT Id, PersonEmail, PersonEmail_Verified_Date__c, PersonEmail_Verified_By__c, 
                                        Email2__pc, Email2_Verified_Date__c, Email2_Verified_By__c, 
                                        Email3__pc, Email3_Verified_Date__c, Email3_Verified_By__c 
                                        FROM Account 
                                        WHERE RecordTypeId IN :accountRecordTypeIds 
                                        AND Email3__pc IN :individualEmailResultMap.keySet()];
        
        if(accountList3 != null && !accountList3.isEmpty()) {
            accountSet.addAll(accountList3);
        }
        
        // Copy all set records into list
        List < Account > accountList = new List < Account > ();
        
        for(Account accountObj: accountSet) {
            Boolean isUpdate = false;
            if(individualEmailResultMap.containsKey(accountObj.PersonEmail)) {
                et4ae5__IndividualEmailResult__c individualEmailResult = individualEmailResultMap.get(accountObj.PersonEmail);
                if(accountObj.PersonEmail_Verified_Date__c == null || individualEmailResult.et4ae5__DateSent__c > accountObj.PersonEmail_Verified_Date__c) {
                    accountObj.PersonEmail_Verified_Date__c = Date.valueOf(individualEmailResult.et4ae5__DateSent__c);
                    accountObj.PersonEmail_Verified_By__c = individualEmailResult.LastModifiedById;
                    isUpdate = true;
                }
            }
            if(individualEmailResultMap.containsKey(accountObj.Email2__pc)) {
                et4ae5__IndividualEmailResult__c individualEmailResult = individualEmailResultMap.get(accountObj.Email2__pc);
                if(accountObj.Email2_Verified_Date__c == null || individualEmailResult.et4ae5__DateSent__c > accountObj.Email2_Verified_Date__c) {
                    accountObj.Email2_Verified_Date__c = Date.valueOf(individualEmailResult.et4ae5__DateSent__c);
                    accountObj.Email2_Verified_By__c = individualEmailResult.LastModifiedById;
                    isUpdate = true;
                }
            }
            if(individualEmailResultMap.containsKey(accountObj.Email3__pc)) {
                et4ae5__IndividualEmailResult__c individualEmailResult = individualEmailResultMap.get(accountObj.Email3__pc);
                if(accountObj.Email3_Verified_Date__c == null  || individualEmailResult.et4ae5__DateSent__c > accountObj.Email3_Verified_Date__c) {
                    accountObj.Email3_Verified_Date__c = Date.valueOf(individualEmailResult.et4ae5__DateSent__c);
                    accountObj.Email3_Verified_By__c = individualEmailResult.LastModifiedById;
                    isUpdate = true;
                }
            }
            
            if(isUpdate) {
                accountList.add(accountObj);
            }
        }
        
        // Update Account Records
        if(!accountList.isEmpty()) {
            AccountHandler.doNotRun = true;
            Database.update(accountList, false);
        }
    }
    
    public void finish(Database.BatchableContext BC){}
}