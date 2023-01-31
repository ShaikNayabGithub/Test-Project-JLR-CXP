Global class MembershipBatchSalesConsultantJob implements Schedulable, Database.Batchable<sObject>, database.Stateful{

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new MembershipBatchSalesConsultantJob(), 200);
    } 
    Id salesconsultantRecId = Schema.SObjectType.Membership__c.getRecordTypeInfosByName().get('Sales Consultants').getRecordTypeId();
    //Membership_Export_Setting__mdt numberOfDays = Membership_Export_Setting__mdt.getInstance('Memebership_Batch');
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
      String query;
        query = 'SELECT ';
        query += 'Id,LastName,userName,Contact.Account.Name,Alias,Contact.Account.Parent.DMS_Identifier__c,Contact.Account.DMS_Identifier__c,Contact.Account.Parent.NameLocal,Contact.Account.NameLocal, Contact.Account.Local_Market_ID__c,Name,Title, Department, MobilePhone, email, Profile.Name';
        query += ' FROM User';
        query += ' WHERE';
        query += ' Market__c = \'Korea\'';
        query += ' AND ContactId != null';
        query += ' AND isActive = True';
        query += ' AND Profile.Name LIKE \'Sales%\'';
        query += ' AND ((CreatedDate = LAST_N_DAYS:1) OR (LastModifiedDate = LAST_N_DAYS:1 ))'; //created or (created or last modified) 
        

       List<Membership__c> allRows = [select id from Membership__c where RecordType.Name= 'Sales Consultants'];
        if(allRows!=null){
        delete allRows;    
        }
        else{
            system.assertEquals(0,allRows.size(),'Membership object expected to be empty but was not.');
        }
   system.debug('@@@return' + database.getQueryLocator(query));
     return database.getQueryLocator(query);   
    }
    global void execute(Database.BatchableContext BC, List<User> UserList) {
     system.debug('UserList @@@'+UserList); 
        
        List<gfkObjectModel> output = new List<gfkObjectModel>();
        if(UserList!=null &&  UserList.size() > 0){
        for(User usr: UserList){
        gfkObjectModel temp = gfkProcessQuery(usr);
            if(temp!=null){
                 output.add(temp);
            }
            
        }
        }
        if(!output.isEmpty())
        { 
            Set<Id> processedRecIds = new Set<Id>();
            List<Membership__c> gfkSalesExData = new List<Membership__c>();
            for(gfkObjectModel line : output){
            gfkSalesExData.add(new Membership__c(
            SC_ID__c = line.SCID,
            Retailer_Name__c=  line.RetailerName,
            Retailer_ID__c = line.RetailerID,
            Showroom_name__c = line.ShowroomName,
           // Unique_Identifier__c = line.UniuqeIdentifier, //showroomid
            Department__c = line.Department,
            User_Name__c = line.UserName,
            User_ID__c= line.UserID,
            User_Phone__c= line.UserPhoneNumber,
            Email__c= line.Email,
            Role__c= line.Role,
            Showroom_Sequence__c = line.ShowroomSequence,
           // Dealer_Group__c = line.DealerGroup,
            recordTypeId =salesconsultantRecId 
                ));
            }
            system.debug(' @@@'+gfkSalesExData);
            Insert gfkSalesExData;
            //Insert gfkSalesExData2;
            
        }
        
    }
    global void finish(Database.BatchableContext BC){
    }
    
    private gfkObjectModel gfkProcessQuery(User usr){
        gfkObjectModel gfkModel = new gfkObjectModel();
        
        //if(acc.RecordType.Name =='Retailer' && accountRetailer.contains(acc.Id)){
         gfkModel.SCID = usr.ID; 
        if(usr != null && usr.Contact !=null && usr.Contact.Account !=null){
         gfkModel.RetailerName =  usr.Contact.Account.Parent.NameLocal;

         gfkModel.ShowroomName =  usr.Contact.Account.NameLocal;  

         gfkModel.RetailerID = usr.Contact.Account.Parent.DMS_Identifier__c;

         gfkModel.ShowroomSequence = usr.Contact.Account.DMS_Identifier__c ; //showroom id mapping was mapped to this field earlier.//change the label ,let teh api name be same.
        // gfkModel.DealerGroup = usr.Contact.Account.Parent.NameLocal; //shall we keep this field? as same mapping as retailername. //delete the field
        }
         gfkModel.Department= usr.Department;
         gfkModel.UserName = usr.LastName;
         gfkModel.UserID = usr.userName;
         gfkModel.UserPhoneNumber =usr.MobilePhone ;
         gfkModel.Email = usr.Email ;
        string role = usr.Profile.Name;
        string target = ' MENA';
        String replacement = '';
        string roleupdate  = role.replace(target, replacement) ;
         gfkModel.Role = usr.Title !=null ? usr.Title : roleupdate;
         
         

        return gfkModel;
    }
    
    public class gfkObjectModel {
    public String SCID {get;set;}
    public String RetailerName {get;set;}    
    public String RetailerID {get;set;}
    public String ShowroomName {get;set;}
    public String ShowroomID {get;set;}
    public String Department {get;set;}
    public String UserName {get;set;}    
    public String UserID {get;set;}    
    public String UserPhoneNumber {get;set;}    
    public String Email {get;set;}
    public String Role {get;set;}
    public String UniuqeIdentifier {get;set;} 
    public String ShowroomSequence {get;set;}
    public String DealerGroup {get;set;}
    }
    


}