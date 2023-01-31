public class AccountUtility {
    public static List<Contact> GetPersonContactCountrys(List<Account> accounts)
    {
        Set<Id> contactIds = new Set<Id>();
        for(Account account : accounts){
            if(account.IsPersonAccount){
                contactIds.add(account.PersonContactId);
            }
        }
        
        return [Select MailingCountry, aop_Country__c, Account_Pseudo_Owner_Id__c, Country_ISO_Code__c, OwnerId From Contact Where Id In:contactIds];
    }
}