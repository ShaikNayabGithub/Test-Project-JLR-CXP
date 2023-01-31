// Created by Jatin Gupta | Changi Consulting | Nov-2020.

@RestResource(urlMapping='/Opportunities/*')
global class CXPInboundOpps { 
    
    @HttpPost
    global static string create(){
        String request = RestContext.request.requestBody.toString();
        system.debug('request::::'+request);
        List<MFTOppsWrapper> OppsWrapper = MFTOppsWrapper.parse(request);
        List<String> ErrorLogs = new List<String>();
        List<String> SuccessLogs = new List<String>();
        
        List<opportunity> oppsToUpdate = new List<opportunity>();
    	List<Account> accsToUpdate = new List<Account>();
    	List<Contact> consToUpdate = new List<Contact>();
        
        try{
            Set<string> DMSidList = new Set<string>();
            Set<string> OppsIdList = new Set<string>();
            for(MFTOppsWrapper rec : OppsWrapper){
                if(string.isNotBlank(rec.JobRouterID))
                	DMSidList.add(rec.JobRouterID);
                if(string.isNotBlank(rec.CXPID))
                	OppsIdList.add(rec.CXPID);
            }
            
            Map<string,string> OppidToDMSIdMap = new Map<string,string>();
            string query = 'Select id, DMS_Last_Edit_Date__c, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity where';
            if(DMSidList.size()>0)
                query += ' MENA_DMS_ID__c in: DMSidList or';
            if(OppsIdList.size()>0)
                query += ' id in: OppsIdList or';
            query = query.removeEnd('or');
            List<opportunity> oppsList = database.query(query);
            for(opportunity oppRec : oppsList){
                OppidToDMSIdMap.put(oppRec.id, oppRec.MENA_DMS_ID__c);
                
                if(string.isNotBlank(oppRec.MENA_DMS_ID__c))
                    DMSidList.remove(oppRec.MENA_DMS_ID__c);
            }
            
            prepareListsForUpdate(oppsList, OppidToDMSIdMap, OppsWrapper, oppsToUpdate, accsToUpdate, consToUpdate);
            
            Map<string,string> DMSidToLeadidMap = new Map<string,string>();
            List<Lead> leadsList = new List<Lead>();
            if(DMSidList.size() > 0){
                for(Lead leadRec : [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead where DMS_ID__c in: DMSidList and IsConverted = false]){
                    leadsList.add(leadRec);
                    DMSidToLeadidMap.put(leadRec.DMS_ID__c, leadRec.id);
                    DMSidList.remove(leadRec.DMS_ID__c);
                }
            }
            system.debug('leadsList::::'+leadsList);
            
            List<Lead> leadsToInsert = new List<Lead>();
            for(MFTOppsWrapper rec : OppsWrapper){
                if(DMSidList.contains(rec.JobRouterID) && string.isNotBlank(rec.JobRouterID)){
                    Lead leadToInsert = new Lead();
                    leadToInsert.DMS_ID__c = rec.JobRouterID;
                    leadToInsert.firstname = rec.FirstName;
                    leadToInsert.lastname = rec.LastName;
                    leadToInsert.Email = rec.Email;
                    leadToInsert.Phone = rec.Phone;
                    leadToInsert.MobilePhone = rec.Mobile;
                    leadToInsert.LeadSource = 'OEM Web & Digital';
                    leadToInsert.Country_ISO_Code__c = 'MA';
                    leadsToInsert.add(leadToInsert);
                }
            }
            system.debug('leadsToInsert::::'+leadsToInsert);
            
            if(leadsToInsert.size()>0){
                for(Database.SaveResult r : database.insert(leadsToInsert, false)){ if(!r.isSuccess()){ErrorLogs.add('Lead Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Lead Success:::'+r.getId());}}
                leadsList.addall(leadsToInsert);
            }
            
            if(oppsToUpdate.size()>0)
                for(Database.SaveResult r : database.update(oppsToUpdate,false)){ if(!r.isSuccess()){ErrorLogs.add('Opportunity Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Opportunity Success:::'+r.getId());}}
            if(consToUpdate.size()>0)
                for(Database.SaveResult r : database.update(consToUpdate,false)){ if(!r.isSuccess()){ErrorLogs.add('Contact Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Contact Success:::'+r.getId());}}
            if(accsToUpdate.size()>0)
                for(Database.SaveResult r : database.update(accsToUpdate,false)){ if(!r.isSuccess()){ErrorLogs.add('Account Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Account Success:::'+r.getId());}}
            
            string status = 'Success';
            if(ErrorLogs.size()>0)
                status = 'Error';
            ErrorLogs.addall(SuccessLogs);
            string LogId = CXPInboundLeads.createUpdateLogs(request, 'Success', ErrorLogs, 'Jobrouter CXP Opportunities', null, status);
            
            if(leadsList.size()>0)
            	System.enqueueJob(new MFTLeadConvertQueueable(leadsList, OppsWrapper, LogId));
            
            return 'Success';
        }
        catch(exception e){
            CXPInboundLeads.createUpdateLogs(request, e.getMessage(), new List<String>{e.getStackTraceString()}, 'Jobrouter CXP Opportunities', null, 'Error');
            return string.valueOf(e.getMessage());
        }
    }
    
    public static void prepareListsForUpdate(List<opportunity> oppsList, Map<string,string> OppidToDMSIdMap, List<MFTOppsWrapper> OppsWrapper, List<opportunity> oppsToUpdate, List<Account> accsToUpdate, List<Contact> consToUpdate){
        Map<string,string> OppidToAccIdMap = new Map<string,string>();
        Map<string,string> OppidToPAccIdMap = new Map<string,string>();
        Map<string,string> OppidToConIdMap = new Map<string,string>();
        Map<string,opportunity> OppidToOppMap = new Map<string,opportunity>();
        List<OpportunityLineItem> oppLIList = new List<OpportunityLineItem>();
        List<Asset> assetList = new List<Asset>();
        Set<String> pricebook2Set = new Set<String>();
        
        Map<string,string> frenchStageToStageNameMap = new Map<string,string>();
        for(Jobrouter_Opportunity_Stages__mdt mdtRec : [Select label, Opportunity_StageName__c from Jobrouter_Opportunity_Stages__mdt])
            frenchStageToStageNameMap.put(mdtRec.label.toLowerCase(), mdtRec.Opportunity_StageName__c);
        system.debug('frenchStageToStageNameMap::::'+frenchStageToStageNameMap);
        
        for(opportunity oppRec : oppsList){
            if(oppRec.account.IsPersonAccount)
                OppidToPAccIdMap.put(oppRec.id, oppRec.accountId);
            else{
                OppidToAccIdMap.put(oppRec.id, oppRec.accountId);
                if(string.isNotBlank(oppRec.contactid))
                    OppidToConIdMap.put(oppRec.id, oppRec.contactid);
            }
            pricebook2Set.add(oppRec.Pricebook2Id);
            OppidToOppMap.put(oppRec.id, oppRec);
        }
        system.debug('OppidToConIdMap::::'+OppidToConIdMap);
        system.debug('OppidToPAccIdMap::::'+OppidToPAccIdMap);
        system.debug('OppidToAccIdMap::::'+OppidToAccIdMap);
        
        Set<String> BrandSet = new Set<String>();
        Set<String> ModelSet = new Set<String>();
        Set<String> vinSet = new Set<String>();
        for(MFTOppsWrapper rec : OppsWrapper){
            BrandSet.add(rec.Brand);
            ModelSet.add(rec.PrimaryModelInterest);
            if(string.isNotBlank(rec.VIN))
                vinSet.add(rec.VIN);
        }
        
        Map<string, Asset> vinToAssetMap = new Map<string, Asset>();
        Map<string, String> PriceBookEntryRecord = new Map<string, String>();
        Set<String> product2IdSet = new Set<String>();
        if(vinSet.size()>0){
            for(Asset rec : [Select id, VIN__c, Product2Id from Asset where VIN__c in: vinSet]){
                vinToAssetMap.put(rec.VIN__c, rec);
                product2IdSet.add(rec.Product2Id);
            }
            
            system.debug('pricebook2Set:::'+pricebook2Set);
            for(pricebookentry pbe : [Select id, product2id, pricebook2id  from pricebookentry where product2id in: product2IdSet and pricebook2id in: pricebook2Set])
                PriceBookEntryRecord.put(pbe.product2id + '#$%' + pbe.pricebook2id, pbe.id);
        }
        system.debug('PriceBookEntryRecord:::'+PriceBookEntryRecord);
        
        Map<string,string> BrandIdMap = new Map<string,string>();
        Map<string,string> ModelIdMap = new Map<string,string>();
        for(Vehicle_Specification__c vehicleRec : [Select id, name from Vehicle_Specification__c where name in: BrandSet and recordtype.name = 'Make'])
            BrandIdMap.put(vehicleRec.name.toLowerCase(), vehicleRec.id);
        for(Vehicle_Specification__c vehicleRec : [Select id, name from Vehicle_Specification__c where name in: ModelSet and recordtype.name = 'Model'])
            ModelIdMap.put(vehicleRec.name.toLowerCase(), vehicleRec.id);
        system.debug('BrandIdMap::::'+BrandIdMap);
        system.debug('ModelIdMap::::'+ModelIdMap);
        
        for(MFTOppsWrapper rec : OppsWrapper){
            for(string oppRecId : OppidToDMSIdMap.keyset()){
                if((string.isNotBlank(rec.CXPID) && oppRecId == rec.CXPID) || (string.isNotBlank(rec.JobRouterID) && OppidToDMSIdMap.get(oppRecId) == rec.JobRouterID)){
                    opportunity oppRec = new opportunity();
                    oppRec.id = oppRecId;
                    if(string.isNotBlank(rec.Brand) && BrandIdMap.containsKey(rec.Brand.toLowerCase())){
                        oppRec.Brand__c = BrandIdMap.get(rec.Brand.toLowerCase());
                    }
                    if(string.isNotBlank(rec.PrimaryModelInterest) && ModelIdMap.containsKey(rec.PrimaryModelInterest.toLowerCase())){
                        oppRec.Primary_Model_Interest__c = ModelIdMap.get(rec.PrimaryModelInterest.toLowerCase());
                    }
                    oppRec.MENA_CDK_Opportunity_Owner__c = rec.User;
                    
                    
                    for(String stageKey : frenchStageToStageNameMap.keyset()){
                        if(rec.Stage.toLowerCase().contains(stageKey) && frenchStageToStageNameMap.get(stageKey) == 'Handover & RDA' && OppidToOppMap.get(oppRec.id).stagename != 'Handover & RDA'){
                            oppRec.StageName = 'Handover & RDA';
                            oppRec.VIN__c = rec.VIN;
                            oppRec.Handover_Date__c = date.parse(rec.HandoverDate);
                            
                            if(OppidToOppMap.get(oppRec.id).Number_of_opp_products_with_asset__c <= 0 && string.isNotBlank(rec.VIN) && vinToAssetMap.containsKey(rec.VIN) && string.isNotBlank(rec.SalesPrice)){
                                assetList.add(new Asset(id = vinToAssetMap.get(rec.VIN).id, AccountId = OppidToOppMap.get(oppRec.id).accountId));
                                string Key = vinToAssetMap.get(rec.VIN).product2id + '#$%' + OppidToOppMap.get(oppRec.id).Pricebook2Id;
                                If(PriceBookEntryRecord.containsKey(Key))
                                    oppLIList.add(new OpportunityLineItem(product2Id = vinToAssetMap.get(rec.VIN).product2id, Asset__c = vinToAssetMap.get(rec.VIN).id, opportunityId = oppRec.id, quantity = 1, PricebookEntryId = PriceBookEntryRecord.get(Key), unitprice=decimal.valueOf(rec.SalesPrice)));
                            }
                            break;
                        }
                    }    
                    if(frenchStageToStageNameMap.containsKey(rec.Stage.toLowerCase()) && frenchStageToStageNameMap.get(rec.Stage.toLowerCase()) == 'Lost' && OppidToOppMap.get(oppRec.id).stagename != 'Lost'){
                        oppRec.StageName = 'Lost';
                        oppRec.Date_Lost__c = date.parse(rec.DateLost);
                        oppRec.Retailer_Loss_Category__c = rec.LossCategory;
                        oppRec.Retailer_Loss_Type__c = rec.LossReason;
                        oppRec.Retailer_Loss_Description__c = rec.LossNotes;
                    }
                    else if(frenchStageToStageNameMap.containsKey(rec.Stage.toLowerCase()) && frenchStageToStageNameMap.get(rec.Stage.toLowerCase()) == 'Order Taken' && OppidToOppMap.get(oppRec.id).stagename != 'Order Taken'){
                        oppRec.StageName = 'Order Taken';
                        
                        if(OppidToOppMap.get(oppRec.id).Number_of_opp_products_with_asset__c <= 0 && string.isNotBlank(rec.VIN) && vinToAssetMap.containsKey(rec.VIN) && string.isNotBlank(rec.SalesPrice)){
                            assetList.add(new Asset(id = vinToAssetMap.get(rec.VIN).id, AccountId = OppidToOppMap.get(oppRec.id).accountId));
                            string Key = vinToAssetMap.get(rec.VIN).product2id + '#$%' + OppidToOppMap.get(oppRec.id).Pricebook2Id;
                            If(PriceBookEntryRecord.containsKey(Key))
                                oppLIList.add(new OpportunityLineItem(product2Id = vinToAssetMap.get(rec.VIN).product2id, Asset__c = vinToAssetMap.get(rec.VIN).id, opportunityId = oppRec.id, quantity = 1, PricebookEntryId = PriceBookEntryRecord.get(Key), unitprice=decimal.valueOf(rec.SalesPrice)));
                        }
                    }
                    else if(frenchStageToStageNameMap.containsKey(rec.Stage.toLowerCase()) && frenchStageToStageNameMap.get(rec.Stage.toLowerCase()) == 'Negotiation & Approval' && OppidToOppMap.get(oppRec.id).stagename != 'Negotiation & Approval'){
                        oppRec.StageName = 'Negotiation & Approval';
                        oppRec.Trade_In__c = true;
                        if(string.isNotBlank(rec.TradeInValue))
                        	oppRec.Trade_in_Value__c = decimal.valueOf(rec.TradeInValue);
                        if(string.isNotBlank(rec.OfferApplied))
                        	oppRec.Offer_Applied__c = decimal.valueOf(rec.OfferApplied);
                        oppRec.Local_deposit_amount__c = rec.LocalDepositAmount;
                        if(string.isNotBlank(rec.VAT) && decimal.valueOf(rec.VAT) > 0){
                            decimal VatPercent = decimal.valueOf(rec.VAT)/decimal.valueOf(rec.SalesPrice);
                            oppRec.VAT__c = integer.valueOf(VatPercent.round(System.RoundingMode.HALF_UP));	//should be percentage
                        }
                        oppRec.Amount = decimal.valueOf(rec.SalesPrice);
                    }
                    else if(frenchStageToStageNameMap.containsKey(rec.Stage.toLowerCase()) && frenchStageToStageNameMap.get(rec.Stage.toLowerCase()) == 'Test Drive Taken/Booked' && OppidToOppMap.get(oppRec.id).stagename != 'Test Drive Taken/Booked'){
                        oppRec.StageName = 'Test Drive Taken/Booked';
                        if(string.isNotBlank(rec.TestDriveDate)){
                            oppRec.Test_Drive_Completed_Date__c = date.parse(rec.TestDriveDate);
                            oppRec.Test_Drive_Completed_Date_MENA__c = date.parse(rec.TestDriveDate);
                        }
                        oppRec.Test_Drive_Completed_MENA__c = true;
                    }
                    else if(frenchStageToStageNameMap.containsKey(rec.Stage.toLowerCase()) && frenchStageToStageNameMap.get(rec.Stage.toLowerCase()) == 'Qualified'){
                        oppRec.StageName = 'Qualified';
                        if(string.isNotBlank(rec.Budget))
                        	oppRec.Budget__c = decimal.valueOf(rec.Budget);
                    }
                    system.debug('oppRec:::'+oppRec);
                    oppsToUpdate.add(oppRec);
                    
                    Account accRec = new Account();
                    accRec.id = OppidToAccIdMap.containsKey(oppRec.id) ? OppidToAccIdMap.get(oppRec.id) : OppidToPAccIdMap.get(oppRec.id);
                    accRec.PersonMobilePhone = rec.Mobile;
                    accRec.PersonOtherPhone = rec.Phone;
                    accRec.PersonEmail = rec.Email;
                    accsToUpdate.add(accRec);
                }
            }
        }
        if(assetList.size()>0)
            CXPInboundOpps.updateasset(JSON.serialize(assetList));//update assetList;
        if(oppLIList.size()>0)
            insert oppLIList;   
    }
    
    @future
    public static void updateasset(String assetString){
        List<Asset> assetList = new List<Asset>();
        assetList = (List<Asset>)System.JSON.deserialize(assetString, List<Asset>.class);
        update assetList;
    }
    
}