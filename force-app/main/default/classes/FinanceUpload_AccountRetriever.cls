public class FinanceUpload_AccountRetriever { 
    public List<Account> Retrieve(Set<String> lastNames,Set<String> emails, Set<String> phoneNumbers,set<String> legalEntityId)
    {
        if(lastNames.size() == 0 && emails.Size() == 0 && phoneNumbers.Size() == 0 && legalEntityId.size()==0) return new List<Account>();
        
        if(legalEntityId.size()>0)
            return [SELECT LegalEntityID__c,corporate__c,PersonEmail, Email2__pc, Email3__pc,Retailer_Email__c , PersonHomePhone, PersonMobilePhone,
                    PersonOtherPhone, Phone,PersonAssistantPhone,owner.accountid  FROM Account 
                    WHERE (LegalEntityID__c IN: legalEntityId) 
                    AND RecordTypeId!=: SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id
                    AND RecordTypeId!=: SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id
                    AND RecordTypeId !=: SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id];
            else{
             
            return [SELECT recordtypeid,LegalEntityID__c,corporate__c,PersonEmail, Email2__pc, Email3__pc,Retailer_Email__c , PersonHomePhone, PersonMobilePhone,
                    PersonOtherPhone, Phone,PersonAssistantPhone,owner.accountid  FROM Account 
                    WHERE (lastname in:lastNames OR Retailer_Email__c IN: emails OR PersonEmail IN: emails OR Email2__pc IN: emails OR Email3__pc IN: emails
                    OR PersonAssistantPhone IN: phoneNumbers OR PersonHomePhone IN: phoneNumbers OR PersonMobilePhone IN: phoneNumbers 
                    OR PersonOtherPhone IN: phoneNumbers OR Phone IN: phoneNumbers )
                    AND RecordTypeId!=: SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id
                    AND RecordTypeId!=: SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id
                    AND RecordTypeId !=: SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id];
                 }   
    }
    
    public list<Account> findDuplicates(List<Account> listAccounts){
  
    System.debug('account is in the before accountretriever: ' +listaccounts);
     
     account a;
     Map<ID,account>duplicatesRemoved=new Map<ID,account>(listAccounts);
     Set<id> removedIds=new Set<Id>();
     
        for(integer i=0;i<listAccounts.size();i++){

            a=listAccounts[i];
            
            for(account a2:listAccounts){
            
                if(duplicatedValue(a2,a)==true)
                    if(a2.id!=a.id)
                        duplicatesRemoved.remove(a.id);              
            }
        }
   
        System.debug('after removing duplicates: '+ duplicatesRemoved.values());  
     return duplicatesRemoved.values();   
    }
    
    public boolean duplicatedValue(account a, account a2){
    
     if(a2.Retailer_Email__c==a.Retailer_Email__c && !String.isblank(a2.retailer_email__c) ||
                !String.isBlank(a2.PersonAssistantPhone) && a2.PersonAssistantPhone==a.PersonAssistantPhone ||
                !String.isBlank(a2.personOtherPhone) && a2.PersonOtherPhone ==a.PersonOtherPhone ||
                !String.isBlank(a2.Retailer_Email__c) && a2.Retailer_Email__c ==a.Retailer_Email__c ||
                !String.isBlank(a2.PersonEmail) && a2.PersonEmail==a.PersonEmail ||
                !String.isBlank(a2.Email2__pc) && a2.Email2__pc ==a.Email2__pc ||
                !String.isBlank(a2.Email3__pc) && a2.Email3__pc==a.Email3__pc ||
                !String.isBlank(a2.PersonHomePhone) && a2.PersonHomePhone==a.phone ||
                !String.isBlank(a2.Retailer_Email__c) && a2.Retailer_Email__c==a.PersonEmail

                )
                
                return true;
                else return false;    
    }

    public void RemoveContactDetailsFromSets(Set<String> emails, Set<String> phoneNumbers, List<Account> accounts)
    {
        for(Account account : accounts) {
            if(String.IsNotEmpty(account.PersonEmail)) {
                emails.Remove(account.PersonEmail);
            }
            if(String.IsNotEmpty(account.Email2__pc)) {
                emails.Remove(account.Email2__pc);
            }
            if(String.IsNotEmpty(account.Email3__pc)) {
                emails.Remove(account.Email3__pc);
            }
            if(String.IsNotEmpty(account.PersonHomePhone)) {
                phoneNumbers.Remove(account.PersonHomePhone);
            }
            if(String.IsNotEmpty(account.PersonMobilePhone)) {
                phoneNumbers.Remove(account.PersonMobilePhone);
            }
            if(String.IsNotEmpty(account.PersonOtherPhone)) {
                phoneNumbers.Remove(account.PersonOtherPhone);
            }
            if(String.IsNotEmpty(account.Phone)) {
                phoneNumbers.Remove(account.Phone);
            }
             if(String.IsNotEmpty(account.PersonAssistantPhone )) {
                phoneNumbers.Remove(account.PersonAssistantPhone );
            }
            
            if(String.IsNotEmpty(account.Retailer_Email__c )) {
                emails.Remove(account.Retailer_Email__c );
            }
        }
    }
}