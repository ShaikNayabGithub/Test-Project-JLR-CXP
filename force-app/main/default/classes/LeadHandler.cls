//preprod
public class LeadHandler {
    
    
    // public Map<string,Vietnam_Spam_Identifier__mdt> mapSpamIdentifier = new Map<string,Vietnam_Spam_Identifier__mdt>([select label,DeveloperName,field__c from Vietnam_Spam_Identifier__mdt]);
    private static Map<String,Schema.RecordTypeInfo> ContactSchema = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
    private static Map<String,Schema.RecordTypeInfo> OpportunitySchema = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    public static String SHOWROOM_VISIT_FORM = 'Showroom Visit Form';    
    
    
    // public static Id spamQId = [select queue.id from queuesobject where queue.developername = 'VietnamSpamQueue' limit 1 ].queue.id ;
    private static final Map<String, Map<SObjectType, String>> fieldMapping = new Map<String, Map<SObjectType, String>>{
        Schema.Lead.FirstNameLocal.getDescribe().getName()=>new Map<SObjectType, String>{ 
            Schema.Task.SObjectType=>Schema.Task.First_Name_Local__c.getDescribe().getName(),
                Schema.Event.SObjectType=>Schema.Event.First_Name_Local__c.getDescribe().getName()},
                    Schema.Lead.LastNameLocal.getDescribe().getName()=>new Map<SObjectType, String>{ 
                        Schema.Task.SObjectType=>Schema.Task.Last_Name_Local__c.getDescribe().getName(),
                            Schema.Event.SObjectType=>Schema.Event.Last_Name_Local__c.getDescribe().getName()}};
                                
                                private static final Map<SObjectType, String> childRelationshipMap = new Map<SObjectType, String>{
                                    Schema.Task.SObjectType=>Schema.Task.WhoId.getDescribe().getName(),
                                        Schema.Event.SObjectType=>Schema.Event.WhoId.getDescribe().getName()};
                                            
                                            private static User currentUser{
                                                get{
                                                    if(currentUser == null){
                                                        currentUser = [SELECT country_iso_code__c FROM User where id=:UserInfo.getUserId()];
                                                    }
                                                    return currentUser;
                                                }
                                                set;
                                            }
    
    private boolean ownerIsQueue(Id ownerId) {
        return String.ValueOf(ownerid).StartsWith('00G');
    }
    
    private boolean atLeastOneOwnerIdIsAQueue(Set<String> ownerIds) {
        
        if(ownerIds != null && !ownerIds.isEmpty()){
            for (Id i : ownerIds) {
                if (i != null && ownerIsQueue(Id.ValueOf(i))) return true;
            }
            return false;
        }else{
            return false;
        }
        
    }
    
    private void SetPreferredRetailerIfBlank(List<Lead> Leads) { 
        Set<String> ownerIds = new Set<String>();
        for (Lead l : Leads) { 
            if (l.Preferred_Retailer__c==null && l.ownerid != null )
            {
                ownerIds.add(String.ValueOf(l.ownerid)); 
            }
        }
        if (ownerIds.size()>0) {
            Map<Id,User> userOwners = new Map<Id,User>([select id,contactid,contact.accountid from user where id in : ownerids ]); 
            Map<Id,Id> queueOwners = new Map<Id,Id>();  
            if (atLeastOneOwnerIdIsAQueue(ownerids)) {
                for (Account a: [select id, queue_id__c from Account where RecordType.DeveloperName = 'Retailer' and queue_id__c in : ownerids ]) 
                    queueOwners.put(Id.ValueOf(a.queue_id__c),a.id); 
            }
            User u = new User(); 
            for (Lead l : Leads) {
                if (l.Preferred_Retailer__c==null) {
                    if (ownerIsQueue(l.ownerid) && queueOwners.containsKey(l.ownerid)) { 
                        l.Preferred_Retailer__c = queueOwners.get(l.ownerid); 
                    } else {
                        u = userOwners.get(l.ownerid); 
                        if (u!=null && u.contactid!=null && u.contact.accountid!=null) l.Preferred_Retailer__c = u.contact.accountid;
                    }
                }
            }
        }
    } 
    
    public void PreCreate(List<Lead> leads) {
        DefaultPurchaseTypeToNewVehicle(leads);
        webToLeadLookUpSetter wtlust = new webToLeadLookUpSetter();
        WebToLeadExistingLeadLookup wtlExisting = new WebToLeadExistingLeadLookup();
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        OwnerMarketSetter ownerMarketSetter = new OwnerMarketSetter();
        LeadNumberCleanupSetter leadNumberCleanupSetter = new LeadNumberCleanupSetter(leads);
        //LeadTypeChecker leadTypeChecker = new LeadTypeChecker(leads);
        Lead_SLADeadlineHandler_F slaDeadlineHandlerFactory = new Lead_SLADeadlineHandler_F();
        Lead_SLADeadlineHandler slaDeadlineHandler = slaDeadlineHandlerFactory.Create();
        OwnerISOCodeSetter ownerISOSetter = new OwnerISOCodeSetter();       
        
        //Email2LeadOwnerSetter LeadOwnerSetter = new Email2LeadOwnerSetter(); 
        
        //if (isBrowserUser())
        //{
        //    leadTypeChecker.check();
        //}
        
        //LeadOwnerSetter.email2LeadSetter(leads); 
        wtlust.mappingFieldPopulated(leads);
        wtlExisting.CheckAllWebLeads(leads);
        if (UserInfo.getUserType()=='Standard' || UserInfo.getUserType()=='PowerPartner') 
            sObjectCountrySetter.SetCountryFromOwner(leads, new List<Schema.DescribeFieldResult> { Lead.Country.getDescribe() });
        ownerMarketSetter.SetMarketFromOwner(leads, Schema.Lead.Owners_Market__c);
        leadNumberCleanupSetter.clean();   
        slaDeadlineHandler.SetSLADeadline(leads);
        ownerISOSetter.SetISOCodes(leads);        
        
        UdaanUtility.IndiaUdaan_checkDuplicateLead(leads);        
        SetPreferredRetailerIfBlank(leads);
        DefaultRecordTypeForShuhoLeads(leads);
        
        Id spamQId = [select queue.id from queuesobject where queue.developername = 'VietnamSpamQueue' limit 1 ].queue.id ;
        for (Lead l : leads) {
            
            if(l.Web2Lead_Check_Code__c != null && l.Country_ISO_Code__c == 'VN' && isSpam(l))
            {
                //assign to spam queue 
                l.ownerId =  spamQId; 
            }
        }
        
        // list<Currency_Iso_Code__mdt> retrievedMetaData = [SELECT Label, Iso_Code__c FROM Currency_Iso_Code__mdt];
        Map < String, Currency_Iso_Code__mdt> retrievedMetaData = Currency_Iso_Code__mdt.getAll();
        Map<String, String> MappedMetaData = new Map<String, String>();
        for(Currency_Iso_Code__mdt m : retrievedMetaData.values()) {
            MappedMetaData.put(m.Label, m.Iso_Code__c);
            //System.debug(m.Label + ' ' + m.Iso_Code__c);
        }

        List<Lead> consentList = new List<Lead>();
        Set<Id> accountIds = new Set<Id>();
        for(Lead l: leads) {
            //System.debug('RUNNING LEAD');
            if(l.Country_ISO_Code__c != null) {
                //System.debug('VALUE NOT NULL LEAD');
                if(MappedMetaData.containsKey(l.Country_ISO_Code__c)) {
                    l.CurrencyIsoCode = MappedMetaData.get(l.Country_ISO_Code__c);
                    //l.CurrencyIsoCode = 'INR';
                    //System.debug('VALUES ' + l.CurrencyIsoCode + ' . ' + l.Country_ISO_Code__c);
                    //System.debug('VALUES ' + MappedMetaData.get(l.Country_ISO_Code__c));
                }
            }
            
            if (l.IndividualId == null && l.Account__c == null) consentList.add(l);
            if (l.IndividualId == null && l.Account__c != null) accountIds.add(l.Account__c);
        }

        if (!accountIds.isEmpty()) for(Account acc : [Select Id, PersonIndividualId From Account Where Id in :accountIds]) for(Lead l: leads) if (acc.Id == l.Account__c) l.IndividualId = acc.PersonIndividualId;
        if (!consentList.isEmpty()) ConsentHandler.setConsents(consentList);
        
    }
    
    public void PreUpdate(List<Lead> leads_current, List<Lead> leads_old) {
        DefaultPurchaseTypeToNewVehicle(leads_current);
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        OwnerMarketSetter ownerMarketSetter = new OwnerMarketSetter();
        OwnerISOCodeSetter ownerISOSetter = new OwnerISOCodeSetter();
        ChildSObjectLocalFieldUpdater childSObjectLocalFieldUpdater = new ChildSObjectLocalFieldUpdater(fieldMapping, childRelationshipMap);
        
        //LeadTypeChecker leadTypeChecker = new LeadTypeChecker(leads_current);
        //leadTypeChecker.check();
        
        sObjectCountrySetter.EqualiseCountryAndCodes(leads_current, leads_old, Lead.Country.getDescribe());
        ownerMarketSetter.SetMarketFromOwner(leads_current, Schema.Lead.Owners_Market__c);
        ownerISOSetter.SetISOCodes(leads_current);
        childSObjectLocalFieldUpdater.UpdateChildren(leads_current, leads_old);
        
        SetPreferredRetailerIfBlank(leads_current);
        UpdateLeadDetailsOnBefore(leads_current, leads_old);
    }
    
    public void PostCreate(List<Lead> leads) {
        if(!system.isFuture() && !System.isBatch()){
            webToLeadLookUpSetter.PopulateLeadQueueData(JSON.serialize(leads));
        }
        UdaanUtility.IndiaUdaan_createTask(leads);
        RecordSharer sharer = new RecordSharer();  
        LeadTerritoryAssignmentHandler territoryAssignmentHandler = new LeadTerritoryAssignmentHandler();
        coopStatsRollUpLogic.updateLeadCount(SObjectUtilities.GetFieldValuesId(leads, 'Campaign_Activity__c')); //added by Masthan as part of COOP-Sprint1
        try{            
            sharer.Share_Leads(leads);          //LB don't want the trigger to error if the sharing fails
            territoryAssignmentHandler.applyKoreanRules(leads); 
        }catch (Exception  e){}
        
        List<Lead> LeadstoConvert = new List<Lead>();
        Set<Id> LeadOwnerQIds = new Set<Id>();
        for(Lead Ld : leads){
            if(Ld.Country_ISO_Code__c == 'JP' && Ld.Secondary_Lead_Source__c != null && Ld.Secondary_Lead_Source__c == SHOWROOM_VISIT_FORM){
                system.debug('£££ Filtering leads '+ Ld.Secondary_Lead_Source__c);
                system.debug('£££ Lead Preferred Retailer '+ Ld.Preferred_Retailer__c);
                LeadstoConvert.add(Ld);
                if(string.valueOf(Ld.OwnerId).startsWith('00G')){
                    LeadOwnerQIds.add(Ld.OwnerId);
                }
                system.debug('££££ LeadOwnerQIds '+ LeadOwnerQIds);
            }
        }
        system.debug('LeadstoConvert -->  '+LeadstoConvert);
        system.debug('LeadOwnerQIds -->  '+LeadOwnerQIds); 
        if(!system.isFuture() 
           && !System.isBatch() 
           && LeadstoConvert.size() > 0){
               LeadConversionHandler.convertleads(json.serialize(LeadstoConvert),LeadOwnerQIds);
           }

           
           
    }
    
    public void PostUpdate(List<Lead> leads, Map<Id, Lead> oldAccountMap) {
        DuplicateOpportunityContactRoleRemover duplicateOpportunityContactRoleRemover = new DuplicateOpportunityContactRoleRemover();
        
        List<Lead> convertedLeads = new List<Lead>(); 
        set<Id> campaignActivitiesList = new Set<Id>(); //added by Masthan as part of COOP-Sprint1
        for (Lead l : leads) {
            Lead  LeadOLD = oldAccountMap.get(l.Id);
            if (l.IsConverted && (LeadOLD == null || leadOLD.IsConverted == False) ) {
                convertedLeads.add(l);
            }
            //Start - added by Masthan as part of COOP-Sprint1
            if(l.Campaign_Activity__c != LeadOLD.Campaign_Activity__c){
                campaignActivitiesList.add(l.Campaign_Activity__c);
                campaignActivitiesList.add(LeadOLD.Campaign_Activity__c);
            }
            //Stop - added by Masthan as part of COOP-Sprint1
        }
        
        duplicateOpportunityContactRoleRemover.DeleteDuplicateContactRoles(convertedLeads);
        if(campaignActivitiesList.size() > 0) coopStatsRollUpLogic.updateLeadCount(campaignActivitiesList); //added by Masthan as part of COOP-Sprint1
        
        if (convertedLeads.size() > 0) {
            SetCheckboxesForConvertedLead setBools = new SetCheckboxesForConvertedLead(); 
            setBools.setCheckboxes(convertedLeads);
        }
        
        //DJB added
        RecordSharer sharer = new RecordSharer();  
        LeadTerritoryAssignmentHandler territoryAssignmentHandler = new LeadTerritoryAssignmentHandler();
        try{            
            sharer.Share_Leads(leads);          //LB don't want the trigger to error if the sharing fails 
            territoryAssignmentHandler.applyKoreanRules(leads);
        }catch (Exception  e){}
    }
    
    
    public void PostDelete(List<Lead> leads) 
    { 
        system.debug('leads'+leads);
        coopStatsRollUpLogic.updateLeadCount(SObjectUtilities.GetFieldValuesId(leads, 'Campaign_Activity__c')); //added by Masthan as part of COOP-Sprint1
        
    }
    
    public void PostUnDelete(List<Lead> leads) 
    { 
        system.debug('leads'+leads);
        coopStatsRollUpLogic.updateLeadCount(SObjectUtilities.GetFieldValuesId(leads, 'Campaign_Activity__c')); //added by Masthan as part of COOP-Sprint1
        
    }
    
    public boolean isBrowserUser()
    {
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        String currentUrl = String.valueOf(URL.getCurrentRequestUrl()).toLowerCase();
        
        if(currentUrl.containsIgnoreCase('/'+keyPrefix+'/e') || currentUrl.containsIgnoreCase('/aura')){        
            return true;
        }
        
        return false;
    }
    
    public void duplicateChecker(List<Lead> newLeads){
        
        //Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        //String keyPrefix = r.getKeyPrefix();
        
        //String currentUrl = String.valueOf(URL.getCurrentRequestUrl()).toLowerCase();
        
        //if(!(currentUrl.containsIgnoreCase('/'+keyPrefix+'/e') || currentUrl.containsIgnoreCase('/aura'))){
        if(!isBrowserUser()){
            for(Lead acct: newLeads){
                if(currentUser != null && String.IsBlank(currentUser.country_iso_code__c)){  
                    acct.Pass_Duplicate_Rule__c = true;                 
                }
            }
        }
    }
    
    public void mobilePhonePopulate(List<Lead> newLeads){
        List<string> countryCodes = new List<string>();
        Map < String, MENA_Country_Codes__mdt > retrieveCustomMetadataMap = MENA_Country_Codes__mdt.getAll();
        // for(MENA_Country_Codes__mdt rec : [Select DeveloperName from MENA_Country_Codes__mdt])
        for(MENA_Country_Codes__mdt rec : retrieveCustomMetadataMap.values())
            countryCodes.add(rec.DeveloperName);
        for(Lead leadRec : newLeads){
            if(countryCodes.contains(leadRec.Country_ISO_Code__c)){
                if(string.isBlank(leadRec.Phone) && string.isNotBlank(leadRec.MobilePhone))
                    leadRec.Phone = leadRec.MobilePhone;
                else if(string.isNotBlank(leadRec.Phone) && string.isBlank(leadRec.MobilePhone))
                    leadRec.MobilePhone = leadRec.Phone;
            }
        }
    }
    
    private void DefaultPurchaseTypeToNewVehicle(List<Lead> leads) {
        for(Lead l : leads){
            if(l.Type__c == 'Product' && l.Purchase_Type__c == null){
                l.Purchase_Type__c = 'New Vehicle';
            }
        }
    }
    
     private void DefaultRecordTypeForShuhoLeads(List<Lead> leads) {
         Id leadRecTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId();
          for(Lead Ld : leads){
             if(Ld.Country_ISO_Code__c == 'JP' && Ld.Secondary_Lead_Source__c != null && Ld.Secondary_Lead_Source__c == SHOWROOM_VISIT_FORM){
               ld.recordTypeId = leadRecTypeId;
               ld.Enquiry_Type__c = 'Generic';
             }
        }
     }
    
    private void UpdateLeadDetailsOnBefore(List<Lead> leads, List<Lead> oldleads) {
        //Update Enquiry Type For Mena
        for(integer i = 0; i < leads.size(); i++){
            if(leads[i].RecordTypeId == Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId()){
                // if(oldleads[i].RecordTypeId != leads[i].RecordTypeId && oldleads[i].RecordTypeId != Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead_Process_Streamlined').getRecordTypeId() && leads[i].Enquiry_Type__c == null){
                if(oldleads[i].RecordTypeId != null && oldleads[i].RecordTypeId != leads[i].RecordTypeId && oldleads[i].RecordTypeId != Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead_Process_Streamlined').getRecordTypeId() && leads[i].Enquiry_Type__c == null){
                    
                    leads[i].Enquiry_Type__c = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(oldleads[i].RecordTypeId).getName();
                    leads[i].Status = 'New';
                }
            }

            //Update Contactability Last Modified Date
            if (leads[i].Email != oldleads[i].Email || leads[i].Phone != oldleads[i].Phone || leads[i].MobilePhone != oldleads[i].MobilePhone) leads[i].Contactability_Last_Modified_Date__c = Datetime.now();
        }
    }
    
    //CXPD-922
    public boolean isSpam(Lead ld)
    {
        //CXPD-1631
        string name = ld.firstname + ld.lastname;
        //check if name contains numbers
        if(name.isNumeric()) return true;
        
        //check if name contains multiple upper case
        String[] chars = name.split('');
        integer upper = 0; 
        
        /*for(integer i = 0; i < name.length(); i++) 
        { 
            
            if (chars[i].isAllUppercase()) 
                upper++; 
            if(upper > 2)
                return true;
        }*/
        //if(upper > 2) return true;
        //check if Email and name contains text in configured spam list
        Map<string,Vietnam_Spam_Identifier__mdt> mapSpamIdentifier = Vietnam_Spam_Identifier__mdt.getAll();
        for(string st : mapSpamIdentifier.keyset()) {
            if(mapSpamIdentifier.get(st).Field__c == 'Email' && ld.Email != null && ld.Email.contains(mapSpamIdentifier.get(st).label))
                return true;
            if(mapSpamIdentifier.get(st).Field__c == 'Name' && ld.Description != null && ld.Description.contains(mapSpamIdentifier.get(st).label))
                return true;
        }
        
        
        return false;
    }
    
    /*public static void CXPLeads(List<Lead> leadsList) {
        List<string> allowedCountries = new List<string>();
        for(MENA_DMS_Integration_Identifier__mdt rec : [Select MasterLabel from MENA_DMS_Integration_Identifier__mdt])
            allowedCountries.add(rec.MasterLabel);
        
        List<string> leadIds = new List<string>();
        for(Lead rec : leadsList){
            if(allowedCountries.contains(rec.Country_ISO_Code__c) && rec.Enquiry_Type__c != 'KMI' && rec.Status != 'Lost')
                leadIds.add(rec.id);
        }
        System.debug('leadIds::::'+leadIds);
        
        List<string> recIds = new List<string>();
        for(Lead rec : [Select id from Lead where id in: leadIds and Preferred_Retailer__r.DMS_Type__c = 'CDK']){
            recIds.add(rec.Id);
        }
        System.debug('recIds::::'+recIds);
        
        //Send To Mulesoft for CDK
        if(recIds.size()>0)
            LeadHandler.CXPtoDMS(recIds);
    }
    
    
    @future (callout=true)                              //Send To Mulesoft for CDK
    public static void CXPtoDMS(List<String> recIds) {
        List<string> updatedRecIds = new List<string>();
        for(Lead rec : [Select id from Lead where id in: recIds and Preferred_Retailer__r.DMS_Type__c = 'CDK' and Enquiry_Type__c != 'KMI' and Status != 'Lost']){
            updatedRecIds.add(rec.Id);
        }
        List<Lead> leadsToUpdate = new List<Lead>();
        BaseMulesoftConnector conn = new BaseMulesoftConnector(Constants.CALLOUT_ENDPOINT_SETTINGS_DEVELOPER_NAME_MULESOFT_CXP_TO_CDK);
        for(string rec : updatedRecIds){
            CXPtoCDKWrapper.inputWrapper requestPayload = new  CXPtoCDKWrapper.inputWrapper(rec);
            String body = Json.serialize(requestPayload);
            System.debug(body);
            String response = conn.doCallout(HttpMethods.POST, body);
            If(response.containsAny(label.CDK_Lead_Success_Message ))
                leadsToUpdate.add(new Lead(id = rec, Sent_To_CDK__c = True));
            else
                leadsToUpdate.add(new Lead(id = rec, CDK_Integration_Error__c = response, CDK_Error__c = true));
        }
        
        if(leadsToUpdate.size()>0)
            update leadsToUpdate;
    }*/
    
    public static void leadOwner(List<Lead> leadsList) {
        Map<string, MENA_Lead_Conversion_settings__mdt > leadConvertMap = new Map<string, MENA_Lead_Conversion_settings__mdt>();
        /**
        for(MENA_Lead_Conversion_settings__mdt rec : [Select Country_Code__c, Owner_Id__c from MENA_Lead_Conversion_settings__mdt where Used_In__c = 'Lead Handler'])
            leadConvertMap.put(rec.Country_Code__c, rec);
        **/
        for(MENA_Lead_Conversion_settings__mdt rec: MENA_Lead_Conversion_settings__mdt.getAll().values()) {
            if(rec.Used_In__c == 'Lead Handler') {
                leadConvertMap.put(rec.Country_Code__c, rec);
            }
        }
        
        List<string> accIds = new List<string>();
        for(Lead rec : leadsList)
            accIds.add(rec.Preferred_Retailer__c);
        
        if(accIds.size()>0){
            List<string> finalAccIds = new List<string>();
            for(Account accRec : [Select id from Account where id in: accIds and DMS_Type__c = 'JobRouter'])
                finalAccIds.add(accRec.id);
            
            if(finalAccIds.size()>0){
                for(Lead rec : leadsList){
                    if(rec.Enquiry_Type__c != 'KMI' && finalAccIds.contains(rec.Preferred_Retailer__c) && rec.Status != 'Lost' && leadConvertMap.containsKey(rec.Country_ISO_Code__c))
                        rec.ownerId = leadConvertMap.get(rec.Country_ISO_Code__c).Owner_Id__c;
                }
            }
        }
    }
    
    public static void convertLeads(Map<id,Lead> leadsMap) {
        
        System.enqueueJob(new LeadConvertQueueable(leadsMap));
    }
}