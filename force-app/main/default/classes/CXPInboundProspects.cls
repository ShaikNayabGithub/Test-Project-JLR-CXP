// Created by Jatin Gupta | Changi Consulting | Aug-2020.

@RestResource(urlMapping='/Prospects/*')
global class CXPInboundProspects {
    Public static List<opportunity> oppsToUpdate = new List<opportunity>();
    Public static List<Account> accsToUpdate = new List<Account>();
    Public static List<Contact> consToUpdate = new List<Contact>();
    
    @HttpPost
    global static string create(){
        String request = RestContext.request.requestBody.toString();
        system.debug('request::::'+request);
        List<MFTProspectsWrapper> prospectsWrapper = MFTProspectsWrapper.parse(request);
        system.debug('prospectsWrapper::::'+prospectsWrapper);
        List<String> ErrorLogs = new List<String>();
        List<String> SuccessLogs = new List<String>();
        
        try{
            List<string> DMSidList = new List<string>();
            Map<string, string> HubIDToLastEditDateMap = new Map<string, string>();
            for(MFTProspectsWrapper rec : prospectsWrapper){
                HubIDToLastEditDateMap.put(rec.LeadHubID, rec.LastEditDate);
                DMSidList.add(rec.LeadHubID);
            }
            
            Map<string,string> DMSidToOppidMap = new Map<string,string>();
            List<opportunity> oppsList = [Select id, DMS_Last_Edit_Date__c, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity where MENA_DMS_ID__c in: DMSidList];
            for(opportunity oppRec : oppsList){
                //Boolean isNewUpdate = HubIDToLastEditDateMap.containsKey(oppRec.MENA_DMS_ID__c) && Date.parse(HubIDToLastEditDateMap.get(oppRec.MENA_DMS_ID__c)).daysBetween(system.today()) == 1;
                //if(isNewUpdate){
                    DMSidToOppidMap.put(oppRec.MENA_DMS_ID__c, oppRec.id);
                //}
            }
            prepareListsForUpdate(oppsList, DMSidToOppidMap, prospectsWrapper);
            
            Map<string,string> DMSidToLeadidMap = new Map<string,string>();
            List<Lead> leadsList = new List<Lead>();
            if(DMSidToOppidMap.values().size() != DMSidList.size()){
                for(Lead leadRec : [Select id, DMS_ID__c, ownerId, Country_ISO_Code__c from Lead where DMS_ID__c in: DMSidList and IsConverted = false]){
                    leadsList.add(leadRec);
                    DMSidToLeadidMap.put(leadRec.DMS_ID__c, leadRec.id);
                }
            }
            system.debug('leadsList::::'+leadsList);
            
            /*List<Lead> leadsToInsert = new List<Lead>();
            for(MFTProspectsWrapper rec : prospectsWrapper){
                if(!DMSidToOppidMap.containsKey(rec.LeadHubID) && !DMSidToLeadidMap.containsKey(rec.LeadHubID)){
                    Lead leadToInsert = new Lead();
                    leadToInsert.DMS_ID__c = rec.LeadHubID;
                    leadToInsert.firstname = rec.FirstName;
                    leadToInsert.lastname = rec.Surname;
                    leadToInsert.Email = rec.Email;
                    leadToInsert.Phone = rec.Phone;
                    leadToInsert.MobilePhone = rec.Mobile;
                    leadToInsert.LeadSource = rec.LeadSource;
                    leadToInsert.Enquiry_Type__c = rec.EnquirySource;
                    leadToInsert.Purchase_Type__c = rec.TypeNewUsed;
                    if(string.isNotBlank(rec.CompanyName))
                        leadToInsert.Company = rec.CompanyName;
                    leadsToInsert.add(leadToInsert);
                }
            }
            system.debug('leadsToInsert::::'+leadsToInsert);
            
            if(leadsToInsert.size()>0){
                insert leadsToInsert;
                leadsList.addall(leadsToInsert);
            }*/
            
            //convertLeads(leadsList, prospectsWrapper);
            
            if(oppsToUpdate.size()>0)
                for(Database.SaveResult r : database.update(oppsToUpdate,false)){ if(!r.isSuccess()){ErrorLogs.add('Opportunity Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Opportunity Success:::'+r.getId());}}
            if(consToUpdate.size()>0)
                for(Database.SaveResult r : database.update(consToUpdate,false)){ if(!r.isSuccess()){ErrorLogs.add('Contact Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Contact Success:::'+r.getId());}}
            if(accsToUpdate.size()>0)
                for(Database.SaveResult r : database.update(accsToUpdate,false)){ if(!r.isSuccess()){ErrorLogs.add('Account Errors:::'+JSON.Serialize(r.getErrors()));}else{SuccessLogs.add('Account Success:::'+r.getId());}}
            //update listToUpdate;
            string status = 'Success';
            if(ErrorLogs.size()>0)
                status = 'Error';
            ErrorLogs.addall(SuccessLogs);
            string LogId = CXPInboundLeads.createUpdateLogs(request, 'Success', ErrorLogs, 'CDK CXP Prospects', null, status);
            
            if(leadsList.size()>0)
                System.enqueueJob(new MFTLeadConvertQueueable(leadsList, prospectsWrapper, LogId));
            
            return 'Success';
        }
        catch(exception e){
            CXPInboundLeads.createUpdateLogs(request, e.getMessage(), new List<String>{e.getStackTraceString()}, 'CDK CXP Prospects', null, 'Error');
            return string.valueOf(e.getMessage());
        }
        
    }
    
    /*private static void convertLeads(List<Lead> leadsList, List<MFTProspectsWrapper> prospectsWrapper){
        List<Database.LeadConvert> leadsConvertList = new List<Database.LeadConvert>();
        Map<Id,Lead> leadsMap = new Map<Id,Lead>();
        for(Lead rec : leadsList){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(rec.Id);
            lc.setOwnerId(userinfo.getUserId());
            lc.convertedStatus = 'Qualified';
            leadsConvertList.add(lc);
            leadsMap.put(rec.Id, rec);
        }
        system.debug('leadsConvertList::::'+leadsConvertList);
        
        if(!leadsConvertList.isEmpty()){
            List<Opportunity> convertedOppsList = new List<Opportunity>();
            
            Database.LeadConvertResult[] lcrList = Database.convertLead(leadsConvertList, false);                    
            for(Database.LeadConvertResult lcr : lcrList){
                convertedOppsList.add(new Opportunity(id = lcr.getOpportunityId(), DMS_Opportunity_ID__c = leadsMap.get(lcr.getLeadId()).DMS_ID__c));
            }
            system.debug('convertedOppsList::::'+convertedOppsList);
            
            if(convertedOppsList.size()>0)
                update convertedOppsList;
            
            Map<string,string> DMSidToOppidMap = new Map<string,string>();
            List<opportunity> oppsList = [Select id, DMS_Opportunity_ID__c, accountId, account.IsPersonAccount, contactid, stagename from opportunity where id in: convertedOppsList];
            for(opportunity oppRec : oppsList){
                DMSidToOppidMap.put(oppRec.DMS_Opportunity_ID__c, oppRec.id);
            }
            prepareListsForUpdate(oppsList, DMSidToOppidMap, prospectsWrapper);
        }
    }*/
    
    public static void prepareListsForUpdate(List<opportunity> oppsList, Map<string,string> DMSidToOppidMap, List<MFTProspectsWrapper> prospectsWrapper){
        Map<string,string> OppidToAccIdMap = new Map<string,string>();
        Map<string,string> OppidToPAccIdMap = new Map<string,string>();
        Map<string,string> OppidToConIdMap = new Map<string,string>();
        Map<string,opportunity> OppidToOppMap = new Map<string,opportunity>();
        List<OpportunityLineItem> oppLIList = new List<OpportunityLineItem>();
        List<Asset> assetList = new List<Asset>();
        Set<String> pricebook2Set = new Set<String>();
        
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
        for(MFTProspectsWrapper rec : prospectsWrapper){
            BrandSet.add(rec.Brand);
            ModelSet.add(rec.Model);
            if(string.isNotBlank(rec.VehicleIdentificationNumber))
            	vinSet.add(rec.VehicleIdentificationNumber);
        }
        
        Map<string, Asset> vinToAssetMap = new Map<string, Asset>();
        Map<string, String> PriceBookEntryRecord = new Map<string, String>();
        Set<String> product2IdSet = new Set<String>();
        if(vinSet.size()>0){
            for(Asset rec : [Select id, VIN__c, Product2Id from Asset where VIN__c in: vinSet]){
                vinToAssetMap.put(rec.VIN__c, rec);
                product2IdSet.add(rec.Product2Id);
            }
            
            for(pricebookentry pbe : [Select id, product2id, pricebook2id  from pricebookentry where product2id in: product2IdSet and pricebook2id in: pricebook2Set])
                PriceBookEntryRecord.put(pbe.product2id + '#$%' + pbe.pricebook2id, pbe.id);
        }
        
        Map<string,string> BrandIdMap = new Map<string,string>();
        Map<string,string> ModelIdMap = new Map<string,string>();
        for(Vehicle_Specification__c vehicleRec : [Select id, name from Vehicle_Specification__c where name in: BrandSet and recordtype.name = 'Make'])
            BrandIdMap.put(vehicleRec.name.toLowerCase(), vehicleRec.id);
        for(Vehicle_Specification__c vehicleRec : [Select id, name from Vehicle_Specification__c where name in: ModelSet and recordtype.name = 'Model'])
            ModelIdMap.put(vehicleRec.name.toLowerCase(), vehicleRec.id);
        system.debug('BrandIdMap::::'+BrandIdMap);
        system.debug('ModelIdMap::::'+ModelIdMap);
        
        for(MFTProspectsWrapper rec : prospectsWrapper){
            if(DMSidToOppidMap.containsKey(rec.LeadHubID)){
                opportunity oppRec = new opportunity();
                oppRec.id = DMSidToOppidMap.get(rec.LeadHubID);
                oppRec.CDK_Customer_unique_Number__c = rec.CustomeruniqueNumber;
                //oppRec.LeadSource = rec.LeadSource;
                //oppRec.Enquiry_Type__c = rec.EnquirySource;
                if(string.isNotBlank(rec.Brand) && BrandIdMap.containsKey(rec.Brand.toLowerCase())){
                    oppRec.Brand__c = BrandIdMap.get(rec.Brand.toLowerCase());
                }
                if(string.isNotBlank(rec.Model) && ModelIdMap.containsKey(rec.Model.toLowerCase())){
                    oppRec.Primary_Model_Interest__c = ModelIdMap.get(rec.Model.toLowerCase());
                }
                oppRec.MENA_CDK_Opportunity_Owner__c = rec.AccountOwner;
                
                if((rec.DeliveryDate != '--/--/----' || rec.InvoiceDate != '--/--/----' || rec.RegistrationDate != '--/--/----') && OppidToOppMap.get(oppRec.id).stagename != 'Handover & RDA'){
                    oppRec.StageName = 'Handover & RDA';
                    oppRec.VIN__c = rec.VehicleIdentificationNumber;
                    if(rec.DeliveryDate != '--/--/----' )
                    	oppRec.Handover_Date__c = Date.parse(rec.DeliveryDate);
                    else if(rec.RegistrationDate != '--/--/----')
                        oppRec.Handover_Date__c = Date.parse(rec.RegistrationDate);
                    else if(rec.InvoiceDate != '--/--/----')
                        oppRec.Handover_Date__c = Date.parse(rec.InvoiceDate);
                    
                    
                    if(OppidToOppMap.get(oppRec.id).Number_of_opp_products_with_asset__c <= 0 && string.isNotBlank(rec.VehicleIdentificationNumber) && vinToAssetMap.containsKey(rec.VehicleIdentificationNumber) && string.isNotBlank(rec.Price)){
                        assetList.add(new Asset(id = vinToAssetMap.get(rec.VehicleIdentificationNumber).id, AccountId = OppidToOppMap.get(oppRec.id).accountId));
                        string Key = vinToAssetMap.get(rec.VehicleIdentificationNumber).product2id + '#$%' + OppidToOppMap.get(oppRec.id).Pricebook2Id;
                        If(PriceBookEntryRecord.containsKey(Key))
                            oppLIList.add(new OpportunityLineItem(product2Id = vinToAssetMap.get(rec.VehicleIdentificationNumber).product2id, Asset__c = vinToAssetMap.get(rec.VehicleIdentificationNumber).id, opportunityId = oppRec.id, quantity = 1, PricebookEntryId = PriceBookEntryRecord.get(Key), unitprice=decimal.valueOf(rec.Price)));
                    }
                }
                else if(rec.Lost != '--/--/----' && OppidToOppMap.get(oppRec.id).stagename != 'Lost'){
                    oppRec.StageName = 'Lost';
                    oppRec.Date_Lost__c = date.parse(rec.Lost);
                    oppRec.Retailer_Loss_Category__c = rec.EventType;
                    oppRec.Retailer_Loss_Type__c = rec.LostSaleRef;
                }
                else if(rec.Order != '--/--/----' && OppidToOppMap.get(oppRec.id).stagename != 'Order Taken'){
                    oppRec.StageName = 'Order Taken';
                    oppRec.Quote_saved_date__c = date.parse(rec.Order);
                    if(OppidToOppMap.get(oppRec.id).Number_of_opp_products_with_asset__c <= 0 && string.isNotBlank(rec.VehicleIdentificationNumber) && vinToAssetMap.containsKey(rec.VehicleIdentificationNumber) && string.isNotBlank(rec.Price)){
                        assetList.add(new Asset(id = vinToAssetMap.get(rec.VehicleIdentificationNumber).id, AccountId = OppidToOppMap.get(oppRec.id).accountId));
                        string Key = vinToAssetMap.get(rec.VehicleIdentificationNumber).product2id + '#$%' + OppidToOppMap.get(oppRec.id).Pricebook2Id;
                        If(PriceBookEntryRecord.containsKey(Key))
                            oppLIList.add(new OpportunityLineItem(product2Id = vinToAssetMap.get(rec.VehicleIdentificationNumber).product2id, Asset__c = vinToAssetMap.get(rec.VehicleIdentificationNumber).id, opportunityId = oppRec.id, quantity = 1, PricebookEntryId = PriceBookEntryRecord.get(Key), unitprice=decimal.valueOf(rec.Price)));
                    }
                }
                else if(rec.Quote != '--/--/----' && OppidToOppMap.get(oppRec.id).stagename != 'Negotiation & Approval'){
                    oppRec.StageName = 'Negotiation & Approval';
                    oppRec.Quotation_Provided_MENA__c = true;
                    oppRec.Quote_saved_date__c = date.parse(rec.Quote);
                }
                else if(rec.Demo != '--/--/----' && OppidToOppMap.get(oppRec.id).stagename != 'Test Drive Taken/Booked'){
                    oppRec.StageName = 'Test Drive Taken/Booked';
                    oppRec.Test_Drive_Completed_Date__c = date.parse(rec.Demo);
                    oppRec.Test_Drive_Completed_Date_MENA__c = date.parse(rec.Demo);
                    oppRec.Test_Drive_Completed_MENA__c = true;
                }
                else if(string.isNotBlank(rec.VehicleIdentificationNumber) && rec.Price == '0'){
                    oppRec.StageName = 'Vehicle Selection';
                }
                else if(string.isBlank(rec.VehicleIdentificationNumber) && string.isNotBlank(rec.Price) && decimal.valueOf(rec.Price) > 0 && rec.Demo == '--/--/----' && rec.Quote == '--/--/----' && rec.Order == '--/--/----' && rec.Lost == '--/--/----' && rec.DeliveryDate == '--/--/----')
                    oppRec.StageName = 'Negotiation & Approval';
                
                if(string.isNotBlank(rec.TypeNewUsed)){
                    if(rec.TypeNewUsed == 'NEW')
                        oppRec.Purchase_Type__c = 'New Vehicle';
                    else 
                        oppRec.Purchase_Type__c = 'Used Vehicle';
                }
                if(rec.LastEditDate != '--/--/----')
            		oppRec.DMS_Last_Edit_Date__c = Date.parse(rec.LastEditDate);
                if(string.isNotBlank(rec.Price)){
                    oppRec.Amount = decimal.valueOf(rec.Price);
                    if(string.isNotBlank(rec.VAT) && decimal.valueOf(rec.VAT) > 0){
                        decimal VatPercent = decimal.valueOf(rec.VAT)/decimal.valueOf(rec.Price);
                        oppRec.VAT__c = integer.valueOf(VatPercent.round(System.RoundingMode.HALF_UP));	//should be percentage
                    }
                }
                oppRec.Country_ISO_Code__c = OppidToOppMap.get(oppRec.id).account.Country_ISO_Code__c;
                system.debug('oppRec:::'+oppRec);
                oppsToUpdate.add(oppRec);
                
                Account accRec = new Account();
                accRec.id = OppidToAccIdMap.containsKey(oppRec.id) ? OppidToAccIdMap.get(oppRec.id) : OppidToPAccIdMap.get(oppRec.id);
                if(OppidToAccIdMap.containsKey(oppRec.id)){
                	if(string.isNotBlank(rec.CompanyName))
                    	accRec.Name = rec.CompanyName;
                    if(OppidToConIdMap.containsKey(oppRec.id)){
                    	Contact conRec = new Contact();
                        conRec.id = OppidToConIdMap.get(oppRec.id);
                        conRec.Salutation = rec.Salutation;
                        //conRec.FirstName = rec.FirstName;
                        //conRec.LastName = rec.Surname;
                        conRec.Gender__c = rec.Gender;
                        conRec.Language__c = rec.Language;
                        conRec.Employment_Status__c = rec.EmploymentStatus;
                        conRec.Title = rec.Occupation;
                        conRec.MobilePhone = rec.Mobile;
                        conRec.Phone = rec.Phone;
                        conRec.HomePhone = rec.HomePhone;
                        conRec.Email = rec.Email;
                        conRec.Email2__c = rec.Email2;
                        consToUpdate.add(conRec);
                    }
                }
                else{
                    accRec.Salutation = rec.Salutation;
                    //accRec.FirstName = rec.FirstName;
                    //accRec.LastName = rec.Surname;
                    accRec.Gender__pc = rec.Gender;
                    accRec.Language__pc = rec.Language;
					accRec.Employment_Status__pc = rec.EmploymentStatus;
                    accRec.PersonTitle = rec.Occupation;
                    accRec.PersonMobilePhone = rec.Mobile;
                    accRec.PersonOtherPhone = rec.Phone;
                    accRec.PersonHomePhone = rec.HomePhone;
                    accRec.PersonEmail = rec.Email;
                    accRec.Email2__pc = rec.Email2;
                }
                accRec.Industry = rec.Industry;
                accRec.BillingStreet = rec.Address;
                accRec.BillingCity = rec.Address2;
                accRec.BillingCountry = rec.NationalityCode;
                accsToUpdate.add(accRec);
            }
        }
        if(assetList.size()>0)
            update assetList;
        if(oppLIList.size()>0)
            insert oppLIList;   
    }
}