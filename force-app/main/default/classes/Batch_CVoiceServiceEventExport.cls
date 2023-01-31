global class Batch_CVoiceServiceEventExport implements Schedulable, Database.Batchable<sObject>, database.Stateful{

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_CVoiceServiceEventExport(), 200);
    } 
    
    Id ServiceDataRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('Service_Event');
        
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c));
        Date endDate = System.today()-1;
        
        if(test.isRunningTest())
            endDate=System.today();
        
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day(), 0, 0, 0);
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day(), 23, 59, 59);
        
        Set<Id> recordTypeIds = new Set<Id>();
        recordTypeIds.add(Schema.SObjectType.Event.getRecordTypeInfosByName().get('Service Appointment').getRecordTypeId());
        recordTypeIds.add(Schema.SObjectType.Event.getRecordTypeInfosByName().get('JLR Event').getRecordTypeId());

        String query='SELECT ';
        
        //Event Fields
        query+='Id, VIN_Brand__c , Brand__c, Country_ISO_Code__c, Service_Type__c, CurrencyIsoCode, VIN_number__c, EndDateTime, AccountId, Who_Contact__c, EndDate, OwnerId, Owner.Type, ';
        
        //Asset Fields 
        query+=' VIN_number__r.PurchaseDate, VIN_number__r.Vehicle_Initial_Registration_Date__c, VIN_number__r.Handover_Date__c, VIN_number__r.Model_Year__c, VIN_number__r.Name, VIN_number__r.Model__r.Name, VIN_number__r.Registration_Number__c, ';
        
        //Account Fields
        query+=' Account.IsPersonAccount, Account.Primary_Account__c, Account.Primary_Account__r.Dealer_CI_Code__c, Account.Primary_Account__r.Dealer_CI_Code_2__c, Account.Owner.ContactId, Account.Owner.Contact.AccountId, ';
        query+=' Account.Owner.Contact.Account.Dealer_CI_Code__c, Account.Owner.Contact.Account.Dealer_CI_Code_2__c, Account.BillingStreet, Account.BillingCity, Account.BillingPostalCode, Account.BillingCountry, ';
        query+=' Account.Language__pc,  Account.Gender__pc, Account.PersonIndividualId, ';
       
        //Contact Fields
        query+=' Who_Contact__r.AccountId, Who_Contact__r.Account.Name, Who_Contact__r.Title, Who_Contact__r.FirstName, Who_Contact__r.LastName, Who_Contact__r.Salutation, Who_Contact__r.MailingStreet, Who_Contact__r.MailingCity, ';
        query+=' Who_Contact__r.MailingPostalCode, Who_Contact__r.MailingCountry, Who_Contact__r.HomePhone, Who_Contact__r.Phone, Who_Contact__r.MobilePhone, Who_Contact__r.Email, Who_Contact__r.Email2__c, Who_Contact__r.Language__c, ';
        query+=' Who_Contact__r.Gender__c, Who_Contact__r.Birthdate, Who_Contact__r.IndividualId';
        
        //FILTERS
        query += ' FROM Event';    
        query += ' WHERE';    
        //query += ' createddate=LAST_N_Days:7 ';
        query += ' CreatedDate >=:DtPeriodStart AND CreatedDate <=: DtPeriodEnd ';
        Query += ' AND RecordTypeId in :recordTypeIds ';
        Query += ' AND Service_Type__c IN (\'1st Service\',\'2nd service\',\'3rd Service\',\'4th Service\',\'5th Service\',\'Warranty\',\'General Repair\',\'Recall\',\'UPS - Update Pre Sale\')';
        Query += ' AND Country_ISO_Code__c=\'JP\' ';
        Query += ' AND Service_Status__c=\'Completed\'';
        Query += ' AND VIN_number__r.Handover_Date__c != NULL '; //CXPD-2353
        
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Service Event Batch'];
        if (!Test.isRunningTest()) {
            delete allRows;
        } 
        
        system.debug(query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Event> EvtLst) 
    {
        Set<Id> allIndividualIdSet = new Set<Id>();
        
        for(Event ent : EvtLst){
            if(ent.Who_Contact__c != null) allIndividualIdSet.add(ent.Who_Contact__r.IndividualId);
            if(ent.AccountId != null && ent.Account.IsPersonAccount) allIndividualIdSet.add(ent.Account.PersonIndividualId);
        }

        Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :allIndividualIdSet  And Channel__c in ('Email','Telephone','Post') And DataUsePurpose.LegalBasis.Retailer_Only__c = false]) {
            List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
            Boolean allSurveyOptOut = true;
            if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
            
            consentList.add(cptc);
            consentMap.put(cptc.PartyId, consentList);
        }
        
        //CXPD-2046
        Map<Id, User> eventOwnerMap = new Map<Id, User>();
        for(Event ent: EvtLst){
            if(ent.OwnerId!=NULL && ent.Owner.Type=='User'){
                eventOwnerMap.put(ent.OwnerId, NULL);
            }
        }
        for(User usr: [SELECT Id, ContactId, Contact.Account.Dealer_CI_Code__c, Contact.Account.Dealer_CI_Code_2__c FROM User WHERE Id IN : eventOwnerMap.keyset()]){
            if(eventOwnerMap.containsKey(usr.Id)){
                eventOwnerMap.put(usr.Id, usr);
            }
        }
        
        List<cVoiceObjectModel> output = new List<cVoiceObjectModel>();
        for(Event ent : EvtLst)
        {
            cVoiceObjectModel temp = gfkProcessQuery(ent, eventOwnerMap, consentMap);
            if (temp!=null) output.add(temp);
        }
        
        if(!output.isEmpty())
        {
            
            List<cVoice_Survey__c> cVoiceData = new List<cVoice_Survey__c>();
            for(cVoiceObjectModel line : output){
                cVoiceData.add(new cVoice_Survey__c(
                    recordTypeId= ServiceDataRecId,
                    Process_Name__c='Service Event Batch',
                    Vehicle_Purchase_Date__c=line.VehiclePurchaseDate,
                    Vehicle_Delivery_Date__c=line.VehicleDeliveryDate,
                    Service_Event_Date__c=line.ServiceEventDate,
                    Vehicle_Registration_Date__C=line.VehicleRegistrationDate,
                    Source_Object__c='Event',
                    Manufacturer__c = line.Manufacturer,
                    Country_Code__c = line.CountryCode, 
                    Event_Type__c = line.EventType,
                    Dealer_Code__c = line.DealerCode,
                    Customer_Unique_ID__c = line.CustomerUniqueId,
                    Company_name__c = line.CompanyName,
                    Title__c = line.Title,
                    FirstName__c = line.FirstName,
                    Surname_Field_1__c = line.Surname1,
                    Salutation__c = '', 
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
                    Gender__c=line.Gender,
                    Preferred_Methods_of_Contact__c = line.PrefMethodsOfContact,
                    Permissions_for_Contact__c = line.PermissionsForContact,
                    Month_and_Year_of_Birth__c=line.DateofBirth
                ));
            }
            Insert cVoiceData;
        }  
    }
    
    global void finish(Database.BatchableContext BC) 
    {
    }
    
    
    private cVoiceObjectModel gfkProcessQuery(Event ent, Map<Id, User> eventOwnerMap, Map<id, List<ContactPointTypeConsent>> consentMap){
        Time myTime = Time.newInstance(0, 0, 0, 0); 
        //CXPD-2353
        
        if (ent.enddate <= ent.vin_number__r.handover_date__c.addDays(7)){
            return null;
        }
        
        //CXPD-2353
        cVoiceObjectModel serviceEvtModel = new cVoiceObjectModel();   
        serviceEvtModel.Manufacturer=ent.VIN_Brand__c;
        if(serviceEvtModel.Manufacturer==null || serviceEvtModel.Manufacturer=='')
        serviceEvtModel.Manufacturer=ent.Brand__c;
        
        serviceEvtModel.CountryCode=ent.Country_ISO_Code__c;
        
        switch on ent.Service_Type__c {
            when '1st Service','2nd service','3rd Service','4th Service','5th Service' {		
                serviceEvtModel.EventType='1';
            }	
            when 'Warranty','Recall','UPS - Update Pre Sale' {	
                serviceEvtModel.EventType='2';
            }
            when 'General Repair' {
                serviceEvtModel.EventType='4';
            }
            when else {
                serviceEvtModel.EventType='';
            }
        }
        
        serviceEvtModel.VehiclePurchaseDate= ent.VIN_number__r.PurchaseDate !=null ? datetime.newInstance(ent.VIN_number__r.PurchaseDate, myTime).format('dd/MM/yyyy'):'';
        serviceEvtModel.VehicleRegistrationDate= ent.VIN_number__r.Vehicle_Initial_Registration_Date__c !=null ? datetime.newInstance(ent.VIN_number__r.Vehicle_Initial_Registration_Date__c, myTime).format('dd/MM/yyyy'):'';
        serviceEvtModel.VehicleDeliveryDate= ent.VIN_number__r.Handover_Date__c !=null ? datetime.newInstance(ent.VIN_number__r.Handover_Date__c, myTime).format('dd/MM/yyyy'):'';
        serviceEvtModel.ServiceEventDate=ent.EndDate !=null ? datetime.newInstance(ent.EndDate, myTime).format('dd/MM/yyyy'):'';
        
        If(ent.AccountId !=null)
        {
            if(ent.Account.IsPersonAccount)
            {
                /*if(Ent.Account.OwnerId !=null)
                {
                   serviceEvtModel.DealerCode= ent.VIN_Brand__c=='Jaguar' ? ent.Account.Owner.Contact.Account.Dealer_CI_Code__c : ent.Account.Owner.Contact.Account.Dealer_CI_Code_2__c;
                }*/
            }else{
               
                /*if(Ent.Account.Primary_Account__c !=null)
                {
                   serviceEvtModel.DealerCode= ent.VIN_Brand__c=='Jaguar'? Ent.Account.Primary_Account__r.Dealer_CI_Code__c : ent.Account.Primary_Account__r.Dealer_CI_Code_2__c;
                }*/
                
                serviceEvtModel.Address1=Ent.Account.BillingStreet;
                serviceEvtModel.Address5=Ent.Account.BillingCity;
                serviceEvtModel.Address7=Ent.Account.BillingPostalCode;
                serviceEvtModel.Address8=Ent.Account.BillingCountry;
            }
        }
        
        //CXPD-2046
        if(eventOwnerMap.containsKey(ent.OwnerId)){
            if(eventOwnerMap.get(ent.OwnerId)!=NULL){
                User eventOwner = eventOwnerMap.get(ent.OwnerId);
                serviceEvtModel.DealerCode= ent.VIN_Brand__c=='Jaguar' ? eventOwner.Contact.Account.Dealer_CI_Code__c : eventOwner.Contact.Account.Dealer_CI_Code_2__c;
            }
        }else{
            serviceEvtModel.DealerCode = '';
        }
        
        
        if(ent.Who_Contact__c !=null){
            serviceEvtModel.CustomerUniqueId=ent.Who_Contact__r.AccountId;
            serviceEvtModel.CompanyName=ent.Who_Contact__r.Account.Name;
            serviceEvtModel.Title=ent.Who_Contact__r.Title;
            serviceEvtModel.FirstName=ent.Who_Contact__r.FirstName;
            serviceEvtModel.Surname1=ent.Who_Contact__r.LastName;
            serviceEvtModel.Salutation=ent.Who_Contact__r.Salutation;
            serviceEvtModel.HomeTelephoneNumber=ent.Who_Contact__r.HomePhone;
            serviceEvtModel.BusinessTelephoneNumber=ent.Who_Contact__r.Phone;
            serviceEvtModel.MobileTelephoneNumber=ent.Who_Contact__r.MobilePhone;
            serviceEvtModel.EmailAddress1=ent.Who_Contact__r.Email;
            serviceEvtModel.EmailAddress2=ent.Who_Contact__r.Email2__c;
            serviceEvtModel.PreferredLanguage=ent.Who_Contact__r.Language__c;
			serviceEvtModel.Gender=ent.Who_Contact__r.Gender__c;    
            
            if(ent.Who_Contact__r.Birthdate !=null)
            {
                list<string> tempDate= ent.Who_Contact__r.Birthdate.format().split('/');
                serviceEvtModel.DateofBirth=tempDate[1]+'/'+tempDate[2];
            }
            
            if(ent.Account.IsPersonAccount)
            {
                serviceEvtModel.Address1=ent.Who_Contact__r.MailingStreet;
                serviceEvtModel.Address5=Ent.Who_Contact__r.MailingCity;
                serviceEvtModel.Address7=Ent.Who_Contact__r.MailingPostalCode;
                serviceEvtModel.Address8=Ent.Who_Contact__r.MailingCountry;
            }
        }
        
        
        if(ent.VIN_number__c !=null)
        {
            serviceEvtModel.ModelName=ent.VIN_number__r.Model__r.Name;
            serviceEvtModel.ModelYear=ent.VIN_number__r.Model_Year__c;
            serviceEvtModel.VIN=ent.VIN_number__r.Name;
            serviceEvtModel.RegNumber=ent.VIN_number__r.Registration_Number__c;
            
        }
        
        serviceEvtModel.OwnerShipCycle='0';
        
        
        
        Map<String,Boolean> Suppressions = ConsentHandler.SuppressionsForOpportunity(ent, consentMap, serviceEvtModel.Manufacturer);
        
        if(Suppressions.get('OPTOUT_SURVEY'))
           {
               return null;
           }
        serviceEvtModel.CompleteSupression = (Suppressions.get('OPTOUT_GLOBAL')?'Yes':'No'); 
        
        if (serviceEvtModel.CompleteSupression == 'Yes' ) {
            serviceEvtModel.SupressionEmail = '';
            serviceEvtModel.SupressionPhone = '';
            serviceEvtModel.SupressionMail = '';
        } else {
            serviceEvtModel.SupressionEmail = Suppressions.get('OPTOUT_EMAIL')?'Yes':'No';
            serviceEvtModel.SupressionPhone = Suppressions.get('OPTOUT_PHONE')?'Yes':'No';
            serviceEvtModel.SupressionMail = Suppressions.get('OPTOUT_DIRECTMAIL')?'Yes':'No';            
        }
        
        if(AreMandatoryFieldsPopulated(serviceEvtModel)){
            return serviceEvtModel;
        }
        return null;
    }
    private Boolean AreMandatoryFieldsPopulated(cVoiceObjectModel model){
        List<CVoice_Required_Fields_per_Batch__mdt> gfkFields = [SELECT DeveloperName 
                                                                 FROM CVoice_Required_Fields_per_Batch__mdt 
                                                                 where Is_Active__c = True
                                                                 AND Process_Name__c='Service Event Batch'];
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
        public string ServiceEventDate {get; set;}
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