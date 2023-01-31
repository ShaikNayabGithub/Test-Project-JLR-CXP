public class ConnectedServicesConsentBatch implements Database.Batchable<SObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'Select Id, Gigya_Id__c, Last_Name__c, Email_Address__c, Mobile_Phone__c, Business_Phone__c, Home_Phone__c, VIN__c, Market__c, VHS_Accepted__c, VHS_Accepted_Date__c From Connected_Services_Consent__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Connected_Services_Consent__c > scope){
        Map<String, Connected_Services_Consent__c> vinMap = new Map<String, Connected_Services_Consent__c>();
        for (Connected_Services_Consent__c csc : scope) if(String.isNotBlank(csc.VIN__c)) vinMap.put(csc.VIN__c, csc);

        Map<Id, Connected_Services_Consent__c> individualMap = new Map<Id, Connected_Services_Consent__c>();

        for (Role__c rl : [Select Id, Vehicle__r.VIN__c, Contact__c, Contact__r.IndividualId, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Email2__c, Contact__r.Email3__c, Contact__r.MobilePhone, Contact__r.Phone, Contact__r.HomePhone
                            , Account__c, Account__r.PersonIndividualId, Account__r.FirstName, Account__r.LastName, Account__r.PersonEmail, Account__r.Email2__pc, Account__r.Email3__pc, Account__r.PersonMobilePhone, Account__r.Phone, Account__r.PersonHomePhone From Role__c Where Vehicle__r.VIN__c in :vinMap.keySet() And Role__c = 'Current Owner']) {
            Connected_Services_Consent__c csc = vinMap.get(rl.Vehicle__r.VIN__c);
            if (rl.Contact__c != null && rl.Contact__r.IndividualId != null && rl.Contact__r.LastName == csc.Last_Name__c && 
                ((rl.Contact__r.Email != null && rl.Contact__r.Email == csc.Email_Address__c) || (rl.Contact__r.Email2__c != null && rl.Contact__r.Email2__c == csc.Email_Address__c) || (rl.Contact__r.Email3__c != null && rl.Contact__r.Email3__c == csc.Email_Address__c) || (rl.Contact__r.MobilePhone != null && rl.Contact__r.MobilePhone == csc.Mobile_Phone__c) || (rl.Contact__r.Phone != null && rl.Contact__r.Phone == csc.Business_Phone__c ) || (rl.Contact__r.HomePhone != null && rl.Contact__r.HomePhone == csc.Home_Phone__c))) {
                individualMap.put(rl.Contact__r.IndividualId, csc);
            } else if (rl.Account__c != null && rl.Account__r.PersonIndividualId != null && rl.Account__r.LastName == csc.Last_Name__c && 
                ((rl.Account__r.PersonEmail != null && rl.Account__r.PersonEmail == csc.Email_Address__c) || (rl.Account__r.Email2__pc != null && rl.Account__r.Email2__pc == csc.Email_Address__c) || (rl.Account__r.Email3__pc != null && rl.Account__r.Email3__pc == csc.Email_Address__c)  || (rl.Account__r.PersonMobilePhone != null && rl.Account__r.PersonMobilePhone == csc.Mobile_Phone__c)  || (rl.Account__r.Phone != null && rl.Account__r.Phone == csc.Business_Phone__c ) || (rl.Account__r.PersonHomePhone != null && rl.Account__r.PersonHomePhone == csc.Home_Phone__c))) {
                individualMap.put(rl.Account__r.PersonIndividualId, csc);
            }
        }

        if (individualMap.isEmpty()) return;

        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();
        String connectedCar = consentSettings.get('Purpose_Conntected_Car').CXP_Name__c;
        Map<Id, String> purposeNameMap = new Map<Id, String>();

        for (DataUsePurpose dup : [Select Id, Name, LegalBasis.Name, LegalBasisId From DataUsePurpose Where Translatable_Value__c = :connectedCar And LegalBasis.Retailer_Only__c = false]) {
            purposeNameMap.put(dup.Id, (dup.LegalBasisId!=null?dup.LegalBasis.Name+':':'') + dup.Name);
        }

        Map<String, ContactPointTypeConsent> existingConsentMap = new Map<String, ContactPointTypeConsent>();
        for (ContactPointTypeConsent cptc : [Select Id, PartyId, DataUsePurposeId, CaptureDate, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId in :individualMap.keySet() And DataUsePurposeId in :purposeNameMap.keySet() And Retailer__c = null Order By CaptureDate asc]) {
            existingConsentMap.put(cptc.PartyId + cptc.Channel__c, cptc);
        }

        List<ContactPointTypeConsent> consentList = new List<ContactPointTypeConsent>();
        for (Id individualId : individualMap.keySet()) {
            Connected_Services_Consent__c csc = individualMap.get(individualId);
            for (Id pId : purposeNameMap.keySet()) {
                for (Schema.PicklistEntry ple : ContactPointTypeConsent.Channel__c.getDescribe().getPicklistValues()) {
                    String channelName = ple.getValue();
                    ContactPointTypeConsent cptc = new ContactPointTypeConsent(Name = purposeNameMap.get(pId)+':'+channelName, PartyId = individualId, DataUsePurposeId = pId, Channel__c = channelName);
                    if (existingConsentMap.containsKey(individualId+channelName)) {
                        cptc = existingConsentMap.get(individualId+channelName);
                        if (cptc.PrivacyConsentStatus == 'OptIn' && csc.VHS_Accepted__c=='Y') continue;
                    }
                    cptc.PrivacyConsentStatus = csc.VHS_Accepted__c=='Y'?'OptIn':'OptOut';
                    Date captureDate = String.isEmpty(csc.VHS_Accepted_Date__c)?null:Date.parse(csc.VHS_Accepted_Date__c);
                    cptc.CaptureDate = captureDate==null?Datetime.now():Datetime.newInstance(captureDate.year(), captureDate.month(), captureDate.day());
                    consentList.add(cptc);
                }
            }
        }

        if (!consentList.isEmpty()) upsert consentList;
    }
    
    public void finish(Database.BatchableContext bc){
        // finish code
    }

    public void execute(SchedulableContext sc){
        Database.executeBatch(new ConnectedServicesConsentBatch(), 50);
    }  
}