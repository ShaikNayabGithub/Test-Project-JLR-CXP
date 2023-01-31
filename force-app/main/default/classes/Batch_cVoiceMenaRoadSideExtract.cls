global class Batch_cVoiceMenaRoadSideExtract implements Schedulable, Database.Batchable<sObject>, database.Stateful 
{
    datetime startTime;
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_cVoiceMenaRoadSideExtract(), 200);
    } 
    
    Id PurchaseRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Roadside').getRecordTypeId();
    Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('Road_Side');
    //Id RecTypeId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('CRC').getRecordTypeId();
    list<string> MinaMarketsLst;

    global Database.QueryLocator start(Database.BatchableContext BC) {  
        String query;
        String periodStart;
        String periodEnd;
        
     	MinaMarketsLst= system.label.IMS_BATCH_MENA_MARKET_IN.split(';');
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c)+1);
        Date endDate = System.today();
        if(test.isRunningTest())
            endDate=System.today();
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        
        String sStartdate = DtPeriodStart.format('yyyy-MM-dd') + 'T00:00:00.000z';
        String sEnddate = DtPeriodEnd.format('yyyy-MM-dd')+ 'T23:59:59.000z';
        
        
        //RECORD TYPE IDS
        List<String> PersonAccountRTids = new List<String>();
        PersonAccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId())+'\'');
        PersonAccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId())+'\'');    
        
        list<string> opportunityIdLst= new list<string>();
        
        query = 'SELECT ';
        //CASE FIELDS
        query += 'Id, Brand__c, Incident_Country_Code__c, Title__c, First_Name__c, Last_Name__c, Event_DateTime__c, Licence_Plate__c, Email__c, Language_Code__c, Survey_Suppression_Flag__c, Roadside_Event_ID__c,Repairing_Dealer_Code__c, Hire_Out_Date__c, Hired_Out_Model__c, Model__c, Hired_Out_Model__r.Name, Source__c,';
        
        //CASE ASSET FIELDS
        query += ' VIN__r.Handover_Date__c, VIN__r.Vehicle_Initial_Registration_Date__c, VIN__r.VIN__c, VIN__r.Delivered_Date__c, ';
        query += ' VIN__r.Model_Year__c, VIN__r.Model_Alternative__c, VIN__r.Registration_Number__c, VIN__r.New_or_Used__c, ';
        query += ' VIN__r.SalesPersonCode__c, VIN__r.SalesPersonName__c, Vin__r.Salesperson_Dealer_Code__c, Vin__r.Salesperson_Dealer_Code2__c, Vin__r.Account.Owner.Contact.Account.Dealer_CI_Code__c, Vin__r.Account.Owner.Contact.Account.Dealer_CI_Code_2__c,';
        
        //BUSINESS ACCOUNT FIELDS
        query += 'VIN__r.Account.Name, VIN__r.Account.recordtype.developername, VIN__r.Account.Phone, VIN__r.Account.BillingStreet, VIN__r.Account.BillingCity, VIN__r.Account.Retailer_Email__c,';
        query += 'VIN__r.Account.BillingPostalCode, VIN__r.Account.BillingCountry, VIN__r.Account.Key_Contact__c, ';
        
        
        //PERSON ACCOUNT FIELDS
        query += 'VIN__r.Account.IsPersonAccount, VIN__r.Account.FirstName, VIN__r.Account.LastName, VIN__r.Account.Country_iso_code__pc, VIN__r.Account.Owner.Country_iso_code__c,  VIN__r.Account.Owner.Dealer_CI_Code__c, VIN__r.Account.Owner.Dealer_CI_Code_2__c, ';
        query += 'VIN__r.Account.PersonTitle, VIN__r.Account.Salutation, VIN__r.Account.personmailingstreet, VIN__r.Account.personmailingcity, VIN__r.Account.personmailingstate,';
        query += 'VIN__r.Account.personmailingpostalcode, VIN__r.Account.personmailingcountry, VIN__r.Account.personmobilephone, VIN__r.Account.personemail,';
        query += 'VIN__r.Account.PersonHomePhone, VIN__r.Account.Language__pc, VIN__r.Account.PersonBirthdate, VIN__r.Account.Gender__pc,';
        
        //INDIVIDUAL
        query += 'VIN__r.Account.PersonIndividualId';
        
        //FILTERS
        query += ' FROM Event_Details__c';    
        query += ' WHERE';    
        query += ' createddate >=' + sStartdate +' AND createddate <='+sEnddate;
        query += ' AND Incident_Country_Code__c !=null'; 
        
        if (Test.isRunningTest()) {
            System.Assert(Database.query(query).size()>0, 'Opportunity query in AssetBatch contructor finds no records for test. Please check query: ' + query );
        }
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Roadside Mena Batch' limit 10000];
        if (!Test.isRunningTest()) {
            delete allRows;
        } else {
            system.assertEquals(0,allRows.size(),'Gfk_Sales_Export__c object expected to be empty but was not.');
        }
        startTime=system.now();
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Event_Details__c> eventDetailsLst) 
    {
        
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Roadside Mena Batch' AND createddate <:startTime limit 8000];
        if (!Test.isRunningTest() && ! allRows.isEmpty()) {
            delete allRows;
        } 
        
        system.debug('cases @@@'+eventDetailsLst);
        String periodStart;
        String periodEnd;
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c)+1);
        Date endDate = System.today();
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        
        set<Id> accountIdSetForCon = New set<Id>();
        Map<Id, Id> individualIdMap = New Map<Id, Id>();
        
        
        for(Event_Details__c entdtls : eventDetailsLst){
            if(entdtls.VIN__r.Account.recordtype.developername=='Corporate') accountIdSetForCon.add(entdtls.VIN__r.AccountId);
            if(entdtls.VIN__r.Account.recordtype.developername!='Corporate') individualIdMap.put(entdtls.VIN__r.AccountId, entdtls.VIN__r.Account.PersonIndividualId);
        }
        
        for (Account corporateAcc : [select Id, Key_Contact__c, Key_Contact__r.IndividualId, (select Id, IndividualId from contacts limit 1) from Account where ID IN :accountIdSetForCon]) {
            if (corporateAcc.Key_Contact__c != null) individualIdMap.put(corporateAcc.Id, corporateAcc.Key_Contact__r.IndividualId);
            if (corporateAcc.Key_Contact__c == null && !corporateAcc.contacts.isEmpty()) individualIdMap.put(corporateAcc.Id, corporateAcc.contacts[0].IndividualId);
        }

        Set<Id> allIndividualIdSet = new Set<Id>();
        allIndividualIdSet.addAll(individualIdMap.values());

        Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :allIndividualIdSet  And Channel__c in ('Email','Telephone','Post') And DataUsePurpose.LegalBasis.Retailer_Only__c = false]) {
            List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
            if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
            consentList.add(cptc);
            consentMap.put(cptc.PartyId, consentList);
        }
        
        
        List<gfkObjectModel> output = new List<gfkObjectModel>();
        for(Event_Details__c entdtls : eventDetailsLst){
            gfkObjectModel temp = gfkProcessQuery(entdtls, periodStart, periodEnd, individualIdMap, consentMap);
            
            if (temp!=null)
                output.add(temp);
        }
        system.debug('output @@@'+output);
        if(!output.isEmpty())
        {
            
            List<cVoice_Survey__c> gfkSalesExData = new List<cVoice_Survey__c>();
            for(gfkObjectModel line : output){
                gfkSalesExData.add(new cVoice_Survey__c(
                    Run_Date_of_Extract__c = line.RunDateofExtract,
                    Extract_From_Date__c = line.ExtractFromDate,
                    Extract_To_Date__c = line.ExtractToDate,
                    Manufacturer__c = line.Manufacturer,
                    Country_Code__c = line.CountryCode, 
                    Event_Type__c = line.EventType,
                    Vehicle_Purchase_Date__c = line.VehiclePurchaseDate,
                    Vehicle_Registration_Date__c = line.VehicleRegistrationDate ,
                    Vehicle_Delivery_Date__c = line.VehicleDeliveryDate,
                    Service_Event_Date__c=line.ServiceEventDate,
                    Dealer_Code__c=line.DealerCode,
                    Sales_Employee_Code__c = line.EmployeeCode,
                    Employee_Name__c = line.EmployeeName,
                    Customer_Unique_ID__c=line.CustomerUniqueId,
                    Company_name__c = line.CompanyName,
                    Title__c = line.Title,
                    FirstName__c = line.FirstName,
                    Surname_Field_1__c = line.Surname1,
                    Surname_Field_2__c = line.Surname2,
                    Salutation__c = line.Salutation, 
                    Address_1__c = line.Address1,
                    Address_2__c = line.Address2, 
                    Address_3__c = line.Address3, 
                    Address_4__c = line.Address4, 
                    Address_5__c = line.Address5, 
                    Address_6__c = line.Address6, 
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
                    Ownership_Cycle__c = line.OwnerShipCycle, 
                    Gender__c = line.Gender,
                    Private_Owner__c = line.PrivateOwner,
                    Owning_Company__c = line.OwningCompany, 
                    User_Chooser_Or_Driver__c = line.UserChooserDriver, 
                    Employer_Company__c = line.EmployerCompany,
                    Month_and_Year_of_Birth__c = line.DateofBirth,
                    Preferred_Methods_of_Contact__c = line.PrefMethodsOfContact,
                    Permissions_for_Contact__c = line.PermissionsForContact,
                    BREAKDOWN_DATE__c =line.BreakDownDate,
                    BREAKDOWN_COUNTRY__c= line.CountryCode,
                    BREAKDOWN_CASE_ID__c=line.BreakDownCaseId,
                    CAR_HIRE_START_DATE__c=line.CarHireStartDate,
                    CAR_HIRE_MODEL__c=line.CarHireModel,
                    BREAKDOWN_ATTENDING_RESOURCE__c=line.BreakDownAttendingResourse,
                    ROADSIDE_ASSISTANCE_PROVIDER__c=line.Source,
                    DATA_SOURCE__c=line.Source,
                    recordTypeId=PurchaseRecId,
                    Source_Object__c='Event Details',
                    Process_Name__c='Roadside Mena Batch',
                    Repairing_Dealer_Code__c=line.RepairingDealerCode
                ));
            }
            system.debug('objCase @@@'+gfkSalesExData);
            Insert gfkSalesExData;
        }
    }
    
    
    global void finish(Database.BatchableContext BC) 
    {
    }
    
    private gfkObjectModel gfkProcessQuery(Event_Details__c o, string periodStart2, string periodEnd2, Map<Id, Id> individualIdMap, Map<id, List<ContactPointTypeConsent>> consentMap){
        
        gfkObjectModel gfkModel = new gfkObjectModel();
        StringUtil su = new StringUtil();
        gfkModel.Manufacturer  = o.Brand__c;
        gfkModel.CountryCode = o.Incident_Country_Code__c;
        gfkModel.EventType = '4';
        gfkModel.RepairingDealerCode=o.Repairing_Dealer_Code__c;
        
        if(o.Vin__r.Vehicle_Initial_Registration_Date__c != null )       
            gfkModel.VehicleRegistrationDate = o.Vin__r.Vehicle_Initial_Registration_Date__c.format();
        
        if(o.Vin__r.Delivered_Date__c != null){
            gfkModel.VehicleDeliveryDate = o.Vin__r.Delivered_Date__c.format();
        }
        
        if(o.Vin__r.Handover_Date__c != null){
            gfkModel.VehiclePurchaseDate = o.Vin__r.Handover_Date__c.format();
        }
        
        /*if(o.Event_DateTime__c != null){
            gfkModel.ServiceEventDate= o.Event_DateTime__c.format();
        }*/
        //CXPD-1555
        if(gfkModel.CountryCode == 'IN'){
            gfkModel.Source = o.Source__c;
        }
        else{
            gfkModel.Source = 'Mena Assist';
        }
        //CXPD-1446
        if(MinaMarketsLst.contains(gfkModel.CountryCode) && gfkModel.CountryCode != 'IN'){
          		gfkModel.DealerCode = gfkModel.Manufacturer=='Jaguar' ? o.Vin__r.Salesperson_Dealer_Code__c : o.Vin__r.Salesperson_Dealer_Code2__c;
                gfkModel.EmployeeCode = o.Vin__r.SalesPersonCode__c;
                gfkModel.EmployeeName = o.Vin__r.SalesPersonName__c;
        }
        else
          gfkModel.DealerCode=gfkModel.Manufacturer=='Jaguar' ? o.Vin__r.Account.Owner.Contact.Account.Dealer_CI_Code__c:o.Vin__r.Account.Owner.Contact.Account.Dealer_CI_Code_2__c;
        gfkModel.CustomerUniqueId = o.Id; 
        
        if(o.vin__r.Account.recordtype.developername == 'Individual'){
            gfkModel.Title = o.vin__r.Account.PersonTitle;
            gfkModel.FirstName = o.vin__r.Account.Firstname;
            gfkModel.Surname1 = o.vin__r.Account.LastName;
            gfkModel.Salutation = o.vin__r.Account.Salutation;
            gfkModel.Address1 = o.vin__r.Account.PersonMailingStreet;
            gfkModel.Address5 = o.vin__r.Account.PersonMailingCity;
            gfkModel.Address7 = o.vin__r.Account.PersonMailingPostalCode;
            gfkModel.Address8 = o.vin__r.Account.PersonMailingCountry;
            gfkModel.HomeTelephoneNumber = o.vin__r.Account.PersonHomePhone;
            gfkModel.BusinessTelephoneNumber = o.vin__r.Account.PersonMobilePhone;
            gfkModel.Gender = o.vin__r.Account.Gender__pc;
            if(o.vin__r.Account.PersonBirthdate!= null){
                gfkModel.DateofBirth = o.vin__r.Account.PersonBirthdate.format();
                gfkModel.DateofBirth = gfkModel.DateofBirth.substring(3);
            }
            else{
                gfkModel.DateofBirth = '';
            }
            
        }else if(o.vin__r.Account.recordtype.developername == 'Corporate')
        {
            gfkModel.Address1 = o.vin__r.Account.BillingStreet;
            gfkModel.Address5 = o.vin__r.Account.BillingCity;
            gfkModel.Address7 = o.vin__r.Account.BillingPostalCode;
            gfkModel.Address8 = o.vin__r.Account.BillingCountry;
            gfkModel.HomeTelephoneNumber = o.vin__r.Account.Phone;
        }
        
        if(o.vin__r.Model_Alternative__c  != null){ 
            gfkModel.ModelName = o.vin__r.Model_Alternative__c;
        }else{
            gfkModel.ModelName = o.Model__c;
        }
        gfkModel.ModelYear = o.vin__r.Model_Year__c;
        gfkModel.VIN = o.Vin__r.VIN__c;
        gfkModel.RegNumber = o.Licence_Plate__c !=null? o.Licence_Plate__c :o.Vin__r.Registration_Number__c;
        gfkModel.EmailAddress1 = o.Email__c;
        gfkModel.PreferredLanguage = o.Language_Code__c;
        gfkModel.OwnerShipCycle= o.Vin__r.New_or_Used__c;
        gfkModel.BreakDownDate = o.Event_DateTime__c !=null ? o.Event_DateTime__c.format() :'';
        gfkModel.BreakDownCaseId =o.Roadside_Event_ID__c;
        gfkModel.CountryCode = o.Incident_Country_Code__c;
        //gfkModel.BreakDownAttendingResourse= o.Category_2__c;
        if(o.Hire_Out_Date__c !=null)
            gfkModel.CarHireStartDate=o.Hire_Out_Date__c.format();
        gfkModel.CarHireModel=o.Hired_Out_Model__r.Name;
        
        gfkModel.Surname2 = '';
        gfkModel.Address3 = '';
        gfkModel.Address4 = '';
        gfkModel.Address6 = '';
        gfkModel.PrivateOwner = '';
        gfkModel.OwningCompany = '';
        gfkModel.UserChooserDriver = '';
        gfkModel.EmployerCompany = '';
        gfkModel.PrefMethodsOfContact = '';
        gfkModel.PermissionsForContact = '';
        gfkModel.RunDateofExtract = System.Now().format();
        gfkModel.ExtractFromDate = periodStart2;
        gfkModel.ExtractToDate = periodEnd2;

        
        Map<String,Boolean> Suppressions = ConsentHandler.SuppressionsForOpportunity(o, individualIdMap, consentMap, gfkModel.Manufacturer);
        
        gfkModel.CompleteSupression = (Suppressions.get('OPTOUT_GLOBAL')?'Yes':'No'); 
        if(o.Survey_Suppression_Flag__c)
            gfkModel.CompleteSupression='Yes';
        
        if(Suppressions.get('OPTOUT_SURVEY'))
        {
            return null;  
        }
        
        if (gfkModel.CompleteSupression == 'Yes' ) {
            gfkModel.SupressionEmail = '';
            gfkModel.SupressionPhone = '';
            gfkModel.SupressionMail = '';
        } else {
            gfkModel.SupressionEmail = Suppressions.get('OPTOUT_EMAIL')?'Yes':'No';
            gfkModel.SupressionPhone = Suppressions.get('OPTOUT_PHONE')?'Yes':'No';
            gfkModel.SupressionMail = Suppressions.get('OPTOUT_DIRECTMAIL')?'Yes':'No';            
        }
        
        system.debug('Mandatory @@@'+AreMandatoryFieldsPopulated(gfkModel));
        
        if(AreMandatoryFieldsPopulated(gfkModel)){
            return gfkModel;
        }
        return null;
        
    } 
    
    private Boolean AreMandatoryFieldsPopulated(gfkObjectModel model){
        List<CVoice_Required_Fields_per_Batch__mdt> gfkFields = [SELECT DeveloperName 
                                                                 FROM CVoice_Required_Fields_per_Batch__mdt 
                                                                 where Is_Active__c = True
                                                                 AND Process_Name__c='Roadside Mena Batch'];
        for(CVoice_Required_Fields_per_Batch__mdt setting : gfkFields){
            String fieldValue = model.GetField(setting.DeveloperName);
            if(string.isBlank(fieldValue))
            {
                return false;
            }
            
        }
        return true;
    }
    
    public class gfkObjectModel {
        public string OpportunityId {get; set;}
        public String RunDateofExtract {get;set;}
        public String ExtractFromDate {get;set;}
        public String ExtractToDate {get;set;}
        public String Manufacturer {get;set;}
        public string CountryCode {get;set;}
        public string EventType {get;set;}
        public string VehiclePurchaseDate {get;set;}
        public string VehicleRegistrationDate {get;set;}
        public string VehicleDeliveryDate {get;set;}
        public string SalesEventDate {get; set;}
        public string ServiceEventDate {get; set;}
        public string DealerCode {get; set;}
        public string CustomerUniqueId {get; set;}
        public string CompanyName {get; set;}
        public String Title {get;set;}
        public String FirstName {get;set;}
        public String Surname1 {get;set;}
        public String Surname2 {get;set;}
        public String Salutation {get;set;}
        public String Address1 {get;set;}               
        public String Address2 {get;set;}
        public String Address3 {get;set;}
        public String Address4 {get;set;}
        public String Address5 {get;set;}
        public String Address6 {get;set;}
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
        public String skipRecord {get;set;} 
        public String BreakDownDate {get;set;} 
        public String BreakDownCaseId {get;set;} 
        public String BreakDownAttendingResourse {get;set;} 
        public String CarHireStartDate {get;set;} 
        public String CarHireModel {get;set;}
        public String RepairingDealerCode {get;set;}
        public String Source {get;set;}
        
        public string GetField(string field){
            String json_instance = Json.serialize(this);
            Map<String, Object> untyped_instance;
            untyped_instance= (Map<String, Object>)JSON.deserializeUntyped(json_instance);  
            Object fieldValue = untyped_instance.get(field);
            return string.valueOf(fieldValue);        
        }
    }
}