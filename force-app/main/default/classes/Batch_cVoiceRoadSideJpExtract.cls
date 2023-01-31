global class Batch_cVoiceRoadSideJpExtract implements Schedulable, Database.Batchable<sObject>, database.Stateful 
{
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_cVoiceRoadSideJpExtract(), 200);
    } 
    
    Id PurchaseRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Roadside').getRecordTypeId();
    Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('Road_Side');
    //Id RecTypeId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('CRC').getRecordTypeId();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        String query;
        String periodStart;
        String periodEnd;
        
		        
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c));
        Date endDate = System.today()-1;
        if(test.isRunningTest())
            endDate=System.today();
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        
        String sStartdate = DtPeriodStart.format('yyyy-MM-dd');
        String sEnddate = DtPeriodEnd.format('yyyy-MM-dd');
        
        //RECORD TYPE IDS
        List<String> PersonAccountRTids = new List<String>();
        PersonAccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId())+'\'');
        PersonAccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId())+'\'');    
       
        list<string> opportunityIdLst= new list<string>();

        query = 'SELECT ';
        //CASE FIELDS
        query += 'Id, Category_2__c, Brand__c, Licence_Plate__c, Case_Contact_Email__c, Incident_Date__c, CaseNumber, ';
        
        //CASE ASSET FIELDS
        query += ' Asset.Brand__c, Asset.Brand__r.Name, Asset.Handover_Date__c, Asset.Vehicle_Initial_Registration_Date__c, Asset.VIN__c, Asset.Delivered_Date__c, ';
        query += ' Asset.Model_Year__c, Asset.Model_Alternative__c, Asset.Registration_Number__c, Asset.New_or_Used__c, ';
        
        //BUSINESS ACCOUNT FIELDS
        query += 'Asset.AccountId, Asset.Account.country_iso_code__c, Asset.Account.Dealer_CI_Code__c, Asset.Account.Dealer_CI_Code_2__c,'; 
        query += 'Asset.Account.Name, Asset.Account.recordtype.developername, Asset.Account.Phone, Asset.Account.BillingStreet, Asset.Account.BillingCity, Asset.Account.Retailer_Email__c,';
        query += 'Asset.Account.BillingPostalCode, Asset.Account.BillingCountry, Asset.Account.Key_Contact__c, ';
        
        //PERSON ACCOUNT FIELDS
        query += 'Asset.Account.IsPersonAccount, Asset.Account.FirstName, Asset.Account.LastName, Asset.Account.Country_iso_code__pc, Asset.Account.Owner.Country_iso_code__c,  Asset.Account.Owner.Dealer_CI_Code__c, Asset.Account.Owner.Dealer_CI_Code_2__c, ';
        query += 'Asset.Account.PersonTitle, Asset.Account.Salutation, Asset.Account.personmailingstreet, Asset.Account.personmailingcity, Asset.Account.personmailingstate,';
        query += 'Asset.Account.personmailingpostalcode, Asset.Account.personmailingcountry, Asset.Account.personmobilephone, Asset.Account.personemail,';
        query += 'Asset.Account.PersonHomePhone, Asset.Account.Language__pc, Asset.Account.PersonBirthdate, Asset.Account.Gender__pc,';

        //INDIVIDUAL
        query += 'Asset.Account.PersonIndividualId';
                
        
        //FILTERS
        query += ' FROM Case';    
        query += ' WHERE';    
        query += ' Incident_Date__c >=' + sStartDate +' AND Incident_Date__c <='+sEnddate;
        query += ' AND Gfk_Survey_Suppression__c != \'Yes\' ';
        query += ' AND Legal_Case__c != TRUE ';
        query += ' AND Case_Flag__c excludes (\'Legal\',\'Suppressed\') ';
        query += ' AND Status != \'Closed\' ';
        query += ' AND type = \'Roadside Assistance\' ';
        query +=' AND ( Asset.Account.Country_iso_code__pc IN (\'JP\',\'TW\',\'KR\') OR  Asset.Account.owner.Country_iso_code__c IN (\'JP\',\'TW\',\'KR\') OR Asset.Account.Country_iso_code__c IN ( \'JP\', \'TW\', \'KR\') )';
        
        
        if (Test.isRunningTest()) {
            System.Assert(Database.query(query).size()>0, 'Opportunity query in AssetBatch contructor finds no records for test. Please check query: ' + query );
        }
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Roadside Batch'];
        if (!Test.isRunningTest()) {
            delete allRows;
        } else {
            system.assertEquals(0,allRows.size(),'Gfk_Sales_Export__c object expected to be empty but was not.');
        }
        return database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext BC, List<Case> CaseLst) 
    {
        system.debug('cases @@@'+CaseLst);
        String periodStart;
        String periodEnd;
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c));
        Date endDate = System.today()-1;
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        
        set<Id> accountIdSetForCon = New set<Id>();
        Map<Id, Id> individualIdMap = New Map<Id, Id>();
        
        
        for(Case objCase : CaseLst){
            if(objCase.Asset.Account.recordtype.developername=='Corporate') accountIdSetForCon.add(objCase.Asset.AccountId);
            if(objCase.Asset.Account.recordtype.developername!='Corporate') individualIdMap.put(objCase.Asset.AccountId, objCase.Asset.Account.PersonIndividualId);
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
        for(Case objCase : CaseLst){
            gfkObjectModel temp = gfkProcessQuery(objCase, periodStart, periodEnd, individualIdMap, consentMap);
            
            if (temp!=null)
                output.add(temp);
        }
        system.debug('output @@@'+output);
        if(!output.isEmpty())
        {
        
        List<cVoice_Survey__c> gfkSalesExData = new List<cVoice_Survey__c>();
        for(gfkObjectModel line : output){
            gfkSalesExData.add(new cVoice_Survey__c(
                Opportunity_Id__c = line.OpportunityId,
                Run_Date_of_Extract__c = line.RunDateofExtract,
                Extract_From_Date__c = line.ExtractFromDate,
                Extract_To_Date__c = line.ExtractToDate,
                Manufacturer__c = line.Manufacturer,
                Country_Code__c = line.CountryCode, 
                Event_Type__c = line.EventType,
                Vehicle_Purchase_Date__c = line.VehiclePurchaseDate,
                Vehicle_Registration_Date__c = line.VehicleRegistrationDate ,
                Vehicle_Delivery_Date__c = line.VehicleDeliveryDate,
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
                BREAKDOWN_ATTENDING_RESOURCE__c=line.BreakDownAttendingResourse,
                ROADSIDE_ASSISTANCE_PROVIDER__c=line.CountryCode=='KR'?'Master':(line.CountryCode=='TW' ?'Jaguar Land Rover 道路救援客服中心':'Prestige International'),
                DATA_SOURCE__c=line.CountryCode=='KR'?'Master':(line.CountryCode=='TW' ?'Jaguar Land Rover 道路救援客服中心':'Prestige International'),
                recordTypeId=PurchaseRecId,
                Source_Object__c='Case',
                Process_Name__c='Roadside Batch'
            ));
        }
        system.debug('objCase @@@'+gfkSalesExData);
        Insert gfkSalesExData;
        }
    }
    
    
    global void finish(Database.BatchableContext BC) 
    {
    }
    
    private gfkObjectModel gfkProcessQuery(Case o, string periodStart2, string periodEnd2, Map<Id, Id> individualIdMap, Map<id, List<ContactPointTypeConsent>> consentMap){
                        
        gfkObjectModel gfkModel = new gfkObjectModel();
        StringUtil su = new StringUtil();
        
        gfkModel.OpportunityId = o.Id;
        
        gfkModel.EventType = '4';
        
        gfkModel.CustomerUniqueId = o.Asset.AccountId; 
        gfkModel.CompanyName = o.Asset.Account.Name;

            if(o.Asset.Brand__c != null && o.Asset.Brand__r.Name != null)
                gfkModel.Manufacturer  = o.Asset.Brand__r.Name;
            
            if(o.Asset.Vehicle_Initial_Registration_Date__c != null )       
                gfkModel.VehicleRegistrationDate = o.Asset.Vehicle_Initial_Registration_Date__c.format();
            
            if(o.Asset.Delivered_Date__c != null){
                gfkModel.VehicleDeliveryDate = o.Asset.Delivered_Date__c.format();
            }
        
        	if(o.Asset.Handover_Date__c != null){
                gfkModel.VehiclePurchaseDate = o.Asset.Handover_Date__c.format();
            }
            
            if(o.Asset.Model_Alternative__c  != null){
                gfkModel.ModelName = o.Asset.Model_Alternative__c;
            }
                gfkModel.ModelYear = o.Asset.Model_Year__c;
                gfkModel.VIN = o.Asset.VIN__c;
                gfkModel.RegNumber = o.Licence_Plate__c !=null? o.Licence_Plate__c :o.Asset.Registration_Number__c;

        String countryCode = '';
        
        gfkModel.DealerCode=gfkModel.Manufacturer=='Jaguar' ? o.Asset.Account.Owner.Dealer_CI_Code__c : o.Asset.Account.Owner.Dealer_CI_Code_2__c;
        If(o.Asset.Account.recordtype.developername == 'Corporate'){
   
            if(o.Asset.Account.Country_ISO_Code__c != null){
                countryCode = o.Asset.Account.Country_ISO_Code__c ;
            }
                
            gfkModel.Address1 = o.Asset.Account.BillingStreet;
            gfkModel.Address5 = o.Asset.Account.BillingCity;
            gfkModel.Address7 = o.Asset.Account.BillingPostalCode;
            gfkModel.Address8 = o.Asset.Account.BillingCountry;
            
            gfkModel.HomeTelephoneNumber = o.Asset.Account.Phone;
            gfkModel.EmailAddress2 = o.Asset.Account.Retailer_Email__c;
            
        }else{
            gfkModel.CompanyName = '';
            if(o.Asset.Account.recordtype.developername == 'Individual'){
                if(o.Asset.Account.Country_iso_code__pc != null){
                    countryCode = o.Asset.Account.Country_iso_code__pc;
                }else if(o.Asset.Account.Country_iso_code__pc == null){
                    countryCode = o.Asset.Account.Owner.Country_iso_code__c;
                }else{
                    countryCode = '';
                } 
                gfkModel.Title = o.Asset.Account.PersonTitle;
                gfkModel.FirstName = o.Asset.Account.Firstname;
                gfkModel.Surname1 = o.Asset.Account.LastName;
                gfkModel.Salutation = o.Asset.Account.Salutation;
                gfkModel.Address1 = o.Asset.Account.PersonMailingStreet;
                gfkModel.Address5 = o.Asset.Account.PersonMailingCity;
                gfkModel.Address7 = o.Asset.Account.PersonMailingPostalCode;
                gfkModel.Address8 = o.Asset.Account.PersonMailingCountry;
                gfkModel.HomeTelephoneNumber = o.Asset.Account.PersonHomePhone;
                gfkModel.BusinessTelephoneNumber = o.Asset.Account.PersonMobilePhone;
                gfkModel.PreferredLanguage = o.Asset.Account.Language__pc;
                gfkModel.Gender = o.Asset.Account.Gender__pc;
                if(o.Asset.Account.PersonBirthdate!= null){
                    gfkModel.DateofBirth = o.Asset.Account.PersonBirthdate.format();
                    gfkModel.DateofBirth = gfkModel.DateofBirth.substring(3);
                }
                else{
                    gfkModel.DateofBirth = '';
                }
                
            }
        }
        gfkModel.OwnerShipCycle= o.Asset.New_or_Used__c;
        gfkModel.EmailAddress1 = o.Case_Contact_Email__c;
        gfkModel.BreakDownDate = o.Incident_Date__c !=null ? o.Incident_Date__c.format() :'';
        gfkModel.BreakDownCaseId =o.CaseNumber;
        gfkModel.BreakDownAttendingResourse= o.Category_2__c;
        gfkModel.CountryCode = countryCode;
        gfkModel.Surname2 = '';
        gfkModel.Address3 = '';
        gfkModel.Address4 = '';
        gfkModel.Address6 = '';
        gfkModel.BusinessTelephoneNumber = '';  
        gfkModel.InvoiceNumber = '';
        gfkModel.InvoiceValue = '';
        gfkModel.OwnershipCycle = '';
        gfkModel.PrivateOwner = '';
        gfkModel.OwningCompany = '';
        gfkModel.UserChooserDriver = '';
        gfkModel.EmployerCompany = '';
        gfkModel.PrefMethodsOfContact = '';
        gfkModel.PermissionsForContact = '';
        gfkModel.RunDateofExtract = System.Now().format();
        gfkModel.ExtractFromDate = periodStart2;
        gfkModel.ExtractToDate = periodEnd2;
        
        if(countryCode=='JP')
            gfkModel.Salutation='';
        
        Map<String,Boolean> Suppressions = ConsentHandler.SuppressionsForOpportunity(o, individualIdMap, consentMap, gfkModel.Manufacturer);
        
        gfkModel.CompleteSupression = (Suppressions.get('OPTOUT_GLOBAL')?'Yes':'No'); 
                
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
	
         system.debug('Manadatory @@@'+AreMandatoryFieldsPopulated(gfkModel));
        
        if(AreMandatoryFieldsPopulated(gfkModel)){
            return gfkModel;
        }
        return null;

    } 
    

    
    private Boolean AreMandatoryFieldsPopulated(gfkObjectModel model){
        List<CVoice_Required_Fields_per_Batch__mdt> gfkFields = [SELECT DeveloperName 
                                                                 FROM CVoice_Required_Fields_per_Batch__mdt 
                                                                 where Is_Active__c = True
                                                                 AND Process_Name__c='Asset Batch'];
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
        
        public string GetField(string field){
            String json_instance = Json.serialize(this);
            Map<String, Object> untyped_instance;
            untyped_instance= (Map<String, Object>)JSON.deserializeUntyped(json_instance);  
            Object fieldValue = untyped_instance.get(field);
            return string.valueOf(fieldValue);        
        }
    }
}