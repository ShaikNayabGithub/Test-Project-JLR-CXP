Global class MembershipBatchCustomerOpportunity implements Schedulable, Database.Batchable<sObject>, database.Stateful{
global void execute(SchedulableContext SC) {
        Database.executeBatch(new MembershipBatchCustomerOpportunity(), 200);
    }
Id customertRecId = Schema.SObjectType.Membership__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext BC) {
    //STAGENAME
      list<string> stagename = new list<string>();
      stagename.add('\''+ string.valueof('Order Taken') +'\'');
      stagename.add('\''+ string.valueof('Handover & RDA') +'\'');    
       
    string Query;
    query = 'SELECT ';
    query += 'Id,Account.LastName,Account.FirstName,Account.Preferred_Sales_Retailer__r.NameLocal,Primary_Contact__r.Id,Account.Preferred_Sales_Retailer__r.Parent.NameLocal,Account.Owner.LastName,HandOver_Date__c,Account.persontitle,';
    query += 'Account.Gender__pc,Account.PersonMobilePhone,Account.BillingPostalCode,Account.BillingState,Account.BillingCity,Account.BillingStreet,';
    query += 'Account.External_ID_SF__pc,Account.Phone,Account.ShippingPostalCode,Account.ShippingState,Account.ShippingStreet,Account.ShippingCity,Account.External_ID_SF__c,';
    query += 'Account.PersonEmail,Account.Occupation__pc,Contract_Reference__r.Name,Date_of_Deposit_cancelled__c,Account.Retailer_Email__c,';
    query += 'Account.Name,Account.Recordtype.Name, ';
    query += 'primary_contact__r.Email';
    query += ' FROM Opportunity';
    query += ' WHERE Handover_Date__c = LAST_N_DAYS:3';
    query += ' AND Handover_Date__c < TODAY';
    query += ' AND Country_ISO_Code__c = \'KR\'';
    
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
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        set<id> oppids = new set<id>();
        for(Opportunity opp: oppList){
         oppids.add(opp.Id);   
        }
        list<Account> accList = [select id,(Select id,StartDate from Contracts ORDER BY LastModifiedDate DESC),(select id from opportunities where id IN: oppids)from Account where ID IN (select accountid from opportunity where id IN: oppids)];
        map<id,contract> oppcontract = new map<id,contract>();
        map<list<opportunity>,Account> oppacnt = new map<list<opportunity>,Account>();
        map<account,contract> accContract = new map<account,contract>();
        for(Account acc: accList){
            for(Opportunity opp: acc.opportunities){
                if(acc.contracts.size() > 0)
              oppcontract.put(opp.Id, acc.contracts[0]);  
            }
        }
        system.debug('@@@oppcontract' + oppcontract);
        map<opportunity,opportunitylineitem> opplineitem = new map<opportunity,opportunitylineitem>();
        List<gfkObjectModel> output = new List<gfkObjectModel>();
        contract con = new contract();
        //start
        map<id,opportunitylineitem> opplinemap = new map<id,opportunitylineitem>();
        list<opportunitylineitem> oppprod= [select id,opportunityId,Asset__r.VIN__c,Asset__r.Brand__r.Name,Asset__r.Model__r.Model_Alternative__c,Asset__r.Warranty_Start_Date__c,Asset__r.KR_Platinum_Care_End_Date__c,Asset__r.Product2.Alternative_Name__c from opportunitylineitem where opportunityid IN: oppids AND Asset__c !=null] ;
        for(opportunitylineitem oppline : oppprod){
        opplinemap.put(oppline.opportunityId, oppline) ;   
        }
        opportunitylineitem linerecord;
        //end 
        for(Opportunity opp: oppList){
            system.debug('@@@opp' + opp);
          if(opplinemap.size() != null  && opplinemap.containsKey(opp.id)){
                 linerecord = opplinemap.get(opp.Id);
            }
            system.debug('@@oppcontractTEST'+ oppcontract.containsKey(opp.Id) );
            if(oppcontract != null && oppcontract.containsKey(opp.Id)){
               con = oppcontract.get(opp.Id);
            }
            system.debug('@@@con' + con);
            gfkObjectModel temp = gfkProcessQuery(opp,linerecord,con);
            if(temp!=null){
                 output.add(temp);
            }
            
        }
        if(!output.isEmpty())
        { 
            Set<Id> processedRecIds = new Set<Id>();
            List<Membership__c> gfkSalesExData = new List<Membership__c>();
            //List<Membership__c> gfkSalesExData2 = new List<Membership__c>();
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
            Email__c = line.Email,
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
            //Upsert gfkSalesExData Unique_Identifier__c;
            Insert gfkSalesExData;
        
    }
  }
 global void finish(Database.BatchableContext BC){
    }
     private gfkObjectModel gfkProcessQuery(Opportunity opp,opportunitylineitem linerecord,contract con){
        gfkObjectModel gfkModel = new gfkObjectModel();
        //string[] accountName = opp.Account.Preferred_Sales_Retailer__r.Name.split('-');
       // if(accountName.size() > 0)
        gfkModel.Retailer= opp.Account.Preferred_Sales_Retailer__r.Parent.NameLocal;
       // if(accountName.size() > 1)
        gfkModel.Showroom =  opp.Account.Preferred_Sales_Retailer__r.NameLocal;
        gfkModel.SalesConsultant = opp.Account.Owner.LastName;
        gfkModel.SCuserid =  opp.Account.Owner.Id;
        gfkModel.ContractDate = string.valueof(con.StartDate);
        gfkModel.DeliveryDate = string.valueof(opp.HandOver_Date__c);
        gfkModel.VIN = linerecord != null ? string.valueof(linerecord.Asset__r.VIN__c) : '';
        gfkModel.Brand = linerecord != null ? string.valueof(linerecord.Asset__r.Brand__r.Name) : '';
        gfkModel.ModelName = linerecord != null  ? string.valueof(linerecord.Asset__r.Model__r.Model_Alternative__c) : ''; //is this right 
        gfkModel.IndividualORCorporate = opp.Account.Recordtype.Name;
        gfkModel.Gender = opp.Account.Gender__pc;
        gfkModel.HomePostNo = opp.Account.BillingPostalCode;
        gfkModel.HomeAddress1 = opp.Account.BillingState;
        String BillingCity = opp.Account.BillingCity != null ? opp.Account.BillingCity : '';
        String BillingStreet = opp.Account.BillingStreet != null ? opp.Account.BillingStreet : '';
        gfkModel.HomeAddress2 = BillingCity;
         if(BillingCity != '' && BillingStreet != ''){
          gfkModel.HomeAddress2 +=  ' '; 
         }
         
          gfkModel.HomeAddress2 +=  BillingStreet; 
         
        gfkModel.CompanypostNo = opp.Account.ShippingPostalCode;
        gfkModel.CompanyAddress1 = opp.Account.ShippingState;
        string ShippingCity = opp.Account.ShippingCity != null ? opp.Account.ShippingCity : '';
        string ShippingStreet = opp.Account.ShippingStreet != null ? opp.Account.ShippingStreet : '';
         gfkModel.CompanyAddress2 = ShippingCity;
         if(ShippingCity != '' && ShippingStreet != ''){
          gfkModel.CompanyAddress2 +=  ' '; 
         }
         
          gfkModel.CompanyAddress2 +=  ShippingStreet; 
         
        
        
        if(opp.Account.Recordtype.Name == 'Individual'){
        string customerName = '';
            if(opp.Account.LastName != null){
             customerName += opp.Account.LastName;   
            }
            if(opp.Account.FirstName != null){
             customerName += opp.Account.FirstName;   
            }
        if(customerName != null){
             customerName = customerName.trim();   
            }
        gfkModel.Customername = customerName;   //use the trim functionality 
        //gfkModel.Customername = '';
        gfkModel.CustomerID =  opp.Account.Id;   
        gfkModel.MobileNumber = opp.Account.PersonMobilePhone; 
        gfkModel.DMDelivery = 'Home';
        gfkModel.Email = opp.Account.PersonEmail; //correct
        gfkModel.CompanyName = '';
        
        }
        
        else if(opp.Account.Recordtype.Name == 'Corporate'){
            gfkModel.Customername = opp.Account.Name;
            gfkModel.CustomerID =  opp.Primary_Contact__r.Id; //which contact field to be fetched from opp
            gfkModel.MobileNumber = opp.Account.Phone; 
            gfkModel.DMDelivery = 'Company';
            gfkModel.Email = opp.primary_contact__r.Email; //correct
            gfkModel.CompanyName = opp.Account.Name;
        }
        gfkModel.Position = opp.Account.persontitle;
        gfkModel.ModelDerivativeName = linerecord != null ? string.valueof(linerecord.Asset__r.Product2.Alternative_Name__c) : '';
        gfkModel.PatinumCareEndDate = linerecord != null ? string.valueof(linerecord.Asset__r.KR_Platinum_Care_End_Date__c): '';
        gfkModel.PatinumCareStartDate = '';
         if(gfkModel.PatinumCareEndDate != ''){
         gfkModel.PatinumCareStartDate = linerecord != null ? string.valueof(linerecord.Asset__r.Warranty_Start_Date__c) : '';    
         }
        
        gfkModel.Occupation = opp.Account.Occupation__pc;
        gfkModel.ContractNo = opp.Contract_Reference__r.Name;
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