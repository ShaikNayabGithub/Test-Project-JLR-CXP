public without sharing class AssetInquiryController {

    private final string MSG_01 = Label.vlMSG_01;// 'Sharing not possible. In order to share this record, the current Asset\'s parent Account owner must be notified, but this is not possible as no valid Email Addresses could be found.';
    private final string MSG_02 = Label.vlMSG_02;// 'Asset {0} was not found.';
    private final string MSG_03 = Label.vlMSG_03;// 'Asset {0} and it\'\'s customer is now shared with you. The Customer record owner has been notified at: {1}';
    private final string MSG_04 = Label.vlMSG_04;// 'This Asset is not owned by a Customer and therefore Retailer permission is required for data sharing. Please contact your local NSC Delegated Administrator to request transfer of this Asset between Retailers.';
    private final string MSG_05 = Label.vlMSG_05;// 'Only assets that belong to Migrated Vehicle Accounts can be transferred at this time.';
    private final string MSG_06 = Label.vlMSG_06;// 'Retailer migration successful. Asset {0} now belongs to your Retailer (or Region).';
    private final string MSG_07 = Label.vlMSG_07;// 'Asset {0} was found.';
    private final string MSG_08 = Label.vlMSG_08;// 'A \'Migrated Vehicles\' Account that matches your Market could not be found. Please contact an Administrator';
    private List<User> userRecords;
    
    /*private class emailContent {
        private final string subject = Label.vlEmailContentSubject; //'CXP Notifiction: A record you own has been shared';
        private final string line1 = Label.vlEmailContentLine1; //'Please be advised, the following CXP Customer Record (and associated Asset(s)) have been shared (read-only) ';
        private final string line2 = Label.vlEmailContentLine2; //'with another CXP User following a record-sharing request.<br><br>';
        private final string line3 = Label.vlEmailContentLine3; //'Customer Record You Own: {0}/{1}<br/>';
        private final string line4 = Label.vlEmailContentLine4; //'Has been shared with User: {0} {1} (Email: {2})<br/>';
        private final string line5 = Label.vlEmailContentLine5; //'At Retailer: {0}<br/>';
        private final string line6 = Label.vlEmailContentLine6; //'Retailer Market: {0}<br/>';
    }*/
      
    public class MyException extends Exception {}

    private Map<String,String> countryCodeMap() {
        Map<String,String> mcc = new Map<String,String>();
        mcc.put('AF','Afghanistan'); mcc.put('AX','Aland Islands'); mcc.put('AL','Albania'); mcc.put('DZ','Algeria'); mcc.put('AS','American Samoa'); mcc.put('AD','Andorra'); mcc.put('AO','Angola'); 
        mcc.put('AI','Anguilla'); mcc.put('AQ','Antarctica'); mcc.put('AG','Antigua and Barbuda'); mcc.put('AR','Argentina'); mcc.put('AM','Armenia'); mcc.put('AW','Aruba'); mcc.put('AU','Australia'); 
        mcc.put('AT','Austria'); mcc.put('AZ','Azerbaijan'); mcc.put('BS','Bahamas'); mcc.put('BH','Bahrain'); mcc.put('BD','Bangladesh'); mcc.put('BB','Barbados'); mcc.put('BY','Belarus'); 
        mcc.put('BE','Belgium'); mcc.put('BZ','Belize'); mcc.put('BJ','Benin'); mcc.put('BM','Bermuda'); mcc.put('BT','Bhutan'); mcc.put('BO','Bolivia'); mcc.put('BA','Bosnia and Herzegovina'); 
        mcc.put('BW','Botswana'); mcc.put('BV','Bouvet Island'); mcc.put('BR','Brazil'); mcc.put('VG','British Virgin Islands'); mcc.put('IO','British Indian Ocean Territory'); 
        mcc.put('BN','Brunei Darussalam'); mcc.put('BG','Bulgaria'); mcc.put('BF','Burkina Faso'); mcc.put('BI','Burundi'); mcc.put('KH','Cambodia'); mcc.put('CM','Cameroon'); mcc.put('CA','Canada'); mcc.put('CV','Cape Verde'); 
        mcc.put('KY','Cayman Islands'); mcc.put('CF','Central African Republic'); mcc.put('TD','Chad'); mcc.put('CL','Chile'); mcc.put('CN','China'); mcc.put('HK','Hong Kong , SAR China'); mcc.put('MO','Macao , SAR China'); 
        mcc.put('CX','Christmas Island'); mcc.put('CC','Cocos (Keeling) Islands'); mcc.put('CO','Colombia'); mcc.put('KM','Comoros'); mcc.put('CG','Congo (Brazzaville)'); mcc.put('CD','Congo , (Kinshasa)'); 
        mcc.put('CK','Cook Islands'); mcc.put('CR','Costa Rica'); mcc.put('CI','Côte d\'Ivoire'); mcc.put('HR','Croatia'); mcc.put('CU','Cuba'); mcc.put('CY','Cyprus'); mcc.put('CZ','Czech Republic'); 
        mcc.put('DK','Denmark'); mcc.put('DJ','Djibouti'); mcc.put('DM','Dominica'); mcc.put('DO','Dominican Republic'); mcc.put('EC','Ecuador'); mcc.put('EG','Egypt'); mcc.put('SV','El Salvador'); 
        mcc.put('GQ','Equatorial Guinea'); mcc.put('ER','Eritrea'); mcc.put('EE','Estonia'); mcc.put('ET','Ethiopia'); mcc.put('FK','Falkland Islands (Malvinas)'); mcc.put('FO','Faroe Islands'); 
        mcc.put('FJ','Fiji'); mcc.put('FI','Finland'); mcc.put('FR','France'); mcc.put('GF','French Guiana'); mcc.put('PF','French Polynesia'); mcc.put('TF','French Southern Territories'); 
        mcc.put('GA','Gabon'); mcc.put('GM','Gambia'); mcc.put('GE','Georgia'); mcc.put('DE','Germany'); mcc.put('GH','Ghana'); mcc.put('GI','Gibraltar'); mcc.put('GR','Greece'); mcc.put('GL','Greenland'); 
        mcc.put('GD','Grenada'); mcc.put('GP','Guadeloupe'); mcc.put('GU','Guam'); mcc.put('GT','Guatemala'); mcc.put('GG','Guernsey'); mcc.put('GN','Guinea'); mcc.put('GW','Guinea-Bissau'); 
        mcc.put('GY','Guyana'); mcc.put('HT','Haiti'); mcc.put('HM','Heard and Mcdonald Islands'); mcc.put('VA','Holy See (Vatican City State)'); mcc.put('HN','Honduras'); mcc.put('HU','Hungary'); 
        mcc.put('IS','Iceland'); mcc.put('IN','India'); mcc.put('ID','Indonesia'); mcc.put('IR','Iran, Islamic Republic of'); mcc.put('IQ','Iraq'); mcc.put('IE','Ireland'); mcc.put('IM','Isle of Man'); 
        mcc.put('IL','Israel'); mcc.put('IT','Italy'); mcc.put('JM','Jamaica'); mcc.put('JP','Japan'); mcc.put('JE','Jersey'); mcc.put('JO','Jordan'); mcc.put('KZ','Kazakhstan'); mcc.put('KE','Kenya'); 
        mcc.put('KI','Kiribati'); mcc.put('KP','Korea (North)'); mcc.put('KR','Korea (South)'); mcc.put('KW','Kuwait'); mcc.put('KG','Kyrgyzstan'); mcc.put('LA','Lao PDR'); mcc.put('LV','Latvia'); 
        mcc.put('LB','Lebanon'); mcc.put('LS','Lesotho'); mcc.put('LR','Liberia'); mcc.put('LY','Libya'); mcc.put('LI','Liechtenstein'); mcc.put('LT','Lithuania'); mcc.put('LU','Luxembourg'); 
        mcc.put('MK','Macedonia, Republic of'); mcc.put('MG','Madagascar'); mcc.put('MW','Malawi'); mcc.put('MY','Malaysia'); mcc.put('MV','Maldives'); mcc.put('ML','Mali'); mcc.put('MT','Malta'); 
        mcc.put('MH','Marshall Islands'); mcc.put('MQ','Martinique'); mcc.put('MR','Mauritania'); mcc.put('MU','Mauritius'); mcc.put('YT','Mayotte'); mcc.put('MX','Mexico'); mcc.put('FM','Micronesia, Federated States of'); 
        mcc.put('MD','Moldova'); mcc.put('MC','Monaco'); mcc.put('MN','Mongolia'); mcc.put('ME','Montenegro'); mcc.put('MS','Montserrat'); mcc.put('MA','Morocco'); 
        mcc.put('MZ','Mozambique'); mcc.put('MM','Myanmar'); mcc.put('NA','Namibia'); mcc.put('NR','Nauru'); mcc.put('NP','Nepal'); mcc.put('NL','Netherlands'); mcc.put('AN','Netherlands Antilles'); 
        mcc.put('NC','New Caledonia'); mcc.put('NZ','New Zealand'); mcc.put('NI','Nicaragua'); mcc.put('NE','Niger'); mcc.put('NG','Nigeria'); mcc.put('NU','Niue'); mcc.put('NF','Norfolk Island'); 
        mcc.put('MP','Northern Mariana Islands'); mcc.put('NO','Norway'); mcc.put('OM','Oman'); mcc.put('PK','Pakistan'); mcc.put('PW','Palau'); mcc.put('PS','Palestinian Territory'); mcc.put('PA','Panama');
         mcc.put('PG','Papua New Guinea'); mcc.put('PY','Paraguay'); mcc.put('PE','Peru'); mcc.put('PH','Philippines'); mcc.put('PN','Pitcairn'); mcc.put('PL','Poland'); mcc.put('PT','Portugal'); 
         mcc.put('PR','Puerto Rico'); mcc.put('QA','Qatar'); mcc.put('RE','Réunion'); mcc.put('RO','Romania'); mcc.put('RU','Russian Federation'); mcc.put('RW','Rwanda'); mcc.put('BL','Saint-Barthélemy'); 
         mcc.put('SH','Saint Helena'); mcc.put('KN','Saint Kitts and Nevis'); mcc.put('LC','Saint Lucia'); mcc.put('MF','Saint-Martin (French part)'); mcc.put('PM','Saint Pierre and Miquelon'); 
         mcc.put('VC','Saint Vincent and Grenadines'); mcc.put('WS','Samoa'); mcc.put('SM','San Marino'); mcc.put('ST','Sao Tome and Principe'); mcc.put('SA','Saudi Arabia'); mcc.put('SN','Senegal'); 
         mcc.put('RS','Serbia'); mcc.put('SC','Seychelles'); mcc.put('SL','Sierra Leone'); mcc.put('SG','Singapore'); mcc.put('SK','Slovakia'); mcc.put('SI','Slovenia'); mcc.put('SB','Solomon Islands');
          mcc.put('SO','Somalia'); mcc.put('ZA','South Africa'); mcc.put('GS','South Georgia and the South Sandwich Islands'); mcc.put('SS','South Sudan'); mcc.put('ES','Spain'); mcc.put('LK','Sri Lanka'); 
          mcc.put('SD','Sudan'); mcc.put('SR','Suriname'); mcc.put('SJ','Svalbard and Jan Mayen Islands'); mcc.put('SZ','Swaziland'); mcc.put('SE','Sweden'); mcc.put('CH','Switzerland'); 
          mcc.put('SY','Syrian Arab Republic (Syria)'); mcc.put('TW','Taiwan , Republic of China'); mcc.put('TJ','Tajikistan'); mcc.put('TZ','Tanzania , United Republic of'); mcc.put('TH','Thailand'); mcc.put('TL','Timor-Leste');
           mcc.put('TG','Togo'); mcc.put('TK','Tokelau'); mcc.put('TO','Tonga'); mcc.put('TT','Trinidad and Tobago'); mcc.put('TN','Tunisia'); mcc.put('TR','Turkey'); mcc.put('TM','Turkmenistan'); 
           mcc.put('TC','Turks and Caicos Islands'); mcc.put('TV','Tuvalu'); mcc.put('UG','Uganda'); mcc.put('UA','Ukraine'); mcc.put('AE','United Arab Emirates'); mcc.put('GB','United Kingdom'); 
           mcc.put('US','United States of America'); mcc.put('UM','US Minor Outlying Islands'); mcc.put('UY','Uruguay'); mcc.put('UZ','Uzbekistan'); mcc.put('VU','Vanuatu'); mcc.put('VE','Venezuela (Bolivarian Republic)'); 
           mcc.put('VN','Viet Nam'); mcc.put('VI','Virgin Islands, US'); mcc.put('WF','Wallis and Futuna Islands'); mcc.put('EH','Western Sahara'); mcc.put('YE','Yemen'); 
           mcc.put('ZM','Zambia'); mcc.put('ZW','Zimbabwe');
        return mcc;
    }

    public AssetInquiryController() {
       lblTitle=Label.vlTitle;//'Vehicle/Asset Lookup';
       lblEnterVIN=Label.vlEnterVIN;//'Enter Asset Identification'; 
       lblStatus=Label.vlStatus;//'Status';  
       lblSearch=Label.vlSearch;//'Search';   
       lblTakeOwnership = Label.vlTakeOwnership;//'Take Ownership';
       lblRequestSharing = Label.vlRequestSharing;//'Request Visibility of Details';
       userRecords = [select country_iso_code__c, contact.account.id,contact.account.recordtype.developername from user where id = : UserInfo.getUserId()];
    }

    public boolean showTObtn {get;set;}
    public boolean showRSbtn {get;set;}

    public string searchVin {get;set;} 
    public string previousVINsearch {get;set;} 

    public string statusMsg {get;set;} 
    public List<Asset> assets {get;set;} 
    //labels
    public string lblTitle {get;set;}
    public string lblEnterVIN {get;set;}
    public string lblStatus {get;set;} 
    public string lblSearch {get;set;}
    public string lblTakeOwnership {get;set;}
    public string lblRequestSharing {get;set;}
    
    public string contactEmails {get;set;} 
    
    public List<String> getEmailsFromCustomer(Id customerId) { 
        
        List<Account> accounts = [select Owner.Email from Account where Id = : customerId]; 
        
        if (!accounts.isEmpty()) { 
            
            return new List<String>{accounts[0].Owner.Email};
        } else { 
        
            return new List<String>(); 
        }
    
    }
        
    public List<String> getEmailsFromRetailer(Id retailerId) {
        
        String emails = '';
        List<String> sEmails = new List<String>();
        
        List<User> users = [select Email from User where 
                                Profile.name = 'Dealer Principle' and 
                                Usertype = 'PowerPartner' and 
                                Contactid in (select id from contact where accountid = : retailerId)];
        for (User u : users) {
            if (EmailUtility.validateEmail(u.email)) sEmails.add(u.email);
        } 
        
        return sEmails;
    
    }
    
    public PageReference requestSharing() {
        showTObtn=false;
        showRSbtn=false;
        statusMsg='';
        assets = null;
        if (previousVINsearch!=null) searchVIN=previousVINsearch; 
        
        if (String.isEmpty(searchVIN)){
            return null; 
        }
        
        List<Asset> transferOwnerAssets = [select name, account.id, account.name,account.Trading_Partner_Type__c,account.Retailer_Type__c, account.Country_ISO_Code__c,
                                            account.recordtype.developername from asset 
                                            where vin__c = : searchVIN or name = : searchVIN or 
                                            registration_number__c = :searchVIN];
                                            
        List<User> newSharedUserDetails = [select firstname, lastname, email, contact.account.name, contact.account.country_iso_code__c from User where Id = : UserInfo.getUserId()];
        
        if (transferOwnerAssets.isEmpty()) {
          
            statusMsg = String.Format(MSG_02,new List<String>{searchVIN}); 
            return null;
        }
                
        if (transferOwnerAssets[0].account.recordtype.developername != 'Retailer') {
            
            List<String> accountOwnerEmails = getEmailsFromCustomer(transferOwnerAssets[0].account.id); 
            
            AccountShare aShare = new AccountShare(
                UserOrGroupId = UserInfo.getUserId(),
                AccountId = transferOwnerAssets[0].account.id,
                AccountAccessLevel='Read',
                OpportunityAccessLevel='None',
                //ContactAccessLevel='None',
                CaseAccessLevel='None'
            );
            try {
          
                if (accountOwnerEmails.isEmpty()) throw new MyException(MSG_01);
                insert aShare;
                /*emailContent ec = new emailContent();
                String emailSubject = ec.subject;
                String emailMsg = ec.line1;
                emailMsg += ec.line2;
                emailMsg += String.Format(ec.line3,new List<String>{URL.getSalesforceBaseUrl().toExternalForm(),transferOwnerAssets[0].account.id});
                emailMsg += String.Format(ec.line4,new List<String>{newSharedUserDetails[0].FirstName,newSharedUserDetails[0].LastName,newSharedUserDetails[0].Email});
                if (String.isNotBlank(newSharedUserDetails[0].contact.account.name)) 
                    emailMsg += String.Format(ec.line5,new List<String>{newSharedUserDetails[0].contact.account.name});
                if (String.isNotBlank(newSharedUserDetails[0].contact.account.country_iso_code__c)) 
                    emailMsg += String.Format(ec.line6,new List<String>{newSharedUserDetails[0].contact.account.country_iso_code__c});

                EmailUtility.SendEmail(accountOwnerEmails,'JLR CXP Notifications', emailSubject, emailMsg);*/
                                       
            } catch (DMLException e) {
               
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,e.getMessage()));
                return null;
            } catch (MyException ex) {
            
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,ex.getMessage()));
                return null;
            } 
            
          
            statusMsg = String.Format(MSG_03,new List<String>{searchVIN,String.join(accountOwnerEmails,';')});
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,statusMsg));
            statusMsg = String.Format(MSG_07,new List<String>{searchVIN});
            
        } else
        {  
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,MSG_04));
            
        }
        
        buildAssetTable(null,transferOwnerAssets[0].id);
    
        return null;
    }    
    
    public PageReference takeOwnership() {
        showTObtn=false;
        showRSbtn=false;
        statusMsg='';
        assets = null;
        if (previousVINsearch!=null) searchVIN=previousVINsearch; 
        
        if (String.isEmpty(searchVIN)) return null;
        
        List<Asset> transferOwnerAssets = [select name, account.name,account.retailer_type__c,account.trading_partner_type__c,account.Country_ISO_Code__c,accountid from asset where vin__c = : searchVIN or name = : searchVIN or registration_number__c = :searchVIN];
        if (transferOwnerAssets.isEmpty()) {
            statusMsg = String.Format(MSG_02,new List<String>{searchVIN}); 
            return null;
        }
        
        
        if (userRecords.isEmpty()) return null;
        
         if (transferOwnerAssets[0].account.name!= null && (!transferOwnerAssets[0].account.name.contains('Migrated Vehicles')
             && transferOwnerAssets[0].account.Retailer_Type__c!='Importer' 
             && (transferOwnerAssets[0].account.Trading_Partner_Type__c=='NDVO' && transferOwnerAssets[0].account.Retailer_Type__c=='Fleet Customer' && userRecords[0].country_iso_code__c!=transferOwnerAssets[0].account.Country_ISO_Code__c)
             )) {
             
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,MSG_05));
                return null;
             
             }

        Map<String,String> mapCountryCodetoCountry = countryCodeMap();
        Id newAssetAccountId;  

        if (userRecords[0].contact.account.id != null && userRecords[0].contact.account.recordtype.developername == 'Retailer') {

            newAssetAccountId = userRecords[0].contact.account.id;

        } else { //No linked Account or not a Retailer linked account

            if (userRecords[0].country_iso_code__c!=null && mapCountryCodetoCountry.containsKey(userRecords[0].country_iso_code__c)) { 

                String accountName = mapCountryCodetoCountry.get(userRecords[0].country_iso_code__c) + ' Migrated Vehicles';
                List<Account> accounts = [select id from Account where name = : accountName ];
                if (!accounts.isEmpty()) newAssetAccountId = accounts[0].id;
 
            }  

        }  

        if (newAssetAccountId!=null) {
            transferOwnerAssets[0].accountid = newAssetAccountId;
            try {
            
            
                update transferOwnerAssets;
                statusMsg = String.Format(MSG_06,new List<String>{searchVIN}); 
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,statusMsg));
                statusMsg = String.Format(MSG_07,new List<String>{searchVIN});
            } catch (DMLException e) {
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,e.getMessage()));
                return null;
            }    
        } else {
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR,MSG_08)); 
        }
        
        buildAssetTable(null,transferOwnerAssets[0].id);
        return null;
    }
    
    public void buildAssetTable(String searchParm, Id assetId) {
        if (String.isNotBlank(searchParm)) {
            assets = [select name, brand__r.name, model__r.name, registration_number__c, Account.PersonMailingCity, Account.BillingCity, 
                    account.name, account.id, account.recordtype.name, account.recordtype.developername, account.country_iso_code__c, 
                    account.Preferred_Sales_Retailer__r.name, account.Preferred_Sales_Retailer__r.id,Account.Trading_Partner_Type__c,
                    account.Preferred_Sales_Retailer__r.recordtype.name, account.Preferred_Sales_Retailer__r.country_iso_code__c,account.Retailer_Type__c, 
                    userrecordaccess.hasreadaccess from asset where vin__c = : searchParm or name = : searchParm or registration_number__c = :searchParm];
        } else {
            assets = [select name, brand__r.name, model__r.name, registration_number__c, Account.PersonMailingCity, Account.BillingCity, 
                        account.name, account.id, account.recordtype.name, account.recordtype.developername, account.country_iso_code__c, 
                        account.Preferred_Sales_Retailer__r.name, account.Preferred_Sales_Retailer__r.id, Account.Trading_Partner_Type__c,
                        account.Preferred_Sales_Retailer__r.recordtype.name, account.Preferred_Sales_Retailer__r.country_iso_code__c,account.Retailer_Type__c,
                        userrecordaccess.hasreadaccess from asset where 
                        id = : assetId]; 
        }
    }
    
    public PageReference searchVIN() {
    
        showTObtn=false;
        showRSbtn=false;
        statusMsg='';
        previousVINsearch=searchVIN;

        if (String.isEmpty(searchVIN)) return null;
    
        searchVIN = searchVIN.toUpperCase();      
    
        buildAssetTable(searchVIN,null);
        
        statusMsg = String.Format( (assets.isEmpty()?MSG_02:MSG_07) , new List<String>{searchVIN});
        
        if (!assets.isEmpty()) {
            if (assets[0].account.recordtype.developername == 'Retailer') {
                contactEmails = String.join(getEmailsFromRetailer(assets[0].account.id),';');
            } else {
                contactEmails = String.join(getEmailsFromCustomer(assets[0].account.id),';');
                //contactEmails = getEmailsFromRetailer(assets[0].account.Preferred_Sales_Retailer__r.id) + getEmailFromCustomer(assets[0].account.id);
            } 
            
            if (assets[0].account.name!= null && (assets[0].account.name.contains('Migrated Vehicles')
             || assets[0].account.Retailer_Type__c=='Importer' 
             || (assets[0].account.Trading_Partner_Type__c=='NDVO' && assets[0].account.Retailer_Type__c=='Fleet Customer'
             && userRecords[0].country_iso_code__c==assets[0].account.Country_ISO_Code__c
            
             )
             )) {
                showTObtn=true;
                showRSbtn=false; 
            } else {
                showTObtn=false;
                showRSbtn=true;
            }
           
           
              
        }  
            
        return null;
    }

}