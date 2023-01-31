global class Batch_CVoiceAPurchaseExport implements Schedulable, Database.Batchable<sObject>, database.Stateful 
{
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Batch_CVoiceAPurchaseExport(), 200);
    } 
    
    Id PurchaseRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Purchase').getRecordTypeId();
    Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('Asset_Batch');
    list<string> MinaMarketsLst;
        
    global Database.QueryLocator start(Database.BatchableContext BC) {  
        String query;
        String periodStart;
        String periodEnd;
        
     	MinaMarketsLst= system.label.IMS_BATCH_MENA_MARKET.split(';');
		        
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
       
        //chnages for CXPD-1487
        // LIST<Account> acntid =[select id from Account];
        //SObject WhatIdObj = event.WhatId;
        DtPeriodStart = DtPeriodStart.addMonths(-1);
        
        system.debug('sStartDate' + sStartDate);
        system.debug('sEnddate' + sEnddate);
        //chnages for CXPD-1487
        query = 'SELECT ';
        //OPPORTUNITY FIELDS
        query += 'Id, apo__c, Brand__r.Name, Handover_Date__c, VIN__c,Survey__c, Vehicle_Initial_Registration_Date__c, Model__r.Name, Model_Year__c, Registration_Number__c, New_or_Used__c, SalesPersonCode__c, Salesperson_Dealer_Code__c, Salesperson_Dealer_Code2__c, SalesPersonName__c, Account.IsPersonAccount,Common_Sale_Type__c, Sale_Type_Code__c, Type_Of_Sale_ID__c, ';
        
        //BUSINESS ACCOUNT FIELDS
        query += 'AccountId, Account.country_iso_code__c, Account.Dealer_CI_Code__c, Account.Dealer_CI_Code_2__c,'; 
        query += 'Account.Name, Account.recordtype.developername, Account.Phone,Account.BillingStreet, Account.BillingCity,Account.Retailer_Email__c,';
        query += 'Account.BillingPostalCode, Account.BillingCountry, Account.Key_Contact__c, ';
        
        //PERSON ACCOUNT FIELDS
        query += 'Account.FirstName,Account.LastName, Account.Country_iso_code__pc, Account.Owner.Country_iso_code__c, ';
        query += 'Account.PersonTitle, Account.Salutation, Account.personmailingstreet, Account.personmailingcity, Account.personmailingstate,';
        query += 'Account.personmailingpostalcode, Account.personmailingcountry, Account.personmobilephone, Account.personemail,';
        query += 'Account.PersonHomePhone, Account.Language__pc, Account.PersonBirthdate, Account.Gender__pc,';

        //INDIVIDUAL
        query += 'Account.PersonIndividualId';
                
        string countryCodeSerial= '\''+string.join(MinaMarketsLst, '\',\'')+'\''; 
        
        //FILTERS
        query += ' FROM Asset';    
        query += ' WHERE';    
        query += ' Handover_Date__c >=' + sStartDate +' AND Handover_Date__c <='+sEnddate;
        query += ' AND Account.RecordTypeId IN (' + String.join(PersonAccountRTids,',') + ') '; 
        query +=' AND ( Account.Country_iso_code__c IN ('+countryCodeSerial+') OR Account.Country_iso_code__pc IN ('+countryCodeSerial+') OR  Account.owner.Country_iso_code__c IN ('+countryCodeSerial+') )';
        //query +=' AND Id NOT IN:assetIdLst'; //Changes added  for cxpd-1487
        if (Test.isRunningTest()) {
            System.Assert(Database.query(query).size()>0, 'Opportunity query in AssetBatch contructor finds no records for test. Please check query: ' + query );
        }
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Asset Batch'];
        if (!Test.isRunningTest()) {
            delete allRows;
        } else {
            system.assertEquals(0,allRows.size(),'Gfk_Sales_Export__c object expected to be empty but was not.');
        }
 
        return database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext BC, List<Asset> AssetLst) 
    {
        system.debug('AssetLst @@@'+AssetLst);
        
        String periodStart;
        String periodEnd;
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c));
        Date endDate = System.today()-1;
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 
        
        set<Id> accountIdSetForCon = New set<Id>();
        set<Id> AssetIdSet = New set<Id>();
        Map<Id, Id> individualIdMap = New Map<Id, Id>();
        
        
        for(Asset Ast : AssetLst){
            AssetIdSet.add(Ast.Id);
            if(Ast.Account.recordtype.developername=='Corporate') accountIdSetForCon.add(Ast.AccountId);
            if(Ast.Account.recordtype.developername!='Corporate') individualIdMap.put(ASt.AccountId, ASt.Account.PersonIndividualId);
        }
        
        for (Account corporateAcc : [select Id, Key_Contact__c, Key_Contact__r.IndividualId, (select Id, IndividualId from contacts limit 1) from Account where ID IN :accountIdSetForCon]) {
            if (corporateAcc.Key_Contact__c != null) individualIdMap.put(corporateAcc.Id, corporateAcc.Key_Contact__r.IndividualId);
            if (corporateAcc.Key_Contact__c == null && !corporateAcc.contacts.isEmpty()) individualIdMap.put(corporateAcc.Id, corporateAcc.contacts[0].IndividualId);
        }

        Set<Id> allIndividualIdSet = new Set<Id>();
        allIndividualIdSet.addAll(individualIdMap.values());

        Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.CXP_Name__c, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :allIndividualIdSet]) {
            List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
            if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
            consentList.add(cptc);
            consentMap.put(cptc.PartyId, consentList);
        }
        
        Map<Id, opportunity> assetOpportunityMap = New Map<Id,opportunity>(); 
        
        for(opportunity opp:[select id, ownerid, Owner.Name, (select Id, Asset__c from OpportunityLineItems where Asset__c IN :AssetIdSet limit 1) from opportunity where ID In (select opportunityId from OpportunityLineItem where Asset__c IN :AssetIdSet)])
        {
            assetOpportunityMap.put(opp.OpportunityLineItems[0].Asset__c, opp);
        }
        
        List<gfkObjectModel> output = new List<gfkObjectModel>();
        for(Asset Ast : AssetLst){
            gfkObjectModel temp = gfkProcessQuery(Ast, periodStart, periodEnd, individualIdMap, consentMap, assetOpportunityMap);
            system.debug('temp.SalesEventDate'+temp?.SalesEventDate);
            if (temp!=null && ((temp.SalesEventDate !=null && temp.SalesEventDate !='' && string.isNotBlank(temp.SalesEventDate) && string.isNotEmpty(temp.SalesEventDate) && date.parse(temp.SalesEventDate)>=startDate && date.parse(temp.SalesEventDate) <=endDate) || test.isRunningTest()) )
                output.add(temp);
        }
        system.debug('output @@@'+output);
        if(!output.isEmpty())
        {
            Set<Id> processedRecIds = new Set<Id>();//CXPD-2305
            List<cVoice_Survey__c> gfkSalesExData = new List<cVoice_Survey__c>();
            for(gfkObjectModel line : output){
                processedRecIds.add(line.OpportunityId);//CXPD-2305
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
                    Sales_Event_Date__c = line.SalesEventDate,
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
                    Sales_Employee_Code__c = line.EmployeeCode,
                    Employee_Name__c = line.EmployeeName,
                    Ownership_Cycle__c = '1', 
                    Gender__c = line.Gender,
                    Private_Owner__c = line.PrivateOwner,
                    Owning_Company__c = line.OwningCompany, 
                    User_Chooser_Or_Driver__c = line.UserChooserDriver, 
                    Employer_Company__c = line.EmployerCompany,
                    Month_and_Year_of_Birth__c = line.DateofBirth,
                    Preferred_Methods_of_Contact__c = line.PrefMethodsOfContact,
                    Permissions_for_Contact__c = line.PermissionsForContact,
                    recordTypeId=PurchaseRecId,
                    Source_Object__c='Asset',
                    Process_Name__c='Asset Batch',
                    Common_Sale_Type__c = line.CommonSaleType ,
                    Sale_Type_Code__c = line.SaleTypeCode,
                    Type_Of_Sale_ID__c=line.TypeOfSaleID
                    
                ));
            }
            system.debug('AssetLst @@@'+gfkSalesExData);
            Insert gfkSalesExData;
            
            //CXPD-2305 changes begin
            List<Event> eventList1= new List<Event>();
            Datetime eventStartPeriod = DateTime.now().addMonths(-2);
            eventList1 = [SELECT Id, VIN_Number__c FROM Event WHERE VIN_number__c !=null AND What.Type IN ('Account') And CreatedDate >= :eventStartPeriod And 
                          Subject like '%Purch Cvoice Survey sent for VIN%'];
            List<Event> newEventList=new List<Event>();
            Set<Id> eventAssetIds= new Set<Id>();
            if(!eventList1.isEmpty()){
                for(Event event: eventList1){
                    eventAssetIds.add(event.VIN_Number__c);
                }
            }
            for(Asset asst: AssetLst){
                if(processedRecIds!=NULL && !processedRecIds.contains(asst.Id)) continue;
                if(eventAssetIds!=NULL && eventAssetIds.contains(asst.Id)) continue;
                Event event = new Event();
                event.ActivityDateTime = DateTime.now();
                event.DurationInMinutes= 1;
                event.WhatId = asst.AccountId;
                event.VIN_number__c= asst.Id;
                event.Description ='Purch Cvoice Survey sent for VIN: '+ asst.VIN__c; //Name
                event.Subject= 'Purch Cvoice Survey sent for VIN: '+ asst.VIN__c;
                newEventList.add(event);
            }
            if(!newEventList.isEmpty())insert newEventList;
            //CXPD-2305 changes end
        }
    }
    
    
    global void finish(Database.BatchableContext BC) 
    {
    }
    
    private gfkObjectModel gfkProcessQuery(Asset o, string periodStart2, string periodEnd2, Map<Id, Id> individualIdMap, Map<id, List<ContactPointTypeConsent>> consentMap, Map<Id, opportunity> assetOpportunityMap){
                        
        gfkObjectModel gfkModel = new gfkObjectModel();
        StringUtil su = new StringUtil();
        
        gfkModel.OpportunityId = o.Id;
        
        gfkModel.EventType = '1';
        
        gfkModel.CustomerUniqueId = o.AccountId; 
        gfkModel.CompanyName = o.Account.Name;
        //gfkModel.EmployeeCode = o.Owner.Name;
        //gfkModel.EmployeeName = o.Owner.Name;
        
            if(o.Brand__r != null && o.Brand__r.Name != null)
                gfkModel.Manufacturer  = o.Brand__r.Name;
            
            if(o.Vehicle_Initial_Registration_Date__c != null )       
                gfkModel.VehicleRegistrationDate = o.Vehicle_Initial_Registration_Date__c.format();
            
            if(o.Handover_Date__c != null){
                gfkModel.VehicleDeliveryDate = o.Handover_Date__c.format();
                gfkModel.SalesEventDate = o.Handover_Date__c.format();
            }
            
            if(o.Model__c != null){
                gfkModel.ModelName = o.Model__r.Name;
            }
                gfkModel.ModelYear = o.Model_Year__c;
                gfkModel.VIN = o.VIN__c;
                gfkModel.RegNumber = o.Registration_Number__c;

        String countryCode = '';
        //CXPD-1446
        gfkModel.DealerCode=gfkModel.Manufacturer=='Jaguar' ? o.Salesperson_Dealer_Code__c : o.Salesperson_Dealer_Code2__c;
        gfkModel.EmployeeCode = o.SalesPersonCode__c;
        gfkModel.EmployeeName = o.SalesPersonName__c;
        
        //CXPD-1983
        gfkModel.CommonSaleType = o.Common_Sale_Type__c;
        gfkModel.SaleTypeCode = o.Sale_Type_Code__c;
        gfkModel.TypeOfSaleID = o.Type_Of_Sale_ID__c;
        
        
        //gfkModel.DealerCode=o.Initial_Sales_Person_Code__c;
        If(o.Account.recordtype.developername == 'Corporate'){
            /*if (o.PartnerAccount.Dealer_CI_Code__c != null && gfkModel.Manufacturer=='Jaguar'){
                gfkModel.DealerCode = o.PartnerAccount.Dealer_CI_Code__c;
            }else if(o.PartnerAccount.Dealer_CI_Code_2__c != null && gfkModel.Manufacturer=='Land Rover'){
                gfkModel.DealerCode = o.PartnerAccount.Dealer_CI_Code_2__c;
            }else{
                gfkModel.DealerCode = '';
            }*/
            
            
            
           //gfkModel.PreferredLanguage = ocr.Contact.Language__c;
                //gfkModel.Gender = ocr.Contact.Gender__c;
                

                
            if(o.Account.Country_ISO_Code__c != null){
                countryCode = o.Account.Country_ISO_Code__c ;
            }
                
            gfkModel.Address1 = o.Account.BillingStreet;
            gfkModel.Address5 = o.Account.BillingCity;
            gfkModel.Address7 = o.Account.BillingPostalCode;
            gfkModel.Address8 = o.Account.BillingCountry;
            
            gfkModel.HomeTelephoneNumber = o.Account.Phone;
            gfkModel.EmailAddress2 = o.Account.Retailer_Email__c;
            
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
                /*if(o.account.Owner.Contact.Account.Dealer_CI_Code__c != null && gfkModel.Manufacturer=='Jaguar'){
                    gfkModel.DealerCode = o.Account.Owner.Contact.Account.Dealer_CI_Code__c;
                }else if(o.account.Owner.Contact.Account.Dealer_CI_Code_2__c != null && gfkModel.Manufacturer=='Land Rover'){
                    gfkModel.DealerCode = o.Account.Owner.Contact.Account.Dealer_CI_Code_2__c;
                }else{
                    gfkModel.DealerCode = '';
                }*/
                gfkModel.Title = o.Account.PersonTitle;
                gfkModel.FirstName = o.Account.Firstname;
                gfkModel.Surname1 = o.Account.LastName;
                gfkModel.Salutation = o.Account.Salutation;
                gfkModel.Address1 = o.Account.PersonMailingStreet;
                gfkModel.Address5 = o.Account.PersonMailingCity;
                gfkModel.Address7 = o.Account.PersonMailingPostalCode;
                gfkModel.Address8 = o.Account.PersonMailingCountry;
                gfkModel.HomeTelephoneNumber = o.Account.PersonHomePhone;
                gfkModel.BusinessTelephoneNumber = o.Account.PersonMobilePhone;
                gfkModel.EmailAddress1 = o.Account.PersonEmail;
                gfkModel.PreferredLanguage = o.Account.Language__pc;
                gfkModel.Gender = o.Account.Gender__pc;
                if(o.Account.PersonBirthdate!= null){
                    gfkModel.DateofBirth = o.Account.PersonBirthdate.format();
                    gfkModel.DateofBirth = gfkModel.DateofBirth.substring(3);
                }
                else{
                    gfkModel.DateofBirth = '';
                }
                
            }
        }
        
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