public without sharing class GPC_ConsentManagementController {
    private static String unknownValue = 'NotSeen';

    @AuraEnabled
    public static ConsentWrapper getConsents(Id recordId){
        

        ConsentWrapper result = new ConsentWrapper();
        result.userName = userinfo.getName();
        result.editAccess = false;
        result.consentOptions = new List<ConsentOptionWrapper>();
        ConsentOptionWrapper consentOption = new ConsentOptionWrapper();
        consentOption.label = Label.GPC_OptIn;
        consentOption.value = 'OptIn';
        result.consentOptions.add(consentOption);
        consentOption = new ConsentOptionWrapper();
        consentOption.label = Label.GPC_OptOut;
        consentOption.value = 'OptOut';
        result.consentOptions.add(consentOption);
        //result.dontMarket = false;

        //Check record access
        UserRecordAccess userAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        if (userAccess.HasEditAccess) result.editAccess = true;
        
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        Map<String, ContactPointTypeConsent> existingConsentMap = new Map<String, ContactPointTypeConsent>();
        Id individualId;

        Boolean isPartner = (UserInfo.getUserType() == 'PowerPartner' && sObjectName != 'Lead');
        
        sObject record = Database.query('Select Id, RecordTypeId, ' + (sObjectName=='Account'?'Retailer_Id__c, Is_Primary__c, PersonIndividualId, PersonContactId, PersonContact.FirstName, PersonContact.LastName':'IndividualId, FirstName, LastName') + (sObjectName=='Lead'?', Status':'') + (sObjectName=='Contact'?', Account.Retailer_Id__c, Account.RecordTypeId':'') + ', Country_ISO_Code__c From ' + sObjectName + ' Where Id = :recordId');

        result.leadConverted = true;
        if (sObjectName == 'Lead' && (String)record.get('Status') == 'Qualified') return result;
        result.leadConverted = false;

        result.isIndividual = false;
        if ((Id)record.get(sObjectName == 'Account'?'PersonIndividualId':'IndividualId') == null) return result;
        result.isIndividual = true;
            
        individualId = (Id)record.get(sObjectName=='Account'?'PersonIndividualId':'IndividualId');

        Id retailerId;
        if (sObjectName=='Account' && (Id)record.get('RecordTypeId') == '01224000000TXPcAAO') retailerId = (Id)record.get('Retailer_Id__c');
        if (sObjectName=='Contact' && record.getSObject('Account') != null && ((Account)record.getSObject('Account')).RecordTypeId == '01224000000kGLJAA2') retailerId = ((Account)record.getSObject('Account')).Retailer_Id__c;

        if (isPartner && retailerId == null) throw new AuraHandledException('Retailer not identified for the record. Please contact support');
        
        //gp added
        //system.debug('individual id' + individualId);
        //system.debug('retailer id' + retailerId);
        //gp ended
        for (ContactPointTypeConsent cptc : Database.query('Select Id, DataUsePurposeId, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId = :individualId And DataUsePurposeId != null'+ (retailerId!=null?' And (Retailer__c = null Or Retailer__c = :retailerId)':' And Retailer__c = null') +' Order By CaptureDate asc')) {
        //GP
        //System.debug('cptc data');
        //system.debug(cptc);
        //GP
            existingConsentMap.put(cptc.DataUsePurposeId + cptc.Channel__c, cptc);
        }
        

        String market = (String)record.get('Country_ISO_Code__c');

        String query = 'SELECT Id, toLabel(Translatable_Value__c), Description, Retailer_Only__c, (SELECT Id, toLabel(Translatable_Value__c), Description, Available_Channels__c FROM DataUsePurposes' + (market != null && market != ''?' WHERE Available_in_Markets__c INCLUDES (:market)':'') + ' ORDER BY Name) FROM DataUseLegalBasis'+ (retailerId==null?' WHERE Retailer_Only__c = false':(isPartner?' WHERE Retailer_Only__c = true':'')) +' ORDER BY Name';
        //GP
        //system.debug('GP : ' + query);
        //system.debug('existingconsentmap data');
        //system.debug(existingConsentMap);
        //GP
        result.legalBasisList = new List<LegalBasisWrapper>();
        for (DataUseLegalBasis legalBasis : Database.query(query)) {
            List<ChannelWrapper> channelList = new List<ChannelWrapper>();
            Integer optInTopicTotal = 0;
            Integer optOutTopicTotal = 0;
            Integer totalOptions = 0;
            for (Schema.PicklistEntry ple : ContactPointTypeConsent.Channel__c.getDescribe().getPicklistValues()) {
                String channelName = ple.getValue();
                String channelLabel = ple.getLabel();
                
                List<PurposeWrapper> pursposeList = new List<PurposeWrapper>();
                Integer optInTotal = 0;
                Integer optOutTotal = 0;
                for (DataUsePurpose purpose : legalBasis.DataUsePurposes) {
                    if (purpose.Available_Channels__c.contains(channelName)) {
                        String consent = unknownValue;
                        String captureDate;
                        String captureBy;
                        if (existingConsentMap.containsKey(purpose.Id+channelName)) {
                            ContactPointTypeConsent cptc = existingConsentMap.get(purpose.Id+channelName);
                            consent = cptc.PrivacyConsentStatus;
                            captureDate = string.valueofGmt(cptc.CaptureDate);
                            captureBy = cptc.LastModifiedBy.Name;
                        }
                        pursposeList.add(new PurposeWrapper(purpose.Id, purpose.Translatable_Value__c, purpose.Description, consent, captureDate, captureBy));
                        if (consent == 'OptIn') optInTotal++;
                        if (consent == 'OptOut') optOutTotal++;
                        totalOptions++;
                    }
                }
                channelList.add(new ChannelWrapper(channelName, channelLabel, optInTotal, optOutTotal, pursposeList));
                optInTopicTotal += optInTotal;
                optOutTopicTotal += optOutTotal;
            }

            result.legalBasisList.add(new LegalBasisWrapper(legalBasis.Id, legalBasis.Translatable_Value__c, legalBasis.Description, optInTopicTotal, optOutTopicTotal, totalOptions, channelList));
        }

        return result;
    }

    @AuraEnabled
    public static void updateConsents(Id recordId, Id legalBasisId, Id purposeId, String channel, String consent){
        directManagement = true;

        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        sObject record = Database.query('Select Id, RecordTypeId, ' + (sObjectName=='Account'?'PersonIndividualId, Retailer_Id__c':'IndividualId') + (sObjectName=='Contact'?', Account.Retailer_Id__c, Account.RecordTypeId':'') + ', Country_ISO_Code__c From ' + sObjectName + ' Where Id = :recordId');
        String market = (String)record.get('Country_ISO_Code__c');
        Id individualId = (Id)record.get(sObjectName=='Account'?'PersonIndividualId':'IndividualId');

        Id retailerId;
        if (sObjectName=='Account' && (Id)record.get('RecordTypeId') == '01224000000TXPcAAO') retailerId = (Id)record.get('Retailer_Id__c');
        if (sObjectName=='Contact' && ((Account)record.getSObject('Account')).RecordTypeId == '01224000000TXPcAAO') retailerId = ((Account)record.getSObject('Account')).Retailer_Id__c;

        Map<Id, String> purposeNameMap = new Map<Id, String>();
        Map<Id, String> purposeChannelMap = new Map<Id, String>();

        String query = 'Select Id, Name, LegalBasisId, LegalBasis.Name, LegalBasis.Retailer_Only__c, Available_Channels__c From DataUsePurpose';
        String whereClause = ' WHERE Id = :purposeId';
        Boolean allPurposes = false;
        system.debug('#purposeId:'+purposeId);
        if (purposeId == null) {
            whereClause = ' WHERE LegalBasisId = :legalBasisId' + (market != null && market != ''?' AND Available_in_Markets__c INCLUDES (:market)':'');
            allPurposes = true;
        }
        Set<Id> purposeIds = new Set<Id>();
        Boolean isRetailerOnlyUpdate = false;
        for (DataUsePurpose dup : Database.query(query + whereClause)) {
            purposeNameMap.put(dup.Id, (dup.LegalBasisId!=null?dup.LegalBasis.Name+':':'') + dup.Name);
            purposeChannelMap.put(dup.Id, dup.Available_Channels__c);
            purposeIds.add(dup.Id);
            if (!isRetailerOnlyUpdate && dup.LegalBasis.Retailer_Only__c) isRetailerOnlyUpdate = true;
        }

        Set<String> channels = new Set<String>();
        if (channel != null) channels.add(channel);
        if (channel == null) for (Schema.PicklistEntry ple : ContactPointTypeConsent.Channel__c.getDescribe().getPicklistValues()) channels.add(ple.getLabel());

        Map<String, ContactPointTypeConsent> cptcMap = new Map<String, ContactPointTypeConsent>();
        for (ContactPointTypeConsent cptc : Database.query('Select Id, DataUsePurposeId, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c, Retailer__c from ContactPointTypeConsent Where PartyId = :individualId'+ (isRetailerOnlyUpdate && retailerId!=null?' And Retailer__c = :retailerId':' And Retailer__c = null') +' And DataUsePurposeId in :purposeIds And Channel__c in :channels')) {
            cptcMap.put(''+cptc.DataUsePurposeId+cptc.Channel__c, cptc);
        }

        List<ContactPointTypeConsent> upsertList = new List<ContactPointTypeConsent>();
        for (Id pId : purposeIds) {
            for (String chn : channels) {
                if (!purposeChannelMap.get(pId).contains(chn)) continue;

                ContactPointTypeConsent rec = new ContactPointTypeConsent(Name = purposeNameMap.get(pId)+':'+chn, PartyId = individualId, DataUsePurposeId = pId, Channel__c = chn);
                if (isRetailerOnlyUpdate && retailerId != null) rec.Retailer__c = retailerId;
                if (cptcMap.containsKey(''+pId+chn)) rec = cptcMap.get(''+pId+chn);

                rec.PrivacyConsentStatus = consent;
                rec.CaptureDate = Datetime.now();
                upsertList.add(rec);
            }
        }

        if (!upsertList.isEmpty()) upsert upsertList;

        syncToCheckboxes(recordId, individualId, market, isRetailerOnlyUpdate, retailerId);
    }

    public static void syncToCheckboxes(Id recordId, Id individualId, String market, Boolean isRetailerOnlyUpdate, Id retailerId) {
        ConsentHandler.syncConsents = false;
        Set<Id> dataUsePurposeIds = new Set<Id>();
        for (DataUsePurpose allDUP : Database.query('SELECT Id FROM DataUsePurpose WHERE LegalBasis.Retailer_Only__c = :isRetailerOnlyUpdate' + (market != null && market != ''?' AND Available_in_Markets__c INCLUDES (:market)':''))) dataUsePurposeIds.add(allDUP.Id);

        Set<String> optOutChannels = new Set<String>();
        Set<String> optInChannels = new Set<String>();
        for (AggregateResult ar : Database.query('Select Channel__c, PrivacyConsentStatus From ContactPointTypeConsent Where PartyId = :individualId And DataUsePurposeId in :dataUsePurposeIds Group By Channel__c, PrivacyConsentStatus')) {
            if ((String)ar.get('PrivacyConsentStatus') == 'OptOut') optOutChannels.add((String)ar.get('Channel__c'));
            else optInChannels.add((String)ar.get('Channel__c'));
        }

        

        system.debug('##optInChannels: '+optInChannels);
        system.debug('##optOutChannels: '+optOutChannels);
        optOutChannels.removeAll(optInChannels);

        if (!optOutChannels.isEmpty()) {
            Set<String> maintainedPurposeChannels = new Set<String>();
            for (AggregateResult ar : Database.query('Select DataUsePurposeId, Channel__c From ContactPointTypeConsent Where PartyId = :individualId And DataUsePurposeId in :dataUsePurposeIds And Channel__c in :optOutChannels Group By DataUsePurposeId, Channel__c')) maintainedPurposeChannels.add((String)ar.get('DataUsePurposeId')+(String)ar.get('Channel__c'));
            
            for (Id purposeId : dataUsePurposeIds) {
                if (optOutChannels.contains('Email') && !maintainedPurposeChannels.contains(purposeId+'Email')) optOutChannels.remove('Email');
                if (optOutChannels.contains('Telephone') && !maintainedPurposeChannels.contains(purposeId+'Telephone')) optOutChannels.remove('Telephone');
                if (optOutChannels.contains('SMS') && !maintainedPurposeChannels.contains(purposeId+'SMS')) optOutChannels.remove('SMS');
                if (optOutChannels.contains('Post') && !maintainedPurposeChannels.contains(purposeId+'Post')) optOutChannels.remove('Post');
            }
        }

        List<sObject> updateList = new List<sObject>();
        for (Contact con : Database.query('Select Id, HasOptedOutOfEmail, DoNotCall, et4ae5__HasOptedOutOfMobile__c, Direct_Mail_Opt_Out__c From Contact Where IndividualId = :individualId And '+(isRetailerOnlyUpdate && retailerId != null?'Account.Owner.Contact.AccountId = :retailerId':'Account.RecordTypeId != \'01224000000TXPcAAO\''))) {
            if (!(con.HasOptedOutOfEmail == optOutChannels.contains('Email')) || !(con.DoNotCall == optOutChannels.contains('Telephone')) || !(con.et4ae5__HasOptedOutOfMobile__c == optOutChannels.contains('SMS')) || !(con.Direct_Mail_Opt_Out__c == optOutChannels.contains('Post'))) 
                updateList.add(new Contact(Id = con.Id
                                        , HasOptedOutOfEmail = optOutChannels.contains('Email')
                                        , DoNotCall = optOutChannels.contains('Telephone')
                                        , et4ae5__HasOptedOutOfMobile__c = optOutChannels.contains('SMS')
                                        , Direct_Mail_Opt_Out__c = optOutChannels.contains('Post')));
        }

        if (!isRetailerOnlyUpdate) {
            for (Lead l : [Select Id, HasOptedOutOfEmail, DoNotCall, et4ae5__HasOptedOutOfMobile__c, Whitemail_Opt_Out__c From Lead Where IndividualId = :individualId]) {
                if (!(l.HasOptedOutOfEmail == optOutChannels.contains('Email')) || !(l.DoNotCall == optOutChannels.contains('Telephone')) || !(l.et4ae5__HasOptedOutOfMobile__c == optOutChannels.contains('SMS')) || !(l.Whitemail_Opt_Out__c == optOutChannels.contains('Post'))) 
                    updateList.add(new Lead(Id = l.Id
                                            , HasOptedOutOfEmail = optOutChannels.contains('Email')
                                            , DoNotCall = optOutChannels.contains('Telephone')
                                            , et4ae5__HasOptedOutOfMobile__c = optOutChannels.contains('SMS')
                                            , Whitemail_Opt_Out__c = optOutChannels.contains('Post')));
            }
        }

        system.debug('updateList: '+updateList);
        if (!updateList.isEmpty()) update updateList;
    }

    public static Boolean directManagement;

    public class ConsentWrapper {
        //@AuraEnabled public Boolean dontMarket {get;set;}
        @AuraEnabled public String userName {get;set;}
        @AuraEnabled public Boolean editAccess {get;set;} 
        @AuraEnabled public Boolean leadConverted {get;set;} 
        @AuraEnabled public Boolean isIndividual {get;set;} 
        @AuraEnabled public List<ConsentOptionWrapper> consentOptions {get;set;} 
        @AuraEnabled public List<LegalBasisWrapper> legalBasisList {get;set;}
    }

    public class ConsentOptionWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
    }

    public class LegalBasisWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Integer optInTotal {get;set;}
        @AuraEnabled public Integer optOutTotal {get;set;}
        @AuraEnabled public Integer totalOptions {get;set;}
        @AuraEnabled public List<ChannelWrapper> channelList {get;set;}
        //@AuraEnabled public List<ChannelWrapper> channelOnlyList {get;set;}

        public LegalBasisWrapper(String id, String name, String description, Integer optInTotal, Integer optOutTotal, Integer totalOptions, List<ChannelWrapper> channelList) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.optInTotal = optInTotal;
            this.optOutTotal = optOutTotal;
            this.totalOptions = totalOptions;
            this.channelList = channelList;
            //this.channelOnlyList = channelOnlyList;
        }
    }

    public class ChannelWrapper {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public Integer optInTotal {get;set;}
        @AuraEnabled public Integer optOutTotal {get;set;}
        @AuraEnabled public List<PurposeWrapper> pursposeList {get;set;}

        public ChannelWrapper(String name, String label, Integer optInTotal, Integer optOutTotal, List<PurposeWrapper> pursposeList) {
            this.name = name;
            this.label = label;
            this.optInTotal = optInTotal;
            this.optOutTotal = optOutTotal;
            this.pursposeList = pursposeList;
        }
    }

    public class PurposeWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public String consent {get;set;}
        @AuraEnabled public String captureDate {get;set;}
        @AuraEnabled public String captureBy {get;set;}
        @AuraEnabled public String previousConsent {get;set;}

        public PurposeWrapper(String id, String name, String description, String consent, String captureDate, String captureBy) {
            this.id = id;
            this.name = name;
            this.description = description;
            this.consent = this.previousConsent = consent;
            this.captureDate = captureDate;
            this.captureBy = captureBy;
        }
    }

    /*public class LabelValueWrapper {
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public Boolean value {get;set;}

        public LabelValueWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }*/
}