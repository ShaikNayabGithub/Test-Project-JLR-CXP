public class LeadConvertQueueable implements Queueable {
    Map<id,Lead> leadsMap = new Map<id,Lead>();
    
    public LeadConvertQueueable(Map<id,Lead> leadMap){
        this.leadsMap = leadMap;
    }
    
    public void execute(QueueableContext context) {
        system.debug('leadsMap:::'+leadsMap);
        Map<string, MENA_Lead_Conversion_settings__mdt  > leadConvertMap = new Map<string, MENA_Lead_Conversion_settings__mdt >();
        for(MENA_Lead_Conversion_settings__mdt  rec : [Select Country_Code__c, Owner_Id__c from MENA_Lead_Conversion_settings__mdt where Used_In__c = 'Lead Handler'])
            leadConvertMap.put(rec.Country_Code__c, rec);
        
        List<string> recIds = new List<string>();
        for(Lead rec : [Select id from Lead where id in: leadsMap.keyset() and Preferred_Retailer__r.DMS_Type__c = 'JobRouter' and Enquiry_Type__c != 'KMI' and Status != 'Lost' and Country_ISO_Code__c in: leadConvertMap.keyset() and Country_ISO_Code__c != null]){
            recIds.add(rec.Id);
        }
        system.debug('recIds:::'+recIds);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        for(string leadId : recIds){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadId);  
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadConverts.add(lc);
        }
        
        if(leadConverts.size()>0){
            List<Lead> leadToUpdate = new List<Lead>();
            List<Account> accToUpdate = new List<Account>();
            List<Contact> conToUpdate = new List<Contact>();
            List<Opportunity> OppToUpdate = new List<Opportunity>();
            for(Database.LeadConvertResult lcr : Database.convertLead(leadConverts)){
                //accToUpdate.add(new Account(id = lcr.getAccountId(), ownerId = leadConvertMap.get(leadsMap.get(lcr.getLeadId()).Country_ISO_Code__c).Owner_Id__c));
                //conToUpdate.add(new Contact(id = lcr.getContactId(), ownerId = leadConvertMap.get(leadsMap.get(lcr.getLeadId()).Country_ISO_Code__c).Owner_Id__c));
                OppToUpdate.add(new Opportunity(id = lcr.getOpportunityId(), stagename = 'Qualified', ownerId = leadConvertMap.get(leadsMap.get(lcr.getLeadId()).Country_ISO_Code__c).Owner_Id__c, 
                                                recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Process with RDA').getRecordTypeId(), Country_ISO_Code__c = leadsMap.get(lcr.getLeadId()).Country_ISO_Code__c));            
            }
            
            if(OppToUpdate.size()>0){
                update OppToUpdate;
                //updateOwners(JSON.serialize(OppToUpdate));
                //updateOwners(JSON.serialize(leadToUpdate),JSON.serialize(accToUpdate),JSON.serialize(conToUpdate),JSON.serialize(OppToUpdate));
            }
        }
    }
}