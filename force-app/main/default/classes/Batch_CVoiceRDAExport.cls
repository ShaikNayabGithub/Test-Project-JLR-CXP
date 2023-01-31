global class Batch_CVoiceRDAExport implements Schedulable, Database.Batchable<sObject>, database.Stateful 
{
    string QueryFilters; 
    string eventType;
    Id PurchaseRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Purchase').getRecordTypeId();
    Id PreownedRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Preowned').getRecordTypeId();
    Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('RDA_Batch');
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_CVoiceRDAExport(), 200);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query='SELECT ';
        
        
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.days__c));
        Date endDate = System.today()-1;
        
        if(test.isRunningTest())
            endDate=System.today();
        
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        
        String sStartdate = DtPeriodStart.format('yyyy-MM-dd') + 'T00:00:00.000z';
        String sEnddate = DtPeriodEnd.format('yyyy-MM-dd') + 'T23:59:59.000z';
        
        //RECORD TYPE IDS
        List<String> PersonAccountRTids = new List<String>();
        PersonAccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId())+'\'');
        PersonAccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId())+'\''); 
        
        //RDA Fields
        query+='Id, Make__c, Country__c, RecordType.Name, Handover_Date__c, Dealer_Code__c, Account__c, Model__c, Model_Year__c, Asset_VIN__c, Registration_Number__c, Sales_Person__c, Sales_Person_RDA__c, Is_APO__c, Contact__c, Opportunity__c, CurrencyIsoCode, ';
        
        //Account Fields
        query+='Account__r.PersonBirthdate, Account__r.Name, Account__r.PersonTitle, Account__r.FirstName, Account__r.LastName, Account__r.Salutation, Account__r.BillingStreet, Account__r.personMailingStreet,';    
        query+='Account__r.BillingCity, Account__r.PersonMailingCity, Account__r.BillingPostalCode, Account__r.PersonMailingPostalCode, Account__r.BillingCountry, Account__r.PersonMailingCountry,';
        query+='Account__r.Phone, Account__r.PersonHomePhone, Account__r.PersonMobilePhone, Account__r.PersonEmail, Account__r.Retailer_Email__c, Account__r.recordtype.developername, ';
        
        query+='Account__r.Language__pc, Account__r.IsPersonAccount, Account__r.PersonIndividualId, Account__r.Primary_Account__c,';
        
        //Contact Fields
        query+='Contact__r.Language__c, Contact__r.Email2__c, Contact__r.Gender__c, Contact__r.Birthdate, Contact__r.MobilePhone, Contact__r.Email, Contact__r.IndividualId,';
        
        //Asset Fields 
        query+=' Asset__c, Asset__r.Model__r.Name, Asset__r.Common_Sale_Type__c, Asset__r.Sale_Type_Code__c, Asset__r.Type_Of_Sale_ID__c, ';
        
        //Opportunity Fields 
        query+=' Opportunity__r.CloseDate, Opportunity__r.Owner.Name ';
        
        //FILTERS
        query += ' FROM RDA__c';    
        query += ' WHERE';    
        //query += ' Handover_Date__c=LAST_N_Days:7 ';
        query += ' Handover_Date__c >=:startDate AND Handover_Date__c <=: endDate '; 
        //query += ' AND Submitted_Status__c = \'Completed\' ';
        Query +=' AND recordType.Name IN (\'New Retail\',\'On-Sell\',\'Trade In\') ';
        query += 'AND Account__r.RecordTypeId IN (' + String.join(PersonAccountRTids,',') + ') '; 
        query +=' AND Country__c=\'AU\' ';
        
        
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='RDA Batch'];
        if (!Test.isRunningTest()) {
            delete allRows;
        } 
        
        system.debug(query);
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RDA__c> RDALst) 
    {
        
        String periodStart;
        String periodEnd;
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.days__C));
        Date endDate = System.today()-1;
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        
        Map<Id, Id> individualIdMap = New Map<Id, Id>();
        
        for(RDA__c rda : RDALst){
            if(rda.Contact__c != null) individualIdMap.put(rda.Account__c, rda.Contact__r.IndividualId);
            else if(rda.Account__c != null && rda.Account__r.IsPersonAccount) individualIdMap.put(rda.Account__c, rda.Account__r.PersonIndividualId);
        }

        Set<Id> allIndividualIdSet = new Set<Id>();
        allIndividualIdSet.addAll(individualIdMap.values());

        Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
        Map<Id, Boolean> surveyOptOutMap = new Map<Id, Boolean>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.CXP_Name__c, PrivacyConsentStatus, Channel__c, DataUsePurpose.Translatable_Value__c from ContactPointTypeConsent Where PartyId in :allIndividualIdSet And DataUsePurpose.LegalBasis.Retailer_Only__c = false]) {
            List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
            Boolean allSurveyOptOut = true;
            if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
            if (surveyOptOutMap.containsKey(cptc.PartyId)) allSurveyOptOut = surveyOptOutMap.get(cptc.PartyId);
            
            consentList.add(cptc);
            consentMap.put(cptc.PartyId, consentList);
            
            if (cptc.DataUsePurpose.CXP_Name__c != ConsentHandler.consentSettings.get('Purpose_Surveys')?.CXP_Name__c) continue;
            if (allSurveyOptOut && cptc.DataUsePurpose.CXP_Name__c == ConsentHandler.consentSettings.get('Purpose_Surveys')?.CXP_Name__c && cptc.PrivacyConsentStatus != 'OptOut') allSurveyOptOut = false;
            surveyOptOutMap.put(cptc.PartyId, allSurveyOptOut);
        }
        
        List<cVoiceObjectModel> output = new List<cVoiceObjectModel>();
        for(RDA__c Rda : RDALst){
            Id individualId;
            if (Rda.Contact__c != null) individualId = Rda.Contact__r.IndividualId;
            else if(Rda.Account__c != null && Rda.Account__r.IsPersonAccount) individualId = Rda.Account__r.PersonIndividualId;

            if(individualId == null || !surveyOptOutMap.containsKey(Rda.Account__c) || !surveyOptOutMap.get(Rda.Account__c)) {
                cVoiceObjectModel temp = gfkProcessQuery(Rda, periodStart, periodEnd, consentMap);
            if (temp!=null) output.add(temp);
            }
        }
        
        if(!output.isEmpty())
        {
            List<cVoice_Survey__c> cVoiceData = new List<cVoice_Survey__c>();
            for(cVoiceObjectModel line : output){
                cVoiceData.add(new cVoice_Survey__c(
                    Opportunity_Id__c = line.recId,
                    Run_Date_of_Extract__c = line.RunDateofExtract,
                    Extract_From_Date__c = line.ExtractFromDate,
                    recordTypeId= line.APPROVED=='No'?  PurchaseRecId: PreownedRecId,
                    Process_Name__c='RDA Batch',
                    Vehicle_Purchase_Date__c=line.VehiclePurchaseDate,
                    Vehicle_Delivery_Date__c=line.VehicleDeliveryDate,
                    Source_Object__c='RDA',
                    Extract_To_Date__c = line.ExtractToDate,
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
                    Invoice_Number__c = line.InvoiceNumber,
                    Invoice_Value__c = line.InvoiceValue,
                    Sales_Event_Date__c= line.SalesEventDate,
                    //Sales_Employee_Code__c = line.EmployeeCode,
                    Employee_Name__c = line.EmployeeName,
                    Ownership_Cycle__c = line.OwnerShipCycle, 
                    Gender__c = line.Gender,
                    Private_Owner__c = line.PrivateOwner,
                    Owning_Company__c = line.OwningCompany, 
                    User_Chooser_Or_Driver__c = line.UserChooserDriver, 
                    Employer_Company__c = line.EmployerCompany,
                    //Month_and_Year_of_Birth__c = line.DateofBirth,
                    Preferred_Methods_of_Contact__c = line.PrefMethodsOfContact,
                    Permissions_for_Contact__c = line.PermissionsForContact,
                    currencyISoCode=line.currencyISoCode,
                    APPROVED__c=line.APPROVED,
                    Common_Sale_Type__c = line.CommonSaleType,
                    Sale_Type_Code__c = line.SaleTypeCode,
                    Type_Of_Sale_ID__c=line.TypeOfSaleID
                ));
            }
            Insert cVoiceData;
            
            //CXPD-2305 changes begin
            Map<Id, cVoice_Survey__c> processedRecMap = new Map<Id, cVoice_Survey__c>();
            for(cVoice_Survey__c cVoiceRec: cVoiceData){
                processedRecMap.put(cVoiceRec.Opportunity_Id__c, cVoiceRec);
            }
            Id purchRecTypeId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByDeveloperName().get('Purchase').getRecordTypeId();
            Id purchPreRecTypeId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByDeveloperName().get('Preowned').getRecordTypeId();
            List<Event> eventList1= new List<Event>();
            Datetime eventStartPeriod = DateTime.now().addMonths(-2);
            eventList1 = [SELECT Id, VIN_Number__c FROM Event WHERE VIN_number__c !=null AND What.Type IN ('Account') And CreatedDate >= :eventStartPeriod And 
                          Subject like '%Cvoice Survey sent for VIN%'];
            List<Event> newEventList=new List<Event>();
            Set<Id> eventAssetIds= new Set<Id>();
            if(!eventList1.isEmpty()){
                for(Event event: eventList1){
                    eventAssetIds.add(event.VIN_Number__c);
                }
            }
            cVoice_Survey__c cVoiceRec = new cVoice_Survey__c();
            for(RDA__c rda: RDALst){
                if(processedRecMap!=NULL && !processedRecMap.containsKey(rda.Id)) continue;
                if(eventAssetIds!=NULL && eventAssetIds.contains(rda.Asset__r.Id)) continue;
                cVoiceRec = processedRecMap.get(rda.Id);
                Event event = new Event();
                event.ActivityDateTime = DateTime.now();
                event.DurationInMinutes= 1;
                event.WhatId = rda.Account__r.Id;
                event.VIN_number__c= rda.Asset__r.Id;
                event.Description ='Cvoice Survey sent for VIN: '+ rda.Asset_VIN__c; //Name
                event.Subject = cVoiceRec.RecordTypeId==purchRecTypeId? 'Purch Cvoice Survey sent for VIN: '+ rda.Asset_VIN__c : 'Purch-Pre Cvoice Survey sent for VIN: '+ rda.Asset_VIN__c;
                newEventList.add(event);
            }
            if(!newEventList.isEmpty())insert newEventList;
            //CXPD-2305 changes end
        }
    }
    
    
    private cVoiceObjectModel gfkProcessQuery(RDA__C rda, string periodStart2, string periodEnd2, Map<id, List<ContactPointTypeConsent>> consentMap){
        Time myTime = Time.newInstance(0, 0, 0, 0); 
        
        cVoiceObjectModel rdaModel = new cVoiceObjectModel();        
        rdaModel.recId = rda.Id;
        rdaModel.Manufacturer=rda.Make__c;
        
        rdaModel.EventType = rda.recordType.Name =='New Retail'? '1':'2';
        rdaModel.SalesEventDate= DateTime.newInstance(rda.Handover_Date__c, myTime).format('dd/MM/yyyy');
        rdaModel.VehicleDeliveryDate= DateTime.newInstance(rda.Handover_Date__c, myTime).format('dd/MM/yyyy');
        rdaModel.DealerCode=rda.Dealer_Code__c;
        
        rdaModel.CustomerUniqueId = rda.Account__r.Primary_Account__c; 
        rdaModel.CompanyName = rda.Account__r.Name;

        //rdaModel.EmployeeCode = rda.Sales_Person_RDA__c;
        rdaModel.EmployeeName = rda.Opportunity__r.Owner.Name;
        rdaModel.ModelName = rda.Asset__c !=null ? rda.Asset__r.Model__r.Name:'';
        rdaModel.ModelYear=rda.Model_Year__c;
        rdaModel.VIN = rda.Asset_VIN__c;
        rdaModel.RegNumber = rda.Registration_Number__c;
        String countryCode = '';
        rdaModel.PreferredLanguage='English';
            
        If(rda.Account__r.recordtype.developername == 'Corporate'){
            rdaModel.Address1 = rda.Account__r.BillingStreet;
            rdaModel.Address5 = rda.Account__r.BillingCity;
            rdaModel.Address7 = rda.Account__r.BillingPostalCode;
            rdaModel.Address8 = rda.Account__r.BillingCountry;
            rdaModel.HomeTelephoneNumber = rda.Account__r.Phone;
            rdaModel.EmailAddress2 = rda.Account__r.Retailer_Email__c;
            //rdaModel.PreferredLanguage=rda.Contact__r.Language__c;
        }else{
            rdaModel.CompanyName = '';
            if(rda.Account__r.recordtype.developername == 'Individual'){
                
                rdaModel.Title = rda.Account__r.PersonTitle;
                rdaModel.FirstName = rda.Account__r.Firstname;
                rdaModel.Surname1 = rda.Account__r.LastName;
                rdaModel.Salutation = rda.Account__r.Salutation;
                rdaModel.Address1 = rda.Account__r.PersonMailingStreet;
                rdaModel.Address5 = rda.Account__r.PersonMailingCity;
                rdaModel.Address7 = rda.Account__r.PersonMailingPostalCode;
                rdaModel.Address8 = rda.Account__r.PersonMailingCountry;
                rdaModel.HomeTelephoneNumber = rda.Account__r.PersonHomePhone;
                //rdaModel.BusinessTelephoneNumber = rda.Account__r.PersonMobilePhone;
                //rdaModel.EmailAddress1 = rda.Account__r.PersonEmail;
                //rdaModel.PreferredLanguage = rda.Account__r.Language__pc;
                //rdaModel.Gender = rda.Account__r.Gender__pc;
                /*if(rda.Account__r.PersonBirthdate!= null){
                    rdaModel.DateofBirth = rda.Account__r.PersonBirthdate.format();
                    rdaModel.DateofBirth = rdaModel.DateofBirth.substring(3);
                }
                else{
                    rdaModel.DateofBirth = '';
                }*/
                
            }
        }
        
        if(rda.Contact__c !=null)
        {
            //rdaModel.Gender = rda.Contact__r.Gender__c; 
            rdaModel.MobileTelephoneNumber=rda.Contact__r.MobilePhone;
            rdaModel.EmailAddress1 = rda.Contact__r.Email;
            rdaModel.EmailAddress2 = rda.Contact__r.Email2__c;
            /*if(rda.Contact__r.Birthdate!= null){
                rdaModel.DateofBirth = rda.Contact__r.Birthdate.format();
                rdaModel.DateofBirth = rdaModel.DateofBirth.substring(3);
            }
            else{
                rdaModel.DateofBirth = '';
            }*/
        }
        
        if(rda.Opportunity__c !=null)
        {
            rdaModel.VehiclePurchaseDate=DateTime.newInstance(rda.Opportunity__r.closeDate, myTime).format('dd/MM/yyyy');
        }
        rdaModel.currencyISoCode=rda.CurrencyIsoCode;
        rdaModel.CountryCode = rda.Country__c;
        rdaModel.Address3 = '';
        rdaModel.Address4 = '';
        rdaModel.Address6 = '';
        rdaModel.BusinessTelephoneNumber = '';  
        rdaModel.InvoiceNumber = '';
        rdaModel.InvoiceValue = '';
        rdaModel.OwnershipCycle = rda.recordType.Name =='New Retail'? '1':'';
        rdaModel.PrivateOwner = '';
        rdaModel.OwningCompany = '';
        rdaModel.UserChooserDriver = '';
        rdaModel.EmployerCompany = '';
        rdaModel.PrefMethodsOfContact = '';
        rdaModel.PermissionsForContact = '';
        rdaModel.RunDateofExtract = System.Now().format();
        rdaModel.ExtractFromDate = periodStart2;
        rdaModel.ExtractToDate = periodEnd2;
        rdaModel.APPROVED= rda.Is_APO__c ?'Yes':'No';
        
        //CXPD-2125
        if(rda.Asset__c!=null){
            rdaModel.CommonSaleType = rda.Asset__r.Common_Sale_Type__c;
            rdaModel.SaleTypeCode = rda.Asset__r.Sale_Type_Code__c;
            rdaModel.TypeOfSaleID = rda.Asset__r.Type_Of_Sale_ID__c;
        }else{
            rdaModel.CommonSaleType = '';
            rdaModel.SaleTypeCode = '';
            rdaModel.TypeOfSaleID = '';
        }
        
        Map<String,Boolean> Suppressions = ConsentHandler.SuppressionsForOpportunity(rda, consentMap, rdaModel.Manufacturer);
        
        rdaModel.CompleteSupression = (Suppressions.get('OPTOUT_GLOBAL')?'Yes':'No'); 
        
        if (rdaModel.CompleteSupression == 'Yes' ) {
            rdaModel.SupressionEmail = '';
            rdaModel.SupressionPhone = '';
            rdaModel.SupressionMail = '';
        } else {
            rdaModel.SupressionEmail = Suppressions.get('OPTOUT_EMAIL')?'Yes':'No';
            rdaModel.SupressionPhone = Suppressions.get('OPTOUT_PHONE')?'Yes':'No';
            rdaModel.SupressionMail = Suppressions.get('OPTOUT_DIRECTMAIL')?'Yes':'No';            
        }
        
        if(AreMandatoryFieldsPopulated(rdaModel)){
            return rdaModel;
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
                                                                 AND Process_Name__c='RDA Batch'];
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
        public string recId {get; set;}
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
        public string DealerCode {get; set;}
        public string CustomerUniqueId {get; set;}
        public string CompanyName {get; set;}
        public String Title {get;set;}
        public String FirstName {get;set;}
        public String Surname1 {get;set;}
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
        public string APPROVED {get;set;} 
        public string currencyISoCode {get;set;} 
        public String CommonSaleType {get;set;} 
        public String TypeOfSaleID {get;set;} 
        public String SaleTypeCode {get;set;}
        
        
        public string GetField(string field){
            String json_instance = Json.serialize(this);
            Map<String, Object> untyped_instance;
            untyped_instance= (Map<String, Object>)JSON.deserializeUntyped(json_instance);  
            Object fieldValue = untyped_instance.get(field);
            return string.valueOf(fieldValue);        
        }
    }
}