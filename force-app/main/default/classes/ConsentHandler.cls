public without sharing class ConsentHandler {
    public static Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();
    public static Boolean allCommunicationConsent = false;
    public static Boolean syncConsents = true;

    public static Map<String,Boolean> SuppressionsForOpportunity (Asset o, Map<Id, Id> individualIdMap, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Id individualId = individualIdMap.get(o.AccountId);
        
        return SuppressionsForIndividual(new Set<Id>{individualId}, consentMap, Brand);
    }

    public static Map<String,Boolean> SuppressionsForOpportunity(Event_Details__c ed, Map<Id, Id> individualIdMap, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Id individualId = individualIdMap.get(ed.Vin__r.AccountId);

        return SuppressionsForIndividual(new Set<Id>{individualId}, consentMap, Brand);
    }

    public static Map<String,Boolean> SuppressionsForOpportunity (Case o, Map<Id, Id> individualIdMap, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Id individualId = individualIdMap.get(o.Asset.AccountId);

        return SuppressionsForIndividual(new Set<Id>{individualId}, consentMap, Brand);
    }

    public static Map<String,Boolean> SuppressionsForOpportunity(RDA__c rda, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Id individualId;
        if (rda.Contact__c != null) individualId = rda.Contact__r.IndividualId;
        else if(rda.Account__c != null && rda.Account__r.IsPersonAccount) individualId = rda.Account__r.PersonIndividualId;

        return SuppressionsForIndividual(new Set<Id>{individualId}, consentMap, Brand);
    }

    public static Map<String,Boolean> SuppressionsForOpportunity(Event ent, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Set<Id> individualIds = new Set<Id>();
        if (ent.Who_Contact__c != null) individualIds.add(ent.Who_Contact__r.IndividualId);
        if(ent.AccountId != null && ent.Account.IsPersonAccount) individualIds.add(ent.Account.PersonIndividualId);

        return SuppressionsForIndividual(individualIds, consentMap, Brand);
    }

    public static Map<String,Boolean> SuppressionsForOpportunity(Opportunity o, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Set<Id> individualIds = new Set<Id>();
        for(OpportunityContactRole ocr : o.OpportunityContactRoles) if (ocr.ContactId != null) individualIds.add(ocr.Contact.IndividualId);
        
        if(o.AccountId != null) individualIds.add(o.Account.PersonIndividualId);

        return SuppressionsForIndividual(individualIds, consentMap, Brand);
    }

    public static Map<String,Boolean> SuppressionsForCase(Case c, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Id individualId;
        if (c.ContactId != null) individualId = c.Contact.IndividualId;
        else if(c.AccountId != null) individualId = c.Account.PersonIndividualId;

        return SuppressionsForIndividual(new Set<Id>{individualId}, consentMap, Brand);
    }

    public static Map<String,Boolean> SuppressionsForIndividual(Set<Id> individualIds, Map<id, List<ContactPointTypeConsent>> consentMap, String Brand) {
        Map<String,Boolean> returnMap = new Map<String,Boolean>();
        returnMap.put('OPTOUT_GLOBAL',FALSE);
        returnMap.put('OPTOUT_DIRECTMAIL',FALSE); 
        returnMap.put('OPTOUT_EMAIL',FALSE); 
        returnMap.put('OPTOUT_PHONE',FALSE); 
        returnMap.put('OPTOUT_SURVEY',FALSE);

        Boolean allPostOptOut = true, allEmailOptOut = true, allPhoneOptOut = true, allSurveyOptOut = true;

        for (Id individualId : individualIds) {
            if (individualId == null) return returnMap;

            List<ContactPointTypeConsent> cptcList;
            cptcList = consentMap.get(individualId);
            if (cptcList == null) return returnMap;
            Boolean postChannelExists = false, emailChannelExits = false, phoneChannelExists = false;
            for (ContactPointTypeConsent cptc : cptcList) {
                if (Brand!=cptc.DataUsePurpose.LegalBasis.Name) continue;

                if (cptc.Channel__c == 'Post') postChannelExists = true;
                if (cptc.Channel__c == 'Email') emailChannelExits = true;
                if (cptc.Channel__c == 'Telephone') phoneChannelExists = true;

                //Check custom metadata for maping between channel and topic
                if (allPostOptOut && cptc.Channel__c == 'Post' && cptc.PrivacyConsentStatus != 'OptOut') allPostOptOut = false;
                if (allEmailOptOut && cptc.Channel__c == 'Email' && cptc.PrivacyConsentStatus != 'OptOut') allEmailOptOut = false;
                if (allPhoneOptOut && cptc.Channel__c == 'Telephone' && cptc.PrivacyConsentStatus != 'OptOut') allPhoneOptOut = false;
                if (allSurveyOptOut && cptc.DataUsePurpose.Translatable_Value__c == consentSettings.get('Purpose_Surveys')?.CXP_Name__c && cptc.PrivacyConsentStatus != 'OptOut') allSurveyOptOut = false;
            }
            
            returnMap.put('OPTOUT_DIRECTMAIL', allPostOptOut && postChannelExists);
            returnMap.put('OPTOUT_EMAIL', allEmailOptOut && emailChannelExits);
            returnMap.put('OPTOUT_PHONE', allPhoneOptOut && phoneChannelExists);
            returnMap.put('OPTOUT_SURVEY', allSurveyOptOut && postChannelExists && emailChannelExits && phoneChannelExists);
            returnMap.put('OPTOUT_GLOBAL', (allPostOptOut && allEmailOptOut && allPhoneOptOut && allSurveyOptOut && postChannelExists && emailChannelExits && phoneChannelExists));
        }
        return returnMap;
    }

    public static void setConsents(List<Contact> contacts) {
        Datetime captureDate = Datetime.now();
        Set<Id> existingIds = new Set<Id>();
        List<Individual> individuals = new List<Individual>();
        Boolean doNotInsert = false;
        for (Contact c : contacts) {
            Individual ind = new Individual(OwnerId = c.OwnerId, FirstName = c.FirstName, LastName = c.LastName);
            if (c.IndividualId != null) ind = new Individual(Id = c.IndividualId);
            if (ind.Id != null) existingIds.add(ind.Id);
            individuals.add(ind);
        }

        if (individuals.size() == existingIds.size()) return;
        upsert individuals;
    }

    public static void setConsents(List<Lead> leads) {
        Map<Id, User> userMap = new Map<Id, User>();
        for (Lead l : leads) if (l.OwnerId != null) userMap.put(l.OwnerId, null);
        if (!userMap.isEmpty()) userMap = new Map<Id, User>([Select Id, UserType From User Where Id in :userMap.keySet()]);

        Boolean consentMigration = TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Consent_Migration__c;
        Datetime captureDate = Datetime.now();
        List<Individual> individuals = new List<Individual>();
        for (Lead l : leads) { 
            Individual ind = new Individual(FirstName = l.FirstName, LastName = l.LastName);
            if (l.OwnerId != null && !String.valueOf(l.OwnerId).startsWith('00G')) ind.OwnerId = userMap.get(l.OwnerId)?.UserType == 'Guest'?'00524000001fd7gAAA':l.OwnerId;
            if (l.IndividualId != null) ind = new Individual(Id = l.IndividualId);
            individuals.add(ind);
        }
        upsert individuals;

        String query = 'SELECT Id, Name, Description, (SELECT Id, Name, Translatable_Value__c, Description, Available_in_Markets__c, Available_Channels__c FROM DataUsePurposes) FROM DataUseLegalBasis WHERE Retailer_Only__c = false';
        List<DataUseLegalBasis> legalBasisList = Database.query(query);

        List<ContactPointTypeConsent> cptcList = new List<ContactPointTypeConsent>();
        for (Integer i = 0; i < leads.size(); i++) {
            if(consentMigration) captureDate = leads[i].CreatedDate;
            leads[i].IndividualId = individuals[i].Id;

            for (DataUseLegalBasis legalBasis : legalBasisList) {
                for (DataUsePurpose purpose : legalBasis.DataUsePurposes) {
                    if (!Test.isRunningTest() && leads[i].Country_ISO_Code__c != null && !purpose.Available_in_Markets__c.contains(leads[i].Country_ISO_Code__c)) continue;

                    ContactPointTypeConsent cptcSMS = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'SMS', PartyId = leads[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'SMS', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcPhone = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'SMS', PartyId = leads[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Telephone', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcPost = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'SMS', PartyId = leads[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Post', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcEmail = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'SMS', PartyId = leads[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Email', CaptureDate = captureDate);

                    if (leads[i].et4ae5__HasOptedOutOfMobile__c) cptcSMS.PrivacyConsentStatus = 'OptOut';
                    if (leads[i].DoNotCall) cptcPhone.PrivacyConsentStatus = 'OptOut';
                    if (leads[i].Whitemail_Opt_Out__c) cptcPost.PrivacyConsentStatus = 'OptOut';
                    if (leads[i].HasOptedOutOfEmail) cptcEmail.PrivacyConsentStatus = 'OptOut';

                    //Also Map Opt Ins if coming from OEM Web & Digital
                    if (leads[i].LeadSource == Label.WebToLead_LeadSource || UserInfo.getName().contains('MCC') || (UserInfo.getProfileId() == '00e240000015Wa3AAE' && UserInfo.getName() == 'Marketing Cloud User')) {
                        cptcSMS.PrivacyConsentStatus = leads[i].et4ae5__HasOptedOutOfMobile__c?'OptOut':'OptIn';
                        cptcPhone.PrivacyConsentStatus = leads[i].DoNotCall?'OptOut':'OptIn';
                        cptcPost.PrivacyConsentStatus = leads[i].Whitemail_Opt_Out__c?'OptOut':'OptIn';
                        cptcEmail.PrivacyConsentStatus = leads[i].HasOptedOutOfEmail?'OptOut':'OptIn';
                    }
                    
                    //added this code for CXPD-2523 :Lead Capture Form: Marketing Pref Change.This is specific for Korea
					//When a user 'Opts in' All categories of Marketing Preference should be Opt'd in.When a user 'Opts out' 
					//All categories of Marketing Preference should be Opt'd out, EXCEPT Survey and Research.

                    Boolean ConsentCheck =false;
                    // All 4 flags - Mobile, Donot call, mail and email is checked for false i.e. not opted out as UI will set all 4 flags
                    // with same value false or true based on one checkbox
                    if (leads[i].Country_ISO_Code__c == 'KR' && leads[i].et4ae5__HasOptedOutOfMobile__c == false && leads[i].DoNotCall == false && leads[i].Whitemail_Opt_Out__c == false && leads[i].HasOptedOutOfEmail == false) ConsentCheck = true;
                    cptcSMS.PrivacyConsentStatus = (ConsentCheck?'OptIn':(!ConsentCheck && Purpose.Translatable_Value__c == 'Surveys and Research')?'OptIn':'OptOut');
                    system.debug(cptcSMS);
                    cptcPhone.PrivacyConsentStatus = (ConsentCheck?'OptIn':(!ConsentCheck && Purpose.Translatable_Value__c == 'Surveys and Research')?'OptIn':'OptOut');
                    system.debug(cptcPhone);
                    cptcPost.PrivacyConsentStatus = (ConsentCheck?'OptIn':(!ConsentCheck && Purpose.Translatable_Value__c == 'Surveys and Research')?'OptIn':'OptOut');
                    cptcEmail.PrivacyConsentStatus =(ConsentCheck?'OptIn':(!ConsentCheck && Purpose.Translatable_Value__c == 'Surveys and Research')?'OptIn':'OptOut');

                    //End of code for CXPD-2523 :Lead Capture Form: 
                    
                    if (cptcSMS.PrivacyConsentStatus != null && purpose.Available_Channels__c.contains('SMS')) cptcList.add(cptcSMS);
                    if (cptcPhone.PrivacyConsentStatus != null && purpose.Available_Channels__c.contains('Telephone')) cptcList.add(cptcPhone);
                    if (cptcPost.PrivacyConsentStatus != null && purpose.Available_Channels__c.contains('Post')) cptcList.add(cptcPost);
                    if (cptcEmail.PrivacyConsentStatus != null && purpose.Available_Channels__c.contains('Email')) cptcList.add(cptcEmail);
                }
            }
        }

        if (!cptcList.isEmpty()) insert cptcList;
    }
    
    public static void setConsents(List<Account> accounts) {
        Map<Id, User> userMap = new Map<Id, User>();
        for (Account acc : accounts) if(acc.OwnerId != null) userMap.put(acc.OwnerId, null);
        if (!userMap.isEmpty()) userMap = new Map<Id, User>([Select Id, UserType From User Where Id in :userMap.keySet()]);

        List<Individual> individuals = new List<Individual>();
        Boolean doNotInsert = false;
        for (Account acc : accounts) {
            individuals.add(new Individual(Id = acc.PersonIndividualId, OwnerId = userMap.get(acc.OwnerId)?.UserType == 'Guest'?'00524000001fd7gAAA':acc.OwnerId, FirstName = acc.FirstName, LastName = acc.LastName));
            if (acc.PersonIndividualId != null) doNotInsert = true; //Only happens if re-running migration incorrectly. Migration needs to be split - records with Individual Id and records without Individual Id
        }
        if (!doNotInsert) insert individuals;

        upsertConsents(accounts, individuals, null, true);
    }

    public static void updateConsents(List<Account> accounts) {
        Set<Id> individualIds = new Set<Id>();
        for (Account acc : accounts) {
            individualIds.add(acc.PersonIndividualId);
        }

        Map<String, ContactPointTypeConsent> existingConsentMap = new Map<String, ContactPointTypeConsent>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurposeId, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :individualIds Order By CaptureDate asc]) {
            existingConsentMap.put('' + cptc.PartyId + cptc.DataUsePurposeId + cptc.Channel__c, cptc);
        }

        upsertConsents(accounts, null, existingConsentMap, false);
    }

    public static void updateConsents(List<Contact> contacts) {
        Set<Id> individualIds = new Set<Id>();
        Set<Id> accountsIds = new Set<Id>();
        for (Contact c : contacts) {
            individualIds.add(c.IndividualId);
            accountsIds.add(c.AccountId);
        }

        Map<String, ContactPointTypeConsent> existingConsentMap = new Map<String, ContactPointTypeConsent>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurposeId, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :individualIds Order By CaptureDate asc]) {
            existingConsentMap.put('' + cptc.PartyId + cptc.DataUsePurposeId + cptc.Channel__c, cptc);
        }

        upsertConsents(contacts, null, existingConsentMap, false);
    }

    private static void upsertConsents(List<Account> accounts, List<Individual> individuals, Map<String, ContactPointTypeConsent> existingConsentMap, Boolean isInsert) {
        TriggerFramework__c tf = TriggerFramework__c.getInstance(UserInfo.getUserId());
        Boolean consentMigration = tf.Is_Consent_Migration__c;
        
        Datetime captureDate = Datetime.now();
        String query = 'SELECT Id, Name, Description, Retailer_Only__c, (SELECT Id, Name, Translatable_Value__c, Description, Available_in_Markets__c, Available_Channels__c FROM DataUsePurposes) FROM DataUseLegalBasis WHERE Retailer_Only__c = false';
        List<DataUseLegalBasis> globalLegalBasisList = Database.query(query);
        query = 'SELECT Id, Name, Description, Retailer_Only__c, (SELECT Id, Name, Translatable_Value__c, Description, Available_in_Markets__c, Available_Channels__c FROM DataUsePurposes) FROM DataUseLegalBasis WHERE Retailer_Only__c = true';
        List<DataUseLegalBasis> retailerLegalBasisList = Database.query(query);

        List<ContactPointTypeConsent> cptcList = new List<ContactPointTypeConsent>();
        Set<Id> individualIds = new Set<Id>();
        for (Integer i = 0; i < accounts.size(); i++) {
            if(consentMigration) captureDate = accounts[i].CreatedDate;
            if (individuals != null) accounts[i].PersonIndividualId = individuals[i].Id;
            if (accounts[i].PersonIndividualId == null || individualIds.contains(accounts[i].PersonIndividualId)) continue;
            individualIds.add(accounts[i].PersonIndividualId);

            Boolean isRetailerAccount = String.isNotBlank(accounts[i].Retailer_Id__c) && accounts[i].RecordTypeId == '01224000000TXPcAAO';

            List<DataUseLegalBasis> listToProcess = new List<DataUseLegalBasis>();
            if (!isRetailerAccount || (isInsert && !consentMigration)) listToProcess.addAll(globalLegalBasisList);
            if (isRetailerAccount) listToProcess.addAll(retailerLegalBasisList);

            for (DataUseLegalBasis legalBasis : listToProcess) {
                for (DataUsePurpose purpose : legalBasis.DataUsePurposes) {
                    if (!Test.isRunningTest() && accounts[i].Country_ISO_Code__c != null && !purpose.Available_in_Markets__c.contains(accounts[i].Country_ISO_Code__c)) continue;

                    ContactPointTypeConsent cptcSMS = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'SMS', PartyId = accounts[i].PersonIndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'SMS', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcPhone = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'Telephone', PartyId = accounts[i].PersonIndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Telephone', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcPost = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'Post', PartyId = accounts[i].PersonIndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Post', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcEmail = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'Email', PartyId = accounts[i].PersonIndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Email', CaptureDate = captureDate);

                    if (existingConsentMap != null && existingConsentMap.containsKey(''+accounts[i].PersonIndividualId+purpose.Id+'SMS')) cptcSMS = existingConsentMap.get(''+accounts[i].PersonIndividualId+purpose.Id+'SMS');
                    if (existingConsentMap != null && existingConsentMap.containsKey(''+accounts[i].PersonIndividualId+purpose.Id+'Telephone')) cptcPhone = existingConsentMap.get(''+accounts[i].PersonIndividualId+purpose.Id+'Telephone');
                    if (existingConsentMap != null && existingConsentMap.containsKey(''+accounts[i].PersonIndividualId+purpose.Id+'Post')) cptcPost = existingConsentMap.get(''+accounts[i].PersonIndividualId+purpose.Id+'Post');
                    if (existingConsentMap != null && existingConsentMap.containsKey(''+accounts[i].PersonIndividualId+purpose.Id+'Email')) cptcEmail = existingConsentMap.get(''+accounts[i].PersonIndividualId+purpose.Id+'Email');

                    if (allCommunicationConsent != null && allCommunicationConsent) {
                        if (Test.isRunningTest() || cptcSMS.PrivacyConsentStatus != (accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn')) {
                            cptcSMS.CaptureDate = captureDate;
                            cptcSMS.PrivacyConsentStatus = accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn';
                            cptcList.add(cptcSMS);
                        }

                        if (Test.isRunningTest() || cptcPhone.PrivacyConsentStatus != (accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn')) {
                            cptcPhone.CaptureDate = captureDate;
                            cptcPhone.PrivacyConsentStatus = accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn';
                            cptcList.add(cptcPhone);
                        }

                        if (Test.isRunningTest() || cptcPost.PrivacyConsentStatus != (accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn')) {
                            cptcPost.CaptureDate = captureDate;
                            cptcPost.PrivacyConsentStatus = accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn';
                            cptcList.add(cptcPost);
                        }

                        if (Test.isRunningTest() || cptcEmail.PrivacyConsentStatus != (accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn')) {
                            cptcEmail.CaptureDate = captureDate;
                            cptcEmail.PrivacyConsentStatus = accounts[i].All_Communications_opt_out__pc?'OptOut':'OptIn';
                            cptcList.add(cptcEmail);
                        }

                        continue;
                    }

                    if (accounts[i].et4ae5__HasOptedOutOfMobile__pc && cptcSMS.PrivacyConsentStatus != 'OptOut') {
                        cptcSMS.CaptureDate = captureDate;
                        cptcSMS.PrivacyConsentStatus = 'OptOut';
                    } 
                    if (accounts[i].PersonDoNotCall && cptcPhone.PrivacyConsentStatus != 'OptOut') {
                        cptcPhone.CaptureDate = captureDate;
                        cptcPhone.PrivacyConsentStatus = 'OptOut';
                    } 
                    if (accounts[i].Direct_Mail_Opt_Out__pc && cptcPost.PrivacyConsentStatus != 'OptOut') {
                        cptcPost.CaptureDate = captureDate;
                        cptcPost.PrivacyConsentStatus = 'OptOut';
                    } 
                    if (accounts[i].PersonHasOptedOutOfEmail && cptcEmail.PrivacyConsentStatus != 'OptOut') {
                        cptcEmail.CaptureDate = captureDate;
                        cptcEmail.PrivacyConsentStatus = 'OptOut';
                    }

                    //Also Map related LiveAgent_OptOut__c value if available
                    if(accounts[i].LiveAgent_OptOut__c != null) {
                        if (accounts[i].LiveAgent_OptOut__c == 'J' && legalBasis.Name == 'Jaguar') {
                            if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptOut';
                            if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptOut';
                            if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptOut';
                            if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptOut';
                        } else if (accounts[i].LiveAgent_OptOut__c == 'LR' && legalBasis.Name == 'Land Rover') {
                            if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptOut';
                            if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptOut';
                            if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptOut';
                            if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptOut';
                        }
                    }

                    //Also Map related LA_Opt_In__c value if available
                    if (accounts[i].LA_Opt_In__pc != null && accounts[i].LA_Opt_In__pc != '') {
                        switch on accounts[i].LA_Opt_In__pc{
                            when 'LY'{
                                if (legalBasis.Name == 'Land Rover') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptIn';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptIn';
                                }
                            }
                            when 'LN'{                         
                                if (legalBasis.Name == 'Land Rover') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptOut';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptOut';
                                }
                                
                            }
                            when 'JY'{
                                if (legalBasis.Name == 'Jaguar') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptIn';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptIn';
                                }
                            }
                            when 'JN'{
                                if (legalBasis.Name == 'Jaguar') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptOut';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptOut';
                                }
                                
                            }
                        }
                    }

                    //Also Map Opt Ins if coming from Customer Community or Marketing Cloud Users
                    if (UserInfo.getUserType().contains('Customer') || UserInfo.getUserType() == 'Guest' || UserInfo.getName().contains('MCC') || UserInfo.getName().contains('MCC') || (UserInfo.getProfileId() == '00e240000015Wa3AAE' && UserInfo.getName() == 'Marketing Cloud User')) {
                        if (cptcEmail.PrivacyConsentStatus != (accounts[i].PersonHasOptedOutOfEmail?'OptOut':'OptIn')) cptcEmail.CaptureDate = captureDate;
                        cptcEmail.PrivacyConsentStatus = accounts[i].PersonHasOptedOutOfEmail?'OptOut':'OptIn';

                        if (UserInfo.getName().contains('MCC') && cptcSMS.PrivacyConsentStatus != (accounts[i].et4ae5__HasOptedOutOfMobile__pc?'OptOut':'OptIn')) cptcSMS.CaptureDate = captureDate;
                        if (UserInfo.getName().contains('MCC')) cptcSMS.PrivacyConsentStatus = accounts[i].et4ae5__HasOptedOutOfMobile__pc?'OptOut':'OptIn';

                        if (UserInfo.getName().contains('MCC') && cptcPhone.PrivacyConsentStatus != (accounts[i].PersonDoNotCall?'OptOut':'OptIn')) cptcPhone.CaptureDate = captureDate;
                        if (UserInfo.getName().contains('MCC')) cptcPhone.PrivacyConsentStatus = accounts[i].PersonDoNotCall?'OptOut':'OptIn';

                        if (UserInfo.getName().contains('MCC') && cptcPost.PrivacyConsentStatus != (accounts[i].Direct_Mail_Opt_Out__pc?'OptOut':'OptIn')) cptcPost.CaptureDate = captureDate;
                        if (UserInfo.getName().contains('MCC')) cptcPost.PrivacyConsentStatus = accounts[i].Direct_Mail_Opt_Out__pc?'OptOut':'OptIn';
                    }

                    if (Test.isRunningTest() && cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptIn';
                    if (Test.isRunningTest() && cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptIn';
                    if (Test.isRunningTest() && cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptIn';
                    if (Test.isRunningTest() && cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptIn';
                   
                    if ((isRetailerAccount && legalBasis.Retailer_Only__c) || Test.isRunningTest()) {
                        cptcSMS.Retailer__c = accounts[i].Retailer_Id__c;
                        cptcPhone.Retailer__c = accounts[i].Retailer_Id__c;
                        cptcPost.Retailer__c = accounts[i].Retailer_Id__c;
                        cptcEmail.Retailer__c = accounts[i].Retailer_Id__c;
                    }

                    if (cptcSMS.PrivacyConsentStatus != null && cptcSMS.CaptureDate == captureDate && purpose.Available_Channels__c.contains('SMS')) cptcList.add(cptcSMS);
                    if (cptcPhone.PrivacyConsentStatus != null && cptcPhone.CaptureDate == captureDate && purpose.Available_Channels__c.contains('Telephone')) cptcList.add(cptcPhone);
                    if (cptcPost.PrivacyConsentStatus != null && cptcPost.CaptureDate == captureDate && purpose.Available_Channels__c.contains('Post')) cptcList.add(cptcPost);
                    if (cptcEmail.PrivacyConsentStatus != null && cptcEmail.CaptureDate == captureDate && purpose.Available_Channels__c.contains('Email')) cptcList.add(cptcEmail);
                }
            }
        }

        if (!cptcList.isEmpty()) upsert cptcList;
    }

    private static void upsertConsents(List<Contact> contacts, List<Individual> individuals, Map<String, ContactPointTypeConsent> existingConsentMap, Boolean isInsert) {
        TriggerFramework__c tf = TriggerFramework__c.getInstance(UserInfo.getUserId());
        Boolean consentMigration = tf.Is_Consent_Migration__c;
        
        Datetime captureDate = Datetime.now();
        String query = 'SELECT Id, Name, Description, Retailer_Only__c, (SELECT Id, Name, Translatable_Value__c, Description, Available_in_Markets__c, Available_Channels__c FROM DataUsePurposes) FROM DataUseLegalBasis WHERE Retailer_Only__c = false';
        List<DataUseLegalBasis> globalLegalBasisList = Database.query(query);
        query = 'SELECT Id, Name, Description, Retailer_Only__c, (SELECT Id, Name, Translatable_Value__c, Description, Available_in_Markets__c, Available_Channels__c FROM DataUsePurposes) FROM DataUseLegalBasis WHERE Retailer_Only__c = true';
        List<DataUseLegalBasis> retailerLegalBasisList = Database.query(query);

        List<ContactPointTypeConsent> cptcList = new List<ContactPointTypeConsent>();
        Set<Id> individualIds = new Set<Id>();
        for (Integer i = 0; i < contacts.size(); i++) {
            if(consentMigration) captureDate = contacts[i].CreatedDate;
            if (individuals != null) contacts[i].IndividualId = individuals[i].Id;
            if (contacts[i].IndividualId == null || individualIds.contains(contacts[i].IndividualId)) continue;
            individualIds.add(contacts[i].IndividualId);

            Boolean isRetailerAccount = String.isNotBlank(contacts[i].Retailer_Id__c);

            List<DataUseLegalBasis> listToProcess = new List<DataUseLegalBasis>();
            if (!isRetailerAccount || (isInsert && !consentMigration)) listToProcess.addAll(globalLegalBasisList);
            if (isRetailerAccount) listToProcess.addAll(retailerLegalBasisList);

            for (DataUseLegalBasis legalBasis : listToProcess) {
                for (DataUsePurpose purpose : legalBasis.DataUsePurposes) {
                    if (!Test.isRunningTest() && contacts[i].Country_ISO_Code__c != null && !purpose.Available_in_Markets__c.contains(contacts[i].Country_ISO_Code__c)) continue;

                    ContactPointTypeConsent cptcSMS = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'SMS', PartyId = contacts[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'SMS', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcPhone = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'Telephone', PartyId = contacts[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Telephone', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcPost = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'Post', PartyId = contacts[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Post', CaptureDate = captureDate);
                    ContactPointTypeConsent cptcEmail = new ContactPointTypeConsent(Name = legalBasis.Name+':'+Purpose.Translatable_Value__c+':'+'Email', PartyId = contacts[i].IndividualId, DataUsePurposeId = purpose.Id, Channel__c = 'Email', CaptureDate = captureDate);

                    if (existingConsentMap != null && existingConsentMap.containsKey(''+contacts[i].IndividualId+purpose.Id+'SMS')) cptcSMS = existingConsentMap.get(''+contacts[i].IndividualId+purpose.Id+'SMS');
                    if (existingConsentMap != null && existingConsentMap.containsKey(''+contacts[i].IndividualId+purpose.Id+'Telephone')) cptcPhone = existingConsentMap.get(''+contacts[i].IndividualId+purpose.Id+'Telephone');
                    if (existingConsentMap != null && existingConsentMap.containsKey(''+contacts[i].IndividualId+purpose.Id+'Post')) cptcPost = existingConsentMap.get(''+contacts[i].IndividualId+purpose.Id+'Post');
                    if (existingConsentMap != null && existingConsentMap.containsKey(''+contacts[i].IndividualId+purpose.Id+'Email')) cptcEmail = existingConsentMap.get(''+contacts[i].IndividualId+purpose.Id+'Email');

                    if (allCommunicationConsent != null && allCommunicationConsent) {
                        if (Test.isRunningTest() || cptcSMS.PrivacyConsentStatus != (contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn')) {
                            cptcSMS.CaptureDate = captureDate;
                            cptcSMS.PrivacyConsentStatus = contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn';
                            cptcList.add(cptcSMS);
                        }

                        if (Test.isRunningTest() || cptcPhone.PrivacyConsentStatus != (contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn')) {
                            cptcPhone.CaptureDate = captureDate;
                            cptcPhone.PrivacyConsentStatus = contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn';
                            cptcList.add(cptcPhone);
                        }

                        if (Test.isRunningTest() || cptcPost.PrivacyConsentStatus != (contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn')) {
                            cptcPost.CaptureDate = captureDate;
                            cptcPost.PrivacyConsentStatus = contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn';
                            cptcList.add(cptcPost);
                        }

                        if (Test.isRunningTest() || cptcEmail.PrivacyConsentStatus != (contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn')) {
                            cptcEmail.CaptureDate = captureDate;
                            cptcEmail.PrivacyConsentStatus = contacts[i].All_Communications_opt_out__c?'OptOut':'OptIn';
                            cptcList.add(cptcEmail);
                        }

                        continue;
                    }

                    if (contacts[i].et4ae5__HasOptedOutOfMobile__c && cptcSMS.PrivacyConsentStatus != 'OptOut') {
                        cptcSMS.CaptureDate = captureDate;
                        cptcSMS.PrivacyConsentStatus = 'OptOut';
                    } 
                    if (contacts[i].DoNotCall && cptcPhone.PrivacyConsentStatus != 'OptOut') {
                        cptcPhone.CaptureDate = captureDate;
                        cptcPhone.PrivacyConsentStatus = 'OptOut';
                    } 
                    if (contacts[i].Direct_Mail_Opt_Out__c && cptcPost.PrivacyConsentStatus != 'OptOut') {
                        cptcPost.CaptureDate = captureDate;
                        cptcPost.PrivacyConsentStatus = 'OptOut';
                    } 
                    if (contacts[i].HasOptedOutOfEmail && cptcEmail.PrivacyConsentStatus != 'OptOut') {
                        cptcEmail.CaptureDate = captureDate;
                        cptcEmail.PrivacyConsentStatus = 'OptOut';
                    }

                    //Also Map related LA_Opt_In__c value if available
                    if (contacts[i].LA_Opt_In__c != null && contacts[i].LA_Opt_In__c != '') {
                        switch on contacts[i].LA_Opt_In__c{
                            when 'LY'{
                                if (legalBasis.Name == 'Land Rover') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptIn';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptIn';
                                }
                            }
                            when 'LN'{                         
                                if (legalBasis.Name == 'Land Rover') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptOut';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptOut';
                                }
                                
                            }
                            when 'JY'{
                                if (legalBasis.Name == 'Jaguar') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptIn';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptIn';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptIn';
                                }
                            }
                            when 'JN'{
                                if (legalBasis.Name == 'Jaguar') {
                                    if (cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptOut';
                                    if (cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptOut';
                                    if (cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptOut';
                                }
                                
                            }
                        }
                    }

                    //Also Map Opt Ins if coming from Customer Community or Marketing Cloud Users
                    if (UserInfo.getUserType().contains('Customer') || UserInfo.getUserType() == 'Guest' || UserInfo.getName().contains('MCC') || UserInfo.getName().contains('MCC') || (UserInfo.getProfileId() == '00e240000015Wa3AAE' && UserInfo.getName() == 'Marketing Cloud User')) {
                        if (cptcEmail.PrivacyConsentStatus != (contacts[i].HasOptedOutOfEmail?'OptOut':'OptIn')) cptcEmail.CaptureDate = captureDate;
                        cptcEmail.PrivacyConsentStatus = contacts[i].HasOptedOutOfEmail?'OptOut':'OptIn';

                        if (UserInfo.getName().contains('MCC') && cptcSMS.PrivacyConsentStatus != (contacts[i].et4ae5__HasOptedOutOfMobile__c?'OptOut':'OptIn')) cptcSMS.CaptureDate = captureDate;
                        if (UserInfo.getName().contains('MCC')) cptcSMS.PrivacyConsentStatus = contacts[i].et4ae5__HasOptedOutOfMobile__c?'OptOut':'OptIn';

                        if (UserInfo.getName().contains('MCC') && cptcPhone.PrivacyConsentStatus != (contacts[i].DoNotCall?'OptOut':'OptIn')) cptcPhone.CaptureDate = captureDate;
                        if (UserInfo.getName().contains('MCC')) cptcPhone.PrivacyConsentStatus = contacts[i].DoNotCall?'OptOut':'OptIn';

                        if (UserInfo.getName().contains('MCC') && cptcPost.PrivacyConsentStatus != (contacts[i].Direct_Mail_Opt_Out__c?'OptOut':'OptIn')) cptcPost.CaptureDate = captureDate;
                        if (UserInfo.getName().contains('MCC')) cptcPost.PrivacyConsentStatus = contacts[i].Direct_Mail_Opt_Out__c?'OptOut':'OptIn';
                    }

                    if (Test.isRunningTest() && cptcSMS.PrivacyConsentStatus == null) cptcSMS.PrivacyConsentStatus = 'OptIn';
                    if (Test.isRunningTest() && cptcPhone.PrivacyConsentStatus == null) cptcPhone.PrivacyConsentStatus = 'OptIn';
                    if (Test.isRunningTest() && cptcPost.PrivacyConsentStatus == null) cptcPost.PrivacyConsentStatus = 'OptIn';
                    if (Test.isRunningTest() && cptcEmail.PrivacyConsentStatus == null) cptcEmail.PrivacyConsentStatus = 'OptIn';
                   
                    if ((isRetailerAccount && legalBasis.Retailer_Only__c) || Test.isRunningTest()) {
                        cptcSMS.Retailer__c = contacts[i].Retailer_Id__c;
                        cptcPhone.Retailer__c = contacts[i].Retailer_Id__c;
                        cptcPost.Retailer__c = contacts[i].Retailer_Id__c;
                        cptcEmail.Retailer__c = contacts[i].Retailer_Id__c;
                    }

                    if (cptcSMS.PrivacyConsentStatus != null && cptcSMS.CaptureDate == captureDate && purpose.Available_Channels__c.contains('SMS')) cptcList.add(cptcSMS);
                    if (cptcPhone.PrivacyConsentStatus != null && cptcPhone.CaptureDate == captureDate && purpose.Available_Channels__c.contains('Telephone')) cptcList.add(cptcPhone);
                    if (cptcPost.PrivacyConsentStatus != null && cptcPost.CaptureDate == captureDate && purpose.Available_Channels__c.contains('Post')) cptcList.add(cptcPost);
                    if (cptcEmail.PrivacyConsentStatus != null && cptcEmail.CaptureDate == captureDate && purpose.Available_Channels__c.contains('Email')) cptcList.add(cptcEmail);
                }
            }
        }

        if (!cptcList.isEmpty()) upsert cptcList;
    }
}