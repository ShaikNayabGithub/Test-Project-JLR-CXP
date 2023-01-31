public class AccountByRequestRecordRetriever {
    private final ContactMatcher contactMatcher;

    public AccountByRequestRecordRetriever(ContactMatcher contactMatcher)
    {
        this.contactMatcher = contactMatcher;
    }

    public Account Retrieve(Request__c requestRecord)
    {      
        Account account = new Account(); 
        account.Id = contactMatcher.GetMatchingContact(requestRecord.Last_Name__c, requestRecord.Email__c, requestRecord.Mobile__c).AccountId;

        return account;
    }
}