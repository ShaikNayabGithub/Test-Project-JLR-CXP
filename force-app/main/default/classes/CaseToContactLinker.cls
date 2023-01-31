public class CaseToContactLinker implements Queueable {//1.2
    private final ContactFromCaseCreator contactFromCaseCreator;
    private Set<Id> queueableCases;

    public void execute(QueueableContext context) {
        //LinkCasesToContacts(queueableCases,false);
        //CaseTriggerHandler.IgnoreCaseLinker = true;
        //update queueableCases;
        LinkCasesToContactsFuture(queueableCases);
    }

    public CaseToContactLinker(ContactFromCaseCreator contactFromCaseCreator, Set<Id> cases){       
        this.contactFromCaseCreator = contactFromCaseCreator;
        queueableCases = cases;
    }

    public CaseToContactLinker(ContactFromCaseCreator contactFromCaseCreator){
        this.contactFromCaseCreator = contactFromCaseCreator;
    }   

    public void LinkCasesToContactsByTrigger(List<Case> cases,Boolean processEmail, Boolean processFuture){
        
        CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
        CaseToContactLinker linker = caseToContactLinkerFactory.Create();
        
        List<Case> caseWithEmail = new List<Case>();   
        Set<Id> caseFutureUpdate = new Set<Id>();   
        
        Set<Id> caseOwnerIds = SObjectUtilities.GetFieldValuesId(cases,'ownerid');
        Map<Id,User> ownerUsers = new Map<Id,User>([Select Id, UserType  
                                    FROM User
                                    Where id in: caseOwnerIds]);                                     

        for(Case c : cases){
            User owner = ownerUsers.get(c.OwnerId);
            if((c.SuppliedEmail != null || c.Case_Contact_Email__c != null)&& (c.Case_Contact_Phone__c == null || (owner != null && owner.UserType.containsIgnoreCase('Partner')))){
                caseWithEmail.add(c);
            }
            else{
                if(c.id != null){
                    caseFutureUpdate.add(c.id);
                }
            }
        }

        if(caseWithEmail.size() > 0 && processEmail ){
            LinkCasesToContacts(caseWithEmail, true);
        }

        //System.debug(caseFutureUpdate);
        if(caseFutureUpdate.size() > 0 && processFuture){
            AccountFromCaseBuilder accountFromCaseBuilder = new AccountFromCaseBuilder();
            PersonContactRetriever personContactRetriever = new PersonContactRetriever();
            ContactFromCaseCreator contactFromCaseCreator = new ContactFromCaseCreator(accountFromCaseBuilder, personContactRetriever);
            CaseToContactLinker queueLinker = new CaseToContactLinker(contactFromCaseCreator, caseFutureUpdate);
            System.enqueueJob(queueLinker);
        }
    }
    
    private static void LinkCasesToContactsFuture(Set<Id> caseIds){
        System.debug(caseIds);
        CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
        CaseToContactLinker linker = caseToContactLinkerFactory.Create();
        
        Map<Id,Case> cases = new Map<Id,Case>([SELECT Id, SuppliedEmail, Case_Contact_Email__c, Case_Contact_Phone__c, ContactID, ownerid,Country_ISO_Code__c,Owner_Region_Or_Market__c, AccountId,Owner_ISO_Code__c
                                         FROM Case
                                         WHERE accountid = null and id in :caseIds
                                            and (SuppliedEmail != null or 
                                                Case_Contact_Email__c != null or 
                                                Case_Contact_Phone__c != null)]);
        System.debug(cases);
        if(cases.size() > 0){                                                                                               
            linker.LinkCasesToContacts(cases.values(),false);
            CaseTriggerHandler.IgnoreCaseLinker = true;
            update cases.values();
        }
    }
    

    //Returns cases which were not processed
    private void LinkCasesToContacts(List<Case> cases, Boolean emailOnly)
    {
        String emailFieldName = Case.SuppliedEmail.getDescribe().getName();
        Set<String> emails = SObjectUtilities.GetFieldValues(cases, emailFieldName); 
        
        String contactEmailFieldName = Case.Case_Contact_Email__c.getDescribe().getName();
        emails.addAll(SObjectUtilities.GetFieldValues(cases, contactEmailFieldName)); 
        
        Set<String> exEmailList = new Set<String>();
        for(Primary_Account_Excluded_Emails__mdt dummyEmail : [Select Label FROM Primary_Account_Excluded_Emails__mdt]){
            exEmailList.add(dummyEmail.Label);
        }
   
        for(String removeEmail : exEmailList){
            if(emails.contains(removeEmail)){
                emails.remove(removeEmail);
            }
        }
        
        String phoneFieldName = Case.Case_Contact_Phone__c.getDescribe().getName();
        Set<String> phones = SObjectUtilities.GetFieldValues(cases, phoneFieldName); 
        
        List<Contact> existingContacts;
        if(emailOnly && emails.size() > 0){
            existingContacts = [Select Email, Phone, MobilePhone, account.Country_ISO_Code__c From Contact Where Email In:emails ];

        }
        else{
            existingContacts = [Select Email, Phone, MobilePhone,account.Country_ISO_Code__c From Contact Where Email In:emails OR Phone In:phones OR MobilePhone In:phones];
        }
        
        List<Case> unmatchedCases = new List<Case>();
        
        List<Case> unprocessedCases = new List<Case>();

        for(Case caseRecord : cases){
            if(String.isEmpty(caseRecord.Case_Contact_Email__c) && String.isNotEmpty(caseRecord.SuppliedEmail)) {
                caseRecord.Case_Contact_Email__c = caseRecord.SuppliedEmail;
            }
            if(caseRecord.ContactID == null)
            {
                if(caseRecord.Case_Contact_Email__c != null || caseRecord.Case_Contact_Phone__c != null)
                {
                    Boolean caseMatchedEmail = CaseExtensions.MatchCaseToContactByEmail(caseRecord, existingContacts);
                    if(!caseMatchedEmail)
                    {
                        if(emailOnly){
                            unmatchedCases.add(caseRecord);
                            continue;
                        }               

                        Boolean caseMatchedPhone = CaseExtensions.MatchCaseToContactByPhone(caseRecord, existingContacts);
                        if(!caseMatchedPhone)
                        {
                            Boolean caseMatchedMobile = CaseExtensions.MatchCaseToContactByMobile(caseRecord, existingContacts);
                            if(!caseMatchedMobile)
                            {
                                unmatchedCases.add(caseRecord);
                            }
                        }
                    }
                } 
            }
        }
        
        System.debug(unmatchedCases);

        if(!unmatchedCases.isEmpty())
        {
            this.contactFromCaseCreator.CreateFromCases(unmatchedCases);
        }
        
    }
}