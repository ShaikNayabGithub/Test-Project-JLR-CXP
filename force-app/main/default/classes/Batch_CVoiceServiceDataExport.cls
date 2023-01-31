global class Batch_CVoiceServiceDataExport implements Schedulable, Database.Batchable<sObject>, database.Stateful 
{
    datetime startTime;
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_CVoiceServiceDataExport(), 200);
    } 
    
    Id ServiceDataRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('Service_Data');
        
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.days__c));
        Date endDate = System.today()-1;        
        
        if(test.isRunningTest())
            endDate=System.today();
        
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        
        String sStartdate = DtPeriodStart.format('yyyy-MM-dd') + 'T00:00:00.000z';
        String sEnddate = DtPeriodEnd.format('yyyy-MM-dd') + 'T23:59:59.000z';
        
        list<string> liveCountryLst=system.label.Batch_CVoice_ServiceData_Country.split(';');
        String query='SELECT ';
        
        //SD Fields
        query+='Id, Brand__c, Country_ISO_Code__c, Service_Date__c, Dealer_Code_JLR__c, Company_Name__c, Title__c, First_Name__c, Last_Name__c, Address1__c, Address2__c, City__c, Post_Code__c, Country__c, Home_Phone__c, Business_Phone__c, ';
        query+='Mobile_Number__c, Model__c, Licence_Plate__c, Email__c, SR_Type__c, CurrencyIsoCode, Preferred_Language__c, Complete_Suppression__c, Service_Employee_Code__c, Service_Employee_Name__c, Service_Repair_Date__c, ';
        
        //Asset Fields 
        query+=' Asset__c, Asset__r.Handover_Date__c, Asset__r.Vehicle_Initial_Registration_Date__c, Asset__r.Model_Year__c, Asset__r.VIN__c, Account__r.Name, Account__r.firstName, Account__r.lastName, Account__r.isPersonAccount, Retailer_Name__c ';
        
        
        //FILTERS
        query += ' FROM Service_Data__c';    
        query += ' WHERE';    
        //query += ' createddate=LAST_N_Days:7 ';
        query += ' createddate >= ' + sStartDate + ' AND createddate <= ' + sEnddate + ' ';
        query += ' AND Country_ISO_Code__c IN:liveCountryLst';
        
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Service Data Batch' limit 10000];
        if (!Test.isRunningTest() && !allRows.isEmpty()) {
            delete allRows;
        } 
        startTime= system.now();
        system.debug(query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Data__c> SDLst) 
    {
        
	List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Service Data Batch' AND createddate <:startTime limit 8000];
        if (!Test.isRunningTest() && ! allRows.isEmpty()) {
            delete allRows;
        } 
                
        List<cVoiceObjectModel> output = new List<cVoiceObjectModel>();
        Map<String, Account> retailerAccMap = new Map<String, Account>();
        
        for(Service_Data__c SD : SDLst)
        {
            if(SD.Country_ISO_Code__c == 'TW' && SD.Retailer_Name__c != NULL){
                retailerAccMap.put(SD.Retailer_Name__c, NULL);
            }
        }
        for(Account acc : [SELECT Name, Dealer_CI_Code__c, Dealer_CI_Code_2__c FROM Account WHERE Name IN : retailerAccMap.keyset() AND Recordtype.DeveloperName = 'Retailer']){
            if(retailerAccMap.containsKey(acc.Name)){
                retailerAccMap.put(acc.Name, acc);
            }
        }
        
        for(Service_Data__c SD : SDLst)
        {
            cVoiceObjectModel temp = gfkProcessQuery(SD, retailerAccMap);
            if (temp!=null) output.add(temp);
        }
        
        if(!output.isEmpty())
        {
            
            List<cVoice_Survey__c> cVoiceData = new List<cVoice_Survey__c>();
            for(cVoiceObjectModel line : output){
                cVoiceData.add(new cVoice_Survey__c(
                    recordTypeId= ServiceDataRecId,
                    Process_Name__c='Service Data Batch',
                    Vehicle_Purchase_Date__c=line.VehiclePurchaseDate,
                    Vehicle_Delivery_Date__c=line.VehicleDeliveryDate,
                    Service_Event_Date__c=line.SalesEventDate,
                    Vehicle_Registration_Date__C=line.VehicleRegistrationDate,
                    Source_Object__c='Service Data',
                    Manufacturer__c = line.Manufacturer,
                    Country_Code__c = line.CountryCode, 
                    Event_Type__c = line.EventType,
                    Dealer_Code__c = line.DealerCode,
                    Customer_Unique_ID__c = line.CustomerUniqueId,
                    Company_name__c = line.CompanyName,
                    Title__c = line.Title,
                    FirstName__c = line.FirstName,
                    Surname_Field_1__c = line.Surname1,
                    Salutation__c = line.Salutation, 
                    Address_1__c = line.Address1,
                    Address_2__c = line.Address2, 
                    Address_5__c = line.Address5, 
                    Address_7__c = line.Address7, 
                    Address_8__c = line.Address8, 
                    Home_Telephone_Number__c = line.HomeTelephoneNumber,
                    Business_Telephone_Number__c = line.BusinessTelephoneNumber,
                    Mobile_Telephone_Number__c = line.MobileTelephoneNumber,
                    Model_Name__c = line.ModelName, 
                    Model_Year__c = line.ModelYear, 
                    VIN__c = line.VIN, 
                    Registration_Number__c = line.RegNumber,
                    Email_Address_1__c = line.EmailAddress1,
                    Email_Address_2__c = line.EmailAddress2,
                    Preferred_Language__c = line.PreferredLanguage,
                    Complete_Suppression__c = line.CompleteSupression, 
                    Suppression_Email__c = line.SupressionEmail,
                    Suppression_Phone__c = line.SupressionPhone,
                    Suppression_Mail__c = line.SupressionMail,
                    Service_Employee_Code__c = line.EmployeeCode,
                    Employee_Name__c = line.EmployeeName,
                    Ownership_Cycle__c = line.OwnerShipCycle, 
                    User_Chooser_Or_Driver__c = line.UserChooserDriver, 
                    Employer_Company__c = line.EmployerCompany,
                    Preferred_Methods_of_Contact__c = line.PrefMethodsOfContact,
                    Permissions_for_Contact__c = line.PermissionsForContact
                ));
            }
            Insert cVoiceData;
        }  
    }
    
    
    private cVoiceObjectModel gfkProcessQuery(Service_Data__c SD, Map<String, Account> retailerAccMap){
        Time myTime = Time.newInstance(0, 0, 0, 0); 
        
        cVoiceObjectModel SdModel = new cVoiceObjectModel();        
        SdModel.Manufacturer=SD.Brand__c;
        SdModel.CountryCode=SD.Country_ISO_Code__c;
        SdModel.CurrencyIsoCode=SD.CurrencyIsoCode;
        switch on SD.SR_Type__c {
            when 'Service','SERVICE','Service Plans', '1', 'General Repairs' {		
                SdModel.EventType='1';
            }	
            when 'Warranty','Extended Warranty','2' {	
                SdModel.EventType='2';
            }
            when 'Service that includes warranty work','3', 'Periodic Maintenance' {
                SdModel.EventType='3';
            }
            when 'Repair','Retail','4', 'Campaign' {
                SdModel.EventType='4';
            }
            when else {
                SdModel.EventType='';
            }
        }
        
        if(SD.Country_ISO_Code__c =='TW' && retailerAccMap.containsKey(SD.Retailer_Name__c) && retailerAccMap.get(SD.Retailer_Name__c) != NULL){
            Account acc = retailerAccMap.get(SD.Retailer_Name__c);
            if(SD.Brand__c == 'Jaguar'){
                SD.Dealer_Code_JLR__c = acc.Dealer_CI_Code__c;
            }
            else if(SD.Brand__c == 'Land Rover'){
                SD.Dealer_Code_JLR__c = acc.Dealer_CI_Code_2__c;
            }
        }
        
        
        SdModel.VehicleRegistrationDate=SD.Asset__r.Vehicle_Initial_Registration_Date__c !=null ? datetime.newInstance(SD.Asset__r.Vehicle_Initial_Registration_Date__c,myTime).format('dd/MM/yyyy'):'';
        SdModel.VehicleDeliveryDate=SD.Asset__r.Handover_Date__c !=null ?datetime.newInstance(SD.Asset__r.Handover_Date__c,myTime).format('dd/MM/yyyy'):'';
        sdModel.SalesEventDate=SD.Service_Date__c !=null ? datetime.newInstance(SD.Service_Date__c,myTime).format('dd/MM/yyyy'): SD.Service_Repair_Date__c !=null ? SD.Service_Repair_Date__c.format('dd/MM/yyyy') :'';
        sdModel.DealerCode=SD.Dealer_Code_JLR__c !=null ? SD.Dealer_Code_JLR__c.length()>5 ? SD.Dealer_Code_JLR__c.substring(SD.Dealer_Code_JLR__c.length()-5, SD.Dealer_Code_JLR__c.length()): SD.Dealer_Code_JLR__c:'';
        sdModel.CustomerUniqueId=SD.Id;
        sdModel.CompanyName= SD.Country_ISO_Code__c =='TW'? SD.Account__r.isPersonAccount ? '' : SD.Account__r.Name : SD.Company_Name__c ; 
        sdModel.Title=SD.Title__c;
        sdModel.FirstName= SD.Country_ISO_Code__c =='TW'? SD.Account__r.isPersonAccount ? SD.Account__r.firstName : '' : SD.First_Name__c;
        sdModel.Surname1= SD.Country_ISO_Code__c =='TW'? SD.Account__r.isPersonAccount ? SD.Account__r.lastName : '' : SD.Last_Name__c;
        sdModel.Address1=SD.Address1__c;
        sdModel.Address2=SD.Address2__c;
        sdModel.Address5=SD.City__c;
        sdModel.Address7=SD.Post_Code__c;
        sdModel.Address8=SD.Country__c;
        sdModel.HomeTelephoneNumber=SD.Home_Phone__c;
        sdModel.BusinessTelephoneNumber=SD.Business_Phone__c;
        sdModel.MobileTelephoneNumber=SD.Mobile_Number__c;
        sdModel.ModelName=SD.Model__c;
        sdModel.ModelYear=SD.Asset__r.Model_Year__c;
        sdModel.VIN=SD.Asset__r.Vin__c;
        sdModel.RegNumber=SD.LIcence_Plate__c;
        sdModel.EmailAddress1=SD.Email__c;
        sdModel.PreferredLanguage=SD.Preferred_Language__c;
        sdModel.CompleteSupression=SD.Complete_Suppression__c;
        sdModel.SupressionEmail=sdModel.CompleteSupression;
        sdModel.SupressionPhone=sdModel.CompleteSupression;
        sdModel.SupressionMail=sdModel.CompleteSupression;
        sdModel.EmployeeCode=SD.Service_Employee_Code__c;
        SdModel.EmployeeName=SD.Service_Employee_Name__c;
        sdModel.OwnerShipCycle='0';
        
        if(AreMandatoryFieldsPopulated(SdModel)){
            return SdModel;
        }
        return null;
        
    } 
    
    global void finish(Database.BatchableContext BC) 
    {
    }
    
    
    private Boolean AreMandatoryFieldsPopulated(cVoiceObjectModel model){
        List<CVoice_Required_Fields_per_Batch__mdt> gfkFields = [SELECT DeveloperName 
                                                                 FROM CVoice_Required_Fields_per_Batch__mdt 
                                                                 where Is_Active__c = True
                                                                 AND Process_Name__c='Service Data Batch'];
        for(CVoice_Required_Fields_per_Batch__mdt setting : gfkFields){
            String fieldValue = model.GetField(setting.DeveloperName);
            if(string.isBlank(fieldValue))
            {
                return false;
            }
            
        }
        return true;
    }
    
    public class cVoiceObjectModel {
        public String Manufacturer {get;set;}
        public string CountryCode {get;set;}
        public string EventType {get;set;}
        public string VehiclePurchaseDate {get;set;}
        public string VehicleRegistrationDate {get;set;}
        public string VehicleDeliveryDate {get;set;}
        public string SalesEventDate {get; set;}
        public string DealerCode {get; set;}
        public string CustomerUniqueId {get; set;}
        public string CompanyName {get; set;}
        public String Title {get;set;}
        public String FirstName {get;set;}
        public String Surname1 {get;set;}
        public String Salutation {get;set;}
        public String Address1 {get;set;}               
        public String Address2 {get;set;}
        public String Address5 {get;set;}
        public String Address7 {get;set;}
        public String Address8 {get;set;}
        public String HomeTelephoneNumber {get;set;}
        public String BusinessTelephoneNumber {get;set;}       
        public String MobileTelephoneNumber {get;set;}
        public String ModelName {get;set;}
        public String ModelYear {get;set;}
        public String VIN {get;set;}
        public String RegNumber {get;set;}
        public String EmailAddress1 {get;set;}
        public String EmailAddress2 {get;set;}
        public String PreferredLanguage {get;set;}
        public String CompleteSupression {get;set;}
        public String SupressionEmail {get;set;}
        public String SupressionPhone {get;set;}
        public String SupressionMail {get;set;}
        public String InvoiceNumber {get;set;}
        public String InvoiceValue {get;set;}
        public String EmployeeCode {get;set;}
        public String EmployeeName {get;set;}
        public String OwnerShipCycle {get;set;}
        public String Gender {get;set;}
        public String privateOwner {get;set;}
        public String OwningCompany {get;set;}
        public String UserChooserDriver {get;set;}
        public String EmployerCompany {get;set;}
        public String DateofBirth {get;set;}
        public String PrefMethodsOfContact {get;set;}
        public String PermissionsForContact {get;set;} 
        public String CurrencyIsoCode {get;set;}
        
        public string GetField(string field){
            String json_instance = Json.serialize(this);
            Map<String, Object> untyped_instance;
            untyped_instance= (Map<String, Object>)JSON.deserializeUntyped(json_instance);  
            Object fieldValue = untyped_instance.get(field);
            return string.valueOf(fieldValue);        
        }
    }
}