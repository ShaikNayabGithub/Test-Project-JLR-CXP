global class GfkBatchExport implements Schedulable, Database.batchable<sObject>, Database.Stateful
{ 
    String query;
    Long counter=0;
    String periodStart;
    String periodEnd;
    String errors = '';
    List<String> illegalStrings = Label.GFK_INVALID_ENTRIES.split(',');
    Id crcRecTypeId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('CRC').getRecordTypeId();
    
    
    global void execute(SchedulableContext SC) {
        Database.executebatch(new GfkBatchExport(), 100);
    } 
    
    global GfkBatchExport()
    {
        Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('CRC_Batch');
        
        //Date startDate = System.today().toStartOfMonth().addDays(-1).toStartOfMonth();
        //Date endDate = System.today().toStartOfMonth().addDays(-1);
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c));
        Date endDate = System.today()-1;
        if(test.isRunningTest())
            endDate=System.today();
        
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        
        String sStartdate = DtPeriodStart.format('yyyy-MM-dd') + 'T00:00:00.000z';
        String sEnddate = DtPeriodEnd.format('yyyy-MM-dd') + 'T23:59:59.000z';
        
        /*List<String> CaseValidRTids = new List<String>();
        CaseValidRTids.add('\''+String.ValueOf(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NSC').getRecordTypeId())+'\'');
        CaseValidRTids.add('\''+String.ValueOf(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enquiry').getRecordTypeId())+'\'');
        //CaseValidRTids.add('\''+String.ValueOf(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NSC').getRecordTypeId())+'\'');*/
        Id generalEquiryRecId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enquiry').getRecordTypeId();
        Id crcRecId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NSC').getRecordTypeId();
        List<String> AccountRTids = new List<String>();
        AccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId())+'\'');
        AccountRTids.add('\''+ String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId())+'\'');
        //String PersonAccountRTid = String.ValueOf(Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId());
        
        query = 'SELECT ';
        //CASE FIELDS
        query += 'Id, Casenumber, Contactid, Accountid, Assetid, Closeddate, Createddate, Country_iso_code__c, Case_Country_ISO_Code__c, Brand__c, Origin, Type, ';
        query += 'OwnerId, Owner.Lastname, Owner.Firstname, Owner.Type, Solved_Date__c, Solved_By__c, Solved_By__r.Firstname, Solved_By__r.Lastname, Category_2__c, Initiated_By__c,';
        query += 'LastModifiedById, LastModifiedBy.Lastname, LastModifiedBy.Firstname, RecordType.Developername, RecordTypeId, Account.RecordTypeId, RecordType.Name, Gfk_Survey_Suppression__c, ';
        //CONTACT FIELDS
        query += 'Contact.Firstname,Contact.lastname,Contact.mailingstreet,Contact.mailingcity,Contact.mailingstate,Contact.mailingpostalcode, contact.mailingcountry, ';
        query += 'Contact.phone,Contact.mobilephone,Contact.email,Contact.salutation,Contact.language__c,Contact.country_iso_code__c, Contact.AccountId, Contact.Account.Name, ';
        //CONTACT SUPPRESSION FIELDS
        query += 'Contact.IndividualId, ';
        //PERSON ACCOUNT FIELDS
        query += 'Account.isPersonAccount, Account.Name,Account.recordtype.developername,Account.firstname,Account.lastname,Account.personmailingstreet,Account.personmailingcity, ';
        query += 'Account.personmailingstate,Account.personmailingpostalcode,Account.phone,Account.personmobilephone,Account.personemail, ';
        query += 'Account.personmailingcountry,Account.country_iso_code__c,Account.salutation,Account.language__pc, ';
        //PERSON ACCOUNT SUPPRESSION FIELDS
        query += 'Account.PersonIndividualId, ';
        //ASSET FIELDS 
        query += 'Asset.Name,Asset.model__r.name,Asset.derivative__r.name,Asset.model__r.derivative__r.name, ';
        query += 'Asset.mileage__c, Asset.registration_number__c ';
        //FILTERS
        query += 'FROM Case ';     
        query += 'WHERE ';
        query += 'Solved_date__c >= ' + sStartDate + ' AND Solved_date__c <= ' + sEnddate + ' '; 
        query += 'AND Gfk_Survey_Suppression__c != \'Yes\' ';
        query += 'AND Legal_Case__c != TRUE ';
        query += 'AND Case_Flag__c excludes (\'Legal\',\'Suppressed\') ';
        //query += 'AND RecordTypeId IN (' + String.join(CaseValidRTids,',') + ') ';
        //query += 'AND Status != \'Closed\' ';
        query += 'AND Initiated_By__c != \'Retailer\' ';
        //query += 'AND Case_Country_ISO_Code__c = \'AU\' ';
        query += 'AND ( ( AccountId != null AND Account.RecordTypeId IN (' + String.join(AccountRTids,',') + ')) OR ( ContactId != null ) )';
        query +=' AND ( (RecordTypeId=\''+crcRecId+'\' AND Status != \'Closed\') OR RecordTypeId=\''+generalEquiryRecId+'\')';
        
        /*
if (Test.isRunningTest()) {
System.Assert( Database.query(query).size()>0, 'Case query in GfkBatchExport contructor finds no records for test. Please check query: ' + query );
}
*/
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='CRC Case Batch'];
        if (!Test.isRunningTest()) {
            delete allRows;
        } else {
            // system.assertEquals(0,allRows.size(),'Gfk_Export__c object expected to be empty but was not.');
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    private boolean shouldProcessRow(Case c) {
        //Boolean isMENA = false;
        //Boolean isLACROCOL = false;
        
        //Set<String> gfkExclude = new Set<String>();
        
        //List<GFK_MENA_Exclusion__mdt> metaValues = [Select Masterlabel from GFK_MENA_Exclusion__mdt];
        /*for(GFK_MENA_Exclusion__mdt gfkValues : metaValues){
gfkExclude.add(gfkValues.MasterLabel);
}
if(gfkExclude.contains(c.Case_Country_ISO_Code__c)){
isMENA = true;
isLACROCOL = true;
}*/
        
        Boolean returnValue = true;
        
        if(c.Case_Country_ISO_Code__c == 'AU' && c.RecordType.Name  =='Enquiry' && (c.Origin == 'OSA Feedback' || c.Origin =='OSA Query'))
        {
            returnValue = false;
        }
        //CXPD-1556
        if(c.Case_Country_ISO_Code__c == 'TW' && c.Type == 'Roadside Assistance')
        {
            returnValue = false;
        }
        //CXPD-2456
        if(c.Case_Country_ISO_Code__c == 'KR' && c.Type == 'Roadside Assistance')
        {
            returnValue = false;
        }
        
        if(c.RecordType.Name  =='Enquiry' && c.Origin=='OSA Feedback' && c.Initiated_By__c=='Survey')
        {
          returnValue = false;
        }
        if (c.AccountId!=null && !c.Account.isPersonAccount && c.ContactId==null) returnValue = false;
        if (c.AccountId==null && c.ContactId==null) returnValue = false;
        /*if (!isMENA || !isLACROCOL){
if (c.AssetId==null) returnValue = false; 
}*/
        
        if (c.AccountId!=null) {
            /*if(isMENA){
if(c.Origin == 'Retailer' || c.Category_2__c == 'Goodwill') returnValue = false;
if (String.isEmpty(c.Account.Lastname) || illegalStrings.contains(c.Account.Lastname)) returnValue = false;
if (String.isEmpty(c.Account.Firstname) || illegalStrings.contains(c.Account.Firstname)) returnValue = false; 
}else{*/
            if (String.isEmpty(c.Account.Lastname) || illegalStrings.contains(c.Account.Lastname)) returnValue = false;
            if (c.Case_Country_ISO_Code__c != 'KR' && (String.isEmpty(c.Account.Firstname) || illegalStrings.contains(c.Account.Firstname))) returnValue = false; 
            //if (illegalStrings.contains(c.Account.PersonMailingStreet)) returnValue = false; 
            //if (illegalStrings.contains(c.Account.PersonMailingState)) returnValue = false; 
            //if (illegalStrings.contains(c.Account.PersonMailingCity)) returnValue = false; 
            //if (illegalStrings.contains(c.Account.PersonMailingPostalCode)) returnValue = false;   
            //}
        } else {
            /*if(isMENA){
if(c.Origin == 'Retailer' || c.Category_2__c == 'Goodwill') return false;
if (String.isEmpty(c.Contact.Lastname) || illegalStrings.contains(c.Contact.Lastname)) returnValue = false;
if (String.isEmpty(c.Contact.Firstname) || illegalStrings.contains(c.Contact.Firstname)) returnValue = false; 
}else{*/
            if ( illegalStrings.contains(c.Contact.Lastname)) returnValue = false;
            if ( c.Case_Country_ISO_Code__c != 'KR' && illegalStrings.contains(c.Contact.Firstname)) returnValue = false; 
            //if ( illegalStrings.contains(c.Contact.MailingStreet)) returnValue = false; 
            //if ( illegalStrings.contains(c.Contact.MailingState)) returnValue = false; 
            //if ( illegalStrings.contains(c.Contact.MailingCity)) returnValue = false; 
            //if ( illegalStrings.contains(c.Contact.MailingPostalCode)) returnValue = false;  
            //}
        }
        
        system.debug('returnValue'+returnValue);
        return returnValue;
        
    }
    
    global void execute(Database.BatchableContext BC, List<Case> GfKCases)
    {
        
        try {

            Map<Id, Id> individualIdMap = New Map<Id, Id>();
        
            for(Case c : GfKCases){
                if(c.ContactId != null) individualIdMap.put(c.AccountId, c.Contact.IndividualId);
                else if(c.AccountId != null) individualIdMap.put(c.AccountId, c.Account.PersonIndividualId);
            }

            Set<Id> allIndividualIdSet = new Set<Id>();
            allIndividualIdSet.addAll(individualIdMap.values());

            Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
            Map<Id, Boolean> surveyOptOutMap = new Map<Id, Boolean>();
            for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :allIndividualIdSet  And Channel__c in ('Email','Telephone','Post') And DataUsePurpose.LegalBasis.Retailer_Only__c = false]) {
                List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
                Boolean allSurveyOptOut = true;
                if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
                if (surveyOptOutMap.containsKey(cptc.PartyId)) allSurveyOptOut = surveyOptOutMap.get(cptc.PartyId);
                
                consentList.add(cptc);
                consentMap.put(cptc.PartyId, consentList);
                
                if (cptc.DataUsePurpose.Translatable_Value__c != ConsentHandler.consentSettings.get('Purpose_Surveys')?.CXP_Name__c) continue;
                if (allSurveyOptOut && cptc.DataUsePurpose.Translatable_Value__c == ConsentHandler.consentSettings.get('Purpose_Surveys')?.CXP_Name__c && cptc.PrivacyConsentStatus != 'OptOut') allSurveyOptOut = false;
                surveyOptOutMap.put(cptc.PartyId, allSurveyOptOut);
            }
            
            List<TransformData> output = new List<TransformData>();
            
            for (Case c : GfKCases) {
                
                if (shouldProcessRow(c)) 
                {
                    Id individualId;
                    if(c.ContactId != null) individualId = c.Contact.IndividualId;
                    else if(c.AccountId != null) individualId = c.Account.PersonIndividualId;

                    if(individualId == null || !surveyOptOutMap.containsKey(c.AccountId) || !surveyOptOutMap.get(c.AccountId)) {
                        if( !(c.RecordType.Name =='Enquiry' && c.Gfk_Survey_Suppression__c =='Yes')) output.add(new TransformData(c, periodStart, periodEnd, consentMap));
                    }
                }
            }

            List<cVoice_Survey__c> gfkData = new List<cVoice_Survey__c>();
            
            for (TransformData line : output) {
                gfkData.add(new cVoice_Survey__c(CRCCode__c=line.CRCCode,
                                                 MarketCode__c=line.MarketCode,
                                                 BrandCode__c=line.BrandCode,
                                                 RunDateofExtract__c=line.RunDateofExtract,
                                                 ExtractFromDate__c=line.ExtractFromDate,
                                                 ExtractToDate__c=line.ExtractToDate,
                                                 ContactId__c=line.ContactId,
                                                 AssetId__c=line.AssetId,
                                                 CustomerLanguageCode__c=line.CustomerLanguageCode,
                                                 UniqueCustomerId__c=line.UniqueCustomerId,
                                                 VehicleRegNumber__c=line.VehicleRegNumber,
                                                 VIN__c=line.VIN,
                                                 VehicleModel__c=line.VehicleModel,
                                                 VehicleDerivative__c=line.VehicleDerivative,
                                                 VehicleMileage__c=line.VehicleMileage,
                                                 VehicleMonthsinService__c=line.VehicleMonthsinService,
                                                 CustomerTitle__c=line.CustomerTitle,
                                                 CustomerInitial__c=line.CustomerInitial,
                                                 CustomerFirstName__c=line.CustomerFirstName,
                                                 CustomerLastName__c=line.CustomerLastName,
                                                 AddressLine1__c=line.AddressLine1,
                                                 AddressLine2__c=line.AddressLine2,
                                                 AddressLine3__c=line.AddressLine3,
                                                 AddressLine4__c=line.AddressLine4,
                                                 City__c=line.City,
                                                 County__c=line.County,
                                                 Country__c=line.Country,
                                                 PostalCode__c=line.PostalCode,
                                                 PhoneMobile__c=line.PhoneMobile,
                                                 PhoneHome__c=line.PhoneHome,
                                                 EmailAddress__c=line.EmailAddress,
                                                 CompanyName__c=line.CompanyName,
                                                 RowId__c=line.RowId,
                                                 CaseNumber__c=line.CaseNumber,
                                                 SRCreatedDate__c=line.SRCreatedDate,
                                                 SRClosedDate__c=line.SRClosedDate,
                                                 Owner__c=line.Owner,
                                                 ClosedBy__c=line.ClosedBy,
                                                 Type__c=line.Type,
                                                 PrimaryReasonCode__c=line.PrimaryReasonCode,
                                                 SecondaryReasonCode__c=line.SecondaryReasonCode,
                                                 ConcernAreaCode__c=line.ConcernAreaCode,
                                                 SymptomCode__c=line.SymptomCode,
                                                 NoOfSelectedContacts__c=line.NoOfSelectedContacts,
                                                 Rule1__c=line.Rule1,
                                                 Rule2__c=line.Rule2,
                                                 C05__c=line.C05,
                                                 C07__c=line.C07,
                                                 C15__c=line.C15,
                                                 T06__c=line.T06,
                                                 T08__c=line.T08,
                                                 T13__c=line.T13,
                                                 Rule5__c=line.Rule5,
                                                 Rule6__c=line.Rule6,
                                                 Rule7a__c=line.Rule7a,
                                                 Rule7b__c=line.Rule7b,
                                                 Rule8__c=line.Rule8,
                                                 COMPLETE_SUPPRESSION__c=line.COMPLETE_SUPPRESSION,
                                                 SUPPRESSION_EMAIL__c=line.SUPPRESSION_EMAIL,
                                                 SUPPRESSION_PHONE__c=line.SUPPRESSION_PHONE,
                                                 SUPPRESSION_MAIL__c=line.SUPPRESSION_MAIL,
                                                 Case_Record_Type__c=line.caseRecTypeName,
                                                 Process_Name__c='CRC Case Batch',
                                                 recordTypeId=crcRecTypeId,
                                                 Source_Object__c='Case'));
            }
            
            insert gfkData;
            
        } catch (Exception e) {
            errors += e.getMessage() + ' --- ' + e.getStackTraceString() + '\n';
            if (Test.isRunningTest()) {
                System.Assert(False,JSON.SerializePretty(errors));
            }
            //EmailUtility.SendEmail('hartnady@gmail.com','System Error',e.getMessage().left(255),e.getMessage() + '---' + e.getStackTracestring() );
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if (!String.isEmpty(errors))
            EmailUtility.SendEmail(Label.TEST_FAILURE_NOTIFICATION_EMAILS.split(','),'GfkBatchExport Daemon','GfkBatchExport Errors','<pre>'+errors+'</pre>');
    }
    
    public class TransformData {
        
        public String CRCCode {get;set;}//ISO 3 Digit Code // Mandatory
        public String MarketCode {get;set;}//Same as CRCCode // Mandatory
        public String BrandCode {get;set;} //J or L // Mandatory
        public String RunDateofExtract {get;set;} // dd/mm/yyyy // Mandatory
        public String ExtractFromDate {get;set;}// dd/mm/yyyy // Mandatory
        public String ExtractToDate {get;set;}// dd/mm/yyyy // Mandatory
        public String ContactId {get;set;}
        public String AssetId {get;set;}
        public String CustomerLanguageCode {get;set;}//2 digit iso // Mandatory
        public String UniqueCustomerId {get;set;}
        public String VehicleRegNumber {get;set;}
        public String VIN {get;set;}//17 character
        public String VehicleModel {get;set;}
        public String VehicleDerivative {get;set;}// XF or Freelander 2
        public String VehicleMileage {get;set;}
        public String VehicleMonthsinService {get;set;}
        public String CustomerTitle {get;set;} // Mandatory
        public String CustomerInitial {get;set;}
        public String CustomerFirstName {get;set;}
        public String CustomerLastName {get;set;}// Mandatory
        public String AddressLine1 {get;set;}// Mandatory
        public String AddressLine2 {get;set;}
        public String AddressLine3 {get;set;}
        public String AddressLine4 {get;set;}
        public String City {get;set;}
        public String County {get;set;}
        public String Country {get;set;}// Mandatory
        public String PostalCode {get;set;}// Mandatory
        public String PhoneMobile {get;set;}
        public String PhoneHome {get;set;}
        public String EmailAddress {get;set;}
        public String CompanyName {get;set;}
        public String RowId {get;set;}
        public String CaseNumber {get;set;}// Mandatory
        public String SRCreatedDate {get;set;}// Mandatory
        public String SRClosedDate {get;set;}// Mandatory
        public String Owner {get;set;}// Mandatory
        public String ClosedBy {get;set;}// Mandatory
        public String Type {get;set;}
        public String PrimaryReasonCode {get;set;}
        public String SecondaryReasonCode {get;set;}
        public String ConcernAreaCode {get;set;}
        public String SymptomCode {get;set;}
        public String NoOfSelectedContacts {get;set;}
        public String Rule1 {get;set;}
        public String Rule2 {get;set;}
        public String C05 {get;set;}
        public String C07 {get;set;}
        public String C15 {get;set;}
        public String T06 {get;set;}
        public String T08 {get;set;}
        public String T13 {get;set;}
        public String Rule5 {get;set;}
        public String Rule6 {get;set;}
        public String Rule7a {get;set;}
        public String Rule7b {get;set;}
        public String Rule8 {get;set;} 
        public String COMPLETE_SUPPRESSION {get;set;}
        public String SUPPRESSION_EMAIL {get;set;}
        public String SUPPRESSION_PHONE {get;set;}
        public String SUPPRESSION_MAIL {get;set;}
        public String caseRecTypeName {get;set;}
        
        private string enclose(string item) {
            return item;
            //return '"' + item + '"';
        }
        
        public TransformData(Case c, string periodStart, string periodEnd, Map<id, List<ContactPointTypeConsent>> consentMap) {
            
            system.debug('processing @@@'+c);
            
            StringUtil su = new StringUtil();
            
            String countryCode = '';
            if (c.country_iso_code__c!=null && c.country_iso_code__c != '' ) {
                countryCode = c.country_iso_code__c;
            } else if (c.AccountId!=null && c.Account.country_iso_code__c!=null && c.Account.country_iso_code__c != '') {
                countryCode = c.Account.country_iso_code__c;
            } else if (c.Contactid!=null && c.Contact.country_iso_code__c!=null && c.Contact.country_iso_code__c!= '' ) {
                countryCode = c.Contact.country_iso_code__c;
            } else if (c.Owner.Type == 'User' && Limits.getQueries() < 100) { 
                countryCode = [select Country_ISO_Code__c from user where id = : c.OwnerId].Country_ISO_Code__c;
            }
            CRCCode = enclose(su.isoCountryCode3(countryCode));
            MarketCode = CRCCode;
            
            if (c.Brand__c == 'Land Rover') {
                BrandCode = 'L';
            } else if (c.Brand__c == 'Jaguar') {
                BrandCode = 'J';
            } else {
                BrandCode = '';
            }
            BrandCode = enclose(BrandCode);
            RunDateofExtract = enclose(System.Now().format('dd/MM/yyyy'));
            ExtractFromDate = enclose(periodStart); //RunDateofExtract;
            ExtractToDate = enclose(periodEnd); //RunDateofExtract;
            if (c.Contactid!=null) {
                ContactId = String.ValueOf(c.Contactid); 
            }
            ContactId = enclose(ContactId);
            String langaugeDescription;
            if (c.AccountId!=null && c.Account.Language__pc!=null) {
                langaugeDescription = c.Account.Language__pc;
            } else if (c.Contactid!=null && c.Contact.Language__c!=null) {
                langaugeDescription = c.Contact.Language__c;
            } else {
                langaugeDescription = ''; //lookup based on country
            }
            CustomerLanguageCode = enclose(su.isoLangCode2(langaugeDescription));
            UniqueCustomerId = enclose((c.AccountId!=null?String.Valueof(c.AccountId):''));
            if (c.AssetId!=null) {
                AssetId = String.ValueOf(c.Assetid);
                VehicleRegNumber = c.Asset.Registration_Number__c;
                VIN = c.Asset.Name;
                VehicleModel = c.Asset.Model__r.Derivative__r.name;
                VehicleDerivative = c.Asset.Model__r.name;
                VehicleMileage = String.ValueOf(c.Asset.Mileage__c);
                VehicleMonthsinService = '';
            } 
            
            if (c.Accountid!=null && c.Account.Salutation!=null) {
                CustomerTitle = c.Account.Salutation;
            } else if (c.Contactid!=null) {
                CustomerTitle = c.Contact.Salutation;
            }
            CustomerTitle = enclose(CustomerTitle);
            if (c.Accountid!=null && c.Account.Firstname!=null) {
                CustomerInitial = c.Account.Firstname.left(1);
            } else if (c.ContactId!=null && c.Contact.Firstname!=null) {
                CustomerInitial = c.Contact.Firstname.left(1);
            }
            CustomerInitial = enclose(CustomerInitial);
            if (c.Accountid!=null && c.Account.isPersonAccount) {
                CustomerFirstName = c.Account.Firstname;
                CustomerLastName = c.Account.Lastname;
                AddressLine1 = c.Account.PersonMailingStreet;
                AddressLine2 = c.Account.PersonMailingState;
                AddressLine3 = c.Account.PersonMailingCity;
                AddressLine4 = c.Account.PersonMailingPostalCode;
                City = c.Account.PersonMailingCity;
                County = '';
                Country = c.Account.PersonMailingCountry;
                PostalCode = c.Account.PersonMailingPostalCode;
                PhoneMobile = c.Account.PersonMobilePhone;
                PhoneHome = c.Account.Phone;
                EmailAddress = c.Account.PersonEmail;
                CompanyName = '';
            } 
            if (c.ContactId!=null) {
                CustomerFirstName = (String.isEmpty(CustomerFirstName)?c.Contact.Firstname:CustomerFirstName);
                CustomerLastName = (String.isEmpty(CustomerLastName)?c.Contact.Lastname:CustomerLastName);
                AddressLine1 = (String.isEmpty(AddressLine1)?c.Contact.MailingStreet:AddressLine1);
                AddressLine2 = (String.isEmpty(AddressLine2)?c.Contact.MailingState:AddressLine2);
                AddressLine3 = (String.isEmpty(AddressLine3)?c.Contact.MailingCity:AddressLine3);
                AddressLine4 = (String.isEmpty(AddressLine4)?c.Contact.MailingPostalCode:AddressLine4);
                City = (String.isEmpty(City)?c.Contact.MailingCity:City);
                County = '';
                Country = (String.isEmpty(Country)?c.Contact.MailingCountry:Country);
                PostalCode = (String.isEmpty(PostalCode)?c.Contact.MailingPostalCode:PostalCode);
                PhoneMobile = (String.isEmpty(PhoneMobile)?c.Contact.MobilePhone:PhoneMobile);
                PhoneHome = (String.isEmpty(PhoneHome)?c.Contact.Phone:PhoneHome);
                EmailAddress = (String.isEmpty(EmailAddress)?c.Contact.Email:EmailAddress);
                CompanyName = (String.isEmpty(CompanyName)?c.Contact.Account.Name:CompanyName);
            }
            AssetId = enclose(AssetId);
            VehicleRegNumber = enclose(VehicleRegNumber);
            VIN = enclose(VIN);
            VehicleModel = enclose(VehicleModel);
            VehicleDerivative = enclose(VehicleDerivative);
            VehicleMileage = enclose(VehicleMileage);
            VehicleMonthsinService = enclose(VehicleMonthsinService);
            
            CustomerFirstName = enclose(CustomerFirstName);
            CustomerLastName = enclose(CustomerLastName);
            AddressLine1 = enclose(AddressLine1);
            AddressLine2 = enclose(AddressLine2);
            AddressLine3 = enclose(AddressLine3);
            AddressLine4 = enclose(AddressLine4);
            City = enclose(City);
            County = enclose(County);
            Country = enclose(Country);
            PostalCode = enclose(PostalCode);
            PhoneMobile = enclose(PhoneMobile);
            PhoneHome = enclose(PhoneHome);
            EmailAddress = enclose(EmailAddress);
            CompanyName = enclose(CompanyName);
            
            RowId = enclose('');
            CaseNumber = enclose(c.CaseNumber);
            SRCreatedDate = enclose(c.CreatedDate.format('dd/MM/yyyy'));
            SRClosedDate = enclose(c.Solved_Date__c.format('dd/MM/yyyy'));
            Owner = enclose(c.Owner.Firstname + ' ' + c.Owner.Lastname); 
            if (c.Solved_By__c != null) { 
                ClosedBy = enclose(c.Solved_By__r.Firstname + ' ' + c.Solved_by__r.Lastname);
            } else {
                ClosedBy = enclose(c.LastModifiedBy.Firstname + ' ' + c.LastModifiedBy.Lastname);
            }
            Type = enclose('');
            PrimaryReasonCode = enclose('');
            SecondaryReasonCode = enclose('');
            ConcernAreaCode = enclose('');
            SymptomCode = enclose('');
            NoOfSelectedContacts = enclose('');
            Rule1 = enclose('');
            Rule2 = enclose('');
            C05 = enclose('');
            C07 = enclose('');
            C15 = enclose('');
            T06 = enclose('');
            T08 = enclose('');
            T13 = enclose('');
            Rule5 = enclose('');
            Rule6 = enclose('');
            Rule7a = enclose('');
            Rule7b = enclose('');
            Rule8 = enclose('');
            caseRecTypeName=c.RecordType.Name;
            
            if(countryCode=='JP')
            CustomerTitle='';
            
            Map<String,Boolean> Suppressions = ConsentHandler.SuppressionsForCase(c, consentMap, c.Brand__c);
            
            COMPLETE_SUPPRESSION = enclose( (Suppressions.get('OPTOUT_GLOBAL')?'Yes':'No') ); 
            
            if ( COMPLETE_SUPPRESSION == 'Yes' ) {
                SUPPRESSION_EMAIL = enclose('');
                SUPPRESSION_PHONE = enclose('');
                SUPPRESSION_MAIL = enclose('');
            } else {
                SUPPRESSION_EMAIL = enclose( (Suppressions.get('OPTOUT_EMAIL')?'Yes':'No') );
                SUPPRESSION_PHONE = enclose( (Suppressions.get('OPTOUT_PHONE')?'Yes':'No') );
                SUPPRESSION_MAIL = enclose( (Suppressions.get('OPTOUT_DIRECTMAIL')?'Yes':'No') );            
            }
            
        }
        
    }
    
}