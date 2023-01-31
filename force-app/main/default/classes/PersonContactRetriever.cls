public class PersonContactRetriever {
    public Map<Id, Account> Retrieve(List<Account> accounts)
    { 
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);       
        List<Account> personContactIds = [Select PersonContactId From Account Where Id In:accountMap.keySet()];
        Map<Id, Account> personContactMap = new Map<Id, Account>(personContactIds); 
        
        return personContactMap;
    }
}