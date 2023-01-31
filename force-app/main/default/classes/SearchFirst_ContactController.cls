public without sharing class SearchFirst_ContactController extends SearchFirst_Controller_A {
    public List<Contact> knownContacts { get; private set; }
    public List<Contact> unknownContacts { get; private set; }
    
    public SearchFirst_ContactController()
    {
        this.knownContacts = new List<Contact>();
        this.unknownContacts = new List<Contact>();
    }
    

    public override void Search()
    {
    	moreRecords = false;
        String whereClause = '';
        whereClause = this.AddTowhereClause(whereClause, new String[] {'FirstName','FirstNameLocal'}, 'FirstName', pageController.searchParameters.FirstName);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'LastName','LastNameLocal'}, 'LastName', pageController.searchParameters.LastName);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Account.Name','Account.NameLocal'}, 'CompanyName', pageController.searchParameters.CompanyName);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Phone', 'MobilePhone'}, 'Phone', pageController.searchParameters.Phone);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Email'}, 'Email', pageController.searchParameters.Email);
        if(String.isEmpty(whereClause)){ return; }
        
        String FirstName = pageController.searchParameters.FirstName;
        String LastName = pageController.searchParameters.LastName;
        String CompanyName = pageController.searchParameters.CompanyName;
        String Phone = pageController.searchParameters.Phone;
        String Email = pageController.searchParameters.Email;
        String query = String.Format('Select Name, FirstName, LastName, Phone, MobilePhone, Email, MailingCity, Site__c, Account.Site__c, AccountId, IsPersonAccount From Contact Where {0}', new List<string> {whereClause});
        query += ' LIMIT ' + (this.MAXRESULTS + 1);
        
        List<sObject> foundContacts = Database.query(query);
            
        Set<Id> contactsWithReadAccess = this.GetRecordsWithReadAccess(foundContacts);
        
        if(!moreRecords){
	        for(sObject foundObject : foundContacts){
    	        Contact foundContact = (Contact)foundObject;
        	    if(foundContact.Account != null && String.isEmpty(foundContact.Site__c) && String.isNotEmpty(foundContact.Account.Site__c)){
            	    foundContact.Site__c = foundContact.Account.Site__c;//temp merge to display either
            	}
	            if(contactsWithReadAccess.contains(foundContact.Id)){
	        		knownContacts.add(foundContact);
            	} else {
	                if(foundContact.IsPersonAccount){
                    	unknownContacts.add(foundContact);
                	}
	            }
            }
        }
    }

    public override void Reset()
    {
        knownContacts.clear();
        unknownContacts.clear();
        moreRecords = false;
    }

    public override PageReference CreateRecord()
    {
        PageReference pageRef = new PageReference('/003/e?retURL=%2F003%2Fo' + (pageController.searchParameters.Firstname != null?'&name_firstcon2='+ pageController.searchParameters.Firstname : '') + 
            (pageController.searchParameters.Lastname != null?'&name_lastcon2='+ pageController.searchParameters.Lastname : '') + 
            (pageController.searchParameters.Phone != null?'&con10='+ pageController.searchParameters.Phone : '') + 
            (pageController.searchParameters.Email != null?'&con15='+ pageController.searchParameters.Email : '') + ((String.isNotEmpty(pageController.searchParameters.RecordTypeId) && pageController.searchParameters.RecordTypeObject == Contact.sObjectType.getDescribe().getName())? '&RecordType='+pageController.searchParameters.RecordTypeId : ''));
        pageRef.getParameters().put('nooverride','1');
        return pageRef;
    }
}