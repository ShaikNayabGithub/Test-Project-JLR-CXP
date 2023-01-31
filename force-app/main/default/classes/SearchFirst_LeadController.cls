public without sharing class SearchFirst_LeadController extends SearchFirst_Controller_A {
    public List<Lead> knownLeads { get; private set; }
    public List<Lead> unknownLeads { get; private set; }
    
    public SearchFirst_LeadController()
    {
        knownLeads = new List<Lead>();
        unknownLeads = new List<Lead>();
    }
    

    public override void Search()
    {
        moreRecords = false;
        String whereClause = '';
        whereClause = this.AddTowhereClause(whereClause, new String[] {'FirstName','FirstNameLocal'}, 'FirstName', pageController.searchParameters.FirstName);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'LastName','LastNameLocal'}, 'LastName', pageController.searchParameters.LastName);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Company','CompanyLocal'}, 'CompanyName', pageController.searchParameters.CompanyName);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Phone', 'MobilePhone'}, 'Phone', pageController.searchParameters.Phone);
        whereClause = this.AddTowhereClause(whereClause, new String[] {'Email'}, 'Email', pageController.searchParameters.Email);
        if(String.isEmpty(whereClause)){ return; }
        
        String FirstName = pageController.searchParameters.FirstName;
        String LastName = pageController.searchParameters.LastName;
        String CompanyName = pageController.searchParameters.CompanyName;
        String Phone = pageController.searchParameters.Phone;
        String Email = pageController.searchParameters.Email;
        String query = String.Format('Select Name, FirstName, LastName, Company, Phone, MobilePhone, Email, City, Site__c, Primary_Model_Interest__c, Status, OwnerId, Owner.Name From Lead Where IsConverted!=true And {0}', new List<string> {whereClause});
        
        
        
        
        
        
               
        
        query += ' LIMIT ' + (this.MAXRESULTS + 1);
        
        List<sObject> foundLeads = Database.query(query);
        
        Set<Id> leadsWithReadAccess = this.GetRecordsWithReadAccess(foundLeads);
        
        Map<Id,User> usersInRetailer = new Map<Id,User>();
        if(foundLeads.size() > 0){                       
            List<User> retailerUser = [select contact.accountid from user where id =:UserInfo.getUserId() and contact.accountid != null];
            
            if(retailerUser.size() == 1){
                usersInRetailer = new Map<Id,User>([select id from user where contact.accountid =: retailerUser[0].contact.accountid  ]);
            }
        }
        
        
        if(!moreRecords){
            for(sObject foundObject : foundLeads){
                Lead foundLead = (Lead)foundObject;
                if(leadsWithReadAccess.contains(foundLead.Id)){
                    knownLeads.add(foundLead);
                } else {                
                    ID ownerId = (ID)foundObject.get('ownerid');
                    if(usersInRetailer.containsKey(ownerId)){
                        unknownLeads.add(foundLead);
                    }
                }
            }
        }
    }

    public override void Reset()
    {
        knownLeads.clear();
        unknownLeads.clear();
        moreRecords = false;
    }

    public override PageReference CreateRecord()
    {
        PageReference pageRef = new PageReference('/00Q/e?retURL=%2F00Q%2Fo' + (pageController.searchParameters.CompanyName != null?'&lea3='+ pageController.searchParameters.CompanyName : '') + 
            (pageController.searchParameters.Firstname != null?'&name_firstlea2='+ pageController.searchParameters.Firstname : '') + 
            (pageController.searchParameters.Lastname != null?'&name_lastlea2='+ pageController.searchParameters.Lastname : '') + 
            (pageController.searchParameters.Phone != null?'&lea8='+ pageController.searchParameters.Phone : '') + 
            (pageController.searchParameters.Email != null?'&lea11='+ pageController.searchParameters.Email : '') + ((String.isNotEmpty(pageController.searchParameters.RecordTypeId) && pageController.searchParameters.RecordTypeObject == Lead.sObjectType.getDescribe().getName())? '&RecordType='+pageController.searchParameters.RecordTypeId : ''));
        pageRef.getParameters().put('nooverride','1');
        return pageRef;
    }
}