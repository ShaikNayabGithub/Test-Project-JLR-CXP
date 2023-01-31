public class GfkSalesBatchData {
    Id PurchaseRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Purchase').getRecordTypeId();
    Id PreownedRecId = Schema.SObjectType.cVoice_Survey__c.getRecordTypeInfosByName().get('Preowned').getRecordTypeId();
    Batch_Interval_Setting__mdt numberOfDays = Batch_Interval_Setting__mdt.getInstance('Opportunity_Batch');
    Map<Id,Id> oppAssetIdsMap = new Map<Id,Id>();//CXPD-2305
    
    public String gfKRetrieveOppData(){
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
       
        /*list<string> opportunityIdLst= new list<string>();
        
        for(opportunityLineItem oli:[select opportunityId from opportunityLineItem where Asset__r.Handover_Date__c >=:startDate AND Asset__r.Handover_Date__c <=:endDate])
        {
            if(!opportunityIdLst.contains('\''+oli.OpportunityId+'\''))
            opportunityIdLst.add('\''+oli.OpportunityId+'\'');
        }*/
        
        query = 'SELECT ';
        //OPPORTUNITY FIELDS
        query += 'Id,Owner.name, asset__c, asset__r.apo__c, Brand__r.Name, Dealer_CI_Code__c, Dealer_CI_Code_2__c, Date_to_Order_Stage_Time__c,CloseDate, Asset__r.Brand__r.Name, Handover_Date__c, Asset__r.VIN__c, Sub_Type__c, Purchase_Type__c, StageName, Asset__r.Common_Sale_Type__c, Asset__r.Sale_Type_Code__c, Asset__r.Type_Of_Sale_ID__c, ';
        
        //BUSINESS ACCOUNT FIELDS
        query += 'AccountId,PartnerAccountId, Account.country_iso_code__c, Account.Dealer_CI_Code__c, Account.Dealer_CI_Code_2__c,'; 
        query += 'Account.Name, Account.recordtype.developername, Account.Phone,Account.BillingStreet, Account.BillingCity,Account.Retailer_Email__c,';
        query += 'Account.BillingPostalCode, Account.BillingCountry, PartnerAccount.Dealer_CI_Code__c, PartnerAccount.Dealer_CI_Code_2__c,';
        
        //PERSON ACCOUNT FIELDS
        query += 'Account.FirstName,Account.LastName, Account.Country_iso_code__pc, Account.Owner.Country_iso_code__c ,Account.Owner.Contact.Account.Dealer_CI_Code__c, Account.Owner.Contact.Account.Dealer_CI_Code_2__c, ';
        query += 'Account.PersonTitle, Account.Salutation, Account.personmailingstreet, Account.personmailingcity, Account.personmailingstate,';
        query += 'Account.personmailingpostalcode, Account.personmailingcountry, Account.personmobilephone, Account.personemail,';
        query += 'Account.PersonHomePhone, Account.Language__pc, Account.PersonBirthdate, Account.Gender__pc,';

        //PERSON ACCOUNT SUPPRESSION FIELDS
        query += 'Account.PersonIndividualId, ';
        
        //OPPORTUNITY LINE ITEM FIELDS
        query += '(Select OpportunityLineItem.Brand__r.Name, OpportunityLineItem.Asset__r.APO__c, Opportunitylineitem.Model__r.Name, Opportunitylineitem.Asset__r.VIN__c,';
        query += 'Opportunitylineitem.Asset__r.Model__r.Name, Opportunitylineitem.Asset__r.Model_Year__c, Opportunitylineitem.Asset__r.Registration_Number__c,';
        query += 'Opportunitylineitem.Asset__r.Vehicle_Initial_Registration_Date__c, Opportunitylineitem.Asset__r.Handover_Date__c, Opportunitylineitem.Asset__r.Common_Sale_Type__c, Opportunitylineitem.Asset__r.Sale_Type_Code__c, Opportunitylineitem.Asset__r.Type_Of_Sale_ID__c ';
        query += 'from OpportunityLineItems Where (OpportunityLineItem.Id != Null) AND (Asset__c != Null)),';
        
        //OPPORTUNITY CONTACT ROLES FIELDS
        query += '(Select contact.country_iso_code__c, Contact.IndividualId, Contact.Gender__c, Contact.Language__c, Contact.Email, Contact.Email2__c,';
        query += 'Contact.Birthdate, Contact.Firstname, Contact.Lastname, Contact.MailingStreet, Contact.MailingCity, Contact.MailingPostalCode, Contact.MailingCountry, Contact.HomePhone, Contact.MobilePhone from OpportunityContactRoles)';
        
        //FILTERS
        query += ' FROM Opportunity';    
        query += ' WHERE';    
        query += ' (Handover_Date__c >=' + sStartDate +' AND Handover_Date__c <='+sEnddate+ 'AND ( StageName = \'Handover\' OR StageName = \'Handover & RDA\' ) ) ';
        //if(!opportunityIdLst.isEmpty())
        //query += ' OR ID IN (' + String.join(opportunityIdLst,',') + ') )';
        query += 'AND Account.RecordTypeId IN (' + String.join(PersonAccountRTids,',') + ') '; 
        
        
        if (Test.isRunningTest()) {
            System.Assert(Database.query(query).size()>0, 'Opportunity query in GfKSalesBatchExport contructor finds no records for test. Please check query: ' + query );
        }
        List<cVoice_Survey__c> allRows = [select id from cVoice_Survey__c where Process_Name__c='Opportunity Batch'];
        if (!Test.isRunningTest()) {
            delete allRows;
        } else {
            system.assertEquals(0,allRows.size(),'Gfk_Sales_Export__c object expected to be empty but was not.');
        }
        return query;
    }
    
    public List<cVoice_Survey__c> gfkExecute(List<Opportunity> gfkOpportunities){
        system.debug('gfkOpportunities @@@'+gfkOpportunities);
        String periodStart;
        String periodEnd;
        Date startDate = System.today().addDays(-integer.valueOf(numberOfDays.Days__c));
        Date endDate = System.today()-1;
        Datetime DtPeriodStart = Datetime.newInstance(startDate.year(),startDate.month(),startDate.day());
        Datetime DtPeriodEnd = Datetime.newInstance(endDate.year(),endDate.month(),endDate.day());
        periodStart = DtPeriodStart.format('dd/MM/yyyy');
        periodEnd = DtPeriodEnd.format('dd/MM/yyyy'); 

        Map<Id, Id> individualIdMap = New Map<Id, Id>();
        
        for(Opportunity o : gfkOpportunities){
            if (o.OpportunityLineItems.isEmpty()) continue;

            for(OpportunityContactRole ocr : o.OpportunityContactRoles) if (ocr.ContactId != null) individualIdMap.put(ocr.ContactId, ocr.Contact.IndividualId);
            
            if(o.AccountId != null) individualIdMap.put(o.AccountId, o.Account.PersonIndividualId);
        }

        Set<Id> allIndividualIdSet = new Set<Id>();
        allIndividualIdSet.addAll(individualIdMap.values());

        Map<id, List<ContactPointTypeConsent>> consentMap = new Map<Id, List<ContactPointTypeConsent>>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurpose.LegalBasis.Name, DataUsePurpose.CXP_Name__c, DataUsePurpose.Translatable_Value__c, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :allIndividualIdSet And DataUsePurpose.LegalBasis.Retailer_Only__c = false]) {
            List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
            Boolean allSurveyOptOut = true;
            if (consentMap.containsKey(cptc.PartyId)) consentList = consentMap.get(cptc.PartyId);
            
            consentList.add(cptc);
            consentMap.put(cptc.PartyId, consentList);
        }
        
        List<gfkObjectModel> output = new List<gfkObjectModel>();
        for(Opportunity o : gfkOpportunities){
            system.debug('OpportunityLineItems @@@'+o.OpportunityLineItems);
            if (o.OpportunityLineItems.isEmpty()) continue;
            gfkObjectModel temp = gfkProcessQuery(o, periodStart, periodEnd, consentMap);
            system.debug('temp.SalesEventDate'+temp?.SalesEventDate);
            if (temp!=null && ((temp.SalesEventDate !=null && temp.SalesEventDate !='' && string.isNotBlank(temp.SalesEventDate) && string.isNotEmpty(temp.SalesEventDate) && date.parse(temp.SalesEventDate)>=startDate && date.parse(temp.SalesEventDate) <=endDate) || test.isRunningTest()) )
                output.add(temp);
        }
        system.debug('output @@@'+output);
        if(output.isEmpty()) return null;
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
                Ownership_Cycle__c = line.EventType=='1'?'1':'', 
                Gender__c = line.Gender,
                Private_Owner__c = line.PrivateOwner,
                Owning_Company__c = line.OwningCompany, 
                User_Chooser_Or_Driver__c = line.UserChooserDriver, 
                Employer_Company__c = line.EmployerCompany,
                Month_and_Year_of_Birth__c = line.DateofBirth,
                Preferred_Methods_of_Contact__c = line.PrefMethodsOfContact,
                Permissions_for_Contact__c = line.PermissionsForContact,
                recordTypeId= line.EventType=='1'?  PurchaseRecId: PreownedRecId,
                Source_Object__c='Opportunity',
                Process_Name__c='Opportunity Batch',
                APPROVED__c=line.APPROVED,
                Common_Sale_Type__c = line.CommonSaleType ,
                Sale_Type_Code__c = line.SaleTypeCode,
                Type_Of_Sale_ID__c=line.TypeOfSaleID
            ));
        }
        //CXPD-2305 changes begin
        Map<Id, cVoice_Survey__c> processedRecMap = new Map<Id, cVoice_Survey__c>();
        for(cVoice_Survey__c cVoiceRec: gfkSalesExData){
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
        Id assetId;
        for(Opportunity opp: gfkOpportunities){
            if(oppAssetIdsMap!=NULL && oppAssetIdsMap.containsKey(opp.Id))assetId = oppAssetIdsMap.get(opp.Id);
            if(processedRecMap!=NULL && !processedRecMap.containsKey(opp.Id)) continue;
            if(eventAssetIds!=NULL && eventAssetIds.contains(assetId)) continue;
            cVoiceRec = processedRecMap.get(opp.Id);
            Event event = new Event();
            event.ActivityDateTime = DateTime.now();
            event.DurationInMinutes= 1;
            event.WhatId = opp.AccountId;
            //if(oppAssetIdsMap.containsKey(opp.Id))assetId = oppAssetIdsMap.get(opp.Id);
            event.VIN_number__c= assetId;
            event.Description ='Cvoice Survey sent for VIN: '+ cVoiceRec.VIN__c; //Name
            event.Subject = cVoiceRec.RecordTypeId==purchRecTypeId ? 'Purch Cvoice Survey sent for VIN: '+ cVoiceRec.VIN__c : 'Purch-Pre Cvoice Survey sent for VIN: '+ cVoiceRec.VIN__c;
            newEventList.add(event);
        }
        if(!newEventList.isEmpty())insert newEventList;
        //CXPD-2305 changes end
        
        system.debug('gfkSalesExData @@@'+gfkSalesExData);
        return gfkSalesExData;
    }
    
    private gfkObjectModel gfkProcessQuery(Opportunity o, string periodStart2, string periodEnd2, Map<id, List<ContactPointTypeConsent>> consentMap){
                        
        gfkObjectModel gfkModel = new gfkObjectModel();
        StringUtil su = new StringUtil();
        
        gfkModel.OpportunityId = o.Id;
        
        gfkModel.EventType = o.Purchase_Type__c=='Used Vehicle' ?'2':'1';
        if(o.Date_to_Order_Stage_Time__c != null){
            gfkModel.VehiclePurchaseDate = o.Date_to_Order_Stage_Time__c.format('dd/MM/yyyy');
        }else{
            gfkModel.VehiclePurchaseDate = '';
        }
        
        gfkModel.CustomerUniqueId = o.AccountId; 
        gfkModel.CompanyName = o.Account.Name;
        gfkModel.EmployeeCode = o.Owner.Name;
        gfkModel.EmployeeName = o.Owner.Name;
        gfkModel.VehicleDeliveryDate = o.Handover_Date__c.format();
        gfkModel.SalesEventDate = o.Handover_Date__c.format();
        
        for(OpportunityLineItem oli : o.OpportunityLineItems){
            if(oli.Brand__c != null && oli.Brand__r.Name != null){
                gfkModel.Manufacturer  = oli.Brand__r.Name;
            }else if(o.Brand__c != null && o.Brand__r.Name != null){
                gfkModel.Manufacturer = o.Brand__r.Name;
            }else{
                gfkModel.Manufacturer = '';
            }
            
            if(oli.Asset__c != null && oli.Asset__r.Vehicle_Initial_Registration_Date__c != null){
                gfkModel.VehicleRegistrationDate = oli.Asset__r.Vehicle_Initial_Registration_Date__c.format();
            }else if(o.Asset__c != null && o.Asset__r.Vehicle_Initial_Registration_Date__c != null){
                gfkModel.VehicleRegistrationDate = o.Asset__r.Vehicle_Initial_Registration_Date__c.format();
            }else{
                gfkModel.VehicleRegistrationDate = '';
            }
            /*if(oli.Asset__c != null && oli.Asset__r.Handover_Date__c != null){
                gfkModel.VehicleDeliveryDate = oli.Asset__r.Handover_Date__c.format();
                gfkModel.SalesEventDate = oli.Asset__r.Handover_Date__c.format();
            }else if(o.Asset__c != null && oli.Asset__r.Handover_Date__c != null){
                gfkModel.VehicleDeliveryDate = o.Asset__r.Handover_Date__c.format();
                gfkModel.SalesEventDate = o.Asset__r.Handover_Date__c.format();
            }else{
                gfkModel.VehicleDeliveryDate = '';
                gfkModel.SalesEventDate = '';
            }*/
            
            if(oli.Asset__c != null){
                oppAssetIdsMap.put(o.Id, oli.Asset__r.Id);//CXPD-2305
                gfkModel.ModelName = oli.Asset__r.Model__r.Name;
                gfkModel.ModelYear = oli.Asset__r.Model_Year__c;
                gfkModel.VIN = oli.Asset__r.VIN__c;
                gfkModel.RegNumber = oli.Asset__r.Registration_Number__c;
                //CXPD-1983
                gfkModel.CommonSaleType = oli.Asset__r.Common_Sale_Type__c;
        		gfkModel.SaleTypeCode = oli.Asset__r.Sale_Type_Code__c;
        		gfkModel.TypeOfSaleID = oli.Asset__r.Type_Of_Sale_ID__c;
            }else if(o.Asset__c != null){
                oppAssetIdsMap.put(o.Id, o.Asset__r.Id);//CXPD-2305
                gfkModel.ModelName = o.Asset__r.Model__r.Name;
                gfkModel.ModelYear = o.Asset__r.Model_Year__c;
                gfkModel.VIN = o.Asset__r.VIN__c;
                gfkModel.RegNumber = o.Asset__r.Registration_Number__c;
                //CXPD-1983
                gfkModel.CommonSaleType = o.Asset__r.Common_Sale_Type__c;
        		gfkModel.SaleTypeCode = o.Asset__r.Sale_Type_Code__c;
        		gfkModel.TypeOfSaleID = o.Asset__r.Type_Of_Sale_ID__c;
            }
            
            
            if(string.IsNotEmpty(gfkModel.Manufacturer) && string.IsNotEmpty(gfkModel.SalesEventDate) && string.IsNotEmpty(gfkModel.VIN))
                break;
        }
        String countryCode = '';
        If(o.Account.recordtype.developername == 'Corporate'){
            if (o.PartnerAccount.Dealer_CI_Code__c != null && gfkModel.Manufacturer=='Jaguar'){
                gfkModel.DealerCode = o.PartnerAccount.Dealer_CI_Code__c;
            }else if(o.PartnerAccount.Dealer_CI_Code_2__c != null && gfkModel.Manufacturer=='Land Rover'){
                gfkModel.DealerCode = o.PartnerAccount.Dealer_CI_Code_2__c;
            }else{
                gfkModel.DealerCode = '';
            }
            
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
                

                if(ocr.Contact.birthdate != null){
                    gfkModel.DateofBirth = ocr.Contact.birthdate.format();
                    gfkModel.DateofBirth = gfkModel.DateofBirth.substring(5);
                }else{
                    gfkModel.DateofBirth = '';
                }
                
                if(o.Account.Country_ISO_Code__c != null){
                    countryCode = o.Account.Country_ISO_Code__c ;
                }else if(o.Account.Country_ISO_Code__c == null){
                    countryCode = ocr.Contact.Country_iso_code__c;
                }else if(ocr.Contact.Country_iso_code__c == null){
                    countryCode = o.Account.Owner.Country_iso_code__c;
                }else{
                    countryCode = '';
                }
                
                if(countryCode=='JP')
                {
                gfkModel.FirstName = ocr.Contact.Firstname;
                gfkModel.Surname1 = ocr.Contact.LastName;
                gfkModel.Address1 = ocr.Contact.MailingStreet;
                gfkModel.Address5 = ocr.Contact.MailingCity;
                gfkModel.Address7 = ocr.Contact.MailingPostalCode;
                gfkModel.Address8 = ocr.Contact.MailingCountry;
                gfkModel.HomeTelephoneNumber=ocr.Contact.HomePhone;
                gfkModel.MobileTelephoneNumber=ocr.Contact.MobilePhone;
                    
                gfkModel.EmailAddress1 = ocr.Contact.Email;
                gfkModel.EmailAddress2 = ocr.Contact.Email2__c;
                }
                if(string.IsNotEmpty(gfkModel.PreferredLanguage) && string.IsNotEmpty(countrycode)) break;
            }

            gfkModel.Address1 = gfkModel.Address1==null ? o.Account.BillingStreet:gfkModel.Address1;
            gfkModel.Address5 = gfkModel.Address5==null ? o.Account.BillingCity:gfkModel.Address5;
            gfkModel.Address7 = gfkModel.Address7==null ? o.Account.BillingPostalCode:gfkModel.Address7;
            gfkModel.Address8 = gfkModel.Address8==null ? o.Account.BillingCountry:gfkModel.Address8;
            
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
                if(o.account.Owner.Contact.Account.Dealer_CI_Code__c != null && gfkModel.Manufacturer=='Jaguar'){
                    gfkModel.DealerCode = o.Account.Owner.Contact.Account.Dealer_CI_Code__c;
                }else if(o.account.Owner.Contact.Account.Dealer_CI_Code_2__c != null && gfkModel.Manufacturer=='Land Rover'){
                    gfkModel.DealerCode = o.Account.Owner.Contact.Account.Dealer_CI_Code_2__c;
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

        /*
        if(countryCode=='IN' || countryCode=='BR' || countryCode=='MX' || countryCode=='TW')
        {
           if(o.StageName == 'Handover')
              gfkModel.SalesEventDate=o.CloseDate !=null ? o.CloseDate.format():''; 
            else
              gfkModel.SalesEventDate=null;
        }
		else if(countryCode=='JP')
        {
          gfkModel.Manufacturer=o.Asset__r.Brand__r.Name;
          gfkModel.SalesEventDate=o.Asset__r.Handover_Date__c !=null ? o.Asset__r.Handover_Date__c.format():'';
          gfkModel.VIN=o.Asset__r.VIN__c;
        }*/
        
        
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
        gfkModel.APPROVED= gfkModel.EventType=='2'? o.Sub_Type__c=='Approved Pre-Owned' ?'Yes':'No':'';
        
        if(countryCode=='JP')
            gfkModel.Salutation='';
        
        Map<String,Boolean> Suppressions = ConsentHandler.SuppressionsForOpportunity(o, consentMap, gfkModel.Manufacturer);
        
        gfkModel.CompleteSupression = (Suppressions.get('OPTOUT_GLOBAL')?'Yes':'No'); 
        
        system.debug('OPTOUT_SURVEY @@@'+Suppressions.get('OPTOUT_SURVEY'));
        
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
                                                                 AND Process_Name__c='Opportunity Batch'];
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
        public string APPROVED {get;set;} 
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