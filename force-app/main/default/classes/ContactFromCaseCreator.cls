public class ContactFromCaseCreator {
    private final AccountFromCaseBuilder accountFromCaseBuilder;
    private final PersonContactRetriever personContactRetriever;
    
    
    public ContactFromCaseCreator(AccountFromCaseBuilder accountFromCaseBuilder, PersonContactRetriever personContactRetriever)
    {
        this.accountFromCaseBuilder = accountFromCaseBuilder;
        this.personContactRetriever = personContactRetriever;
    }
    
    
    public void CreateFromCases(List<Case> cases)
    {
        Map<Case, Account> accountMap = new Map<Case, Account>();
        for(Case caseRecord : cases){
            Account account = this.accountFromCaseBuilder.BuildPersonAccount(caseRecord);
            accountMap.put(caseRecord, account);
        }
        
        try{
            insert accountMap.Values();
        }
        catch(DMLException e){
            for(Case caseRecord : cases){
                String exceptionMessage = e.getMessage();
                String[] splitOnException = exceptionMessage.split('EXCEPTION,');
                if(splitOnException.size() > 1){
                    exceptionMessage = splitOnException[1];
                }
                caseRecord.addError(exceptionMessage);
            }
            return;
        }
        
        Map<Id, Account> personContactMap = this.personContactRetriever.Retrieve(accountMap.Values());
        for(Case caseRecord : cases){
            Account account = accountMap.get(caseRecord);
            caseRecord.ContactId = personContactMap.get(account.Id).PersonContactId;
        }
    }
}