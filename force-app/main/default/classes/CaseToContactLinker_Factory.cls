public class CaseToContactLinker_Factory {//1.2
    public CaseToContactLinker Create()
    {
    	AccountFromCaseBuilder accountFromCaseBuilder = new AccountFromCaseBuilder();
    	PersonContactRetriever personContactRetriever = new PersonContactRetriever();
		ContactFromCaseCreator contactFromCaseCreator = new ContactFromCaseCreator(accountFromCaseBuilder, personContactRetriever);
		
		return new CaseToContactLinker(contactFromCaseCreator);
    }
}