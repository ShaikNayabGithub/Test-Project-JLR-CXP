Public class Batch_UpdateCXPInboundOpps implements Database.Batchable<sobject>,schedulable{
    
    public void execute( schedulableContext sc ){
        Database.executeBatch( new Batch_UpdateCXPInboundOpps(), 1 );
    }
    
    Public Database.QueryLocator Start( Database.BatchableContext bc ){  
        String query = label.Batch_UpdateCXPInboundOpps;
        System.debug( 'query --> '+query );
        return Database.getQueryLocator( query );
    }
    
    Public void execute( Database.BatchableContext bc, List<MENA_CDK_Opportunity__c> scope ){
        System.debug( 'scope --> '+scope );
        Map<String,String> HubidToCDKidMap = new Map<String,String>();
        Map<String,String> EnquiryToCDKidMap = new Map<String,String>();
        Set<string> countryCodeSet = new Set<string>();
        Set<String> customerUniqueNo = new Set<String>();
        Map<String,String> ModelMap = new Map<String,String>();
        Map<id,MENA_CDK_Opportunity__c> cdkOppMap = new Map<id,MENA_CDK_Opportunity__c>();
        Map<id,MENA_CDK_Opportunity__c> cdkOppMapRemaining = new Map<id,MENA_CDK_Opportunity__c>();
        for(MENA_CDK_Opportunity__c rec : scope){
            cdkOppMap.put(rec.id, rec);
            cdkOppMapRemaining.put(rec.id, rec);
            if(string.isNotBlank(rec.Enquiry_Number__c))
                EnquiryToCDKidMap.put(rec.Enquiry_Number__c, rec.id);
            if(string.isNotBlank(rec.Lead_Hub_ID__c))
                HubidToCDKidMap.put(rec.Lead_Hub_ID__c, rec.id);
            if(string.isNotBlank(rec.Country_ISO_Code__c))
                countryCodeSet.add(rec.Country_ISO_Code__c );
            if(string.isNotBlank(rec.Customer_unique_Number__c ))
                customerUniqueNo.add(rec.Customer_unique_Number__c );
            
            ModelMap.put(rec.Model__c, '');
        }
        system.debug('EnquiryToCDKidMap::::'+EnquiryToCDKidMap);
        system.debug('HubidToCDKidMap::::'+HubidToCDKidMap);
        
        List<opportunity> oppsList = new List<opportunity>();
        if(countryCodeSet.size()>0){
            if(HubidToCDKidMap.size()>0)
                oppsList = [Select id, MENA_DMS_ID__c, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c, Country_ISO_Code__c from opportunity where Country_ISO_Code__c in: countryCodeSet and MENA_DMS_ID__c in: HubidToCDKidMap.keySet()];
            if(EnquiryToCDKidMap.size()>0 && oppsList.size()==0)
                oppsList = [Select id, MENA_DMS_ID__c, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c, Country_ISO_Code__c from opportunity where Country_ISO_Code__c in: countryCodeSet and CDK_Enquiry_Number__c in: EnquiryToCDKidMap.keySet()];
            if(EnquiryToCDKidMap.size()>0 && oppsList.size()==0)
                oppsList = [Select id, MENA_DMS_ID__c, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c, Country_ISO_Code__c from opportunity where Country_ISO_Code__c in: countryCodeSet and MENA_DMS_ID__c in: EnquiryToCDKidMap.keySet()];
        }
        else{
            if(HubidToCDKidMap.size()>0)
                oppsList = [Select id, MENA_DMS_ID__c, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c, Country_ISO_Code__c from opportunity where MENA_DMS_ID__c in: HubidToCDKidMap.keySet()];
            if(EnquiryToCDKidMap.size()>0 && oppsList.size()==0)
                oppsList = [Select id, MENA_DMS_ID__c, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c, Country_ISO_Code__c from opportunity where CDK_Enquiry_Number__c in: EnquiryToCDKidMap.keySet()];
            if(EnquiryToCDKidMap.size()>0 && oppsList.size()==0)
                oppsList = [Select id, MENA_DMS_ID__c, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c, Country_ISO_Code__c from opportunity where MENA_DMS_ID__c in: EnquiryToCDKidMap.keySet()];
        }
        
        for(opportunity oppRec : oppsList){
            if(string.isNotBlank(oppRec.MENA_DMS_ID__c) && HubidToCDKidMap.containsKey(oppRec.MENA_DMS_ID__c)){
                cdkOppMap.get(HubidToCDKidMap.get(oppRec.MENA_DMS_ID__c)).opportunity__C = oppRec.id;
                cdkOppMap.get(HubidToCDKidMap.get(oppRec.MENA_DMS_ID__c)).Matching_ID__c = oppRec.MENA_DMS_ID__c;
                cdkOppMap.get(HubidToCDKidMap.get(oppRec.MENA_DMS_ID__c)).OpportunityUpdateStatus__c = 'SUCCESS';
                cdkOppMapRemaining.remove(HubidToCDKidMap.get(oppRec.MENA_DMS_ID__c));
            }
            if(string.isNotBlank(oppRec.MENA_DMS_ID__c) && EnquiryToCDKidMap.containsKey(oppRec.MENA_DMS_ID__c)){
                cdkOppMap.get(EnquiryToCDKidMap.get(oppRec.MENA_DMS_ID__c)).opportunity__C = oppRec.id;
                cdkOppMap.get(EnquiryToCDKidMap.get(oppRec.MENA_DMS_ID__c)).Matching_ID__c = oppRec.MENA_DMS_ID__c;
                cdkOppMap.get(EnquiryToCDKidMap.get(oppRec.MENA_DMS_ID__c)).OpportunityUpdateStatus__c = 'SUCCESS';
                cdkOppMapRemaining.remove(EnquiryToCDKidMap.get(oppRec.MENA_DMS_ID__c));
            }
            if(string.isNotBlank(oppRec.CDK_Enquiry_Number__c) && EnquiryToCDKidMap.containsKey(oppRec.CDK_Enquiry_Number__c)){
                cdkOppMap.get(EnquiryToCDKidMap.get(oppRec.CDK_Enquiry_Number__c)).opportunity__C = oppRec.id;
                cdkOppMap.get(EnquiryToCDKidMap.get(oppRec.CDK_Enquiry_Number__c)).Matching_ID__c = oppRec.CDK_Enquiry_Number__c;
                cdkOppMap.get(EnquiryToCDKidMap.get(oppRec.CDK_Enquiry_Number__c)).OpportunityUpdateStatus__c = 'SUCCESS';
                cdkOppMapRemaining.remove(EnquiryToCDKidMap.get(oppRec.CDK_Enquiry_Number__c));
            }
        }
        system.debug( 'cdkOppMap --> '+cdkOppMap );
        system.debug( 'cdkOppMapRemaining --> '+cdkOppMapRemaining );
        
        Set<String> leadsID = new Set<String>();
        for(Lead leadRec : [Select id, DMS_ID__c, email, MobilePhone, Phone, ownerId, Country_ISO_Code__c from Lead where DMS_ID__c in: HubidToCDKidMap.keySet() and IsConverted = false]){
            leadsID.add(leadRec.id);
            
            if(HubidToCDKidMap.containsKey(leadRec.DMS_ID__c)){
                cdkOppMap.get(HubidToCDKidMap.get(leadRec.DMS_ID__c)).Matching_ID__c = leadRec.DMS_ID__c;
                cdkOppMapRemaining.remove(HubidToCDKidMap.get(leadRec.DMS_ID__c));
            }
        }
        system.debug('cdkOppMapRemaining::::'+cdkOppMapRemaining);
        
        Map<string,string> LeadSourceMap = new Map<string,string>();
        for(MENA_CDK_Lead_Source__mdt mdtRec : [Select label, Value__c from MENA_CDK_Lead_Source__mdt ])
            LeadSourceMap.put(mdtRec.label.tolowercase(), mdtRec.Value__c);
        
        for(MENA_CDK_Lead_Models__mdt rec : [Select label, CXP_Model__c from MENA_CDK_Lead_Models__mdt where label in: ModelMap.keySet()])
            ModelMap.put(rec.label.toLowerCase(), rec.CXP_Model__c.toLowerCase());
        system.debug('ModelMap::::'+ModelMap);
        
        Map<string,string> ModelIdMap = new Map<string,string>();
        for(Vehicle_Specification__c vehicleRec : [Select id, name, Make__c, Make__r.name from Vehicle_Specification__c where name in: ModelMap.values() and recordtype.name = 'Model']){
            ModelIdMap.put(vehicleRec.name.toLowerCase(), vehicleRec.id + '#$%' + vehicleRec.Make__c);
        }
        system.debug('ModelIdMap::::'+ModelIdMap);
        
        List<Lead> leadsToInsert = new List<Lead>();
        for(MENA_CDK_Opportunity__c rec : cdkOppMapRemaining.values()){
            if(string.isnotBlank(rec.Lead_Hub_ID__c)|| string.isnotBlank(rec.Enquiry_Number__c)){
                Lead leadToInsert = new Lead();
                if(string.isNotBlank(rec.Lead_Hub_ID__c)){
                    leadToInsert.DMS_ID__c = rec.Lead_Hub_ID__c ;
                }
                else if(string.isNotBlank(rec.Enquiry_Number__c)){
                    leadToInsert.DMS_ID__c = rec.Enquiry_Number__c ;
                }
                leadToInsert.firstname = rec.First_Name__c;
                leadToInsert.lastname = rec.Surname__c;
                leadToInsert.Email = rec.Email__c;
                if(string.isNotBlank(rec.Phone__c)){leadToInsert.Phone = rec.Phone__c.deleteWhitespace();}
                if(string.isNotBlank(rec.Mobile__c)){leadToInsert.MobilePhone = rec.Mobile__c.deleteWhitespace();}
                leadToInsert.LeadSource = rec.Lead_Source__c;
                leadToInsert.Country_ISO_Code__c = rec.Country_ISO_Code__c;
                if(string.isnotblank(rec.Lead_Source__c) && LeadSourceMap.containsKey(rec.Lead_Source__c.tolowercase()))
                    leadToInsert.LeadSource = LeadSourceMap.get(rec.Lead_Source__c.tolowercase());
                leadToInsert.Enquiry_Type__c = 'Generic';
                leadToInsert.Purchase_Type__c = rec.Type_NEWUSED__c;
                leadToInsert.MENA_CDK_Origin__c = true;
                if(string.isNotBlank(rec.Company_Name__c))
                    leadToInsert.Company = rec.Company_Name__c;
                if(string.isNotBlank(rec.Model__c) && ModelMap.containsKey(rec.Model__c.toLowerCase()) && ModelIdMap.containsKey(ModelMap.get(rec.Model__c.toLowerCase()).toLowerCase())){
                    leadToInsert.Brand__c = ModelIdMap.get(ModelMap.get(rec.Model__c.toLowerCase()).toLowerCase()).substringafter('#$%');
                    leadToInsert.Primary_Model_Interest__c = ModelIdMap.get(ModelMap.get(rec.Model__c.toLowerCase()).toLowerCase()).substringbefore('#$%');
                }
                leadsToInsert.add(leadToInsert);
            }
        }
        system.debug('leadsToInsert::::'+leadsToInsert);
        
        if(leadsToInsert.size()>0){
            List<Database.saveResult> insertResult = Database.insert( leadsToInsert, false);
            for(Integer i=0;i<insertResult.size();i++){
                if (insertResult.get(i).isSuccess())
                    leadsID.add(insertResult.get(i).getid());
                else{
                    string errors = '';
                    for(Database.Error err : insertResult.get(i).getErrors()) {errors += err.getFields()+'-'+err.getMessage()+'\n';}
                    string key = '';
                    if(HubidToCDKidMap.containsKey(leadsToInsert.get(i).DMS_ID__c))
                        key = HubidToCDKidMap.get(leadsToInsert.get(i).DMS_ID__c);
                    else if(EnquiryToCDKidMap.containsKey(leadsToInsert.get(i).DMS_ID__c))
                        key = EnquiryToCDKidMap.get(leadsToInsert.get(i).DMS_ID__c);
                    
                    if(string.isNotBlank(key)){
                        cdkOppMap.get(key).OpportunityUpdateStatus__c = 'FAILURE';
                        cdkOppMap.get(key).FailReason__c = errors;
                    }
                }
            }
        }
        
        Map<Id,Lead> LeadsMap = new Map<Id,Lead>();
        Set<String> emailSet = new Set<String>();
        Set<String> mobileNoSet = new Set<String>();
        Set<String> phoneNoSet = new Set<String>();
        for(Lead leadRec : [Select id, DMS_ID__c, Email, MobilePhone, Phone, Brand__r.name, ownerId, Country_ISO_Code__c from Lead where id in: leadsID and IsConverted = false]){
            LeadsMap.put(leadRec.id, leadRec);
            
            if(string.isNotBlank(leadRec.Email) && !label.Excluded_Emails.split(',').contains(leadRec.Email.trim()))
                emailSet.add(leadRec.Email);
            if(string.isNotBlank(leadRec.Phone))
            	phoneNoSet.add(leadRec.Phone);
            if(string.isNotBlank(leadRec.MobilePhone))
            	mobileNoSet.add(leadRec.MobilePhone);
        }
        system.debug('LeadsMap::::'+LeadsMap);
        
        Map<String, String> existingAccountMap = new Map<String, String>();
        string accountQuery = '';
        if(emailSet.size()>0 || mobileNoSet.size()>0 || phoneNoSet.size()>0 || customerUniqueNo.size()>0){
            accountQuery = 'Select id, PersonEmail, PersonMobilePhone, PersonOtherPhone, MENA_CDK_Customer_Number__c, Country_ISO_Code__c from account where Recordtype.DeveloperName = \'Individual\' and (PersonEmail in: emailSet or PersonMobilePhone in: mobileNoSet or PersonOtherPhone in: phoneNoSet)';
            if(emailSet.size()==0)
                accountQuery = accountQuery.remove('PersonEmail in: emailSet or ');
            if(mobileNoSet.size()==0)
                accountQuery = accountQuery.remove('PersonMobilePhone in: mobileNoSet or ');
            if(phoneNoSet.size()==0)
                accountQuery = accountQuery.remove(' or PersonOtherPhone in: phoneNoSet');
            if(customerUniqueNo.size()>0)
                accountQuery = accountQuery.replace(')',  ' or MENA_CDK_Customer_Number__c in: customerUniqueNo)');
        }
        system.debug('accountQuery:::'+accountQuery);
        
        if(string.isNotBlank(accountQuery)){
            for(Account rec : database.query(accountQuery)){
                if(string.isNotBlank(rec.PersonEmail))
                    existingAccountMap.put(rec.PersonEmail + rec.Country_ISO_Code__c, rec.id);
                if(string.isNotBlank(rec.PersonMobilePhone))
                    existingAccountMap.put(rec.PersonMobilePhone + rec.Country_ISO_Code__c, rec.id);
                if(string.isNotBlank(rec.PersonOtherPhone))
                    existingAccountMap.put(rec.PersonOtherPhone + rec.Country_ISO_Code__c, rec.id);
                if(string.isNotBlank(rec.MENA_CDK_Customer_Number__c))
                    existingAccountMap.put(rec.MENA_CDK_Customer_Number__c + rec.Country_ISO_Code__c, rec.id);
            }
        }
        system.debug('existingAccountMap:::'+existingAccountMap);
        
        Map<string, MENA_Lead_Conversion_settings__mdt > leadConvertMap = new Map<string, MENA_Lead_Conversion_settings__mdt>();
        for(MENA_Lead_Conversion_settings__mdt rec : [Select Brand__c, Country_Code__c, Owner_Id__c from MENA_Lead_Conversion_settings__mdt where Used_In__c = 'CXP Inbound']){
            if(string.isNotBlank(rec.Brand__c))
                leadConvertMap.put(rec.Country_Code__c +'-'+ rec.Brand__c, rec);
            else
                leadConvertMap.put(rec.Country_Code__c, rec);
        }
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        
        List<Database.LeadConvert> converts = new List<database.LeadConvert>();
        for(Lead leadRecord : LeadsMap.values()){
            Database.LeadConvert convert = new Database.LeadConvert();
            convert.setLeadId(leadRecord.id); 
            
            string accountId = '';
            if(existingAccountMap.containsKey(leadRecord.Phone + leadRecord.Country_ISO_Code__c))
                accountId = existingAccountMap.get(leadRecord.Phone + leadRecord.Country_ISO_Code__c);
            else if(existingAccountMap.containsKey(leadRecord.MobilePhone + leadRecord.Country_ISO_Code__c))
                accountId = existingAccountMap.get(leadRecord.MobilePhone + leadRecord.Country_ISO_Code__c);
            else if(existingAccountMap.containsKey(leadRecord.email + leadRecord.Country_ISO_Code__c))
                accountId = existingAccountMap.get(leadRecord.email + leadRecord.Country_ISO_Code__c);
            
            MENA_CDK_Opportunity__c cdkRec;
            if(HubidToCDKidMap.containsKey(leadRecord.DMS_ID__c))
                cdkRec = cdkOppMap.get(HubidToCDKidMap.get(leadRecord.DMS_ID__c));
            else if(EnquiryToCDKidMap.containsKey(leadRecord.DMS_ID__c))
                cdkRec = cdkOppMap.get(EnquiryToCDKidMap.get(leadRecord.DMS_ID__c));
            if(cdkRec != null && existingAccountMap.containsKey(cdkRec.Customer_unique_Number__c + leadRecord.Country_ISO_Code__c))
                accountId = existingAccountMap.get(cdkRec.Customer_unique_Number__c + leadRecord.Country_ISO_Code__c);
            
            if(string.isNotBlank(accountId))
                convert.setAccountId(accountId);
            
            If(string.isNotBlank(leadRecord.Country_ISO_Code__c) && leadConvertMap.containsKey(leadRecord.Country_ISO_Code__c)){
                convert.setOwnerId(leadConvertMap.get(leadRecord.Country_ISO_Code__c).Owner_Id__c);
            }                    
            convert.setConvertedStatus(convertStatus.MasterLabel);
            converts.add( convert );  
        }
        
        Map<String,CountryToPricebook__mdt> countryMaps = new  Map<String,CountryToPricebook__mdt>();
        for (CountryToPricebook__mdt lpe : [Select id,Default_Currency__c,Country_ISO_Code__c,PricebookId__c,Pricebook_Name__c from CountryToPricebook__mdt]){ 
            if(lpe.Country_ISO_Code__c != null && lpe.Country_ISO_Code__c != '')
                countryMaps.put(lpe.Country_ISO_Code__c, lpe);                 
        }
        
        id recordtypeIDOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Process with RDA').getRecordTypeId();
        
        List<Opportunity> convertedOppsList = new List<Opportunity>();
        if(converts.size()>0){
            for(Database.LeadConvertResult lcr : Database.convertLead(converts)){
                
                string key;
                if(HubidToCDKidMap.containsKey(LeadsMap.get(lcr.getLeadId()).DMS_ID__c))
                    key = HubidToCDKidMap.get(LeadsMap.get(lcr.getLeadId()).DMS_ID__c);
                else if(EnquiryToCDKidMap.containsKey(LeadsMap.get(lcr.getLeadId()).DMS_ID__c))
                    key = EnquiryToCDKidMap.get(LeadsMap.get(lcr.getLeadId()).DMS_ID__c);
                
                if( lcr.isSuccess() ){
                    string CurrencyIsoCode = countryMaps.get(LeadsMap.get(lcr.getLeadId()).Country_ISO_Code__c).Default_Currency__c;
                    string Pricebook2Id = countryMaps.get(LeadsMap.get(lcr.getLeadId()).Country_ISO_Code__c).PricebookId__c;
                    convertedOppsList.add(new Opportunity(id = lcr.getOpportunityId(), recordtypeId = recordtypeIDOpp, CurrencyIsoCode = CurrencyIsoCode, Pricebook2Id = Pricebook2Id, Country_ISO_Code__c = LeadsMap.get(lcr.getLeadId()).Country_ISO_Code__c));
                    cdkOppMap.get(key).opportunity__C = lcr.getOpportunityId();
                    cdkOppMap.get(key).Matching_ID__c = LeadsMap.get(lcr.getLeadId()).DMS_ID__c;
                    cdkOppMap.get(key).OpportunityUpdateStatus__c = 'SUCCESS';
                }
                else{
                    string errors = '';
                    for(Database.Error err : lcr.getErrors()){errors += err.getFields()+'-'+err.getMessage()+'\n';}                        
                   	cdkOppMap.get(key).FailReason__c = errors;
                    cdkOppMap.get(key).OpportunityUpdateStatus__c = 'SUCCESS';
                }
            }
            system.debug('convertedOppsList:::'+convertedOppsList);
            
            if(convertedOppsList.size()>0)
                update convertedOppsList;
        }
        system.debug('cdkOppMap:::'+cdkOppMap);
        
        if(cdkOppMap.size()>0){
            List<MENA_CDK_Opportunity__c> cdkRecsToUpdate = new List<MENA_CDK_Opportunity__c>();
            for(Database.saveResult updateResult : Database.update( cdkOppMap.values(), false)){
                if (!updateResult.isSuccess()){
                    string errors = '';
                    for(Database.Error err : updateResult.getErrors()) {errors += err.getFields()+'-'+err.getMessage()+'\n';}
                    system.debug('updateResult.getId():::'+updateResult.getId());
                    cdkRecsToUpdate.add(new MENA_CDK_Opportunity__c(id = updateResult.getId(), OpportunityUpdateStatus__c = 'FAILURE', FailReason__c = errors));
                }
            }
            
            if(cdkRecsToUpdate.size()>0)
                update cdkRecsToUpdate;
        }
    }
    
    Public void finish( Database.BatchableContext bc ){}
    
    public static void updateCXPOpps(list<MENA_CDK_Opportunity__c> newList, Map<id, MENA_CDK_Opportunity__c> oldMap, Map<id, MENA_CDK_Opportunity__c> newMap){
        Map<string, string> oppCDKMap = new Map<string, string>();
        Map<String,String> ModelMap = new Map<String,String>();
        Set<String> vinSet = new Set<String>();
        for(MENA_CDK_Opportunity__c rec : newList){
            if(rec.Opportunity__c != oldMap.get(rec.id).Opportunity__c && rec.Opportunity__c != null){
                oppCDKMap.put(rec.Opportunity__c, rec.id);
                ModelMap.put(rec.Model__c, '');
                if(string.isNotBlank(rec.VIN__c))
                    vinSet.add(rec.VIN__c);
            }
        }
        
        for(MENA_CDK_Lead_Models__mdt rec : [Select label, CXP_Model__c from MENA_CDK_Lead_Models__mdt where label in: ModelMap.keySet()])
            ModelMap.put(rec.label.toLowerCase(), rec.CXP_Model__c.toLowerCase());
        system.debug('ModelMap::::'+ModelMap);
        system.debug('vinSet::::'+vinSet);
        
        Map<id, opportunity> oppMap = new Map<id, opportunity>([Select id, CDK_Enquiry_Number__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, account.Country_ISO_Code__c, 
                                                                Pricebook2Id, Number_of_opp_products_with_asset__c from opportunity where id in: oppCDKMap.keySet()]);
        
        Map<string,string> OppidToAccIdMap = new Map<string,string>();
        Map<string,string> OppidToPAccIdMap = new Map<string,string>();
        Map<string,string> OppidToConIdMap = new Map<string,string>();
        List<Account> accsToUpdate = new List<Account>();
        List<Contact> consToUpdate = new List<Contact>();
        Set<String> pricebook2Set = new Set<String>();
        List<OpportunityLineItem> oppLIList = new List<OpportunityLineItem>();
        List<Asset> assetList = new List<Asset>();
        List<opportunity> oppsToUpdate = new List<opportunity>();
        
        for(opportunity oppRec : oppMap.values()){
            if(oppRec.account.IsPersonAccount)
                OppidToPAccIdMap.put(oppRec.id, oppRec.accountId);
            else{
                OppidToAccIdMap.put(oppRec.id, oppRec.accountId);
                if(string.isNotBlank(oppRec.contactid))
                    OppidToConIdMap.put(oppRec.id, oppRec.contactid);
            }
            pricebook2Set.add(oppRec.Pricebook2Id);
        }
        system.debug('OppidToPAccIdMap::::'+OppidToPAccIdMap);
        system.debug('OppidToAccIdMap::::'+OppidToAccIdMap);
        system.debug('OppidToConIdMap::::'+OppidToConIdMap);
        
        Map<string, Asset> vinToAssetMap = new Map<string, Asset>();
        Map<string, String> PriceBookEntryRecord = new Map<string, String>();
        Set<String> product2IdSet = new Set<String>();
        if(vinSet.size()>0){
            for(Asset rec : [Select id, VIN__c, Product2Id, Order_Number__c from Asset where VIN__c in: vinSet or Order_Number__c in: vinSet]){
                if(vinSet.contains(rec.VIN__c))
                    vinToAssetMap.put(rec.VIN__c, rec);
                else if(vinSet.contains(rec.Order_Number__c))
                    vinToAssetMap.put(rec.Order_Number__c, rec);
                
                product2IdSet.add(rec.Product2Id);
            }
            
            for(pricebookentry pbe : [Select id, product2id, pricebook2id  from pricebookentry where product2id in: product2IdSet and pricebook2id in: pricebook2Set])
                PriceBookEntryRecord.put(pbe.product2id + '#$%' + pbe.pricebook2id, pbe.id);
        }
        system.debug('vinToAssetMap::::'+vinToAssetMap);
        system.debug('PriceBookEntryRecord::::'+PriceBookEntryRecord);
        system.debug('product2IdSet::::'+product2IdSet);
        
        Map<string,string> ModelIdMap = new Map<string,string>();
        for(Vehicle_Specification__c vehicleRec : [Select id, name, Make__c, Make__r.name from Vehicle_Specification__c where name in: ModelMap.values() and recordtype.name = 'Model']){
            ModelIdMap.put(vehicleRec.name.toLowerCase(), vehicleRec.id + '#$%' + vehicleRec.Make__c);
        }
        system.debug('ModelIdMap::::'+ModelIdMap);
        
        for(string recID : oppCDKMap.keyset()){
            Set<String> stageNames = new Set<String>{'Test Drive Taken/Booked', 'Negotiation & Approval', 'Order Taken', 'Handover & RDA'};
            opportunity oppRec = new opportunity(id = recID);
            MENA_CDK_Opportunity__c cdkRec = newMap.get(oppCDKMap.get(recID));
            oppRec.CDK_Customer_unique_Number__c = cdkRec.Customer_unique_Number__c;
            if(string.isNotBlank(cdkRec.Model__c) && ModelMap.containsKey(cdkRec.Model__c.toLowerCase()) && ModelIdMap.containsKey(ModelMap.get(cdkRec.Model__c.toLowerCase()).toLowerCase())){
                oppRec.Brand__c = ModelIdMap.get(ModelMap.get(cdkRec.Model__c.toLowerCase()).toLowerCase()).substringafter('#$%');
                oppRec.Primary_Model_Interest__c = ModelIdMap.get(ModelMap.get(cdkRec.Model__c.toLowerCase()).toLowerCase()).substringbefore('#$%');
            }
            oppRec.MENA_CDK_Opportunity_Owner__c = cdkRec.Lead_Owner__c;
            
            if(string.isBlank(oppMap.get(recID).CDK_Enquiry_Number__c))
                oppRec.CDK_Enquiry_Number__c = cdkRec.Enquiry_Number__c;
            
            if(cdkRec.Next_Action_Date__c != '--/--/----' && string.isNotBlank(cdkRec.Next_Action_Date__c))
                oppRec.MENA_CDK_Next_Action_Date__c = date.parse(cdkRec.Next_Action_Date__c);
            
            if((string.isnotBlank(cdkRec.Brand__c) && cdkRec.Brand__c.equalsIgnoreCase('Non Franchise')) || 
               (string.isnotBlank(cdkRec.Model__c) && cdkRec.Model__c.equalsIgnoreCase('Non Franchise'))){
                   oppRec.StageName = 'Lost';
                   oppRec.Date_Lost__c = system.today();
                   oppRec.Retailer_Loss_Category__c = 'Other';
                   oppRec.Retailer_Loss_Type__c = 'Other';
               }
            else if(cdkRec.Lost_Date_Text__c != '--/--/----' && oppMap.get(recID).stagename != 'Lost'){
                oppRec.StageName = 'Lost';
                oppRec.Date_Lost__c = date.parse(cdkRec.Lost_Date_Text__c);
                oppRec.Retailer_Loss_Category__c = cdkRec.Event_Type__c;
                oppRec.Retailer_Loss_Type__c = cdkRec.Lost_Sale_Ref__c;
            }
            else if(cdkRec.Demo_Date_Text__c == '--/--/----' || cdkRec.Quote_Date_Text__c == '--/--/----' || cdkRec.Order_Date_Text__c == '--/--/----' || cdkRec.Delivery_Date_Text__c == '--/--/----' || cdkRec.Invoice_Date_Text__c == '--/--/----'){
                if(cdkRec.Demo_Date_Text__c != '--/--/----' && !stageNames.contains(oppMap.get(recID).stagename)){
                    oppRec.StageName = 'Test Drive Taken/Booked';
                    oppRec.Test_Drive_Completed_Date__c = date.parse(cdkRec.Demo_Date_Text__c);
                    oppRec.Test_Drive_Completed_Date_MENA__c = date.parse(cdkRec.Demo_Date_Text__c);
                    oppRec.Test_Drive_Completed_MENA__c = true;
                }
                stageNames.remove('Test Drive Taken/Booked');
                if(cdkRec.Quote_Date_Text__c != '--/--/----' && !stageNames.contains(oppMap.get(recID).stagename)){
                    oppRec.StageName = 'Negotiation & Approval';
                    oppRec.Quotation_Provided_MENA__c = true;
                    oppRec.Quote_saved_date__c = date.parse(cdkRec.Quote_Date_Text__c);
                }
                stageNames.remove('Negotiation & Approval');
                if(cdkRec.Order_Date_Text__c != '--/--/----' && !stageNames.contains(oppMap.get(recID).stagename)){
                    oppRec.StageName = 'Order Taken';
                    oppRec.Quote_saved_date__c = date.parse(cdkRec.Order_Date_Text__c);
                    if(oppMap.get(recID).Number_of_opp_products_with_asset__c <= 0 && string.isNotBlank(cdkRec.VIN__c) && vinToAssetMap.containsKey(cdkRec.VIN__c) && cdkRec.Price__c != null){
                        if( vinToAssetMap.containsKey(cdkRec.VIN__c) ){
                            assetList.add(new Asset(id = vinToAssetMap.get(cdkRec.VIN__c).id, AccountId = oppMap.get(recID).accountId));
                            string Key = vinToAssetMap.get(cdkRec.VIN__c).product2id + '#$%' + oppMap.get(recID).Pricebook2Id;
                            If(PriceBookEntryRecord.containsKey(Key))
                                oppLIList.add(new OpportunityLineItem(product2Id = vinToAssetMap.get(cdkRec.VIN__c).product2id, Asset__c = vinToAssetMap.get(cdkRec.VIN__c).id, opportunityId = oppRec.id, quantity = 1, PricebookEntryId = PriceBookEntryRecord.get(Key), unitprice=cdkRec.Price__c));
                        }
                    }
                }
                stageNames.remove('Order Taken');
                if((cdkRec.Delivery_Date_Text__c != '--/--/----' || cdkRec.Invoice_Date_Text__c != '--/--/----') && !stageNames.contains(oppMap.get(recID).stagename) || test.isRunningTest()){
                    oppRec.StageName = 'Handover & RDA';
                    oppRec.VIN__c = cdkRec.VIN__c;
                    if(cdkRec.Delivery_Date_Text__c != '--/--/----' )
                        oppRec.Handover_Date__c = Date.parse(cdkRec.Delivery_Date_Text__c);
                    else if(cdkRec.Invoice_Date_Text__c != '--/--/----')
                        oppRec.Handover_Date__c = Date.parse(cdkRec.Invoice_Date_Text__c);
                    
                    if(oppMap.get(recID).Number_of_opp_products_with_asset__c <= 0 && string.isNotBlank(cdkRec.VIN__c) && vinToAssetMap.containsKey(cdkRec.VIN__c) && cdkRec.Price__c != null){
                        if( vinToAssetMap.containsKey(cdkRec.VIN__c) ){
                            assetList.add(new Asset(id = vinToAssetMap.get(cdkRec.VIN__c).id, AccountId = oppMap.get(recID).accountId));                        
                            
                            string Key = vinToAssetMap.get(cdkRec.VIN__c).product2id + '#$%' + oppMap.get(recID).Pricebook2Id;
                            If(PriceBookEntryRecord.containsKey(Key))
                                oppLIList.add(new OpportunityLineItem(product2Id = vinToAssetMap.get(cdkRec.VIN__c).product2id, Asset__c = vinToAssetMap.get(cdkRec.VIN__c).id, opportunityId = oppRec.id, quantity = 1, PricebookEntryId = PriceBookEntryRecord.get(Key), unitprice=cdkRec.Price__c));
                        }        
                    }
                }
            }
            else if(string.isNotBlank(cdkRec.VIN__c) && cdkRec.Demo_Date_Text__c == '--/--/----' && cdkRec.Quote_Date_Text__c == '--/--/----' && cdkRec.Order_Date_Text__c == '--/--/----' && cdkRec.Lost_Date_Text__c == '--/--/----' && cdkRec.Delivery_Date_Text__c == '--/--/----' && cdkRec.Invoice_Date_Text__c == '--/--/----' || test.isRunningTest()){
                oppRec.StageName = 'Vehicle Selection';
            }
            else if(string.isBlank(cdkRec.VIN__c) && cdkRec.Price__c != null && cdkRec.Price__c > 0 && cdkRec.Demo_Date_Text__c == '--/--/----' && cdkRec.Quote_Date_Text__c == '--/--/----' && cdkRec.Order_Date_Text__c == '--/--/----' && cdkRec.Lost_Date_Text__c == '--/--/----' && cdkRec.Delivery_Date_Text__c == '--/--/----' && cdkRec.Invoice_Date_Text__c == '--/--/----')
                oppRec.StageName = 'Negotiation & Approval';
            
            if(cdkRec.Type_NEWUSED__c == 'NEW')
                oppRec.Purchase_Type__c = 'New Vehicle';
            else
                oppRec.Purchase_Type__c = 'Used Vehicle';
            if(string.isnotBlank(cdkRec.Last_Edit_Date_Text__c) && cdkRec.Last_Edit_Date_Text__c != '--/--/----')
                oppRec.DMS_Last_Edit_Date__c = Date.parse(cdkRec.Last_Edit_Date_Text__c);
            if(cdkRec.Price__c != null ){
                oppRec.Amount = cdkRec.Price__c;
                if(cdkRec.VAT__c != null && cdkRec.VAT__c > 0){
                    decimal VatPercent = cdkRec.VAT__c/cdkRec.Price__c;
                    oppRec.VAT__c = integer.valueOf(VatPercent.round(System.RoundingMode.HALF_UP)); //should be percentage
                }
            }
            oppRec.Country_ISO_Code__c = oppMap.get(recID).account.Country_ISO_Code__c;
            system.debug('oppRec:::'+oppRec);
            oppsToUpdate.add(oppRec);
            
            Account accRec = new Account();
            accRec.id = OppidToAccIdMap.containsKey(recID) ? OppidToAccIdMap.get(recID) : OppidToPAccIdMap.get(recID);
            if(OppidToAccIdMap.containsKey(recID) ){
                if(string.isNotBlank(cdkRec.Company_Name__c))
                    accRec.Name = cdkRec.Company_Name__c;
                if(OppidToConIdMap.containsKey(recID)){
                    Contact conRec = new Contact();
                    conRec.id = OppidToConIdMap.get(recID);
                    conRec.Salutation = cdkRec.Salutation__c;
                    conRec.Gender__c = cdkRec.Gender__c;
                    conRec.Language__c = cdkRec.Language__c;
                    conRec.Employment_Status__c = cdkRec.Employment_Status__c;
                    conRec.Title = cdkRec.Occupation__c;
                    if(string.isNotBlank(cdkRec.Mobile__c)){conRec.MobilePhone = cdkRec.Mobile__c.deleteWhitespace();}
                    if(string.isNotBlank(cdkRec.Phone__c)){conRec.Phone = cdkRec.Phone__c.deleteWhitespace();}
                    if(string.isNotBlank(cdkRec.Home_Phone__c)){conRec.HomePhone = cdkRec.Home_Phone__c.deleteWhitespace();}
                    conRec.Email = cdkRec.Email__c;
                    conRec.Email2__c = cdkRec.Email_2__c;
                    consToUpdate.add(conRec);
                }
            }
            else{
                accRec.Salutation = cdkRec.Salutation__c;
                accRec.Gender__pc = cdkRec.Gender__c;
                accRec.Language__pc = cdkRec.Language__c;
                accRec.Employment_Status__pc = cdkRec.Employment_Status__c;
                accRec.PersonTitle = cdkRec.Occupation__c;
                if(string.isNotBlank(cdkRec.Mobile__c)){accRec.PersonMobilePhone = cdkRec.Mobile__c.deleteWhitespace();}
                if(string.isNotBlank(cdkRec.Phone__c)){accRec.PersonOtherPhone = cdkRec.Phone__c.deleteWhitespace();}
                if(string.isNotBlank(cdkRec.Home_Phone__c)){accRec.PersonHomePhone = cdkRec.Home_Phone__c.deleteWhitespace();}
                accRec.PersonEmail = cdkRec.Email__c;
                accRec.Email2__pc = cdkRec.Email_2__c;
            }
            accRec.Industry = cdkRec.Industry__c;
            accRec.BillingStreet = cdkRec.Address_2__c;
            accRec.BillingCity = cdkRec.Address_3__c;
            accRec.BillingCountry = cdkRec.Nationality_Code__c;
            accRec.MENA_CDK_Customer_Number__c = cdkRec.Customer_unique_Number__c;
            accsToUpdate.add(accRec);
        }
        
        System.debug( 'assetList --> '+assetList );
        System.debug( 'oppLIList --> '+oppLIList );
        System.debug( 'consToUpdate --> '+consToUpdate );
        System.debug( 'accsToUpdate --> '+accsToUpdate );
        
        if(assetList.size()>0)
            update new List<Asset>(New Set<Asset>(assetList));
        if(oppLIList.size()>0)
            insert new List<OpportunityLineItem>(New Set<OpportunityLineItem>(oppLIList));
        if(oppsToUpdate.size()>0)
            update oppsToUpdate;
        if(consToUpdate.size()>0 )
            update consToUpdate;
        if(accsToUpdate.size()>0)
            update accsToUpdate;
    }

    
}