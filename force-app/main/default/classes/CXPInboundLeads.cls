// Created by Jatin Gupta | Changi Consulting | Aug-2020.

@RestResource(urlMapping='/Leads/*')
global class CXPInboundLeads {
    
    @HttpPost
    global static string create(){
        String request = RestContext.request.requestBody.toString();
        system.debug('request::::'+request);
        List<MFTLeadsWrapper> leadsWrapper = MFTLeadsWrapper.parse(request);
        system.debug('leadsWrapper::::'+leadsWrapper);
        List<String> ErrorLogs = new List<String>();
        List<String> SuccessLogs = new List<String>();
        
        try{
            List<Lead> leadList = new List<Lead>();
            List<String> leadIds = new List<String>();
            Set<Id> leadIdsSet = new Set<Id>();
            for(MFTLeadsWrapper rec : leadsWrapper){
                leadIdsSet.add( rec.ExternalOemReferenceID );
            }    
            Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT id,Enquiry_Type__c, DMS_Last_Edit_Date__c FROM Lead Where ID IN : leadIdsSet ]);
            for(MFTLeadsWrapper rec : leadsWrapper){
                //Boolean isNewUpdate = leadMap.containsKey(rec.ExternalOemReferenceID) && Date.parse(rec.EditedOn).daysBetween(system.today()) == 1;
                if(leadMap.containsKey(rec.ExternalOemReferenceID) /*&& isNewUpdate*/){
                    Lead leadToAdd = new Lead();
                    leadToAdd.id = rec.ExternalOemReferenceID;
                    leadToAdd.DMS_ID__c = rec.LeadHubID;
                    //leadToAdd.FirstName = rec.FirstName;
                    //leadToAdd.LastName = rec.Surname;
                    if(string.isNotBlank(rec.Status)){
                        if(rec.Status == 'Converted')
                            leadIds.add(rec.ExternalOemReferenceID);
                        else if(rec.Status == 'Rejected'){
                            leadToAdd.Status = 'Lost';
                            leadToAdd.Lead_Lost__c = true;
                            leadToAdd.Lost_Reason_Others__c = rec.LostLeadComments;
                            leadToAdd.Lost_Reason__c = 'Others';
                        }
                        else
                            leadToAdd.Status = 'Follow Up';
                    }
                    if( rec.EnquiryType == 'GENERAL_SALES_INQUIRY' && leadMap.containsKey(rec.ExternalOemReferenceID) &&
                       String.isBlank(leadMap.get(rec.ExternalOemReferenceID).Enquiry_Type__c )){
                           leadToAdd.Enquiry_Type__c = 'Generic';
                       }
                    leadToAdd.MobilePhone = rec.Mobile;
                    leadToAdd.Phone = rec.Phone;
                    leadToAdd.Email = rec.Email;
                    if(rec.EditedOn != '--/--/----')
                        leadToAdd.DMS_Last_Edit_Date__c = Date.parse(rec.EditedOn);
                    if(string.isNotBlank(rec.TaskActionOwner) && leadToAdd.Status == 'Follow Up')
                        leadToAdd.MENA_CDK_Lead_Owner__c = rec.TaskActionOwner;
                    else if(string.isNotBlank(rec.RejectConvOwner))
                        leadToAdd.MENA_CDK_Lead_Owner__c = rec.RejectConvOwner;
                    leadList.add(leadToAdd);
                }
            }
            system.debug('leadList::::'+leadList);
            
            if(leadList.size()>0)
                for(Database.SaveResult r : database.update(leadList,false)){ if(!r.isSuccess()){ErrorLogs.add('Lead Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Lead Success:::'+r.getId());}}
            
            if(leadIds.size()>0)
                convertLead(leadIds, ErrorLogs, SuccessLogs);
            
            string status = 'Success';
            if(ErrorLogs.size()>0)
                status = 'Error';
            ErrorLogs.addall(SuccessLogs);
            CXPInboundLeads.createUpdateLogs(request, 'Success', ErrorLogs, 'CDK CXP Leads', null, status);
            return 'Success';
        }
        catch(exception e){
            CXPInboundLeads.createUpdateLogs(request, e.getMessage(), new List<String>{e.getStackTraceString()}, 'CDK CXP Leads', null, 'Error');
            return e.getMessage();
        }
    }
    
    public static void convertLead (List<string> leadIds, List<String> ErrorLogs, List<String> SuccessLogs){
        Map<string, MENA_Lead_Conversion_settings__mdt > leadConvertMap = new Map<string, MENA_Lead_Conversion_settings__mdt>();
        for(MENA_Lead_Conversion_settings__mdt rec : [Select Country_Code__c, Owner_Id__c from MENA_Lead_Conversion_settings__mdt where Used_In__c = 'CXP Inbound'])
            leadConvertMap.put(rec.Country_Code__c, rec);
        
        Map<string, string> LeadsMap = new Map<string, string>();
        for(Lead leadRec : [Select id, Country_ISO_Code__c from Lead where id in: leadIds])
            LeadsMap.put(leadRec.id, leadRec.Country_ISO_Code__c);
        
        List<Database.LeadConvert> converts = new List<database.LeadConvert>();
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        for(string recordId: leadIds){
            Database.LeadConvert convert = new Database.LeadConvert();
            convert.setLeadId(recordId); 
            If(string.isNotBlank(LeadsMap.get(recordId)) && leadConvertMap.containsKey(LeadsMap.get(recordId)))
                convert.setOwnerId(leadConvertMap.get(LeadsMap.get(recordId)).Owner_Id__c);
            convert.setConvertedStatus(convertStatus.MasterLabel);
            converts.add(convert);
        }
        Database.LeadConvertResult[] lcrList = Database.convertLead(converts, false);
        for(Database.LeadConvertResult lcr : lcrList){
            if(lcr.isSuccess()){SuccessLogs.add('Lead Convert Success(Opportunity Id):::'+lcr.getOpportunityId());}else{ErrorLogs.add('Lead Convert Errors::: '+lcr.getLeadId()+' '+JSON.Serialize(lcr.getErrors()));}
        }
    }
    
    public static string createUpdateLogs(string request, string response, List<string> logs, string service, string logId, string status){
        Integration_Log__c ILrec = new Integration_Log__c();
        if(string.isBlank(logId)){
            ILrec.Service__c = service;
            ILrec.Request__c = request;
            ILrec.Response__c = response;
            ILrec.Apex_Log__c = string.join(logs, '\n');
        }
        else{
            ILrec.Id = logId;
            ILrec.Response_Additional__c = response + '\n\n' + string.join(logs, '\n');
        }
        if(string.isNotBlank(status))
            ILrec.Status__c = status;
        
        upsert ILrec;
        return ILrec.id;
    }
    
}