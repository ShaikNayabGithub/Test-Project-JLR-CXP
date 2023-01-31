global class Batch_CVoiceLostOpportunityExport_MENA implements Schedulable, Database.Batchable<sObject>, database.Stateful {
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_CVoiceLostOpportunityExport_MENA(), 200);
    } 
    
    Id LostOppRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Lost Opportunity').getRecordTypeId();
    Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('Lost_Opportunity_Batch_MENA');
    list<string> MinaMarketsLst;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        String periodStart;
        String periodEnd;
        
        MinaMarketsLst= system.label.Batch_cVoice_LostOpportunity_Country_MENA.split(';'); 
        string countryCodeSerial= '\''+string.join(MinaMarketsLst, '\',\'')+'\''; 
        
        Date endDate = System.today()-21;
        if(test.isRunningTest()) endDate=System.today();
        Date startDate = endDate.addDays(-integer.valueOf(numberOfDays.Days__c));
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
       
        query = 'SELECT ';
        //OPPORTUNITY FIELDS
        query += 'Id,Owner.name,Date_Lost__c,DB_Created_Date_without_Time__c,Primary_Model_Interest__r.Name, asset__c, asset__r.apo__c, Brand__r.Name, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Date_to_Order_Stage_Time__c,CloseDate, Asset__r.Brand__r.Name, Handover_Date__c, Asset__r.VIN__c, Sub_Type__c, Purchase_Type__c, StageName, Agency_Loss_Category__c, Agency_Loss_Type__c, ';
        
        //BUSINESS ACCOUNT FIELDS
        query += 'AccountId,PartnerAccountId, Account.country_iso_code__c, Account.Dealer_CI_Code__c, Account.Dealer_CI_Code_2__c,Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c, Account.Preferred_Sales_Retailer__r.Dealer_CI_Code_2__c,'; 
        query += 'Account.Name, Account.recordtype.developername, Account.Phone,Account.BillingStreet, Account.BillingCity,Account.Retailer_Email__c,';
        query += 'Account.BillingPostalCode, Account.BillingCountry, PartnerAccount.Dealer_CI_Code__c, PartnerAccount.Dealer_CI_Code_2__c,';
        
        //PERSON ACCOUNT FIELDS
        query += 'Account.FirstName,Account.LastName, Account.Country_iso_code__pc, Account.Owner.Country_iso_code__c ,Account.Owner.Contact.Account.Dealer_CI_Code__c, Account.Owner.Contact.Account.Dealer_CI_Code_2__c, ';
        query += 'Account.PersonTitle, Account.Salutation, Account.personmailingstreet, Account.personmailingcity, Account.personmailingstate,';
        query += 'Account.personmailingpostalcode, Account.personmailingcountry, Account.personmobilephone, Account.personemail,';
        query += 'Account.PersonHomePhone, Account.Language__pc, Account.PersonBirthdate, Account.Gender__pc, ';

        //PERSON ACCOUNT SUPPRESSION FIELDS
        query += 'Account.PersonIndividualId,Account.Retailer_Id__c, ';
        
        //OPPORTUNITY LINE ITEM FIELDS
        query += '(Select OpportunityLineItem.Brand__r.Name, OpportunityLineItem.Asset__r.APO__c, Opportunitylineitem.Model__r.Name, Opportunitylineitem.Asset__r.VIN__c,';
        query += 'Opportunitylineitem.Asset__r.Model__r.Name, Opportunitylineitem.Asset__r.Model_Year__c, Opportunitylineitem.Asset__r.Registration_Number__c,';
        query += 'Opportunitylineitem.Asset__r.Vehicle_Initial_Registration_Date__c, Opportunitylineitem.Asset__r.Handover_Date__c ';
        query += 'from OpportunityLineItems Where OpportunityLineItem.Id != Null),';
        
        //OPPORTUNITY CONTACT ROLES FIELDS
        query += '(Select contact.country_iso_code__c,ContactId, Contact.IndividualId, Contact.Gender__c, Contact.Language__c, Contact.Email, Contact.Email2__c,';
        query += 'Contact.Birthdate, Contact.Firstname, Contact.Lastname, Contact.MailingStreet, Contact.MailingCity, Contact.MailingPostalCode, Contact.MailingCountry, Contact.HomePhone, Contact.MobilePhone from OpportunityContactRoles),';
        
        //OPPORTUNITY ACTIVITYHISTORY FIELDS
        query +='(select LastModifiedDate from ActivityHistories ORDER BY LastModifiedDate desc LIMIT 1)';
        
        
        //FILTERS
        query += ' FROM Opportunity';    
        query += ' WHERE';    
        //query += ' Date_Lost__c >=' + sStartDate +' AND Date_Lost__c <='+sEnddate;
        query += ' (Date_Lost__c >=' + sStartDate +' AND Date_Lost__c <='+sEnddate+ 'AND (StageName = \'Lost\') AND (Agency_Loss_Category__c=\'Other\') AND (Agency_Loss_Type__c=\'Unable to Contact\')) ';
        //if(!opportunityIdLst.isEmpty())
        //query += ' OR ID IN (' + String.join(opportunityIdLst,',') + ') )';
        query += 'AND Account.RecordTypeId IN (' + String.join(PersonAccountRTids,',') + ') '; 
        query +=' AND ( Account.Country_iso_code__c IN ('+countryCodeSerial+') OR Account.Country_iso_code__pc IN ('+countryCodeSerial+') OR  Account.owner.Country_iso_code__c IN ('+countryCodeSerial+') )';
        
        
        if (Test.isRunningTest()) {
           //System.Assert(Database.query(query).size()>0, 'Opportunity query in GfKSalesBatchExport contructor finds no records for test. Please check query: ' + query );
        }
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Lost Opportunity Mena'];
        if (!Test.isRunningTest()) {
           delete allRows;
        } else {
           system.assertEquals(0,allRows.size(),'Gfk_Sales_Export__c object expected to be empty but was not.');
        }
        Database.QueryLocator oppList = database.getQueryLocator(query);
        //System.debug('oppList.size(): '+oppList.size());
        System.debug('oppList: '+oppList);
        system.debug('database.getQueryLocator(query)' + database.getQueryLocator(query));
        return database.getQueryLocator(query);
        
    }
        
    global void execute(Database.BatchableContext BC, List<Opportunity> GfKlostOpportunities) 
    {
       // system.debug('lostOpportunities @@@'+GfKlostOpportunities);    
        String periodStart;
        String periodEnd;
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c));
        Date endDate = System.today()-1;
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        Map<Id, Id> individualIdMap = New Map<Id, Id>();
       Set<Id> ReatilerIdSet = new Set<Id>(); //supression 
        for(Opportunity o : GfKlostOpportunities){
            If(o.Account.Retailer_Id__c != null) ReatilerIdSet.add(o.Account.Retailer_Id__c);
            //if (o.OpportunityLineItems.isEmpty()) continue;

            for(OpportunityContactRole ocr : o.OpportunityContactRoles) {
            if (ocr.ContactId != null) individualIdMap.put(ocr.ContactId, ocr.Contact.IndividualId);
            }
            
             if (o.AccountId != null) individualIdMap.put(o.AccountId, o.Account.PersonIndividualId);
        }
        
        Set<Id> allIndividualIdSet = new Set<Id>();
        allIndividualIdSet.addAll(individualIdMap.values());
        // system.debug('@@allIndividualIdSet' + allIndividualIdSet);
        
       /////////////// 
        Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
        List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c 
                                             from ContactPointTypeConsent Where DataUsePurpose.Translatable_Value__c = 'Surveys and Research'AND PartyId in :allIndividualIdSet AND Retailer__c IN: ReatilerIdSet]) {
            
            
            //Boolean allSurveyOptOut = true;
            if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
            
            consentList.add(cptc);
            consentMap.put(cptc.PartyId, consentList);
                                               
        }
      // system.debug('@@consentMap' + consentMap);   
        ////////////
        
        List<gfkObjectModel> output = new List<gfkObjectModel>();
        for(Opportunity o : GfKlostOpportunities){
            system.debug('OpportunityLineItems @@@'+o.OpportunityLineItems);
           // if (o.OpportunityLineItems.isEmpty()) continue;
            gfkObjectModel temp = gfkProcessQuery(o, periodStart, periodEnd, consentMap);
           // system.debug('temp'+temp);
            //system.debug('temp.SalesEventDate'+temp.SalesEventDate);
            
           // if (temp!=null && ((temp.SalesEventDate !=null && temp.SalesEventDate !='' && string.isNotBlank(temp.SalesEventDate) && string.isNotEmpty(temp.SalesEventDate) && date.parse(temp.SalesEventDate)>=startDate && date.parse(temp.SalesEventDate) <=endDate) ) ) //|| test.isRunningTest()
                output.add(temp);
        }
        system.debug('output @@@'+output);
        //if(output.isEmpty()) return null;
        /////
        
        List<cVoice_Survey__c> gfkSalesExData = new List<cVoice_Survey__c>();
        for(gfkObjectModel line : output){
            gfkSalesExData.add(new cVoice_Survey__c(
                Opportunity_Id__c = line.OpportunityId,
                Manufacturer__c = line.Manufacturer,
                Country_Code__c = line.CountryCode, 
                Event_Type__c = line.EventType,
                Dealer_Code__c = line.DealerCode,
                Customer_Unique_ID__c = line.CustomerUniqueId,
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
                //Model_Name__c = line.ModelName, 
                Model_Year__c = line.ModelYear, 
                //VIN__c = line.VIN, 
               // Registration_Number__c = line.RegNumber,
                Email_Address_1__c = line.EmailAddress1,
                Email_Address_2__c = line.EmailAddress2,
                Preferred_Language__c = line.PreferredLanguage,
                Complete_Suppression__c = line.CompleteSupression, 
                Suppression_Email__c = line.SupressionEmail,
                Suppression_Phone__c = line.SupressionPhone,
                Suppression_Mail__c = line.SupressionMail,
                Employee_Name__c = line.EmployeeName,
                Gender__c = line.Gender,
                Permissions_for_Contact__c = line.PermissionsForContact,
                recordTypeId= LostOppRecId,
                Source_Object__c='Opportunity',
                DATE_OF_LEAD_CREATION__c = line.DATEOFLEADCREATION,
                DATE_MARKED_AS_LOST_LEAD__c= line.DATEMARKEDASLOSTLEAD,
                DATE_OF_LAST_CONTACT__c = line.DATEOFLASTCONTACT,
                MARKETING_PERMISSION__c = line.MARKETINGPERMISSION,
                MODEL_OF_INTEREST__c = line.MODELOFINTEREST,
                Process_Name__c='Lost Opportunity Mena'
               // APPROVED__c=line.APPROVED
            ));
        }
        system.debug('gfkSalesExData @@@'+gfkSalesExData);
        Insert gfkSalesExData;
    
        }
        
    global void finish(Database.BatchableContext BC){
    }
    
    private gfkObjectModel gfkProcessQuery(Opportunity o, string periodStart2, string periodEnd2, Map<id, List<ContactPointTypeConsent>> consentMap){
        gfkObjectModel gfkModel = new gfkObjectModel();
        StringUtil su = new StringUtil();
        
        gfkModel.OpportunityId = o.Id;
        gfkModel.CustomerUniqueId = o.AccountId; 
        gfkModel.EmployeeName = o.Owner.Name;
        gfkModel.CompanyName = o.Account.Name;
        gfkModel.MODELOFINTEREST =o.Primary_Model_Interest__r.Name;
        gfkModel.DATEOFLEADCREATION = o.DB_Created_Date_without_Time__c !=null ? o.DB_Created_Date_without_Time__c.format() : ''; 
        gfkModel.DATEMARKEDASLOSTLEAD = o.Date_Lost__c.format();
        if(!o.ActivityHistories.isEmpty()){
            for(ActivityHistory activity : o.ActivityHistories){
             gfkModel.DATEOFLASTCONTACT = activity.LastModifiedDate.format();
        }
        }
        else gfkModel.DATEOFLASTCONTACT ='';
        
       gfkModel.EventType = '1';
        if(o.OpportunityLineItems != null){
            for(OpportunityLineItem oli : o.OpportunityLineItems){
                if(oli.Brand__c != null && oli.Brand__r.Name != null){
                    gfkModel.Manufacturer  = oli.Brand__r.Name;
                }
                
                if(oli.Asset__c != null){
                    gfkModel.ModelYear = oli.Asset__r.Model_Year__c;
                    
                }else if(o.Asset__c != null){
                    gfkModel.ModelYear = o.Asset__r.Model_Year__c;
                    
                } 
            }  
        }
        
        if(gfkModel.Manufacturer == '' || gfkModel.Manufacturer ==null){
          if(o.Brand__c != null && o.Brand__r.Name != null){
                gfkModel.Manufacturer = o.Brand__r.Name;
            }else{
                gfkModel.Manufacturer = '';
            }  
        }
        
        
        String countryCode = '';
        If(o.Account.recordtype.developername == 'Corporate'){
         if(o.OpportunityContactRoles.isEmpty())
            {
                if(o.Account.Country_ISO_Code__c != null){
                    countryCode = o.Account.Country_ISO_Code__c ;
                }else if(o.Account.Country_ISO_Code__c == null){
                    countryCode = o.Account.Owner.Country_iso_code__c;
                }else{
                    countryCode = '';
                }
            }
            
            for(OpportunityContactRole ocr : o.OpportunityContactRoles){
              gfkModel.PreferredLanguage = ocr.Contact.Language__c;
              gfkModel.Gender = ocr.Contact.Gender__c;  
                
                
              if(o.Account.Country_ISO_Code__c != null){
                    countryCode = o.Account.Country_ISO_Code__c ;
                }else if(o.Account.Country_ISO_Code__c == null){
                    countryCode = ocr.Contact.Country_iso_code__c;
                }else if(ocr.Contact.Country_iso_code__c == null){
                    countryCode = o.Account.Owner.Country_iso_code__c;
                }else{
                    countryCode = '';
                }
                
              if(string.IsNotEmpty(gfkModel.PreferredLanguage) && string.IsNotEmpty(countrycode)) break;

            }
        
            gfkModel.Address1 = gfkModel.Address1==null ? o.Account.BillingStreet:gfkModel.Address1;
            gfkModel.Address5 = gfkModel.Address5==null ? o.Account.BillingCity:gfkModel.Address5;
            gfkModel.Address7 = gfkModel.Address7==null ? o.Account.BillingPostalCode:gfkModel.Address7;
            gfkModel.Address6 = gfkModel.Address6==null ? o.Account.BillingCountry:gfkModel.Address6;   
            
            gfkModel.HomeTelephoneNumber = gfkModel.HomeTelephoneNumber==null? o.Account.Phone:gfkModel.HomeTelephoneNumber;
            gfkModel.EmailAddress2 = o.Account.Retailer_Email__c != null? o.Account.Retailer_Email__c:gfkModel.EmailAddress2;
            
        }else{
            gfkModel.CompanyName = '';
            if(o.Account.recordtype.developername == 'Individual'){
                if(o.Account.Country_iso_code__pc != null){
                    countryCode = o.Account.Country_iso_code__pc;
                }else if(o.Account.Country_iso_code__pc == null){
                    countryCode = o.Account.Owner.Country_iso_code__c;
                }else{
                    countryCode = '';
                } 
                
                if(gfkModel.Manufacturer=='Jaguar' && o.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c!=NULL){
                    gfkModel.DealerCode = o.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c;
                }else if(gfkModel.Manufacturer=='Land Rover' && o.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code_2__c!=NULL){
                    gfkModel.DealerCode = o.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code_2__c;
                }else{
                    gfkModel.DealerCode = '';
                }
                
                gfkModel.Title = o.Account.PersonTitle;
                gfkModel.FirstName = o.Account.Firstname;
                gfkModel.Surname1 = o.Account.LastName;
                gfkModel.Salutation = o.Account.Salutation;
                gfkModel.Address1 = o.Account.PersonMailingStreet;
                gfkModel.Address5 = o.Account.PersonMailingCity;
                gfkModel.Address7 = o.Account.PersonMailingPostalCode;
                gfkModel.Address6 = o.Account.PersonMailingCountry;
                gfkModel.HomeTelephoneNumber = o.Account.PersonHomePhone;
                gfkModel.BusinessTelephoneNumber = o.Account.PersonMobilePhone;
                gfkModel.EmailAddress1 = o.Account.PersonEmail;
                gfkModel.PreferredLanguage = o.Account.Language__pc;
                gfkModel.Gender = o.Account.Gender__pc;

            }
        }
       gfkModel.CountryCode = countryCode;
       gfkModel.Surname2 = '';
       gfkModel.Address2 = '';
       gfkModel.Address3 = '';
       gfkModel.Address4 = '';
       gfkModel.Address8 = '';
        gfkModel.MARKETINGPERMISSION ='Yes';
        if(consentMap.containskey(o.Account.PersonIndividualId)){
            system.debug('@@@ENTRY');
            for(ContactPointTypeConsent cpt: consentMap.get(o.Account.PersonIndividualId)){
              gfkModel.MARKETINGPERMISSION =cpt.PrivacyConsentStatus=='OptOut'? 'No':'Yes';
               // system.debug('@@marketing perm value1' + gfkModel.MARKETINGPERMISSION);
              if(gfkModel.MARKETINGPERMISSION == 'No')
              break;
            }
        }else if(!o.OpportunityContactRoles.isEmpty()){
            for(OpportunityContactRole ocr : o.OpportunityContactRoles){
                if(consentMap.containskey(ocr.Contact.IndividualId)){
                for(ContactPointTypeConsent cpt: consentMap.get(ocr.Contact.IndividualId)){
              gfkModel.MARKETINGPERMISSION =cpt.PrivacyConsentStatus=='OptOut'? 'No':'Yes';
                  //  system.debug('@@marketing perm value2' + gfkModel.MARKETINGPERMISSION);
              if(gfkModel.MARKETINGPERMISSION == 'No')
              break;
            }  
                }
            }
        }
        /* else{
            gfkModel.MARKETINGPERMISSION ='No';
        }*/
       // system.debug('@@marketing perm value3' + gfkModel.MARKETINGPERMISSION);
      // system.debug('Manadatory @@@'+AreMandatoryFieldsPopulated(gfkModel));
       // system.debug('gfkModel@@@'+gfkModel);
       // if(AreMandatoryFieldsPopulated(gfkModel)){
            return gfkModel;

    }
    
   /* private Boolean AreMandatoryFieldsPopulated(gfkObjectModel model){
        List<CVoice_Required_Fields_per_Batch__mdt> gfkFields = [SELECT DeveloperName 
                                                                 FROM CVoice_Required_Fields_per_Batch__mdt 
                                                                 where Is_Active__c = True
                                                                 AND Process_Name__c='Lost Opportunity Batch'];
        for(CVoice_Required_Fields_per_Batch__mdt setting : gfkFields){
            String fieldValue = model.GetField(setting.DeveloperName);
            if(string.isBlank(fieldValue))
            {
                return false;
            }
            
        }
        return true;
    }*/
    
    public class gfkObjectModel {
        
        public string OpportunityId {get; set;}
        public String Manufacturer {get;set;}//
        public string CountryCode {get;set;}
        public string EventType {get;set;}
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
        //public String ModelName {get;set;}
        public String ModelYear {get;set;}
        public String EmailAddress1 {get;set;}
        public String EmailAddress2 {get;set;}
        public String PreferredLanguage {get;set;}
        public String CompleteSupression {get;set;}
        public String SupressionEmail {get;set;}
        public String SupressionPhone {get;set;}
        public String SupressionMail {get;set;}
       // public String InvoiceNumber {get;set;}
      //  public String InvoiceValue {get;set;}
       // public String EmployeeCode {get;set;}
        public String EmployeeName {get;set;}
        public String Gender {get;set;}
        public String PrefMethodsOfContact {get;set;}
        public String PermissionsForContact {get;set;}   
        public String DATEOFLEADCREATION {get;set;}
        public String DATEMARKEDASLOSTLEAD {get;set;}
        public String MARKETINGPERMISSION  {get;set;}
        public String DATEOFLASTCONTACT {get;set;}
        public String MODELOFINTEREST {get;set;}  	

       /* public string GetField(string field){
            String json_instance = Json.serialize(this);
            Map<String, Object> untyped_instance;
            untyped_instance= (Map<String, Object>)JSON.deserializeUntyped(json_instance);  
            Object fieldValue = untyped_instance.get(field);
            return string.valueOf(fieldValue);        
        }*/
    }
}