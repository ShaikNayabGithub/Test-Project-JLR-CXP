Public class Batch_UpdateCXPInboundLeads implements Database.Batchable<sobject>,schedulable{
    
    public void execute( schedulableContext sc ){
        Database.executeBatch( new Batch_UpdateCXPInboundLeads(), 1 );
    }
    
    Public Database.QueryLocator Start( Database.BatchableContext bc ){
        String query = label.Batch_UpdateCXPInboundLeads;
        return Database.getQueryLocator( query );
    }
    
    Public void execute( Database.BatchableContext bc, List<MENA_CDK_Lead__c> scope ){
        Map<id, MENA_CDK_Lead__c> cdkLeadMap = new Map<id, MENA_CDK_Lead__c>();
        List<Lead> leadsToInsert = new List<Lead>();
        Map<string, string> DMSidToCDKidMap = new Map<string, string>();
        For( MENA_CDK_Lead__c eachRecord : scope ){ 
            cdkLeadMap.put( eachRecord.id, new MENA_CDK_Lead__c(id = eachRecord.id));
            if(string.isNotBlank(eachRecord.External_Oem_Reference_ID__c))
                cdkLeadMap.get(eachRecord.id).Lead__c = eachRecord.External_Oem_Reference_ID__c;
            else{
                DMSidToCDKidMap.put(eachRecord.Lead_Hub_ID__c, eachRecord.id);
                Lead LeadToAdd = new Lead();
                leadToAdd.DMS_ID__c = eachRecord.Lead_Hub_ID__c ;
                leadToAdd.FirstName = eachRecord.First_Name__c ;
                leadToAdd.LastName = eachRecord.Surname__c ;
                leadToAdd.MobilePhone = eachRecord.Mobile__c;
                leadToAdd.Phone = eachRecord.Phone__c ;
                leadToAdd.Email = eachRecord.Email__c ;
                leadsToInsert.add(leadToAdd);                
            }
        }
        
        if(leadsToInsert.size()>0){
            List<Database.saveResult> insertResult = Database.insert( leadsToInsert, false);
            for(Integer i=0;i<insertResult.size();i++){
                if (insertResult.get(i).isSuccess()){
                    cdkLeadMap.get(DMSidToCDKidMap.get(leadsToInsert.get(i).DMS_ID__c)).Lead__c = insertResult.get(i).getid();
                    cdkLeadMap.get(DMSidToCDKidMap.get(leadsToInsert.get(i).DMS_ID__c)).LeadUpdateStatus__c = 'SUCCESS';
                }
                else{
                    string errors = '';
                    for(Database.Error err : insertResult.get(i).getErrors()) {errors += err.getFields()+'-'+err.getMessage()+'\n';}
                    cdkLeadMap.get(DMSidToCDKidMap.get(leadsToInsert.get(i).DMS_ID__c)).LeadUpdateStatus__c = 'FAILURE';
                    cdkLeadMap.get(DMSidToCDKidMap.get(leadsToInsert.get(i).DMS_ID__c)).FailReason__c = errors;
                }
            }
        }
        
        if(cdkLeadMap.size()>0){
            List<MENA_CDK_Lead__c> cdkRecsToUpdate = new List<MENA_CDK_Lead__c>();
            for(Database.saveResult updateResult : Database.update( cdkLeadMap.values(), false)){
                if (!updateResult.isSuccess()){
                    string errors = '';
                    for(Database.Error err : updateResult.getErrors()) {errors += err.getFields()+'-'+err.getMessage()+'\n';}
                    cdkRecsToUpdate.add(new MENA_CDK_Lead__c(id = updateResult.getId(), LeadUpdateStatus__c = 'FAILURE', FailReason__c = errors));
                }
            }
            
            if(cdkRecsToUpdate.size()>0)
                update cdkRecsToUpdate;
        }
    }
    
    Public void finish( Database.BatchableContext bc ){}

    public static void updateCXPLeads(list<MENA_CDK_Lead__c> newList, Map<id, MENA_CDK_Lead__c> oldMap, Map<id, MENA_CDK_Lead__c> newMap){
        Map<string, string> leadCDKMap = new Map<string, string>();
        for(MENA_CDK_Lead__c rec : newList){
            if(rec.Lead__c != oldMap.get(rec.id).Lead__c && rec.Lead__c != null){
                leadCDKMap.put(rec.Lead__c, rec.id);
            }
        }
        
        Map<id, lead> leadMap = new Map<id, lead>([SELECT id, CDK_Brand_Name__c, Status, Lead_Lost__c, Lost_Reason_Others__c, Lost_Reason__c, 
                                                   Enquiry_Type__c, MobilePhone, Phone, Email, DMS_Last_Edit_Date__c, MENA_CDK_Lead_Owner__c, 
                                                   Country_ISO_Code__c, isConverted from lead where id in: leadCDKMap.keySet()]);
        
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Lead> leadsToConvert = new List<Lead>();
        Set<String> emailSet = new Set<String>();
        Set<String> mobileNoSet = new Set<String>();
        Set<String> phoneNoSet = new Set<String>();
        Map<string, string> LeadsCountryBrandMap = new Map<string, string>();
        for(string recID : leadCDKMap.keyset()){
            lead leadRec = leadMap.get(recID);
            MENA_CDK_Lead__c cdkRec = newMap.get(leadCDKMap.get(recID));
            
            if(cdkRec.Status__c == 'Rejected'){
                leadRec.Status = 'Lost';
                leadRec.Lead_Lost__c = true;
                leadRec.Lost_Reason_Others__c = string.isBlank(cdkRec.Lost_Lead_Comments__c) ? 'Others' : cdkRec.Lost_Lead_Comments__c;
                leadRec.Lost_Reason__c = 'Others';
            }
            if(cdkRec.Status__c != 'Rejected' && cdkRec.Status__c != 'Converted')
                leadRec.Status = 'Follow Up';
            
            if( cdkRec.Enquiry_Type__c == 'GENERAL_SALES_INQUIRY' && String.isBlank( cdkRec.Enquiry_Type__c ) ){
                leadRec.Enquiry_Type__c = 'Generic';
            }
            
            leadRec.MobilePhone = cdkRec.Mobile__c;
            leadRec.Phone = cdkRec.Phone__c;
            leadRec.Email = cdkRec.Email__c;
            if(cdkRec.Edited_On__c != '--/--/----')
                leadRec.DMS_Last_Edit_Date__c = Date.parse(cdkRec.Edited_On__c);
            if(string.isNotBlank(cdkRec.Task_Action_Owner__c) && leadRec.Status == 'Follow Up'){
                leadRec.MENA_CDK_Lead_Owner__c = cdkRec.Task_Action_Owner__c;
            }
            system.debug('leadRec:::'+leadRec);
            leadsToUpdate.add( leadRec ); 
            
            if( cdkRec.Status__c == 'Converted' && !leadRec.isConverted){
                if(string.isNotBlank(leadRec.CDK_Brand_Name__c))
                    LeadsCountryBrandMap.put(recID, leadRec.Country_ISO_Code__c + '-' + leadRec.CDK_Brand_Name__c);
                else
                    LeadsCountryBrandMap.put(recID, leadRec.Country_ISO_Code__c);
                leadsToConvert.add(leadRec);
            }
            
            if(string.isNotBlank(leadRec.Email) && !label.Excluded_Emails.split(',').contains(leadRec.Email.trim()))
                emailSet.add(leadRec.Email);
            if(string.isNotBlank(leadRec.Phone))
            	phoneNoSet.add(leadRec.Phone);
            if(string.isNotBlank(leadRec.MobilePhone))
            	mobileNoSet.add(leadRec.MobilePhone);
        }
        System.debug( 'LeadsCountryBrandMap --> '+LeadsCountryBrandMap );
        System.debug( 'leadsToConvert --> '+leadsToConvert );
        
        if(leadsToUpdate.size()>0)
            update leadsToUpdate;
        
        Map<String, String> existingAccountMap = new Map<String, String>();
        string accountQuery = '';
        if(emailSet.size()>0 || mobileNoSet.size()>0 || phoneNoSet.size()>0){
            accountQuery = 'Select id, PersonEmail, PersonMobilePhone, PersonOtherPhone, Country_ISO_Code__c from account where recordtype.name = \'Individual\' and createddate != null and (PersonEmail in: emailSet or PersonMobilePhone in: mobileNoSet or PersonOtherPhone in: phoneNoSet)';
            if(emailSet.size()==0)
                accountQuery = accountQuery.remove('PersonEmail in: emailSet or ');
            if(mobileNoSet.size()==0)
                accountQuery = accountQuery.remove('PersonMobilePhone in: mobileNoSet or ');
            if(phoneNoSet.size()==0)
                accountQuery = accountQuery.remove(' or PersonOtherPhone in: phoneNoSet');
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
        for(Lead leadRecord : leadsToConvert ){
            Database.LeadConvert convert = new Database.LeadConvert();
            convert.setLeadId(leadRecord.id); 
            
            string accountId = '';
            if(existingAccountMap.containsKey(leadRecord.Phone + leadRecord.Country_ISO_Code__c))
                accountId = existingAccountMap.get(leadRecord.Phone + leadRecord.Country_ISO_Code__c);
            else if(existingAccountMap.containsKey(leadRecord.MobilePhone + leadRecord.Country_ISO_Code__c))
                accountId = existingAccountMap.get(leadRecord.MobilePhone + leadRecord.Country_ISO_Code__c);
            else if(existingAccountMap.containsKey(leadRecord.email + leadRecord.Country_ISO_Code__c))
                accountId = existingAccountMap.get(leadRecord.email + leadRecord.Country_ISO_Code__c);
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
        List<MENA_CDK_Lead__c> cdkErrorLeads = new List<MENA_CDK_Lead__c>();
        if(converts.size()>0){
            for(Database.LeadConvertResult lcr : Database.convertLead(converts)){
                if( lcr.isSuccess() ){
                    string CurrencyIsoCode = countryMaps.get(leadMap.get(lcr.getLeadId()).Country_ISO_Code__c).Default_Currency__c;
                    string Pricebook2Id = countryMaps.get(leadMap.get(lcr.getLeadId()).Country_ISO_Code__c).PricebookId__c;
                    convertedOppsList.add(new Opportunity(id = lcr.getOpportunityId(), recordtypeId = recordtypeIDOpp, CurrencyIsoCode = CurrencyIsoCode, Pricebook2Id = Pricebook2Id, Country_ISO_Code__c = leadMap.get(lcr.getLeadId()).Country_ISO_Code__c));
                }
                else{
                    string errors = '';
                    for(Database.Error err : lcr.getErrors())
                        errors += err.getFields()+'-'+err.getMessage()+'\n';                            
                   
                    cdkErrorLeads.add(new MENA_CDK_Lead__c(id = leadCDKMap.get(lcr.getLeadId()), LeadUpdateStatus__c = 'FAILURE', FailReason__c = errors));
                }
            }
            system.debug('convertedOppsList:::'+convertedOppsList);
        }
        
        if(convertedOppsList.size()>0)
            update convertedOppsList;
        if(cdkErrorLeads.size()>0)
            update cdkErrorLeads;
	}
}