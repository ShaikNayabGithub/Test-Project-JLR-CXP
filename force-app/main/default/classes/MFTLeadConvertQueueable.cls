public class MFTLeadConvertQueueable implements Queueable {
    List<Lead> leadsList = new List<Lead>();
    List<MFTProspectsWrapper> prospectsWrapper = new List<MFTProspectsWrapper>();
    List<MFTOppsWrapper> OppsWrapper = new List<MFTOppsWrapper>();
    String LogId = '';
    
    public MFTLeadConvertQueueable(List<Lead> leadsList, List<MFTProspectsWrapper> prospectsWrapper, String LogId){
        this.leadsList = leadsList;
        this.prospectsWrapper = prospectsWrapper;
        this.LogId = LogId;
    }
    
    public MFTLeadConvertQueueable(List<Lead> leadsList, List<MFTOppsWrapper> OppsWrapper, String LogId){
        this.leadsList = leadsList;
        this.OppsWrapper = OppsWrapper;
        this.LogId = LogId;
    }
    
    public void execute(QueueableContext context) {
        List<opportunity> oppsToUpdate = new List<opportunity>();
        List<Account> accsToUpdate = new List<Account>();
        List<Contact> consToUpdate = new List<Contact>();
        List<Database.LeadConvert> leadsConvertList = new List<Database.LeadConvert>();
        Map<Id,Lead> leadsMap = new Map<Id,Lead>();
        List<String> ErrorLogs = new List<String>();
        List<String> SuccessLogs = new List<String>();
        Map<String,CountryToPricebook__mdt> countryMaps = new Map<String,CountryToPricebook__mdt>();
        
        for (CountryToPricebook__mdt lpe : [Select id,Default_Currency__c,Country_ISO_Code__c,PricebookId__c,Pricebook_Name__c from CountryToPricebook__mdt]){ 
            if(lpe.Country_ISO_Code__c != null && lpe.Country_ISO_Code__c != '')
                countryMaps.put(lpe.Country_ISO_Code__c, lpe);                 
        }
        
        Map<string, MENA_Lead_Conversion_settings__mdt > leadConvertMap = new Map<string, MENA_Lead_Conversion_settings__mdt>();
        for(MENA_Lead_Conversion_settings__mdt rec : [Select Country_Code__c, Owner_Id__c from MENA_Lead_Conversion_settings__mdt where Used_In__c = 'CXP Inbound'])
            leadConvertMap.put(rec.Country_Code__c, rec);
        
        for(Lead rec : leadsList){
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(rec.Id);
            if(string.isNotBlank(rec.Country_ISO_Code__c) && leadConvertMap.containsKey(rec.Country_ISO_Code__c))
             	lc.setOwnerId(leadConvertMap.get(rec.Country_ISO_Code__c).Owner_Id__c);
            lc.convertedStatus = 'Qualified';
            leadsConvertList.add(lc);
            leadsMap.put(rec.Id, rec);
        }
        system.debug('leadsConvertList::::'+leadsConvertList);
        
        if(!leadsConvertList.isEmpty()){
            Try{
                List<Opportunity> convertedOppsList = new List<Opportunity>();
                id recordtypeIDOpp = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Process with RDA').getRecordTypeId();
                Database.LeadConvertResult[] lcrList = Database.convertLead(leadsConvertList, false);                    
                for(Database.LeadConvertResult lcr : lcrList){
                    if(lcr.isSuccess()){
                        string CurrencyIsoCode = countryMaps.get(LeadsMap.get(lcr.getLeadId()).Country_ISO_Code__c).Default_Currency__c;
						string Pricebook2Id = countryMaps.get(LeadsMap.get(lcr.getLeadId()).Country_ISO_Code__c).PricebookId__c;
                        opportunity oppToAdd = new Opportunity(id = lcr.getOpportunityId(), MENA_DMS_ID__c = leadsMap.get(lcr.getLeadId()).DMS_ID__c, recordtypeId = recordtypeIDOpp, CurrencyIsoCode = CurrencyIsoCode, Pricebook2Id = Pricebook2Id);
                        if(leadsMap.get(lcr.getLeadId()).ownerId != null)
                            oppToAdd.ownerId = leadsMap.get(lcr.getLeadId()).ownerId;
                        oppToAdd.Country_ISO_Code__c = LeadsMap.get(lcr.getLeadId()).Country_ISO_Code__c;
                        convertedOppsList.add(oppToAdd);
                    }else
                        ErrorLogs.add('Lead Convert Errors::: '+lcr.getLeadId()+' '+JSON.Serialize(lcr.getErrors()));
                }
                system.debug('convertedOppsList::::'+convertedOppsList);
                
                if(convertedOppsList.size()>0)
                    Database.update(convertedOppsList, false);
                
                Map<string,string> DMSidToOppidMap = new Map<string,string>();
                List<opportunity> oppsList = [Select id, DMS_Last_Edit_Date__c, MENA_DMS_ID__c, accountId, account.IsPersonAccount, contactid, stagename, VIN__c, Pricebook2Id, account.Country_ISO_Code__c, Number_of_opp_products_with_asset__c from opportunity where id in: convertedOppsList];
                for(opportunity oppRec : oppsList){
                    DMSidToOppidMap.put(oppRec.id, oppRec.MENA_DMS_ID__c);
                }
                
                if(OppsWrapper.size()>0){
                    system.debug('oppsToUpdate::::'+oppsToUpdate);
                    system.debug('accsToUpdate::::'+accsToUpdate);
                    CXPInboundOpps.prepareListsForUpdate(oppsList, DMSidToOppidMap, OppsWrapper, oppsToUpdate, accsToUpdate, consToUpdate);
                    system.debug('oppsToUpdate::::'+oppsToUpdate);
                    system.debug('accsToUpdate::::'+accsToUpdate);
                }
                /*else{
                    Map<string,string> OppidToAccIdMap = new Map<string,string>();
                    Map<string,string> OppidToPAccIdMap = new Map<string,string>();
                    Map<string,string> OppidToConIdMap = new Map<string,string>();
                    Map<string,opportunity> OppidToOppMap = new Map<string,opportunity>();
                    
                    for(opportunity oppRec : oppsList){
                        if(oppRec.account.IsPersonAccount)
                            OppidToPAccIdMap.put(oppRec.id, oppRec.accountId);
                        else{
                            OppidToAccIdMap.put(oppRec.id, oppRec.accountId);
                            if(string.isNotBlank(oppRec.contactid))
                                OppidToConIdMap.put(oppRec.id, oppRec.contactid);
                        }
                        OppidToOppMap.put(oppRec.id, oppRec);
                    }
                    system.debug('OppidToConIdMap::::'+OppidToConIdMap);
                    system.debug('OppidToPAccIdMap::::'+OppidToPAccIdMap);
                    system.debug('OppidToAccIdMap::::'+OppidToAccIdMap);
                    
                    Set<String> BrandSet = new Set<String>();
                    Set<String> ModelSet = new Set<String>();
                    for(MFTProspectsWrapper rec : prospectsWrapper){
                        BrandSet.add(rec.Brand);
                        ModelSet.add(rec.Model);
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
                            if(rec.TypeNewUsed == 'NEW')
                                oppRec.Purchase_Type__c = 'New Vehicle';
                            else
                                oppRec.Purchase_Type__c = 'Used Vehicle';
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
                }*/
                
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
                
                string service = OppsWrapper.size()>0 ? 'Jobrouter CXP Opportunities' : 'CDK CXP Prospects';
                CXPInboundLeads.createUpdateLogs(null, status, ErrorLogs, service, LogId, status);
            }
            catch(exception e){
                string service = OppsWrapper.size()>0 ? 'Jobrouter CXP Opportunities' : 'CDK CXP Prospects';
                CXPInboundLeads.createUpdateLogs(null, e.getMessage(), new List<String>{e.getStackTraceString()}, service, LogId, 'Error');
            }
        }
    }
}