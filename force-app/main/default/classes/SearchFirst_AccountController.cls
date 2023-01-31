public without sharing class SearchFirst_AccountController extends SearchFirst_Controller_A {
    public List<Account> knownAccounts { get; private set; }
    public List<Account> unknownAccounts { get; private set; }
    
    public SearchFirst_AccountController()
    {
        knownAccounts = new List<Account>();
        unknownAccounts = new List<Account>();
    }

    public override void Search()
    {
    	moreRecords = false;
        String whereClause = '';
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Name','NameLocal'}, 'CompanyName', pageController.searchParameters.CompanyName);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Phone'}, 'Phone', pageController.searchParameters.Phone);
        if(String.isEmpty(whereClause)){ return; }
        
        String CompanyName = pageController.searchParameters.CompanyName;
        String Phone = pageController.searchParameters.Phone;
        
        if(String.isEmpty(whereClause)) { return; }
        String query = String.Format('Select Name, Phone, BillingCity, Site__c, ntt_Jaguar_Status__c, ntt_Land_Rover_Status__c, IsPersonAccount From Account Where {0}', new List<string> {whereClause});
        query += ' LIMIT ' + (this.MAXRESULTS + 1);
        
        List<sObject> foundAccounts = Database.query(query);
        
        Set<Id> accountsWithReadAccess = this.GetRecordsWithReadAccess(foundAccounts);
        
        if(!moreRecords){
	        for(sObject foundRecord: foundAccounts){
    	        Account foundAccount = (Account)foundRecord;
        	    if(!foundAccount.IsPersonAccount){
            	    if(accountsWithReadAccess.contains(foundAccount.Id)){
	            		knownAccounts.add(foundAccount);
                	} else {
  	               		unknownAccounts.add(foundAccount);
            	    }
                }
            }
        }
    }

    public override void Reset()
    {
        knownAccounts.clear();
        unknownAccounts.clear();
        moreRecords = false;
    }

    public override PageReference CreateRecord()
    {
        PageReference pageRef = new PageReference('/001/e?retURL=%2F001%2Fo' + (pageController.searchParameters.CompanyName != null?'&acc2='+ pageController.searchParameters.CompanyName : '') + 
            (pageController.searchParameters.Phone != null?'&acc10='+ pageController.searchParameters.Phone : '') + ((String.isNotEmpty(pageController.searchParameters.RecordTypeId) && pageController.searchParameters.RecordTypeObject == Account.sObjectType.getDescribe().getName())? '&RecordType='+pageController.searchParameters.RecordTypeId : ''));
        pageRef.getParameters().put('nooverride','1');
        return pageRef;
    }
}