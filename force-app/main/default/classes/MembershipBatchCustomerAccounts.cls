Global class MembershipBatchCustomerAccounts implements Schedulable, Database.Batchable<sObject>, database.Stateful {
 
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new MembershipBatchCustomerAccounts(), 200);
    }
Id customertRecId = Schema.SObjectType.Membership__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //STAGENAME
        list<string> stagename = new list<string>();
        stagename.add('\''+ string.valueof('Order Taken') +'\'');
        stagename.add('\''+ string.valueof('Handover & RDA') +'\'');
        //RECORDTYPE
        List<String> rectype = new List<String>();
        rectype.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId())+'\'');
        rectype.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId())+'\'');
        
        string Query;
        query = 'SELECT ';
        query += 'Id, RecordType.Name, Opportunities_on_Account__c,';
        query += '(SELECT Id,Account.Preferred_Sales_Retailer__r.Name,Account.Owner.Name,HandOver_Date__c,Account.persontitle,';
        query += 'Account.Gender__pc,Account.PersonMobilePhone,Account.PersonMailingPostalCode,Account.PersonMailingStreet,Account.PersonMailingCity,';
        query += 'Account.External_ID_SF__pc,Account.Phone,Account.Retailer_Email__c,Account.ShippingPostalCode,Account.ShippingStreet,Account.ShippingCity,Account.External_ID_SF__c,';
        query += 'Account.PersonEmail,Account.Occupation__pc,Contract_Reference__c,Date_of_Deposit_cancelled__c,';
        query += 'Account.Name,Account.Recordtype.Name FROM Opportunities WHERE StageName IN (' + String.join(stagename,',') + ') ORDER BY LastModifiedDate DESC LIMIT 1),';
        query += '(SELECT id,StartDate from Contracts ORDER BY LastModifiedDate DESC LIMIT 1)';
        query += ' FROM Account ';
        query += ' WHERE';
        query += ' Account.RecordTypeId IN (' + String.join(rectype,',') + ') ';
        query += ' AND ( (Country_ISO_Code__c  = \'KR\') OR (Country_ISO_Code__pc  = \'KR\'))';
        query += ' AND LastModifiedDate >= LAST_N_DAYS:1';
        query += ' AND Id IN (SELECT Accountid FROM Opportunity WHERE StageName IN (' + String.join(stagename,',') + ')) ';
        
        List<Membership__c> allRows = [select id from Membership__c where RecordType.Name= 'Customer'];
        if(allRows!=null){
        delete allRows;    
        }
        else{
            system.assertEquals(0,allRows.size(),'Membership object expected to be empty but was not.');
        }
        system.debug('@@@return' + database.getQueryLocator(query));
     return database.getQueryLocator(query);
        
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> AccountList) {
        system.debug('AccountList @@@'+AccountList);
        list<Opportunity> opplist = new list<opportunity>();
        map<Opportunity,contract> oppContract= new map<Opportunity,contract>();
        list<Contract> contractlist = new list<contract>();
       if(AccountList!=null &&  AccountList.size() > 0){
        for(Account acc: AccountList){
            system.debug('@@acc.opportunities' + acc.opportunities);
            system.debug('@@acc.Contracts' + acc.contracts);
            if(acc.opportunities.size() > 0)  //fetched the account's opportunities
            {
             system.debug('@@opplist entry1');
             opplist.add(acc.opportunities);
            system.debug('@@opplist entry2');
            if(acc.contracts.size() > 0){
              contractlist.add(acc.contracts);  
            
            oppContract.put(acc.opportunities,acc.contracts);
            }
            }
        }
    }

        map<opportunity,opportunitylineitem> opplineitem = new map<opportunity,opportunitylineitem>();
        List<gfkObjectModel> output = new List<gfkObjectModel>();
        set<id> oppids = new set<id>();
        contract con = new contract();
        for(opportunity opp: opplist){
         oppids.add(opp.id) ;  
        }
        map<id,opportunitylineitem> opplinemap = new map<id,opportunitylineitem>();
        list<opportunitylineitem> oppprod= [select id,opportunityId,Asset__r.VIN__c,Asset__r.Brand__r.Name,Asset__r.Model__r.Name,Asset__r.Warranty_Start_Date__c,Asset__r.KR_Platinum_Care_End_Date__c,Asset__r.Product2.Name from opportunitylineitem where opportunityid IN: oppids AND Asset__c !=null] ;
        for(opportunitylineitem oppline : oppprod){
        opplinemap.put(oppline.opportunityId, oppline) ;   
        }
        system.debug('@@opplinemap' + opplinemap);
       opportunitylineitem linerecord;
        for(opportunity opp: opplist){
         system.debug('@@opp entry');
            if(opplinemap.size() != null  && opplinemap.containsKey(opp.id)){
                 linerecord = opplinemap.get(opp.Id);
            }
            system.debug('@@@@linerecord' + linerecord);
              //for every opp we need to fetch 1 opp line item --only then we can map.if more than 1 how to map.
            if(oppContract != null && oppContract.containskey(opp)){
                system.debug('@@oppcontract entry');
             con = oppContract.get(opp); 
                system.debug('@@con' + con);
            }
           // gfkObjectModel temp = gfkProcessQuery(opp,opplineitem,con);
             gfkObjectModel temp = gfkProcessQuery(opp,linerecord,con);
            if(temp!=null){
                 output.add(temp);
            }
        }

      if(!output.isEmpty())
        { 
            Set<Id> processedRecIds = new Set<Id>();
            List<Membership__c> gfkSalesExData = new List<Membership__c>();
            for(gfkObjectModel line : output){
            gfkSalesExData.add(new Membership__c(
            Retailer_Name__c=  line.Retailer,
            Showroom_name__c = line.Showroom, 
            Sales_Consultant__c = line.SalesConsultant,
            SC_ID__c = line.SCuserid,
            Customer_Name__c= line.Customername,
            Customer_ID__c= line.CustomerID,
            Contract_Date__c= line.ContractDate,
            Delivery_Date__c  = line.DeliveryDate,
            VIN__c= line.VIN,
            Brand__c = line.Brand,
            Model_Name__c = line.ModelName,
            Individual_Corporate__c = line.IndividualORCorporate,
            Gender__c = line.Gender,
            Mobile_number__c = line.MobileNumber,
            Home_Post_No__c = line.HomePostNo,
            Home_address1__c = line.HomeAddress1,
            Home_address2__c = line.HomeAddress2,
            Company_Post_No__c = line.CompanypostNo,
            Company_address1__c = line.CompanyAddress1,
            Company_address2__c = line.CompanyAddress2,
            DM_Delivery__c = line.DMDelivery,
            Position__c = line.Position,
            Platinum_Care_Start_Date__c = line.PatinumCareStartDate,
            Platinum_Care_End_Date__c = line.PatinumCareEndDate, 
            Model_Derivative_Name__c = line.ModelDerivativeName,
            Company_Name__c = line.CompanyName,
            Occupation__c = line.Occupation,
            Contract_no__c = line.ContractNo,
            delivery_cancellation_date__c = line.deliveryCancellationDate,
            Unique_Identifier__c = line.UniuqeIdentifier,
            recordTypeId =customertRecId 
                ));
            }
            system.debug(' @@@'+gfkSalesExData);
            Insert gfkSalesExData;
            //Insert gfkSalesExData2;
            
        }
        
        
    }
    global void finish(Database.BatchableContext BC){
    }
    private gfkObjectModel gfkProcessQuery(Opportunity opp,opportunitylineitem linerecord,Contract con){
        gfkObjectModel gfkModel = new gfkObjectModel();
        string[] accountName = opp.Account.Preferred_Sales_Retailer__r.Name.split('-');
        if(accountName.size() > 0)
        gfkModel.Retailer= accountName[0];
        if(accountName.size() > 1)
        gfkModel.Showroom =  accountName[1];
        gfkModel.SalesConsultant = opp.Account.Owner.Name;
        gfkModel.SCuserid =  opp.Account.Owner.Id;
        gfkModel.Customername = opp.Account.Name;
        gfkModel.CustomerID =  opp.Account.Id;
        gfkModel.ContractDate = string.valueof(con.StartDate);
        gfkModel.DeliveryDate = string.valueof(opp.HandOver_Date__c);
        gfkModel.VIN = linerecord != null ? string.valueof(linerecord.Asset__r.VIN__c) : '';
        gfkModel.Brand = linerecord != null ? string.valueof(linerecord.Asset__r.Brand__r.Name) : '';
        gfkModel.ModelName = linerecord != null  ? string.valueof(linerecord.Asset__r.Model__r.Name) : '';
            
        gfkModel.IndividualORCorporate = opp.Account.Recordtype.Name;
        gfkModel.Gender = opp.Account.Gender__pc;
        if(opp.Account.Recordtype.Name == 'Individual'){
        gfkModel.MobileNumber = opp.Account.PersonMobilePhone; 
        gfkModel.HomePostNo = opp.Account.PersonMailingPostalCode;
        gfkModel.HomeAddress1 = opp.Account.PersonMailingStreet;
        gfkModel.HomeAddress2 = opp.Account.PersonMailingCity;
        gfkModel.DMDelivery = 'Home';
        gfkModel.Email = opp.Account.PersonEmail;
        }
        
        else if(opp.Account.Recordtype.Name == 'Corporate'){
            gfkModel.MobileNumber = opp.Account.Phone; 
            gfkModel.CompanypostNo = opp.Account.ShippingPostalCode;
            gfkModel.CompanyAddress1 = opp.Account.ShippingStreet;
            gfkModel.CompanyAddress2 = opp.Account.ShippingCity;
            gfkModel.DMDelivery = 'Company';
            gfkModel.Email = opp.Account.Retailer_Email__c;
            
        }
           
        gfkModel.Position = opp.Account.persontitle;
        gfkModel.ModelDerivativeName = linerecord != null ? string.valueof(linerecord.Asset__r.Product2.Name) : '';
        gfkModel.PatinumCareStartDate = linerecord != null ? string.valueof(linerecord.Asset__r.Warranty_Start_Date__c) : '';
        gfkModel.PatinumCareEndDate = linerecord != null ? string.valueof(linerecord.Asset__r.KR_Platinum_Care_End_Date__c): '';    
        gfkModel.CompanyName = opp.Account.Name;
        gfkModel.Occupation = opp.Account.Occupation__pc;
        gfkModel.ContractNo = opp.Contract_Reference__c;
        gfkModel.deliveryCancellationDate = string.valueof(opp.Date_of_Deposit_cancelled__c); 
        gfkModel.UniuqeIdentifier = opp.Account.External_ID_SF__c;    
        return gfkModel;  
        
        
    }
    
    
    
    
    public class gfkObjectModel {
    public String Retailer {get;set;}
    public String Showroom {get;set;}    
    public String SalesConsultant {get;set;}
    public String SCuserid {get;set;}
    public String Customername {get;set;}
    public String CustomerID {get;set;}    
    public String ContractDate {get;set;} 
    public String DeliveryDate {get;set;}   
    public String VIN {get;set;}    
    public String Brand {get;set;}
    public String ModelName {get;set;}
    public String IndividualORCorporate {get;set;}
    public String Gender {get;set;}
    public String MobileNumber {get;set;}
    public String Email {get;set;}
    public String HomePostNo {get;set;}
    public String HomeAddress1 {get;set;}
    public String HomeAddress2 {get;set;}
    public String CompanypostNo {get;set;}
    public String CompanyAddress1 {get;set;}
    public String CompanyAddress2 {get;set;}
    public String DMDelivery {get;set;}
    public String Position {get;set;}
    public String PatinumCareStartDate {get;set;}
    public String PatinumCareEndDate {get;set;}
    public String ModelDerivativeName {get;set;}    
    public String CompanyName {get;set;}
    public String Occupation {get;set;}
    public String ContractNo {get;set;}
    public String deliveryCancellationDate {get;set;}
    public String UniuqeIdentifier {get;set;}        
    }

}