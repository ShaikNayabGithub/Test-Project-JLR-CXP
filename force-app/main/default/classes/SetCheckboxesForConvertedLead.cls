public class SetCheckboxesForConvertedLead {
    
    public void setCheckboxes(List<Lead> leads) {
        
        Map<Lead, Id> contactIds = new Map<Lead, Id>(); 
        Map<Lead, Id> opptyIds = new Map<Lead, Id>();
        
        for (Lead l : leads) {
            
            if (l.ConvertedContactId != null) {
                contactIds.put(l, l.ConvertedContactId);
            }
            
            if (l.ConvertedOpportunityId != null) {
                opptyIds.put(l, l.ConvertedOpportunityId);
            }
        }
        
        List<Contact> contacts = [Select Net_Worth__c, Owners_Club_Requested__c, Direct_Mail_Opt_Out__c, HasOptedOutOfEmail, DoNotCall, et4ae5__HasOptedOutOfMobile__c  from Contact where Id in :contactIds.values()];
        List<Opportunity> opps = [Select Accident_History__c, Financed__c, Pricebook2Id, CurrencyIsoCode, Owner.Country_Iso_Code__c,Country_Iso_code__c,Account.Country_Iso_code__c, Finance_Interest__c, In_Control_Vehicle__c, Trade_In__c from Opportunity where Id in :opptyIds.values()];
        
        Map<Id, Contact> convertedContacts = new Map<Id, Contact>(contacts);
        Map<Id, Opportunity> convertedOpps = new Map<Id, Opportunity>(opps);
        Map<String,CountryToPricebook__mdt> countryMaps = new  Map<String,CountryToPricebook__mdt>();
        Map < String, CountryToPricebook__mdt > retrieveCustomMetadataMap = CountryToPricebook__mdt.getAll();
        // List < CountryToPricebook__mdt > listOfPricebooks = [Select id,Default_Currency__c,Country_ISO_Code__c,PricebookId__c,Pricebook_Name__c from CountryToPricebook__mdt];
        for (CountryToPricebook__mdt lpe: retrieveCustomMetadataMap.values()) { 
            if(lpe.Country_ISO_Code__c != null && lpe.Country_ISO_Code__c != ''){
                countryMaps.put(lpe.Country_ISO_Code__c, lpe);   
            }                        
        }
        // System.debug('countryMaps '+Json.serializePretty(countryMaps));
        for (Lead le : leads) {
            
            Id conId = contactIds.get(le);
            Id oppId = opptyIds.get(le);
            
            if (conId != null) {
                //convertedContacts.get(conId).Land_Rover_Whitemail_Opt_Out__c = le.Whitemail_Opt_Out__c;
                //convertedContacts.get(conId).Jaguar_Whitemail_Opt_Out__c = le.Whitemail_Opt_Out__c;
                convertedContacts.get(conId).Direct_Mail_Opt_Out__c = le.Whitemail_Opt_Out__c;
                convertedContacts.get(conId).Net_Worth__c = le.Net_Worth__c;
                //convertedContacts.get(conId).Land_Rover_Email_Opt_Out__c = le.HasOptedOutOfEmail;
                //convertedContacts.get(conId).Jaguar_Email_Opt_Out__c = le.HasOptedOutOfEmail;
                convertedContacts.get(conId).HasOptedOutOfEmail = le.HasOptedOutOfEmail;
                //convertedContacts.get(conId).Jaguar_Phone_Opt_Out__c = le.DoNotCall;
                //convertedContacts.get(conId).Land_Rover_Phone_Opt_out__c = le.DoNotCall;
                convertedContacts.get(conId).DoNotCall = le.DoNotCall;
                //convertedContacts.get(conId).Land_Rover_SMS_Opt_Out__c = le.et4ae5__HasOptedOutOfMobile__c;
                //convertedContacts.get(conId).Jaguar_SMS_Opt_out__c = le.et4ae5__HasOptedOutOfMobile__c;
                convertedContacts.get(conId).et4ae5__HasOptedOutOfMobile__c = le.et4ae5__HasOptedOutOfMobile__c;
                if(le.et4ae5__HasOptedOutOfMobile__c || le.SMS_Opt_Out__c) {
                    //convertedContacts.get(conId).Land_Rover_SMS_Opt_Out__c = true;
                    //convertedContacts.get(conId).Jaguar_SMS_Opt_out__c = true;
                    convertedContacts.get(conId).et4ae5__HasOptedOutOfMobile__c = true;
                }
                else {
                    //convertedContacts.get(conId).Land_Rover_SMS_Opt_Out__c = false;
                    //convertedContacts.get(conId).Jaguar_SMS_Opt_out__c = false;
                    convertedContacts.get(conId).et4ae5__HasOptedOutOfMobile__c = false;
                }
                convertedContacts.get(conId).Owners_Club_Requested__c = le.Owners_Club_Requested__c;
            }
            
            if (oppId != null) {
                convertedOpps.get(oppId).Financed__c = le.Financed__c;
                convertedOpps.get(oppId).Finance_Interest__c = le.Finance_Interest__c;
                convertedOpps.get(oppId).In_Control_Vehicle__c = le.In_Control_Vehicle__c;
                convertedOpps.get(oppId).Trade_In__c = le.Trade_In__c;
                convertedOpps.get(oppId).Accident_History__c = le.Accident_History__c;
                if(convertedOpps.get(oppId).Pricebook2Id == null && convertedOpps.get(oppId).Country_Iso_Code__c != null && countryMaps.containsKey(convertedOpps.get(oppId).Country_Iso_Code__c)){
                    CountryToPricebook__mdt pricebook = countryMaps.get(convertedOpps.get(oppId).Country_Iso_Code__c);
                    
                    
                    if(pricebook != null  && pricebook.PricebookId__c != null && pricebook.Default_Currency__c != null ){                     
                        convertedOpps.get(oppId).Pricebook2Id = pricebook.PricebookId__c;       
                          convertedOpps.get(oppId).CurrencyIsoCode = pricebook.Default_Currency__c;     
                    }
                    
                }
                
                
                
            } 
            
        }
        
        update convertedContacts.values();
        update convertedOpps.values();
    }
}