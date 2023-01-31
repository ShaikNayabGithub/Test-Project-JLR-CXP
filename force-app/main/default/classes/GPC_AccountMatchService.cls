@RestResource(urlMapping='/gpc/v1/account-sync/*')
global with sharing class GPC_AccountMatchService {

    @HttpGet
    global static void executeGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String accountId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1).replace('CXP_','');
        List<Account> accList = [SELECT Id, PersonIndividualId, FirstName, LastName, PersonEmail, SAP_CDC_UID__c FROM Account WHERE Id = :accountId];
        if (accList.isEmpty()) return;

        ProfileWrapper profile = new ProfileWrapper();
        profile.firstName = accList[0].FirstName;
        profile.lastName = accList[0].LastName;
        profile.email = accList[0].PersonEmail;

        Map<String, Object> result = new Map<String, Object>();
        result.put('profile', profile);

        result.put('UID', accList[0].SAP_CDC_UID__c);
        
        Map<String, Object> data = new Map<String, Object>();
        data.put('crm_Id', 'CXP_'+accList[0].Id);
        result.put('data', data);

        Map<String, ContactPointTypeConsent> existingConsentsMap = new Map<String, ContactPointTypeConsent>();
        for (ContactPointTypeConsent cptc : [Select Id, DataUsePurpose.CXP_Name__c, DataUsePurpose.LegalBasis.Name, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId = :accList[0].PersonIndividualId And PrivacyConsentStatus in ('OptIn','OptOut')]) {
            String key = cptc.DataUsePurpose.LegalBasis.Name+cptc.Channel__c+cptc.DataUsePurpose.CXP_Name__c;
            existingConsentsMap.put(key.toUpperCase(), cptc);
        }

        system.debug('##PersonIndividualId: '+accList[0].PersonIndividualId);
        system.debug('##existingConsentsMap: '+existingConsentsMap);

        Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();
        Map<String, String> legalBasisMap = new Map<String, String>();
        Map<String, String> purposeMap = new Map<String, String>();
        Map<String, String> channelMap = new Map<String, String>();

        for (Consent_Mapping__mdt setting : consentSettings.values()) {
            if (setting.DeveloperName.startsWith('LegalBasis')) legalBasisMap.put(setting.API_Name__c, setting.CXP_Name__c);
            else if (setting.DeveloperName.startsWith('Purpose')) purposeMap.put(setting.API_Name__c, setting.CXP_Name__c);
            else if (setting.DeveloperName.startsWith('Channel')) channelMap.put(setting.API_Name__c, setting.CXP_Name__c);
        }

        Map<String, Object> subscriptions = new Map<String, Object>();
        for (String legalBasis : legalBasisMap.keySet()) {
            Map<String, Object> brand = new Map<String, Object>();
            for (String channelPref : channelMap.keySet()) {
                Map<String, Object> channel = new Map<String, Object>();
                for (String purpose : purposeMap.keySet()) {
                    String key = legalBasisMap.get(legalBasis)+channelMap.get(channelPref)+purposeMap.get(purpose);
                    ContactPointTypeConsent consent = existingConsentsMap.get(key.toUpperCase());
                    system.debug('##mapping: '+key.toUpperCase());
                    system.debug('##consent: '+consent);
                    if (consent == null) continue;
                    Map<String, Object> purposePref = new Map<String, Object>();
                    purposePref.put('isSubscribed', consent.PrivacyConsentStatus=='OptIn'?true:false);
                    purposePref.put('lastUpdatedSubscriptionState', consent.CaptureDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
                    channel.put(purpose, purposePref);
                }

                if (!channel.isEmpty()) brand.put(channelPref, channel);
            }

            subscriptions.put(legalBasis, brand);
        }
        if (!subscriptions.isEmpty()) result.put('subscriptions', subscriptions);

        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(result));
    }
    
    @HttpPost
    global static String executePost(){
    //global static String executePost(String inputStr){
        //GPC_SSOHandlerAccountInput input = GPC_SSOHandlerAccountInput.parse(inputStr);

        RestRequest req = RestContext.request;
        system.debug('##req: '+req.requestBody.toString());
        Map<String, Object> inputMain = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());

        RestResponse restRsp = RestContext.response;
        Account acc = new Account();
        acc.PersonLeadSource = 'InControl';
        acc.RecordTypeId = AccountUtilities.RecordTypes.get('Individual_Golden_Record').Id;

        if (inputMain.get('data') != null && ((Map<String, Object>)inputMain.get('data')).get('crm_id') != null) {
            String crmId = (String)((Map<String, Object>)inputMain.get('data')).get('crm_id');
            acc = new Account(Id = crmId.replace('CXP_',''));
        }
        acc.SAP_CDC_UID__c = (String)inputMain.get('UID');

        if (inputMain.get('profile') != null) {
            Map<String, Object> profile = (Map<String, Object>)inputMain.get('profile');
            acc.FirstName = (String)profile.get('firstName');
            acc.LastName = (String)profile.get('lastName');
            acc.PersonEmail = (String)profile.get('email');
            acc.Gender__pc = (String)profile.get('gender');
            if (profile.get('phones') != null) {
                List<Map<String, Object>> phones = (List<Map<String, Object>>)profile.get('phones');
                for (Map<String, Object> phone : phones) {
                    if ((String)phone.get('type') == 'Marketing - Mobile') acc.PersonMobilePhone = (String)phone.get('number');
                    if ((String)phone.get('type') == 'Marketing - Main') acc.Phone = (String)phone.get('number');
                    if ((String)phone.get('type') == 'Marketing - Alternative') acc.PersonOtherPhone = (String)phone.get('number');
                }
            }
        }

        if (inputMain.get('data') != null) {
            Map<String, Object> data = (Map<String, Object>)inputMain.get('data');
            if (data.get('addresses') != null && ((Map<String, Object>)data.get('addresses')).get('postal') != null) {
                Map<String, Object> postal = (Map<String, Object>)((Map<String, Object>)data.get('addresses')).get('postal');
                acc.BillingPostalCode = (String)postal.get('postcode');
                acc.BillingCity = (String)postal.get('city');
                acc.BillingStreet = (String)postal.get('street1') + (postal.get('street2') != null?', ' + (String)postal.get('street2'):'');
                acc.BillingCountry = (String)postal.get('country');
            } 
            if (data.get('registrationCountry') != null) acc.Country_ISO_Code__c = acc.Country_iso_code__pc = convertCountryAlphas3To2((String)data.get('registrationCountry'));
        }

        if (acc.Id != null) update acc;
        else {
            List<Account> accList = new List<Account>{acc};
            List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(accList);
            system.debug('##results: '+results);

            List<Id> matchedAccountIds = new List<Id>();
            for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    system.debug('##dupeResult.getMatchResults(): '+dupeResult.getMatchResults());
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        system.debug('##matchResult.getMatchRecords(): '+matchResult.getMatchRecords());
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            matchedAccountIds.add(((Account)matchRecord.getRecord()).Id);
                        }
                    }
                } 
            }

            if (matchedAccountIds.isEmpty()) {
                PrimaryAccountUpserter.SetPrimaryOwners(accList);
                insert accList;
            } else if (matchedAccountIds.size() > 1) {
                Id currentSelectedId;
                Set<Id> accountsWithSameNumberOfVehicles = new Set<Id>();
                Integer currentNumberOfAssets;
                //CHECK NUMBER OF VEHICLES ASSOCIATED AND SELECT THE ACCOUNTS WITH MORE VEHICLES
                for (AggregateResult ar : [Select Primary_Account__c, count(Id) numberOfAssets From Role__c where Primary_Account__c in :matchedAccountIds Group By Primary_Account__c]) {
                    if (currentSelectedId == null || currentNumberOfAssets < (Integer)ar.get('numberOfAssets')) {
                        currentSelectedId = (Id)ar.get('Primary_Account__c');
                        currentNumberOfAssets = (Integer)ar.get('numberOfAssets');
                        accountsWithSameNumberOfVehicles.clear();
                    }
                    if (currentNumberOfAssets == (Integer)ar.get('numberOfAssets')) accountsWithSameNumberOfVehicles.add((Id)ar.get('Primary_Account__c'));
                }            
                if (currentSelectedId == null || accountsWithSameNumberOfVehicles.size()>0) { //NO VEHICLES ASSOCIATED OR MORE THAN 1 ACCOUNT WITH SAME NUMBER OF VEHICLES
                    currentSelectedId = Database.query('Select Id From Account Where Id in :'+ (accountsWithSameNumberOfVehicles.isEmpty()?'matchedAccountIds':'accountsWithSameNumberOfVehicles') + ' Order By LastModifiedDate DESC')[0].Id;
                }  
                accList[0].Id = currentSelectedId;                
            } else {
                accList[0].Id = matchedAccountIds[0];
            }
            update accList;

            acc = accList[0];
        }

        acc = [Select Id, PersonIndividualId From Account Where Id = :acc.Id];

        if (inputMain.get('subscriptions') != null) {
            Map<String, ContactPointTypeConsent> existingConsentsMap = new Map<String, ContactPointTypeConsent>();
            for (ContactPointTypeConsent cptc : [Select Id, DataUsePurpose.CXP_Name__c, DataUsePurpose.LegalBasis.Name, CaptureDate, LastModifiedBy.Name, PrivacyConsentStatus, Channel__c from ContactPointTypeConsent Where PartyId = :acc.PersonIndividualId And PrivacyConsentStatus in ('OptIn','OptOut')]) {
                String key = cptc.DataUsePurpose.LegalBasis.Name+cptc.Channel__c+cptc.DataUsePurpose.CXP_Name__c;
                existingConsentsMap.put(key.toUpperCase(), cptc);
            }

            List<ContactPointTypeConsent> consentUpsertList = new List<ContactPointTypeConsent>();

            Map<String, Id> purposeIdMap = new Map<String, Id>();
            
            for (DataUsePurpose purpose : [SELECT Id, Name, LegalBasis.Name FROM DataUsePurpose]) {
                purposeIdMap.put(purpose.LegalBasis.Name+purpose.CXP_Name__c, purpose.Id);
            }

            Map<String, Consent_Mapping__mdt> consentSettings = Consent_Mapping__mdt.getAll();
            Map<String, String> legalBasisMap = new Map<String, String>();
            Map<String, String> purposeMap = new Map<String, String>();
            Map<String, String> channelMap = new Map<String, String>();

            for (Consent_Mapping__mdt setting : consentSettings.values()) {
                if (setting.DeveloperName.startsWith('LegalBasis')) legalBasisMap.put(setting.API_Name__c, setting.CXP_Name__c);
                else if (setting.DeveloperName.startsWith('Purpose')) purposeMap.put(setting.API_Name__c, setting.CXP_Name__c);
                else if (setting.DeveloperName.startsWith('Channel')) channelMap.put(setting.API_Name__c, setting.CXP_Name__c);
            }

            Map<String, Object> subscriptions = (Map<String, Object>)inputMain.get('subscriptions');
            for (String legalBasisKey : legalBasisMap.keySet()) {
                if (subscriptions.get(legalBasisKey) != null) {
                    Map<String, Object> legalBasis = (Map<String, Object>)subscriptions.get(legalBasisKey);
                    for (String channelKey : channelMap.keySet()) {
                        if (legalBasis.get(channelKey) != null) {
                            Map<String, Object> channel = (Map<String, Object>)legalBasis.get(channelKey);
                            for (String purposeKey : purposeMap.keySet()) {
                                if (channel.get(purposeKey) != null && (Map<String, Object>)((Map<String, Object>)channel.get(purposeKey)).get('email') != null) {
                                    Map<String, Object> purpose = (Map<String, Object>)((Map<String, Object>)channel.get(purposeKey)).get('email');
                                    String legalBasisCXPName = legalBasisMap.get(legalBasisKey);
                                    String purposeCXPName = purposeMap.get(purposeKey);
                                    
                                    if (!purposeIdMap.containsKey(legalBasisCXPName+purposeCXPName) || purpose.get('isSubscribed') == null || purpose.get('lastUpdatedSubscriptionState') == null) continue;

                                    String channelCXPName = channelMap.get(channelKey);

                                    String key = legalBasisCXPName+channelCXPName+purposeCXPName;
                                    ContactPointTypeConsent existingConsent = existingConsentsMap.get(key.toUpperCase());
                                    system.debug('##mapping: '+key.toUpperCase());
                                    system.debug('##consent: '+existingConsent);
                                    DateTime serviceCaptureDate = DateTime.valueOf(((String)purpose.get('lastUpdatedSubscriptionState')).replace('T',' '));
                                    system.debug('##serviceCaptureDate: '+serviceCaptureDate);
                                    system.debug('##existing and adding to list: '+existingConsent != null && existingConsent.CaptureDate < serviceCaptureDate);
                                    if (existingConsent == null || existingConsent.CaptureDate < serviceCaptureDate) consentUpsertList.add(new ContactPointTypeConsent(Id = existingConsent?.Id, Name = legalBasisCXPName+':'+purposeCXPName+':'+channelCXPName, PartyId = acc.PersonIndividualId, DataUsePurposeId = purposeIdMap.get(legalBasisCXPName+purposeCXPName), Channel__c = channelCXPName, PrivacyConsentStatus = (Boolean)purpose.get('isSubscribed')?'OptIn':'OptOut', CaptureDate = serviceCaptureDate));
                                }
                            }
                        }
                    }
                }
            }


            if(!consentUpsertList.isEmpty()) upsert consentUpsertList;
        }
        
        return acc.Id;
    }

    private static String convertCountryAlphas3To2(String alpha3) {
        Map<String, String> alphaMap = (Map<String, String>)JSON.deserialize('{"AFG":"AF","ALA":"AX","ALB":"AL","DZA":"DZ","ASM":"AS","AND":"AD","AGO":"AO","AIA":"AI","ATA":"AQ","ATG":"AG","ARG":"AR","ARM":"AM","ABW":"AW","AUS":"AU","AUT":"AT","AZE":"AZ","BHS":"BS","BHR":"BH","BGD":"BD","BRB":"BB","BLR":"BY","BEL":"BE","BLZ":"BZ","BEN":"BJ","BMU":"BM","BTN":"BT","BOL":"BO","BIH":"BA","BWA":"BW","BVT":"BV","BRA":"BR","VGB":"VG","IOT":"IO","BRN":"BN","BGR":"BG","BFA":"BF","BDI":"BI","KHM":"KH","CMR":"CM","CAN":"CA","CPV":"CV","CYM":"KY","CAF":"CF","TCD":"TD","CHL":"CL","CHN":"CN","HKG":"HK","MAC":"MO","CXR":"CX","CCK":"CC","COL":"CO","COM":"KM","COG":"CG","COD":"CD","COK":"CK","CRI":"CR","CIV":"CI","HRV":"HR","CUB":"CU","CYP":"CY","CZE":"CZ","DNK":"DK","DKK":"DK","DJI":"DJ","DMA":"DM","DOM":"DO","ECU":"EC","Sal":"El","GNQ":"GQ","ERI":"ER","EST":"EE","ETH":"ET","FLK":"FK","FRO":"FO","FJI":"FJ","FIN":"FI","FRA":"FR","GUF":"GF","PYF":"PF","ATF":"TF","GAB":"GA","GMB":"GM","GEO":"GE","DEU":"DE","GHA":"GH","GIB":"GI","GRC":"GR","GRL":"GL","GRD":"GD","GLP":"GP","GUM":"GU","GTM":"GT","GGY":"GG","GIN":"GN","GNB":"GW","GUY":"GY","HTI":"HT","HMD":"HM","VAT":"VA","HND":"HN","HUN":"HU","ISL":"IS","IND":"IN","IDN":"ID","IRN":"IR","IRQ":"IQ","IRL":"IE","IMN":"IM","ISR":"IL","ITA":"IT","JAM":"JM","JPN":"JP","JEY":"JE","JOR":"JO","KAZ":"KZ","KEN":"KE","KIR":"KI","PRK":"KP","KOR":"KR","KWT":"KW","KGZ":"KG","LAO":"LA","LVA":"LV","LBN":"LB","LSO":"LS","LBR":"LR","LBY":"LY","LIE":"LI","LTU":"LT","LUX":"LU","MKD":"MK","MDG":"MG","MWI":"MW","MYS":"MY","MDV":"MV","MLI":"ML","MLT":"MT","MHL":"MH","MTQ":"MQ","MRT":"MR","MUS":"MU","MYT":"YT","MEX":"MX","FSM":"FM","MDA":"MD","MCO":"MC","MNG":"MN","MNE":"ME","MSR":"MS","MAR":"MA","MOZ":"MZ","MMR":"MM","NAM":"NA","NRU":"NR","NPL":"NP","NLD":"NL","ANT":"AN","NCL":"NC","NZL":"NZ","NIC":"NI","NER":"NE","NGA":"NG","NIU":"NU","NFK":"NF","MNP":"MP","NOR":"NO","OMN":"OM","PAK":"PK","PLW":"PW","PSE":"PS","PAN":"PA","PNG":"PG","PRY":"PY","PER":"PE","PHL":"PH","PCN":"PN","POL":"PL","PRT":"PT","PRI":"PR","QAT":"QA","REU":"RE","ROU":"RO","RUS":"RU","RWA":"RW","BLM":"BL","SHN":"SH","KNA":"KN","LCA":"LC","MAF":"MF","SPM":"PM","VCT":"VC","WSM":"WS","SMR":"SM","STP":"ST","SAU":"SA","SEN":"SN","SRB":"RS","SYC":"SC","SLE":"SL","SGP":"SG","SVK":"SK","SVN":"SI","SLB":"SB","SOM":"SO","ZAF":"ZA","SGS":"GS","SSD":"SS","ESP":"ES","LKA":"LK","SDN":"SD","SUR":"SR","SJM":"SJ","SWZ":"SZ","SWE":"SE","CHE":"CH","SYR":"SY","TWN":"TW","TJK":"TJ","TZA":"TZ","THA":"TH","TLS":"TL","TGO":"TG","TKL":"TK","TON":"TO","TTO":"TT","TUN":"TN","TUR":"TR","TKM":"TM","TCA":"TC","TUV":"TV","UGA":"UG","UKR":"UA","ARE":"AE","GBR":"GB","USA":"US","UMI":"UM","URY":"UY","UZB":"UZ","VUT":"VU","VEN":"VE","VNM":"VN","VIR":"VI","WLF":"WF","ESH":"EH","YEM":"YE","ZMB":"ZM","ZWE":"ZW","GBP":"GB","RUB":"RU","NOK":"NO"}', Map<String, String>.class);
        return alphaMap.get(alpha3);
    }

    public class ProfileWrapper {
        public String firstName;
        public String lastName;
        public String email;
    }
}