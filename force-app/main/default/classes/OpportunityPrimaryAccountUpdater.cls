public class OpportunityPrimaryAccountUpdater {
    public static Data_Enrichment_Priority_on_Opportunity__c customSettingRecord = Data_Enrichment_Priority_on_Opportunity__c.getOrgDefaults();
    public static List<String> individualPiiFields = new List<String>{'Salutation', 'FirstName', 'LastName', 'PersonMailingStreet', 'PersonMailingState', 'PersonMailingPostalCode', 'PersonMailingCountry', 'Phone', 'PersonMobilePhone', 'PersonEmail'};
    public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    
    public static void accountUpdater(List<Opportunity> triggerNewList, Map<Id,Opportunity> triggeroldMap){
        List<Id> accountIdList = new List<Id>();
        List<Account> nonPrimaryAccountList = new List<Account>();
        Map<Id,Account> PrimaryAccountMap = new Map<Id,Account>();         
        List<Account> updatedAccountList = new List<Account>();
        if(customSettingRecord == null){
            return;
        }
        if(customSettingRecord.Field_API_Name__c != null && customSettingRecord.Field_Value__c != null){
            for(Opportunity newOpportunity : triggerNewList){
                if(triggeroldMap != null && triggeroldMap.containsKey(newOpportunity.Id)){ //get the newOpportunity value of the field stored in customSettingRecord.Field_API_Name__c and see if the value equals customSettingRecord.Field_Value__c
                    if(newOpportunity.get(customSettingRecord.Field_API_Name__c) == customSettingRecord.Field_Value__c && newOpportunity.get(customSettingRecord.Field_API_Name__c) != triggeroldMap.get(newOpportunity.Id).get(customSettingRecord.Field_API_Name__c)){
                        accountIdList.add(newOpportunity.AccountId);   
                        if(newOpportunity.Primary_Account__c != null) accountIdList.add(newOpportunity.Primary_Account__c); 
                    }
                }
            }            
        }        
        if(accountIdList.size() > 0){
            String soqlQuery =ConstructSOQLString();
            soqlQuery += ' WHERE Id IN :accountIdList';
            for(Account account: Database.query(soqlQuery)){
                if(account.Is_Primary__c){
                    PrimaryAccountMap.put(account.Id, account);
                }else{
                    nonPrimaryAccountList.add(account); 
                }
            }
        }        
        for(Account nonPrimaryAccount : nonPrimaryAccountList){
            if(nonPrimaryAccount.Primary_Account__c != null && nonPrimaryAccount.RecordTypeId == individualRecordType && PrimaryAccountMap.containsKey(nonPrimaryAccount.Primary_Account__c)){
                for(String fieldName : individualPiiFields){
                    if(nonPrimaryAccount.get(fieldName) != null && nonPrimaryAccount.get(fieldName) != PrimaryAccountMap.get(nonPrimaryAccount.Primary_Account__c).get(fieldName)){
                        PrimaryAccountMap.get(nonPrimaryAccount.Primary_Account__c).put(fieldName, nonPrimaryAccount.get(fieldName));
                    }
                }                
                PrimaryAccountMap.get(nonPrimaryAccount.Primary_Account__c).put('Data_Enrichment_Priority_Level__c', customSettingRecord.Data_Enrichment_Priority_Level__c);                        
                PrimaryAccountMap.get(nonPrimaryAccount.Primary_Account__c).put('Data_Enrichment_Priority_Effective_To__c', system.today().addMonths(Integer.valueOf(customSettingRecord.Data_Enrichment_Priority_Effective_To__c)));
                updatedAccountList.add(PrimaryAccountMap.get(nonPrimaryAccount.Primary_Account__c));
                
            }            
        }
        if(updatedAccountList.size() > 0 ){
            update updatedAccountList;
        }
    }
    
    private static String ConstructSOQLString() {
        Set<String> uniqueFields = new Set<String>();
        String soqlFields = '';
        uniqueFields.addAll(individualPiiFields);
        for(String s : uniqueFields){
            soqlFields += ', ' + s;
        }
        if(soqlFields.length() > 0){
            return 'SELECT Id, RecordTypeId, IsPersonAccount, Is_Primary__c,Primary_Account__c, Data_Enrichment_Priority_Effective_To__c, Data_Enrichment_Priority_Level__c' + soqlFields + ' FROM Account ';
        }
        return null;
    }
    
}