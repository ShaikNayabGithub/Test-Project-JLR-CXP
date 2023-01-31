public class Territory_REST_Update implements Queueable, Database.AllowsCallouts  {

	private Set<Id> accountIds;
	public static Boolean RunInTestContext = false;
	public Territory_REST_Update(Set<Id> accountIds){
		this.accountIds = accountIds;
	}
    
	public void execute(QueueableContext context) {
		UpdateAccountsFuture(accountIds);
	}

    public static void CheckForTerritoryChanges(List<Account> accounts, Map<Id, Account> oldAccountMap){
        Set<Id> accountIds = new Set<Id>();
        for(Account account : accounts){
            Account oldAccount = oldAccountMap.get(account.id);
            if(account.Country_ISO_Code__c != oldAccount.Country_ISO_Code__c
                || account.Country_ISO_Code__pc != oldAccount.Country_ISO_Code__pc
                || account.BillingCountry != oldAccount.BillingCountry){
                if(!accountIds.contains(account.id)){
                    accountIds.add(account.id);
                }
            }
        }
        
		if(accountIds.size() > 0 && (!Test.isRunningTest() || RunInTestContext ) && !system.isBatch() && !system.isFuture()){
			Territory_REST_Update.UpdateAccountsFuture(accountIDs);
		}       
    }
    @future(callout = true)
    public static void UpdateAccountsFuture(Set<Id> accountIds){
        RestUpdateData data = new RestUpdateData();
        for(Id id : accountIds){
            data.records.add(new RestUpdateRecord(id, 'Account'));
        }
        
        CallRestService(data);
    }
    /*
    private void UpdateAccounts(Set<Id> accountIds){
        RestUpdateData data = new RestUpdateData();
        for(Id id : accountIds){
            data.records.add(new RestUpdateRecord(id, 'Account'));
        }

        CallRestService(data);
    }
*/
    public static void CallRestService(RestUpdateData data){
        Http client = new Http();
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String restAPIURL = sfdcURL + '/services/data/v42.0/composite/sobjects?_HttpMethod=PATCH';      

        HttpRequest request = new HttpRequest();

        SF_SessionIdRetriever session = new SF_SessionIdRetriever();
        string sessionId = session.RetrieveSessionId();
        request.setHeader('Authorization', 'Bearer ' + sessionId);
        request.setHeader('Content-Type','application/json');
        request.setHeader('accept','application/json');
        request.setendpoint(restAPIURL);
        request.Setheader('Sforce-Auto-Assign','true');
        request.setmethod('POST'); 
        request.setbody(JSON.serialize(data));
        System.debug(request.getBody());
        HttpResponse response;
        response = client.send(request);
        String str = response.getbody();
    }

    public class RestUpdateData{
        public boolean allOrNone {get;set;}
        public List<RestUpdateRecord> records {get;set;}

        public RestUpdateData(){
            records = new List<RestUpdateRecord>();
            allOrNone = false;
        }
    }

    public class RestUpdateRecord{
        public RestUpdateRecordAttribute attributes {get;set;}
        public Id id{get;set;}

        public RestUpdateRecord(Id id, string type){
            this.id = id;
            attributes = new RestUpdateRecordAttribute(type);
        }
    }

    public class RestUpdateRecordAttribute{
        public string type {get;set;}

        public RestUpdateRecordAttribute(string type){
            this.type = type;
        }
    }
}