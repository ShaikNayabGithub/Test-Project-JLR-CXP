global class Batch_ServiceDataImporter implements Schedulable, Database.Batchable<sObject>, database.Stateful 
{
    
    global void execute(SchedulableContext SC) {
        Batch_ServiceDataImporter batch= new Batch_ServiceDataImporter(Label.IMS_BATCH_MENA_MARKET,false);
        //Database.executeBatch(batch, 50);
        database.executeBatch(batch, 30);
    }  
    
    List<string> SDIFieldsLst= new List<String>();
    List<string> SDFieldsLst= new List<String>();
    List<string> IsoCountryCodeLst= New List<string>();
    List<string> InvalidEmailAddLst= New List<string>();
    Boolean IsRerun;
    String IsoCountryCode = '';
    string Query='';
    Map<string, SDI_Field_Mapping__c> sdFieldMappingSettingMap = SDI_Field_Mapping__c.getAll();
    Map<string,String> countryDialCodeMap= New Map<string,String>();
    Id RetailerConRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();
    Id corporateAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    Id IndividualAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    Map<string,User> secAccountOwnerMap= New Map<String,User>();
    string ownerQstring='select id, market__c, AccountId, Account.Brand__c, Account.country_ISO_Code__c from user where name like \'dummyimp%\' AND Account.Brand__c !=\'Branded\' AND isactive=true';
    
    
    global Batch_ServiceDataImporter(string countryCode, boolean isRerun) 
    {  
        IsoCountryCode = countryCode;
        this.IsRerun=isRerun;
        if(string.isNotEmpty(countryCode) && string.isNotBlank(countryCode))
            IsoCountryCodeLst=countryCode.split(';');
        
        Query = 'select Id from Service_Data_Import__c where Status__c=\'Unprocessed\' ';
        Query += 'and CountryISO_Code__c IN:IsoCountryCodeLst order by Unique_Key__c ';
        
        initBatch();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Data_Import__c> SDILst) 
    {
        ConsentHandler.allCommunicationConsent = true;
        
        //First SOQL
        list<Service_Data_Import__c> SDIRecLst=database.query('select '+string.join(SDIFieldsLst, ', ')+' from Service_Data_Import__c where ID IN:SDILst');
        map<string,list<Service_Data_Import__c>> sdiUniqueKeyMap= new map<string,list<Service_Data_Import__c>>();
        Map<string,Service_Data__c> existingSDMap= new Map<string,Service_Data__c>();
        Map<string,Asset> vinAssetMap= new Map<string,Asset>();
        Map<string,Service_Data_Import__c> SDIRecForMatchingMap = New Map<string,Service_Data_Import__c>();
        Map<string,Service_Data__c> SDRecForInsertMap = New Map<string,Service_Data__c>();
        Map<string,list<Contact>> accountContactMap= new Map<string,list<Contact>>();
        Map<Id,Account> accountLstForUpdate = New Map<Id,Account>();
        Map<Id,Contact> contactLstForUpdate= New Map<Id,Contact>();
        Service_Data__c serviceDataObject;
        List<Contact> contactLstForinsert= New List<Contact>();
        List<Account> accountLstForinsert= New List<Account>();
        
        set<string> companyNameSet = new set<string>();
        set<string> emailIdSet= new set<string>();
        set<string> phoneNoSet = new set<string>();
        set<string> firstNameSet= new set<string>();
        set<string> lastnameSet= new set<string>();
        
        set<string> companyName_ORSet = new set<string>();
        set<string> emailId_ORSet= new set<string>();
        set<string> phoneNo_ORSet = new set<string>();
        set<string> firstName_ORSet= new set<string>();
        set<string> lastname_ORSet= new set<string>();
        
        Map<string,integer> uniqueKeyContactInsertMap= new Map<string,integer>();
        Map<string,integer> uniqueKeyAccountInsertMap= new Map<string,integer>();
        Map<string,integer> uniqueKeyContactUpdateMap= new Map<string,integer>();
        Map<string,integer> uniqueKeyAccountUpdateMap= new Map<string,integer>();
        integer contactInsertCount=0;
        integer accountInsertCount=0;
        integer contactUpdateCount=0;
        integer accountUpdateCount=0;
        
        Map<string,Id> dealerCodeParentIdMap = New Map<string,Id>();
        Set<string> dealerCodeSet = New Set<string>();
        Map<Id,List<Account>> dealerCodeAccountMap= New Map<Id,List<Account>>();
        Set<String> serviceDataImportDMSId= New Set<string>();
        Map<string,Id> existingSDISDIdMap= New Map<string,Id>();
        for(Service_Data_Import__c SDISingleRec:SDIRecLst)
        {
            SDISingleRec.Status__c='Success';
            if(!InvalidEmailAddLst.isEmpty() && SDISingleRec.Email__c !=null)
            {
                if(InvalidEmailAddLst.contains(SDISingleRec.Email__c))
                {
                    SDISingleRec.Email__c=null;  
                }else
                {
                    for(string InvEmail: InvalidEmailAddLst)
                    {
                        if(SDISingleRec.Email__c.contains(InvEmail))
                        {
                            SDISingleRec.Email__c=null;
                            break;
                        }
                    }
                }
            }
            if(!sdiUniqueKeyMap.containsKey(SDISingleRec.Unique_Key__c))
                sdiUniqueKeyMap.put(SDISingleRec.Unique_Key__c, new list<Service_Data_Import__c>());
            sdiUniqueKeyMap.get(SDISingleRec.Unique_Key__c).add(SDISingleRec);
            
            vinAssetMap.put(SDISingleRec.VIN__c,null);
            serviceDataImportDMSId.add(SDISingleRec.DMS_Invoice_Ref_ID__c);
            if(!SDIRecForMatchingMap.containsKey(SDISingleRec.Unique_Key__c))
                SDIRecForMatchingMap.put(SDISingleRec.Unique_Key__c,SDISingleRec);
        }
        
        //Second SOQL
        list<Service_Data__c> existingSDLst=[select id, Asset__r.Name, Unique_Key__c from Service_Data__c where Unique_Key__c IN:sdiUniqueKeyMap.keyset()];
        For(Service_Data_Item__c SDI :[select Id, ServiceData__c, ServiceData__r.Unique_Key__c, DM_Invoice_Reference_ID__c from Service_Data_Item__c where DM_Invoice_Reference_ID__c IN:serviceDataImportDMSId AND ServiceData__r.Unique_Key__c IN :sdiUniqueKeyMap.keyset()])
        {
          existingSDISDIdMap.put(SDI.DM_Invoice_Reference_ID__c, SDI.ServiceData__c);  
        }
        
        system.debug('existingSDISDIdMap '+existingSDISDIdMap);
        
        if(!existingSDLst.isEmpty())
        {
            for(Service_Data__c SDSingleRec:existingSDLst)
            {
                existingSDMap.put(SDSingleRec.Unique_Key__c,SDSingleRec);
                if(vinAssetMap.containsKey(SDSingleRec.Asset__r.Name))
                    vinAssetMap.remove(SDSingleRec.Asset__r.Name);
                SDIRecForMatchingMap.remove(SDSingleRec.Unique_Key__c);
            }
        }
        
        //Third SOQL
        for(Asset assetRec:[select id, Name, Account.Name,
                            Account.FirstName,
                            AccountId,
                            Account.personcontactId,
                            Account.isPersonAccount,
                            Account.LastName, Account.PersonEmail, 
                            Account.Email2__pc, Account.Email3__pc,
                            Account.Retailer_Email__c,
                            Account.Phone,
                            Account.PersonMobilePhone,
                            Account.PersonOtherPhone,
                            Account.PersonHomePhone,
                            Account.Historical_Contact_Details__c
                            //(select id, Name, LastName, Email, Email2__c, Email3__c, HomePhone, MobilePhone, OtherPhone, Phone from Account.contacts)
                            from asset where Name IN: vinAssetMap.keyset()])
        {
            vinAssetMap.put(assetRec.Name,assetRec);
            accountContactMap.put(assetRec.AccountId, new list<contact>());
        }
        //Forth SOQL
        for(contact con:[select id, AccountId, FirstName, Name, Historical_Contact__c, LastName, Email, Email2__c, Email3__c, HomePhone, MobilePhone, OtherPhone, Phone from contact where accountId=:accountContactMap.keySet()])
        {
            accountContactMap.get(con.AccountId).add(con);
        }
        Asset vehicleAsset;
        contact contactForUpsert;
        Account accountForUpsert;
        string historicalString='';
        if(!SDIRecForMatchingMap.isEmpty())
        {
            for(Service_Data_Import__c objServiceDataImport:SDIRecForMatchingMap.values())
            {
                serviceDataObject = new Service_Data__c();
                if(vinAssetMap.containsKey(objServiceDataImport.VIN__c) && vinAssetMap.get(objServiceDataImport.VIN__c)!=null)
                {
                    historicalString='';
                    vehicleAsset=vinAssetMap.get(objServiceDataImport.VIN__c);
                    serviceDataObject.Asset__c=vehicleAsset.Id; 
                    if(objServiceDataImport.Mobile_Number__c!=null)
                    	objServiceDataImport.Mobile_Number__c=objServiceDataImport.Mobile_Number__c.replaceAll('\\D','');
                    if(objServiceDataImport.Business_Phone__c!=null)
                    	objServiceDataImport.Business_Phone__c=objServiceDataImport.Business_Phone__c.replaceAll('\\D','');
                    if(objServiceDataImport.Home_Phone__c!=null)
                    	objServiceDataImport.Home_Phone__c=objServiceDataImport.Home_Phone__c.replaceAll('\\D','');
                    for(string sdiField:SDIFieldsLst)
                    {
                        if(sdFieldMappingSettingMap.containsKey(sdiField))
                        {
                            serviceDataObject.put(sdFieldMappingSettingMap.get(sdiField).Service_Data_Field__c, objServiceDataImport.get(sdiField));
                        }else if(SDFieldsLst.contains(sdiField))
                        {
                            serviceDataObject.put(sdiField, objServiceDataImport.get(sdiField)); 
                        }
                    }  
                    if(serviceDataObject.Units_Mileage_Out__c=='km' || serviceDataObject.Units_Mileage_Out__c=='kms')
                        serviceDataObject.Units_Mileage_Out__c='Kilometers';
                    serviceDataObject.CurrencyIsoCode='GBP';
                    //Matching logic 1
                    string countryDialCode='';
                    
                    if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                    {
                        countryDialCode=countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c);
                    }
                    if(vehicleAsset!=null)
                    {
                        if(vehicleAsset.Account.Name==objServiceDataImport.Company_Name__c || 
                           vehicleAsset.Account.Name==objServiceDataImport.First_Name__c+' '+objServiceDataImport.Last_Name__c || 
                           (vehicleAsset.Account.FirstName==objServiceDataImport.First_Name__c && vehicleAsset.Account.LastName==objServiceDataImport.Last_Name__c) || 
                           (vehicleAsset.Account.isPersonAccount && vehicleAsset.account.LastName !=null  && vehicleAsset.Account.lastName==objServiceDataImport.Last_Name__c && 
                            ((objServiceDataImport.Email__c !=null && (vehicleAsset.Account.Retailer_Email__c==objServiceDataImport.Email__c || vehicleAsset.Account.personEmail==objServiceDataImport.Email__c || vehicleAsset.Account.Email2__pc !=null || vehicleAsset.Account.Email3__pc !=null)) ||  
                             (objServiceDataImport.Mobile_Number__c !=null && (objServiceDataImport.Mobile_Number__c==vehicleAsset.Account.Phone || objServiceDataImport.Mobile_Number__c==countryDialCode+vehicleAsset.Account.Phone || countryDialCode+objServiceDataImport.Mobile_Number__c==vehicleAsset.Account.Phone || objServiceDataImport.Mobile_Number__c==vehicleAsset.Account.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+vehicleAsset.Account.PersonMobilePhone || countryDialCode+objServiceDataImport.Mobile_Number__c==vehicleAsset.Account.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==vehicleAsset.Account.PersonHomePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+vehicleAsset.Account.PersonHomePhone || countryDialCode+objServiceDataImport.Mobile_Number__c==vehicleAsset.Account.PersonHomePhone || objServiceDataImport.Mobile_Number__c== vehicleAsset.Account.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+vehicleAsset.Account.PersonMobilePhone || countryDialCode+objServiceDataImport.Mobile_Number__c==vehicleAsset.Account.PersonMobilePhone)) ||
                             (objServiceDataImport.Home_Phone__c !=null && (objServiceDataImport.Home_Phone__c==vehicleAsset.Account.Phone || objServiceDataImport.Home_Phone__c==countryDialCode+vehicleAsset.Account.Phone || countryDialCode+objServiceDataImport.Home_Phone__c==vehicleAsset.Account.Phone || objServiceDataImport.Home_Phone__c==vehicleAsset.Account.PersonMobilePhone || objServiceDataImport.Home_Phone__c==countryDialCode+vehicleAsset.Account.PersonMobilePhone || countryDialCode+objServiceDataImport.Home_Phone__c==vehicleAsset.Account.PersonMobilePhone || objServiceDataImport.Home_Phone__c==vehicleAsset.Account.PersonHomePhone || objServiceDataImport.Home_Phone__c==countryDialCode+vehicleAsset.Account.PersonHomePhone || countryDialCode+objServiceDataImport.Home_Phone__c==vehicleAsset.Account.PersonHomePhone || objServiceDataImport.Home_Phone__c== vehicleAsset.Account.PersonMobilePhone||  objServiceDataImport.Home_Phone__c==countryDialCode+vehicleAsset.Account.PersonMobilePhone || countryDialCode+objServiceDataImport.Home_Phone__c==vehicleAsset.Account.PersonMobilePhone)) || 
                             (objServiceDataImport.Business_Phone__c !=null && (objServiceDataImport.Business_Phone__c==vehicleAsset.Account.Phone || objServiceDataImport.Business_Phone__c==countryDialCode+vehicleAsset.Account.Phone || countryDialCode+objServiceDataImport.Business_Phone__c==vehicleAsset.Account.Phone || objServiceDataImport.Business_Phone__c==vehicleAsset.Account.PersonMobilePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+vehicleAsset.Account.PersonMobilePhone || countryDialCode+objServiceDataImport.Business_Phone__c==vehicleAsset.Account.PersonMobilePhone || objServiceDataImport.Business_Phone__c==vehicleAsset.Account.PersonHomePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+vehicleAsset.Account.PersonHomePhone||  countryDialCode+objServiceDataImport.Business_Phone__c==vehicleAsset.Account.PersonHomePhone || objServiceDataImport.Business_Phone__c== vehicleAsset.Account.PersonMobilePhone ||  objServiceDataImport.Business_Phone__c==countryDialCode+vehicleAsset.Account.PersonMobilePhone  || countryDialCode+objServiceDataImport.Business_Phone__c==vehicleAsset.Account.PersonMobilePhone)))))
                        {
                            serviceDataObject.Service_Customer_Account__c=vehicleAsset.AccountId;
                            if(vehicleAsset.Account.isPersonAccount)
                            {
                                serviceDataObject.Service_Customer_Contact__c= vehicleAsset.Account.PersonContactId;
                                accountForUpsert= new account();
                                accountForUpsert.Id=vehicleAsset.AccountId;
                                accountForUpsert.FirstName=serviceDataObject.First_Name__c;
                                accountForUpsert.LastName=serviceDataObject.Last_Name__c;
                                
                                
                                if(objServiceDataImport.Email__c!=null && vehicleAsset.Account.PersonEmail !=objServiceDataImport.Email__c)
                                {
                                    if(vehicleAsset.Account.Email2__pc==null || string.isBlank(vehicleAsset.Account.Email2__pc))
                                    {
                                        accountForUpsert.Email2__pc=vehicleAsset.Account.PersonEmail;
                                    }
                                    else if(vehicleAsset.Account.Email3__pc==null || string.isBlank(vehicleAsset.Account.Email3__pc))
                                    {
                                        accountForUpsert.Email3__pc=vehicleAsset.Account.PersonEmail;
                                    }
                                    else{
                                        historicalString=vehicleAsset.Account.Historical_Contact_Details__c !=null ? vehicleAsset.Account.Historical_Contact_Details__c+'\n Email:'+vehicleAsset.Account.PersonEmail : 'Email:'+vehicleAsset.Account.PersonEmail;
                                        //accountForUpsert.Historical_Contact_Details__c= vehicleAsset.Account.Historical_Contact_Details__c !=null ? vehicleAsset.Account.Historical_Contact_Details__c+'\n Email:'+vehicleAsset.Account.PersonEmail : vehicleAsset.Account.PersonEmail;
                                        //historicalString+='\n Removed On:'+system.today();
                                        
                                    }
                                    accountForUpsert.PersonEmail=objServiceDataImport.Email__c;
                                }
                                if(objServiceDataImport.Mobile_Number__c !=null && vehicleAsset.Account.PersonMobilePhone !=objServiceDataImport.Mobile_Number__c)
                                {
                                    if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                    {
                                        if(string.isNotBlank(historicalString) && historicalString!=null)
                                        {
                                            historicalString= historicalString+'\n Phone:'+vehicleAsset.Account.PersonMobilePhone;
                                        }else{
                                            historicalString= vehicleAsset.Account.Historical_Contact_Details__c !=null ? vehicleAsset.Account.Historical_Contact_Details__c+'\n Phone:'+vehicleAsset.Account.PersonMobilePhone : 'Phone:'+vehicleAsset.Account.PersonMobilePhone;                                        
                                        }
                                        //accountForUpsert.Historical_Contact_Details__c= vehicleAsset.Account.Historical_Contact_Details__c !=null ? vehicleAsset.Account.Historical_Contact_Details__c+'\n Phone:'+vehicleAsset.Account.PersonMobilePhone : vehicleAsset.Account.PersonMobilePhone;
                                        //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today(); 
                                        accountForUpsert.PersonMobilePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Mobile_Number__c;  
                                    }
                                }
                                
                                if(objServiceDataImport.Home_Phone__c !=null && vehicleAsset.Account.PersonHomePhone !=objServiceDataImport.Home_Phone__c)
                                {
                                    if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                    {
                                        if(string.isNotBlank(historicalString) && historicalString !=null)
                                        {
                                            historicalString= historicalString+'\n Home Phone:'+vehicleAsset.Account.PersonHomePhone;
                                        }else{
                                            historicalString= vehicleAsset.Account.Historical_Contact_Details__c !=null ? vehicleAsset.Account.Historical_Contact_Details__c+'\n Home Phone:'+vehicleAsset.Account.PersonHomePhone : 'Home Phone:'+vehicleAsset.Account.PersonHomePhone;
                                        }
                                        //accountForUpsert.Historical_Contact_Details__c= vehicleAsset.Account.Historical_Contact_Details__c !=null ? vehicleAsset.Account.Historical_Contact_Details__c+'\n Home Phone:'+vehicleAsset.Account.PersonHomePhone : vehicleAsset.Account.PersonHomePhone;
                                        //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today(); 
                                        accountForUpsert.PersonHomePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Home_Phone__c;
                                    }
                                }
                                if(string.isNotBlank(historicalString))
                                {
                                    historicalString+='\n Removed On:'+system.today().format(); 
                                    accountForUpsert.Historical_Contact_Details__c=historicalString;
                                }
                                accountLstForUpdate.put(accountForUpsert.Id,accountForUpsert);
                                uniqueKeyAccountUpdateMap.put(objServiceDataImport.Unique_Key__c,accountUpdateCount);
                                accountUpdateCount++;
                            }
                            else if(accountContactMap.containsKey(vehicleAsset.AccountId) && accountContactMap.get(vehicleAsset.AccountId) !=null && !accountContactMap.get(vehicleAsset.AccountId).isEmpty())
                            {
                                contactForUpsert= new contact();
                                for(contact con:accountContactMap.get(vehicleAsset.AccountId))
                                {
                                    if( (con.FirstName==objServiceDataImport.First_Name__c && con.LastName==objServiceDataImport.Last_Name__c) ||
                                       (con.lastName==objServiceDataImport.Last_Name__c && 
                                        ((objServiceDataImport.Email__c !=null && (con.Email==objServiceDataImport.Email__c || con.Email2__c !=null || con.Email3__c !=null)) ||  
                                         (objServiceDataImport.Mobile_Number__c !=null && (objServiceDataImport.Mobile_Number__c==con.Phone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.Phone || objServiceDataImport.Mobile_Number__c==con.MobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.MobilePhone || objServiceDataImport.Mobile_Number__c==con.HomePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.HomePhone || objServiceDataImport.Mobile_Number__c==con.MobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.MobilePhone)) ||
                                         (objServiceDataImport.Home_Phone__c !=null && (objServiceDataImport.Home_Phone__c==con.Phone || objServiceDataImport.Home_Phone__c==countryDialCode+con.Phone || objServiceDataImport.Home_Phone__c==con.MobilePhone || objServiceDataImport.Home_Phone__c==countryDialCode+con.MobilePhone || objServiceDataImport.Home_Phone__c==con.HomePhone || objServiceDataImport.Home_Phone__c==countryDialCode+con.HomePhone || objServiceDataImport.Home_Phone__c== con.MobilePhone||  objServiceDataImport.Home_Phone__c==countryDialCode+con.MobilePhone)) || 
                                         (objServiceDataImport.Business_Phone__c !=null && (objServiceDataImport.Business_Phone__c==con.Phone || objServiceDataImport.Business_Phone__c==countryDialCode+con.Phone || objServiceDataImport.Business_Phone__c==con.MobilePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+con.MobilePhone || objServiceDataImport.Business_Phone__c==con.HomePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+con.HomePhone || objServiceDataImport.Business_Phone__c== con.MobilePhone ||  objServiceDataImport.Business_Phone__c==countryDialCode+con.MobilePhone)))))
                                    {
                                        serviceDataObject.Service_Customer_Contact__c= con.Id; 
                                        contactForUpsert=con;
                                        contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                        contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                        if(objServiceDataImport.Email__c!=null && con.Email !=objServiceDataImport.Email__c)
                                        {
                                            if(con.Email2__c==null)
                                                con.Email2__c=con.Email;
                                            else if(con.Email3__c==null)
                                                con.Email3__c=con.Email;
                                            else{
                                                historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Email:'+con.Email : 'Email:'+con.Email;
                                                //con.Historical_Contact__c+='\n Removed On:'+system.today();
                                            }
                                            con.Email=objServiceDataImport.Email__c;
                                        }
                                        if(objServiceDataImport.Mobile_Number__c !=null && con.MobilePhone !=objServiceDataImport.Mobile_Number__c)
                                        {
                                            if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                            {
                                                if(string.isNotBlank(historicalString) && historicalString !=null)
                                                {
                                                    historicalString= historicalString+'\n Phone:'+con.MobilePhone;
                                                }else{
                                                    historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Phone:'+con.MobilePhone : 'Phone:'+con.MobilePhone;
                                                }
                                                //con.Historical_Contact__c= 
                                                //con.Historical_Contact__c+='\n Removed On:'+system.today(); 
                                                con.MobilePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Mobile_Number__c;  
                                            }
                                        }
                                        
                                        if(objServiceDataImport.Home_Phone__c !=null && con.HomePhone !=objServiceDataImport.Home_Phone__c)
                                        {
                                            if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                            {
                                                if(string.isNotBlank(historicalString) && historicalString !=null)
                                                {
                                                    historicalString= historicalString+'\n Home Phone:'+con.HomePhone;
                                                }else{
                                                    historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Home Phone:'+con.HomePhone : 'Home Phone:'+con.HomePhone;
                                                }
                                                //con.Historical_Contact__c= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Home Phone:'+con.HomePhone : con.HomePhone;
                                                //con.Historical_Contact__c+='\n Removed On:'+system.today(); 
                                                con.HomePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Home_Phone__c;
                                            }
                                        }
                                        
                                        if(string.isNotBlank(historicalString))
                                        {
                                            historicalString+='\n Removed On:'+system.today().format(); 
                                            con.Historical_Contact__c=historicalString;
                                        }
                                        
                                        contactLstForUpdate.put(con.Id,con);
                                        uniqueKeyContactUpdateMap.put(objServiceDataImport.Unique_Key__c,contactUpdateCount);
                                        contactUpdateCount++;
                                        break;
                                    }
                                }
                                
                                if(serviceDataObject.Service_Customer_Contact__c==null )
                                {
                                    if(objServiceDataImport.Last_Name__c !=null)
                                    {
                                        contactForUpsert.AccountId=vehicleAsset.AccountId;
                                        contactForUpsert.RecordTypeId= RetailerConRecId;
                                        contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                        contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                        contactForUpsert.Email=objServiceDataImport.Email__c;
                                        contactForUpsert.Phone=objServiceDataImport.Business_Phone__c;
                                        contactForUpsert.MobilePhone=objServiceDataImport.Mobile_Number__c;
                                        contactForUpsert.HomePhone=objServiceDataImport.Home_Phone__c;
                                        //contactForUpsert.DMS_Identifier__c=objServiceDataImport.Dms_Id__c;
                                        contactForUpsert.Title=objServiceDataImport.Title__c;
                                        contactForUpsert.OtherPhone=objServiceDataImport.Home_Phone__c;
                                        //contactForUpsert.aop_Country__c=objServiceDataImport.Country__c;
                                        contactForUpsert.Country_ISO_Code__c=objServiceDataImport.CountryISO_Code__c;
                                        contactLstForinsert.add(contactForUpsert);
                                        uniqueKeyContactInsertMap.put(objServiceDataImport.Unique_Key__c,contactInsertCount);
                                        contactInsertCount++;
                                    }else{
                                        objServiceDataImport.Status__c='Failed';
                                        objServiceDataImport.Error_Message__c='Data provided is not sufficient to create/update records.';
                                        for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                            {
                                                errRec.Status__c='Failed';
                                                errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                                            }
                                    }
                                }
                            }else if(!vehicleAsset.Account.IspersonAccount){
                                if(objServiceDataImport.Last_Name__c !=null)
                                {
                                    contactForUpsert= new contact();
                                    contactForUpsert.AccountId=vehicleAsset.AccountId;
                                    contactForUpsert.RecordTypeId= RetailerConRecId;
                                    contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                    contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                    contactForUpsert.Email=objServiceDataImport.Email__c;
                                    contactForUpsert.Phone=objServiceDataImport.Business_Phone__c;
                                    contactForUpsert.MobilePhone=objServiceDataImport.Mobile_Number__c;
                                    contactForUpsert.HomePhone=objServiceDataImport.Home_Phone__c;
                                    //contactForUpsert.DMS_Identifier__c=objServiceDataImport.Dms_Id__c;
                                    contactForUpsert.Title=objServiceDataImport.Title__c;
                                    contactForUpsert.OtherPhone=objServiceDataImport.Home_Phone__c;
                                    //contactForUpsert.aop_Country__c=objServiceDataImport.Country__c;
                                    contactForUpsert.Country_ISO_Code__c=objServiceDataImport.CountryISO_Code__c;
                                    contactLstForinsert.add(contactForUpsert);
                                    uniqueKeyContactInsertMap.put(objServiceDataImport.Unique_Key__c,contactInsertCount);
                                    contactInsertCount++;
                                }else{
                                    objServiceDataImport.Status__c='Failed';
                                    objServiceDataImport.Error_Message__c='Data provided is not sufficient to create/update records.';
                                    for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                    {
                                        errRec.Status__c='Failed';
                                        errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                                    }
                                }
                            }else{
                                objServiceDataImport.Status__c='Failed';
                                objServiceDataImport.Error_Message__c='Matched with invalid combination of account/contact.';
                                for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                {
                                    errRec.Status__c='Failed';
                                    errRec.Error_Message__c='Matched with invalid combination of account/contact.';
                                }
                            }
                            
                        }else if(objServiceDataImport.Dealer_Code_JLR__c !=null && objServiceDataImport.Dealer_Code_JLR__c !=''){
                            dealerCodeSet.add(objServiceDataImport.Dealer_Code_JLR__c);
                            if(objServiceDataImport.Company_Name__c !=null && string.isNotBlank(objServiceDataImport.Company_Name__c) && objServiceDataImport.Company_Name__c !='')
                                companyNameSet.add(objServiceDataImport.Company_Name__c);
                            if(objServiceDataImport.First_Name__c !=null && string.isNotBlank(objServiceDataImport.First_Name__c) && objServiceDataImport.First_Name__c !='' && objServiceDataImport.Last_Name__c !=null && string.isNotBlank(objServiceDataImport.Last_Name__c) && objServiceDataImport.Last_Name__c !='')
                                companyNameSet.add(objServiceDataImport.First_Name__c+' '+objServiceDataImport.Last_Name__c);
                            if(objServiceDataImport.First_Name__c !=null && string.isNotBlank(objServiceDataImport.First_Name__c) && objServiceDataImport.First_Name__c !='')
                                firstNameSet.add(objServiceDataImport.First_Name__c); 
                            if(objServiceDataImport.Last_Name__c !=null && string.isNotBlank(objServiceDataImport.Last_Name__c) && objServiceDataImport.Last_Name__c !='')
                                lastnameSet.add(objServiceDataImport.First_Name__c); 
                            if(objServiceDataImport.Email__c !=null && string.isNotBlank(objServiceDataImport.Email__c) && objServiceDataImport.Email__c !='')
                                emailIdSet.add(objServiceDataImport.Email__c);
                            if(objServiceDataImport.Business_Phone__c !=null && string.isNotBlank(objServiceDataImport.Business_Phone__c) && objServiceDataImport.Business_Phone__c !='')
                            {
                                phoneNoSet.add(objServiceDataImport.Business_Phone__c);
                                phoneNoSet.add(countryDialCodeMap+objServiceDataImport.Business_Phone__c);
                            }
                            if(objServiceDataImport.Mobile_Number__c !=null && string.isNotBlank(objServiceDataImport.Mobile_Number__c) && objServiceDataImport.Mobile_Number__c !='')
                            {
                                phoneNoSet.add(objServiceDataImport.Mobile_Number__c);
                                phoneNoSet.add(countryDialCodeMap+objServiceDataImport.Mobile_Number__c);  
                            }
                            if(objServiceDataImport.Home_Phone__c !=null && string.isNotBlank(objServiceDataImport.Home_Phone__c) && objServiceDataImport.Home_Phone__c !='')
                            {
                                phoneNoSet.add(objServiceDataImport.Home_Phone__c);
                                phoneNoSet.add(countryDialCodeMap+objServiceDataImport.Home_Phone__c);
                            }
                        }
                    }
                    
                    SDRecForInsertMap.put(objServiceDataImport.Unique_Key__c,serviceDataObject);  
                }else{
                    objServiceDataImport.Status__c='Failed';
                    objServiceDataImport.Error_Message__c='Vin number not found. ';
                    
                    for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                    {
                        errRec.Status__c='Failed';
                        errRec.Error_Message__c='Vin number not found. ';
                    }
                }
            }
        }
        
        boolean searchOutsideRegion =false;
        
        if(!dealerCodeSet.isEmpty())
        {
            //Map<Id,AggregateResult> JLRDealerParentId= new Map<Id,AggregateResult>([select parentId Id, Primary_Dealer_Code__c FROM Account WHERE Primary_Dealer_Code__c IN:dealerCodeAccountMap.keySet() group by parentId ]);
            for(Account parentDealer:[select Id, parentId, Primary_Dealer_Code__c FROM Account WHERE Primary_Dealer_Code__c IN:dealerCodeSet AND parentId !=null])
            {
                dealerCodeParentIdMap.put(parentDealer.Primary_Dealer_Code__c, parentDealer.parentId); 
            }
            if(dealerCodeParentIdMap.values() !=null)
            {
                for(Account customerAcc:[select id, Name,
                                         FirstName,
                                         Preferred_Sales_Retailer__r.parentId,
                                         personcontactId,
                                         isPersonAccount,
                                         LastName, PersonEmail, 
                                         Email2__pc, Email3__pc,
                                         Retailer_Email__c,
                                         Phone,
                                         PersonMobilePhone,
                                         PersonOtherPhone,
                                         PersonHomePhone,
                                         Historical_Contact_Details__c,
                                         (select id, AccountId, 
                                          FirstName,
                                          Name, Historical_Contact__c, 
                                          LastName, Email, 
                                          Email2__c, Email3__c, 
                                          HomePhone, MobilePhone, 
                                          OtherPhone, Phone from contacts
                                          Where (Name IN:companyNameSet OR FirstName IN: firstNameSet OR LastName IN :lastnameSet OR Email2__c IN:emailIdSet OR Email3__c IN:emailIdSet OR HomePhone IN:phoneNoSet OR MobilePhone IN:phoneNoSet OR OtherPhone IN:phoneNoSet OR Phone IN:phoneNoSet  ) )
                                         From Account where Preferred_Sales_Retailer__r.parentId IN: dealerCodeParentIdMap.values() 
                                         AND (recordtypeId=:corporateAccRecId OR recordTypeId=:IndividualAccRecId)
                                         AND ( (Name IN: companyNameSet AND (Retailer_Email__c IN: emailIdSet OR PersonEmail IN:emailIdSet OR Email2__pc IN:emailIdSet OR Email2__pc IN:emailIdSet  ) )
                                              OR (Name IN: companyNameSet) 
                                              OR (Name IN: companyNameSet AND (Phone IN: phoneNoSet OR PersonMobilePhone IN: phoneNoSet OR PersonOtherPhone IN: phoneNoSet OR PersonHomePhone IN: phoneNoSet) ) 
                                              OR (Name IN: companyNameSet AND FirstName IN: firstNameSet AND LastName IN:lastnameSet ) 
                                              OR (FirstName IN: firstNameSet AND LastName IN: lastnameSet AND (Retailer_Email__c IN: emailIdSet OR PersonEmail IN:emailIdSet OR Email2__pc IN:emailIdSet OR Email2__pc IN:emailIdSet  )) 
                                              OR (FirstName IN: firstNameSet AND LastName IN: lastnameSet AND (Phone IN: phoneNoSet OR PersonMobilePhone IN: phoneNoSet OR PersonOtherPhone IN: phoneNoSet OR PersonHomePhone IN: phoneNoSet))) ])
                {
                    if(!dealerCodeAccountMap.containsKey(customerAcc.Preferred_Sales_Retailer__r.parentId))
                    {
                        dealerCodeAccountMap.put(customerAcc.Preferred_Sales_Retailer__r.parentId, new list<Account>());
                    }
                    dealerCodeAccountMap.get(customerAcc.Preferred_Sales_Retailer__r.parentId).add(customerAcc);
                }
            }
            list<Account> accountForMatchingLst;
            
            for(Service_Data_Import__c objServiceDataImport:SDIRecForMatchingMap.values())
            {
                if(objServiceDataImport.Status__c!='Failed')
                {
                    if(!dealerCodeAccountMap.isEmpty() && dealerCodeParentIdMap.containsKey(objServiceDataImport.Dealer_Code_JLR__c) && dealerCodeAccountMap.containsKey(dealerCodeParentIdMap.get(objServiceDataImport.Dealer_Code_JLR__c)) && SDRecForInsertMap.containsKey(objServiceDataImport.Unique_Key__c))
                    {
                        serviceDataObject = SDRecForInsertMap.get(objServiceDataImport.Unique_Key__c);
                        accountForMatchingLst= dealerCodeAccountMap.get(dealerCodeParentIdMap.get(objServiceDataImport.Dealer_Code_JLR__c));
                        string countryDialCode='';
                        if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                        {
                            countryDialCode=countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c);
                        }
                        
                        if(serviceDataObject.Service_Customer_Account__c==null)
                        {
                            for(Account customerAcc:accountForMatchingLst)
                            {
                                historicalString='';
                                if(customerAcc.Name==objServiceDataImport.Company_Name__c || 
                                   customerAcc.Name==objServiceDataImport.First_Name__c+' '+objServiceDataImport.Last_Name__c || 
                                   (customerAcc.FirstName==objServiceDataImport.First_Name__c && customerAcc.LastName==objServiceDataImport.Last_Name__c) || 
                                   (customerAcc.isPersonAccount && customerAcc.LastName !=null  && customerAcc.lastName==objServiceDataImport.Last_Name__c && 
                                    ((objServiceDataImport.Email__c !=null && (customerAcc.Retailer_Email__c==objServiceDataImport.Email__c || customerAcc.personEmail==objServiceDataImport.Email__c || customerAcc.Email2__pc !=null || customerAcc.Email3__pc !=null)) ||  
                                     (objServiceDataImport.Mobile_Number__c !=null && (objServiceDataImport.Mobile_Number__c==customerAcc.Phone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.Phone || countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.Phone || objServiceDataImport.Mobile_Number__c==customerAcc.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==customerAcc.PersonHomePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.PersonHomePhone ||countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.PersonHomePhone || objServiceDataImport.Mobile_Number__c== customerAcc.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.PersonMobilePhone  ||countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.PersonMobilePhone)) ||
                                     (objServiceDataImport.Home_Phone__c !=null && (objServiceDataImport.Home_Phone__c==customerAcc.Phone || objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.Phone || countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.Phone || objServiceDataImport.Home_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.PersonMobilePhone ||countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Home_Phone__c==customerAcc.PersonHomePhone || objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.PersonHomePhone || countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.PersonHomePhone || objServiceDataImport.Home_Phone__c== customerAcc.PersonMobilePhone||  objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.PersonMobilePhone ||countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.PersonMobilePhone)) || 
                                     (objServiceDataImport.Business_Phone__c !=null && (objServiceDataImport.Business_Phone__c==customerAcc.Phone || objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.Phone || countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.Phone || objServiceDataImport.Business_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Business_Phone__c==customerAcc.PersonHomePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.PersonHomePhone ||countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.PersonHomePhone || objServiceDataImport.Business_Phone__c== customerAcc.PersonMobilePhone ||  objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.PersonMobilePhone)))))
                                {
                                    serviceDataObject.Service_Customer_Account__c=customerAcc.Id;
                                    if(customerAcc.isPersonAccount)
                                    {
                                        serviceDataObject.Service_Customer_Contact__c= customerAcc.PersonContactId;
                                        accountForUpsert= new account();
                                        accountForUpsert.Id=customerAcc.Id;
                                        accountForUpsert.FirstName=serviceDataObject.First_Name__c;
                                        accountForUpsert.LastName=serviceDataObject.Last_Name__c;
                                        
                                        
                                        if(objServiceDataImport.Email__c!=null && customerAcc.PersonEmail !=objServiceDataImport.Email__c)
                                        {
                                            if(customerAcc.Email2__pc==null)
                                                accountForUpsert.Email2__pc=accountForUpsert.PersonEmail;
                                            else if(customerAcc.Email3__pc==null)
                                                accountForUpsert.Email3__pc=accountForUpsert.PersonEmail;
                                            else{
                                                historicalString= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Email:'+customerAcc.PersonEmail : 'Email:'+customerAcc.PersonEmail;
                                                //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today();
                                            }
                                            accountForUpsert.PersonEmail=objServiceDataImport.Email__c;
                                        }
                                        if(objServiceDataImport.Mobile_Number__c !=null && customerAcc.PersonMobilePhone !=objServiceDataImport.Mobile_Number__c)
                                        {
                                            if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                            {
                                                if(string.isNotBlank(historicalString) && historicalString !=null)
                                                {
                                                    historicalString= historicalString+'\n Phone'+customerAcc.PersonMobilePhone;
                                                }else{
                                                    historicalString= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Phone:'+customerAcc.PersonMobilePhone : 'Phone'+customerAcc.PersonMobilePhone;
                                                }
                                                
                                                //accountForUpsert.Historical_Contact_Details__c= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Phone:'+customerAcc.PersonMobilePhone : customerAcc.PersonMobilePhone;
                                                //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today(); 
                                                accountForUpsert.PersonMobilePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Mobile_Number__c;  
                                            }
                                        }
                                        
                                        if(objServiceDataImport.Home_Phone__c !=null && customerAcc.PersonHomePhone !=objServiceDataImport.Home_Phone__c)
                                        {
                                            if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                            {
                                                if(string.isNotBlank(historicalString) && historicalString !=null)
                                                {
                                                    historicalString= historicalString+'\n Home Phone:'+customerAcc.PersonHomePhone;
                                                }else{
                                                    historicalString= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Home Phone:'+customerAcc.PersonHomePhone : 'Home Phone:'+customerAcc.PersonHomePhone;
                                                }
                                                //accountForUpsert.Historical_Contact_Details__c= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Home Phone:'+customerAcc.PersonHomePhone : customerAcc.PersonHomePhone;
                                                //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today(); 
                                                accountForUpsert.PersonHomePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Home_Phone__c;
                                            }
                                        }
                                        
                                        if(string.isNotBlank(historicalString))
                                        {
                                            historicalString+='\n Removed On:'+system.today().format(); 
                                            accountForUpsert.Historical_Contact_Details__c=historicalString;
                                        }
                                        
                                        accountLstForUpdate.put(accountForUpsert.Id,accountForUpsert);
                                        uniqueKeyAccountUpdateMap.put(objServiceDataImport.Unique_Key__c,accountUpdateCount);
                                        accountUpdateCount++;
                                    }
                                    else if(!customerAcc.contacts.isEmpty())
                                    {
                                        contactForUpsert= new contact();
                                        for(contact con:customerAcc.contacts)
                                        {
                                            if( (con.FirstName==objServiceDataImport.First_Name__c && con.LastName==objServiceDataImport.Last_Name__c) ||
                                               (con.lastName==objServiceDataImport.Last_Name__c && 
                                                ((objServiceDataImport.Email__c !=null && (con.Email==objServiceDataImport.Email__c || con.Email2__c !=null || con.Email3__c !=null)) ||  
                                                 (objServiceDataImport.Mobile_Number__c !=null && (objServiceDataImport.Mobile_Number__c==con.Phone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.Phone || objServiceDataImport.Mobile_Number__c==con.MobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.MobilePhone || objServiceDataImport.Mobile_Number__c==con.HomePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.HomePhone || objServiceDataImport.Mobile_Number__c==con.MobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.MobilePhone)) ||
                                                 (objServiceDataImport.Home_Phone__c !=null && (objServiceDataImport.Home_Phone__c==con.Phone || objServiceDataImport.Home_Phone__c==countryDialCode+con.Phone || objServiceDataImport.Home_Phone__c==con.MobilePhone || objServiceDataImport.Home_Phone__c==countryDialCode+con.MobilePhone || objServiceDataImport.Home_Phone__c==con.HomePhone || objServiceDataImport.Home_Phone__c==countryDialCode+con.HomePhone || objServiceDataImport.Home_Phone__c== con.MobilePhone||  objServiceDataImport.Home_Phone__c==countryDialCode+con.MobilePhone)) || 
                                                 (objServiceDataImport.Business_Phone__c !=null && (objServiceDataImport.Business_Phone__c==con.Phone || objServiceDataImport.Business_Phone__c==countryDialCode+con.Phone || objServiceDataImport.Business_Phone__c==con.MobilePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+con.MobilePhone || objServiceDataImport.Business_Phone__c==con.HomePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+con.HomePhone || objServiceDataImport.Business_Phone__c== con.MobilePhone ||  objServiceDataImport.Business_Phone__c==countryDialCode+con.MobilePhone)))))
                                            {
                                                serviceDataObject.Service_Customer_Contact__c= con.Id; 
                                                contactForUpsert=con;
                                                contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                                contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                                if(objServiceDataImport.Email__c!=null && con.Email !=objServiceDataImport.Email__c)
                                                {
                                                    if(con.Email2__c==null)
                                                        con.Email2__c=con.Email;
                                                    else if(con.Email3__c==null)
                                                        con.Email3__c=con.Email;
                                                    else{
                                                        historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Email:'+con.Email : 'Email:'+con.Email;
                                                        //con.Historical_Contact__c= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Email:'+con.Email : con.Email;
                                                        //con.Historical_Contact__c+='\n Removed On:'+system.today();
                                                    }
                                                    con.Email=objServiceDataImport.Email__c;
                                                }
                                                if(objServiceDataImport.Mobile_Number__c !=null && con.MobilePhone !=objServiceDataImport.Mobile_Number__c)
                                                {
                                                    if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                                    {
                                                        if(string.isNotBlank(historicalString) && historicalString !=null)
                                                        {
                                                            historicalString= historicalString+'\n Phone:'+con.MobilePhone;
                                                        }else{
                                                            historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Phone:'+con.MobilePhone : 'Phone:'+con.MobilePhone;
                                                        }
                                                        //con.Historical_Contact__c= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Phone:'+con.MobilePhone : con.MobilePhone;
                                                        //con.Historical_Contact__c+='\n Removed On:'+system.today(); 
                                                        con.MobilePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Mobile_Number__c;  
                                                    }
                                                }
                                                
                                                if(objServiceDataImport.Home_Phone__c !=null && con.HomePhone !=objServiceDataImport.Home_Phone__c)
                                                {
                                                    if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                                    {
                                                        if(string.isNotBlank(historicalString) && historicalString !=null)
                                                        {
                                                            historicalString= historicalString+'\n Home Phone:'+con.HomePhone;
                                                        }else{
                                                            historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Home Phone:'+con.HomePhone : 'Home Phone:'+con.HomePhone;
                                                        }
                                                        //con.Historical_Contact__c= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Home Phone:'+con.HomePhone : con.HomePhone;
                                                        //con.Historical_Contact__c+='\n Removed On:'+system.today(); 
                                                        con.HomePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Home_Phone__c;
                                                    }
                                                }
                                                if(string.isNotBlank(historicalString))
                                                {
                                                    historicalString+='\n Removed On:'+system.today().format(); 
                                                    con.Historical_Contact__c=historicalString;
                                                }
                                                contactLstForUpdate.put(con.Id,con);
                                                uniqueKeyContactUpdateMap.put(objServiceDataImport.Unique_Key__c,contactUpdateCount);
                                                contactUpdateCount++;
                                                break;
                                            }
                                        }
                                        
                                        if(serviceDataObject.Service_Customer_Contact__c==null )
                                        {
                                            if(objServiceDataImport.Last_Name__c !=null)
                                            {
                                                contactForUpsert.AccountId=customerAcc.Id;
                                                contactForUpsert.RecordTypeId= RetailerConRecId;
                                                contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                                contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                                contactForUpsert.Email=objServiceDataImport.Email__c;
                                                contactForUpsert.Phone=objServiceDataImport.Business_Phone__c;
                                                contactForUpsert.MobilePhone=objServiceDataImport.Mobile_Number__c;
                                                contactForUpsert.HomePhone=objServiceDataImport.Home_Phone__c;
                                                //contactForUpsert.DMS_Identifier__c=objServiceDataImport.Dms_Id__c;
                                                contactForUpsert.Title=objServiceDataImport.Title__c;
                                                contactForUpsert.OtherPhone=objServiceDataImport.Home_Phone__c;
                                                //contactForUpsert.aop_Country__c=objServiceDataImport.Country__c;
                                                contactForUpsert.Country_ISO_Code__c=objServiceDataImport.CountryISO_Code__c;
                                                contactLstForinsert.add(contactForUpsert);
                                                uniqueKeyContactInsertMap.put(objServiceDataImport.Unique_Key__c,contactInsertCount);
                                                contactInsertCount++;
                                            }else{
                                                objServiceDataImport.Status__c='Failed';
                                                objServiceDataImport.Error_Message__c='Data provided is not sufficient to create/update records.';
                                                for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                                {
                                                    errRec.Status__c='Failed';
                                                    errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                                                }
                                            }
                                        }
                                    }else if(!customerAcc.IspersonAccount){
                                        if(objServiceDataImport.Last_Name__c !=null)
                                        {
                                            contactForUpsert= new contact();
                                            contactForUpsert.AccountId=customerAcc.Id;
                                            contactForUpsert.RecordTypeId= RetailerConRecId;
                                            contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                            contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                            contactForUpsert.Email=objServiceDataImport.Email__c;
                                            contactForUpsert.Phone=objServiceDataImport.Business_Phone__c;
                                            contactForUpsert.MobilePhone=objServiceDataImport.Mobile_Number__c;
                                            contactForUpsert.HomePhone=objServiceDataImport.Home_Phone__c;
                                            //contactForUpsert.DMS_Identifier__c=objServiceDataImport.Dms_Id__c;
                                            contactForUpsert.Title=objServiceDataImport.Title__c;
                                            contactForUpsert.OtherPhone=objServiceDataImport.Home_Phone__c;
                                            //contactForUpsert.aop_Country__c=objServiceDataImport.Country__c;
                                            contactForUpsert.Country_ISO_Code__c=objServiceDataImport.CountryISO_Code__c;
                                            contactLstForinsert.add(contactForUpsert);
                                            uniqueKeyContactInsertMap.put(objServiceDataImport.Unique_Key__c,contactInsertCount);
                                            contactInsertCount++;
                                        }else{
                                            objServiceDataImport.Status__c='Failed';
                                            objServiceDataImport.Error_Message__c='Data provided is not sufficient to create/update records.';
                                            for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                            {
                                                errRec.Status__c='Failed';
                                                errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                                            }
                                        }
                                    }else{
                                        objServiceDataImport.Status__c='Failed';
                                        objServiceDataImport.Error_Message__c='Matched with invalid combination of account/contact.';
                                        for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                        {
                                            errRec.Status__c='Failed';
                                            errRec.Error_Message__c='Matched with invalid combination of account/contact.';
                                        }
                                    }
                                    if(serviceDataObject.Service_Customer_Account__c !=null)
                                        break; 
                                }
                            }
                        }
                        SDRecForInsertMap.put(objServiceDataImport.Unique_Key__c,serviceDataObject);
                        
                    }
                    
                    if(serviceDataObject.Service_Customer_Account__c==null && !searchOutsideRegion)
                    {
                        searchOutsideRegion=true;
                        if(objServiceDataImport.Company_Name__c !=null && string.isNotBlank(objServiceDataImport.Company_Name__c) && objServiceDataImport.Company_Name__c !='')
                            companyName_ORSet.add(objServiceDataImport.Company_Name__c);
                        if(objServiceDataImport.First_Name__c !=null && string.isNotBlank(objServiceDataImport.First_Name__c) && objServiceDataImport.First_Name__c !='' && objServiceDataImport.Last_Name__c !=null && string.isNotBlank(objServiceDataImport.Last_Name__c) && objServiceDataImport.Last_Name__c !='')
                            companyName_ORSet.add(objServiceDataImport.First_Name__c+' '+objServiceDataImport.Last_Name__c);
                        if(objServiceDataImport.First_Name__c !=null && string.isNotBlank(objServiceDataImport.First_Name__c) && objServiceDataImport.First_Name__c !='')
                            firstName_ORSet.add(objServiceDataImport.First_Name__c); 
                        if(objServiceDataImport.Last_Name__c !=null && string.isNotBlank(objServiceDataImport.Last_Name__c) && objServiceDataImport.Last_Name__c !='')
                            lastname_ORSet.add(objServiceDataImport.First_Name__c); 
                        if(objServiceDataImport.Email__c !=null && string.isNotBlank(objServiceDataImport.Email__c) && objServiceDataImport.Email__c !='')
                            emailId_ORSet.add(objServiceDataImport.Email__c);
                        if(objServiceDataImport.Business_Phone__c !=null && string.isNotBlank(objServiceDataImport.Business_Phone__c) && objServiceDataImport.Business_Phone__c !='')
                        {
                            phoneNo_ORSet.add(objServiceDataImport.Business_Phone__c);
                            phoneNo_ORSet.add(countryDialCodeMap+objServiceDataImport.Business_Phone__c);
                        }
                        if(objServiceDataImport.Mobile_Number__c !=null && string.isNotBlank(objServiceDataImport.Mobile_Number__c) && objServiceDataImport.Mobile_Number__c !='')
                        {
                            phoneNo_ORSet.add(objServiceDataImport.Mobile_Number__c);
                            phoneNo_ORSet.add(countryDialCodeMap+objServiceDataImport.Mobile_Number__c);  
                        }
                        if(objServiceDataImport.Home_Phone__c !=null && string.isNotBlank(objServiceDataImport.Home_Phone__c) && objServiceDataImport.Home_Phone__c !='')
                        {
                            phoneNo_ORSet.add(objServiceDataImport.Home_Phone__c);
                            phoneNo_ORSet.add(countryDialCodeMap+objServiceDataImport.Home_Phone__c);
                        }
                    }
                }
            }
        }
        
        
        if(searchOutsideRegion)
        {
            list<Account> allOtherRegionAcccounts=[select id, Name,
                                                   FirstName,
                                                   personcontactId,
                                                   isPersonAccount,
                                                   LastName, PersonEmail, 
                                                   Email2__pc, Email3__pc,
                                                   Retailer_Email__c,
                                                   Phone,
                                                   PersonMobilePhone,
                                                   PersonOtherPhone,
                                                   PersonHomePhone,
                                                   Historical_Contact_Details__c,
                                                   (select id, AccountId, 
                                                    FirstName,
                                                    Name, Historical_Contact__c, 
                                                    LastName, Email, 
                                                    Email2__c, Email3__c, 
                                                    HomePhone, MobilePhone, 
                                                    OtherPhone, Phone from contacts
                                                    Where (Name IN:companyName_ORSet OR FirstName IN: firstName_ORSet OR LastName IN :lastname_ORSet OR Email2__c IN:emailId_ORSet OR Email3__c IN:emailId_ORSet OR HomePhone IN:phoneNo_ORSet OR MobilePhone IN:phoneNo_ORSet OR OtherPhone IN:phoneNo_ORSet OR Phone IN:phoneNo_ORSet  ) )
                                                   From Account where Preferred_Sales_Retailer__r.parentId NOT IN: dealerCodeParentIdMap.values() 
                                                   AND (recordtypeId=:corporateAccRecId OR recordTypeId=:IndividualAccRecId)
                                                   AND ( (Name IN: companyName_ORSet AND (Retailer_Email__c IN: emailId_ORSet OR PersonEmail IN:emailId_ORSet OR Email2__pc IN:emailId_ORSet OR Email2__pc IN:emailId_ORSet  ) )
                                                        OR (Name IN: companyName_ORSet) 
                                                        OR (Name IN: companyName_ORSet AND (Phone IN: phoneNo_ORSet OR PersonMobilePhone IN: phoneNo_ORSet OR PersonOtherPhone IN: phoneNo_ORSet OR PersonHomePhone IN: phoneNo_ORSet) ) 
                                                        OR (Name IN: companyName_ORSet AND FirstName IN: firstName_ORSet AND LastName IN:lastname_ORSet ) 
                                                        OR (FirstName IN: firstName_ORSet AND LastName IN: lastname_ORSet AND (Retailer_Email__c IN: emailId_ORSet OR PersonEmail IN:emailId_ORSet OR Email2__pc IN:emailId_ORSet OR Email2__pc IN:emailId_ORSet  )) 
                                                        OR (FirstName IN: firstName_ORSet AND LastName IN: lastname_ORSet AND (Phone IN: phoneNo_ORSet OR PersonMobilePhone IN: phoneNo_ORSet OR PersonOtherPhone IN: phoneNo_ORSet OR PersonHomePhone IN: phoneNo_ORSet))) ]; 
            
            if(!allOtherRegionAcccounts.isEmpty() && allOtherRegionAcccounts !=null)
            {
                for(Service_Data_Import__c objServiceDataImport:SDIRecForMatchingMap.values())
                {
                    if(objServiceDataImport.Status__c!='Failed')
                    {
                        serviceDataObject = SDRecForInsertMap.get(objServiceDataImport.Unique_Key__c);
                        serviceDataObject.review_Required__C=true;
                        string countryDialCode='';
                        if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                        {
                            countryDialCode=countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c);
                        }
                        
                        if(serviceDataObject.Service_Customer_Account__c==null)
                        {
                            for(Account customerAcc:allOtherRegionAcccounts)
                            {
                                historicalString='';
                                if(customerAcc.Name==objServiceDataImport.Company_Name__c || 
                                   customerAcc.Name==objServiceDataImport.First_Name__c+' '+objServiceDataImport.Last_Name__c || 
                                   (customerAcc.FirstName==objServiceDataImport.First_Name__c && customerAcc.LastName==objServiceDataImport.Last_Name__c) || 
                                   (customerAcc.isPersonAccount && customerAcc.LastName !=null  && customerAcc.lastName==objServiceDataImport.Last_Name__c && 
                                    ((objServiceDataImport.Email__c !=null && (customerAcc.Retailer_Email__c==objServiceDataImport.Email__c || customerAcc.personEmail==objServiceDataImport.Email__c || customerAcc.Email2__pc !=null || customerAcc.Email3__pc !=null)) ||  
                                     (objServiceDataImport.Mobile_Number__c !=null && (objServiceDataImport.Mobile_Number__c==customerAcc.Phone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.Phone || countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.Phone || objServiceDataImport.Mobile_Number__c==customerAcc.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==customerAcc.PersonHomePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.PersonHomePhone  || countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.PersonHomePhone || objServiceDataImport.Mobile_Number__c== customerAcc.PersonMobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Mobile_Number__c==customerAcc.PersonMobilePhone)) ||
                                     (objServiceDataImport.Home_Phone__c !=null && (objServiceDataImport.Home_Phone__c==customerAcc.Phone || objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.Phone || countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.Phone || objServiceDataImport.Home_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Home_Phone__c==customerAcc.PersonHomePhone || objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.PersonHomePhone ||countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.PersonHomePhone || objServiceDataImport.Home_Phone__c== customerAcc.PersonMobilePhone ||  objServiceDataImport.Home_Phone__c==countryDialCode+customerAcc.PersonMobilePhone ||  countryDialCode+objServiceDataImport.Home_Phone__c==customerAcc.PersonMobilePhone)) || 
                                     (objServiceDataImport.Business_Phone__c !=null && (objServiceDataImport.Business_Phone__c==customerAcc.Phone || objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.Phone || countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.Phone || objServiceDataImport.Business_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.PersonMobilePhone || objServiceDataImport.Business_Phone__c==customerAcc.PersonHomePhone || objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.PersonHomePhone ||countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.PersonHomePhone || objServiceDataImport.Business_Phone__c== customerAcc.PersonMobilePhone ||  objServiceDataImport.Business_Phone__c==countryDialCode+customerAcc.PersonMobilePhone || countryDialCode+objServiceDataImport.Business_Phone__c==customerAcc.PersonMobilePhone)))))
                                {
                                    serviceDataObject.Service_Customer_Account__c=customerAcc.Id;
                                    
                                    if(customerAcc.isPersonAccount)
                                    {
                                        serviceDataObject.Service_Customer_Contact__c= customerAcc.PersonContactId;
                                        accountForUpsert= new account();
                                        accountForUpsert.Id=customerAcc.Id;
                                        accountForUpsert.FirstName=serviceDataObject.First_Name__c;
                                        accountForUpsert.LastName=serviceDataObject.Last_Name__c;
                                        
                                        
                                        if(objServiceDataImport.Email__c!=null && customerAcc.PersonEmail !=objServiceDataImport.Email__c)
                                        {
                                            if(customerAcc.Email2__pc==null)
                                                accountForUpsert.Email2__pc=accountForUpsert.PersonEmail;
                                            else if(customerAcc.Email3__pc==null)
                                                accountForUpsert.Email3__pc=accountForUpsert.PersonEmail;
                                            else{
                                                historicalString= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Email:'+customerAcc.PersonEmail : 'Email:'+customerAcc.PersonEmail;
                                                //accountForUpsert.Historical_Contact_Details__c= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Email:'+customerAcc.PersonEmail : customerAcc.PersonEmail;
                                                //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today();
                                            }
                                            accountForUpsert.PersonEmail=objServiceDataImport.Email__c;
                                        }
                                        if(objServiceDataImport.Mobile_Number__c !=null && customerAcc.PersonMobilePhone !=objServiceDataImport.Mobile_Number__c)
                                        {
                                            if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                            {
                                                if(string.isNotBlank(historicalString) && historicalString !=null)
                                                {
                                                    historicalString= historicalString+'\n Phone:'+customerAcc.PersonMobilePhone;
                                                }else{
                                                    historicalString= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Phone:'+customerAcc.PersonMobilePhone : 'Phone:'+customerAcc.PersonMobilePhone;
                                                }
                                                //accountForUpsert.Historical_Contact_Details__c= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Phone:'+customerAcc.PersonMobilePhone : customerAcc.PersonMobilePhone;
                                                //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today(); 
                                                accountForUpsert.PersonMobilePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Mobile_Number__c;  
                                            }
                                        }
                                        
                                        if(objServiceDataImport.Home_Phone__c !=null && customerAcc.PersonHomePhone !=objServiceDataImport.Home_Phone__c)
                                        {
                                            if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                            {
                                                if(string.isNotBlank(historicalString) && historicalString !=null)
                                                {
                                                    historicalString= historicalString+'\n Home Phone:'+customerAcc.PersonHomePhone;
                                                }else{
                                                    historicalString= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Home Phone:'+customerAcc.PersonHomePhone : 'Home Phone:'+customerAcc.PersonHomePhone;
                                                }
                                                //accountForUpsert.Historical_Contact_Details__c= customerAcc.Historical_Contact_Details__c !=null ? customerAcc.Historical_Contact_Details__c+'\n Home Phone:'+customerAcc.PersonHomePhone : customerAcc.PersonHomePhone;
                                                //accountForUpsert.Historical_Contact_Details__c+='\n Removed On:'+system.today(); 
                                                accountForUpsert.PersonHomePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Home_Phone__c;
                                            }
                                        }
                                        
                                        if(string.isNotBlank(historicalString))
                                        {
                                            historicalString+='\n Removed On:'+system.today().format(); 
                                            accountForUpsert.Historical_Contact_Details__c=historicalString;
                                        }
                                        accountLstForUpdate.put(accountForUpsert.id, accountForUpsert);
                                        uniqueKeyAccountUpdateMap.put(objServiceDataImport.Unique_Key__c,accountUpdateCount);
                                        accountUpdateCount++;
                                    }
                                    else if(!customerAcc.contacts.isEmpty())
                                    {
                                        contactForUpsert= new contact();
                                        for(contact con:customerAcc.contacts)
                                        {
                                            if( (con.FirstName==objServiceDataImport.First_Name__c && con.LastName==objServiceDataImport.Last_Name__c) ||
                                               (con.lastName==objServiceDataImport.Last_Name__c && 
                                                ((objServiceDataImport.Email__c !=null && (con.Email==objServiceDataImport.Email__c || con.Email2__c !=null || con.Email3__c !=null)) ||  
                                                 (objServiceDataImport.Mobile_Number__c !=null && (objServiceDataImport.Mobile_Number__c==con.Phone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.Phone || objServiceDataImport.Mobile_Number__c==con.MobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.MobilePhone || objServiceDataImport.Mobile_Number__c==con.HomePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.HomePhone || objServiceDataImport.Mobile_Number__c==con.MobilePhone || objServiceDataImport.Mobile_Number__c==countryDialCode+con.MobilePhone)) ||
                                                 (objServiceDataImport.Home_Phone__c !=null && (objServiceDataImport.Home_Phone__c==con.Phone || objServiceDataImport.Home_Phone__c==countryDialCode+con.Phone || objServiceDataImport.Home_Phone__c==con.MobilePhone || objServiceDataImport.Home_Phone__c==countryDialCode+con.MobilePhone || objServiceDataImport.Home_Phone__c==con.HomePhone || objServiceDataImport.Home_Phone__c==countryDialCode+con.HomePhone || objServiceDataImport.Home_Phone__c== con.MobilePhone||  objServiceDataImport.Home_Phone__c==countryDialCode+con.MobilePhone)) || 
                                                 (objServiceDataImport.Business_Phone__c !=null && (objServiceDataImport.Business_Phone__c==con.Phone || objServiceDataImport.Business_Phone__c==countryDialCode+con.Phone || objServiceDataImport.Business_Phone__c==con.MobilePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+con.MobilePhone || objServiceDataImport.Business_Phone__c==con.HomePhone|| objServiceDataImport.Business_Phone__c==countryDialCode+con.HomePhone || objServiceDataImport.Business_Phone__c== con.MobilePhone ||  objServiceDataImport.Business_Phone__c==countryDialCode+con.MobilePhone)))))
                                            {
                                                serviceDataObject.Service_Customer_Contact__c= con.Id; 
                                                contactForUpsert=con;
                                                contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                                contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                                if(objServiceDataImport.Email__c!=null && con.Email !=objServiceDataImport.Email__c)
                                                {
                                                    if(con.Email2__c==null)
                                                        con.Email2__c=con.Email;
                                                    else if(con.Email3__c==null)
                                                        con.Email3__c=con.Email;
                                                    else{
                                                        historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Email:'+con.Email : 'Email:'+con.Email;
                                                        //con.Historical_Contact__c= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Email:'+con.Email : con.Email;
                                                        //con.Historical_Contact__c+='\n Removed On:'+system.today();
                                                    }
                                                    con.Email=objServiceDataImport.Email__c;
                                                }
                                                if(objServiceDataImport.Mobile_Number__c !=null && con.MobilePhone !=objServiceDataImport.Mobile_Number__c)
                                                {
                                                    if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                                    {
                                                        if(string.isNotBlank(historicalString) && historicalString!=null)
                                                        {
                                                            historicalString= historicalString+'\n Phone:'+con.MobilePhone;
                                                        }else{
                                                            historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Phone:'+con.MobilePhone : 'Phone:'+con.MobilePhone;
                                                        }
                                                        //con.Historical_Contact__c= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Phone:'+con.MobilePhone : con.MobilePhone;
                                                        //con.Historical_Contact__c+='\n Removed On:'+system.today(); 
                                                        con.MobilePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Mobile_Number__c;  
                                                    }
                                                }
                                                
                                                if(objServiceDataImport.Home_Phone__c !=null && con.HomePhone !=objServiceDataImport.Home_Phone__c)
                                                {
                                                    if(countryDialCodeMap.containsKey(objServiceDataImport.CountryISO_Code__c))
                                                    {
                                                        if(string.isNotBlank(historicalString) && historicalString!=null)
                                                        {
                                                            historicalString= historicalString+'\n Home Phone:'+con.HomePhone;
                                                        }else{
                                                            historicalString= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Home Phone:'+con.HomePhone : 'Home Phone:'+con.HomePhone;
                                                        }
                                                        //con.Historical_Contact__c= con.Historical_Contact__c !=null ? con.Historical_Contact__c+'\n Home Phone:'+con.HomePhone : con.HomePhone;
                                                        //con.Historical_Contact__c+='\n Removed On:'+system.today(); 
                                                        con.HomePhone= countryDialCodeMap.get(objServiceDataImport.CountryISO_Code__c)+objServiceDataImport.Home_Phone__c;
                                                    }
                                                }
                                                
                                                if(string.isNotBlank(historicalString))
                                                {
                                                    historicalString+='\n Removed On:'+system.today().format(); 
                                                    con.Historical_Contact__c=historicalString;
                                                }
                                                contactLstForUpdate.put(con.Id, con);
                                                uniqueKeyContactUpdateMap.put(objServiceDataImport.Unique_Key__c,contactUpdateCount);
                                                contactUpdateCount++;
                                                break;
                                            }
                                        }
                                        
                                        if(serviceDataObject.Service_Customer_Contact__c==null )
                                        {
                                            if(objServiceDataImport.Last_Name__c !=null)
                                            {
                                                contactForUpsert.AccountId=customerAcc.Id;
                                                contactForUpsert.RecordTypeId= RetailerConRecId;
                                                contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                                contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                                contactForUpsert.Email=objServiceDataImport.Email__c;
                                                contactForUpsert.Phone=objServiceDataImport.Business_Phone__c;
                                                contactForUpsert.MobilePhone=objServiceDataImport.Mobile_Number__c;
                                                contactForUpsert.HomePhone=objServiceDataImport.Home_Phone__c;
                                                //contactForUpsert.DMS_Identifier__c=objServiceDataImport.Dms_Id__c;
                                                contactForUpsert.Title=objServiceDataImport.Title__c;
                                                contactForUpsert.OtherPhone=objServiceDataImport.Home_Phone__c;
                                                //contactForUpsert.aop_Country__c=objServiceDataImport.Country__c;
                                                contactForUpsert.Country_ISO_Code__c=objServiceDataImport.CountryISO_Code__c;
                                                contactLstForinsert.add(contactForUpsert);
                                                uniqueKeyContactInsertMap.put(objServiceDataImport.Unique_Key__c,contactInsertCount);
                                                contactInsertCount++;
                                            }else{
                                                objServiceDataImport.Status__c='Failed';
                                                objServiceDataImport.Error_Message__c='Data provided is not sufficient to create/update records.';
                                                for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                                {
                                                    errRec.Status__c='Failed';
                                                    errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                                                }
                                            }
                                        }
                                    }else if(!customerAcc.IspersonAccount){
                                        if(objServiceDataImport.Last_Name__c !=null)
                                        {
                                            contactForUpsert= new contact();
                                            contactForUpsert.AccountId=customerAcc.Id;
                                            contactForUpsert.RecordTypeId= RetailerConRecId;
                                            contactForUpsert.FirstName=objServiceDataImport.First_Name__c;
                                            contactForUpsert.LastName=objServiceDataImport.Last_Name__c;
                                            contactForUpsert.Email=objServiceDataImport.Email__c;
                                            contactForUpsert.Phone=objServiceDataImport.Business_Phone__c;
                                            contactForUpsert.MobilePhone=objServiceDataImport.Mobile_Number__c;
                                            contactForUpsert.HomePhone=objServiceDataImport.Home_Phone__c;
                                            //contactForUpsert.DMS_Identifier__c=objServiceDataImport.Dms_Id__c;
                                            contactForUpsert.Title=objServiceDataImport.Title__c;
                                            contactForUpsert.OtherPhone=objServiceDataImport.Home_Phone__c;
                                            //contactForUpsert.aop_Country__c=objServiceDataImport.Country__c;
                                            contactForUpsert.Country_ISO_Code__c=objServiceDataImport.CountryISO_Code__c;
                                            contactLstForinsert.add(contactForUpsert);
                                            uniqueKeyContactInsertMap.put(objServiceDataImport.Unique_Key__c,contactInsertCount);
                                            contactInsertCount++;
                                        }else{
                                            objServiceDataImport.Status__c='Failed';
                                            objServiceDataImport.Error_Message__c='Data provided is not sufficient to create/update records.';
                                            for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                            {
                                                errRec.Status__c='Failed';
                                                errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                                            }
                                        }
                                    }else{
                                        objServiceDataImport.Status__c='Failed';
                                        objServiceDataImport.Error_Message__c='Matched with invalid combination of account/contact.';
                                        for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(objServiceDataImport.Unique_Key__c))
                                        {
                                            errRec.Status__c='Failed';
                                            errRec.Error_Message__c='Matched with invalid combination of account/contact.';
                                        }
                                    }
                                    if(serviceDataObject.Service_Customer_Account__c !=null)
                                        break; 
                                }
                            }
                        }
                        SDRecForInsertMap.put(objServiceDataImport.Unique_Key__c,serviceDataObject);
                    }
                }
            }
            
        }
        
        Service_Data_Import__c SDI = New Service_Data_Import__c();
        for(string Key:SDRecForInsertMap.keySet())
        {
            Service_Data__c SD= SDRecForInsertMap.get(Key);
            if(SD.Service_Customer_Account__c==null || SD.Service_Customer_Contact__c==null)
            {
                SDI=SDIRecForMatchingMap.get(Key);
                if(SD.Service_Customer_Account__c==null)
                {
                    accountForUpsert= new account();
                    if(SDI.CorporateAccIndicator__c || (SDI.Company_Name__c!=null && SDI.Last_Name__c==null) || (SDI.Company_Name__c!=null && SDI.Company_Name__c.contains(SDI.Last_Name__c) ))
                    {
                        if(SDI.Last_Name__c!=null && string.isNotBlank(SDI.Last_Name__c))
                        {
                            accountForUpsert= new Account();
                            accountForUpsert.RecordTypeId=corporateAccRecId;
                            accountForUpsert.Name=SDI.Company_Name__c;
                            accountForUpsert.Retailer_Email__c=SDI.Email__c;
                            accountForUpsert.BillingCity=SDI.City__c;
                            accountForUpsert.BillingState=SDI.State__c;
                            accountForUpsert.BillingCountry=SDI.Country__c;
                            accountForUpsert.Country_ISO_Code__c=SDI.CountryISO_Code__c;
                            accountForUpsert.BillingPostalCode=SDI.Post_Code__c;
                            //accountForUpsert.DMS_Identifier__c=SDI.DMS_Invoice_Ref_ID__c;
                            
                            if(!secAccountOwnerMap.isEmpty())
                            {
                                if(SDI.CountryISO_Code__c !='LB' && SDI.CountryISO_Code__c !='KW' )
                                {
                                    accountForUpsert.OwnerId=secAccountOwnerMap.get(SDI.CountryISO_Code__c).Id; 
                                    accountForUpsert.Owner_Retailer__c=secAccountOwnerMap.get(SDI.CountryISO_Code__c).AccountId;
                                }else{
                                    accountForUpsert.OwnerId=secAccountOwnerMap.get(SDI.CountryISO_Code__c+'#'+SDI.Brand__c).Id; 
                                    accountForUpsert.Owner_Retailer__c=secAccountOwnerMap.get(SDI.CountryISO_Code__c+'#'+SDI.Brand__c).AccountId;
                                }
                            }
                            accountLstForinsert.add(accountForUpsert);
                            uniqueKeyAccountInsertMap.put(SDI.Unique_Key__c,accountInsertCount);
                            accountInsertCount++;
                            
                            contactForUpsert= new Contact();
                            contactForUpsert.LastName=SDI.Last_Name__c;
                            contactForUpsert.FirstName=SDI.First_Name__c;
                            contactForUpsert.Email=SDI.Email__c;
                            //contactForUpsert.DMS_Identifier__c=SDI.Database_Reference_ID__c;
                            contactForUpsert.Title=SDI.Title__c;
                            contactForUpsert.MobilePhone=SDI.Mobile_Number__c;
                            contactForUpsert.HomePhone=SDI.Home_Phone__c;
                            contactForUpsert.OtherPhone=SDI.Business_Phone__c;
                            contactForUpsert.Country_ISO_Code__c=SDI.CountryISO_Code__c;
                            //contactForUpsert.aop_Country__c=SDI.Country__c;
                            contactForUpsert.MailingCountry=SDI.Country__c;
                            contactForUpsert.MailingCity=SDI.City__c;
                            contactForUpsert.MailingState=SDI.State__c;
                            contactForUpsert.MailingPostalCode=SDI.Post_Code__c;
                            contactForUpsert.RecordTypeId= RetailerConRecId;
                            contactLstForinsert.add(contactForUpsert);
                            uniqueKeyContactInsertMap.put(SDI.Unique_Key__c,contactInsertCount);
                            contactInsertCount++;
                        }else{
                            SDI.Status__c='Failed';
                            SDI.Error_Message__c='Data provided is not sufficient to create/update records.';
                            for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(SDI.Unique_Key__c))
                            {
                                errRec.Status__c='Failed';
                                errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                            }
                        }
                    }else if(SDI.Last_Name__c!=null && string.isNotBlank(SDI.Last_Name__c))
                    {
                        accountForUpsert= new Account();
                        accountForUpsert.RecordTypeId=IndividualAccRecId;
                        accountForUpsert.LastName=SDI.Last_Name__c;
                        accountForUpsert.FirstName=SDI.First_Name__c;
                        accountForUpsert.PersonTitle=SDI.Title__c;
                        accountForUpsert.PersonMobilePhone=SDI.Mobile_Number__c;
                        accountForUpsert.PersonHomePhone=SDI.Home_Phone__c;
                        accountForUpsert.PersonOtherPhone=SDI.Business_Phone__c;
                        accountForUpsert.PersonMailingStreet=SDI.Address1__c;
                        accountForUpsert.PersonMailingCity=SDI.Address2__c;
                        accountForUpsert.Additional_Notes__pc=SDI.City__c;
                        accountForUpsert.PersonMailingState=SDI.State__c;
                        accountForUpsert.PersonMailingCountry=SDI.Country__c;
                        accountForUpsert.PersonMailingPostalCode=SDI.Post_Code__c;
                        accountForUpsert.PersonEmail=SDI.Email__c;
                        //accountForUpsert.aop_Country__pc=SDI.Country__c;
                        accountForUpsert.Country_ISO_Code__pc=SDI.CountryISO_Code__c;
                        accountForUpsert.Country_ISO_Code__c=SDI.CountryISO_Code__c;
                        if(SDI.CountryISO_Code__c !='LB' && SDI.CountryISO_Code__c !='KW' )
                        {
                            accountForUpsert.OwnerId=secAccountOwnerMap.get(SDI.CountryISO_Code__c).Id; 
                            accountForUpsert.Owner_Retailer__c=secAccountOwnerMap.get(SDI.CountryISO_Code__c).AccountId;
                        }else{
                            accountForUpsert.OwnerId=secAccountOwnerMap.get(SDI.CountryISO_Code__c+'#'+SDI.Brand__c).Id; 
                            accountForUpsert.Owner_Retailer__c=secAccountOwnerMap.get(SDI.CountryISO_Code__c+'#'+SDI.Brand__c).AccountId;
                        }
                        accountLstForinsert.add(accountForUpsert);
                        uniqueKeyAccountInsertMap.put(SDI.Unique_Key__c,accountInsertCount);
                        accountInsertCount++;
                    }else{
                        SDI.Status__c='Failed';
                        SDI.Error_Message__c='Data provided is not sufficient to create/update records.';
                        for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(SDI.Unique_Key__c))
                        {
                            errRec.Status__c='Failed';
                            errRec.Error_Message__c='Data provided is not sufficient to create/update records.';
                        }
                    }
                }
            }
            SDRecForInsertMap.put(Key,SD);
        }
        
        Map<string,Id> uniqueIdAccIdMap= new map<string,Id>();
        string errorString='';
        if(!accountLstForinsert.isEmpty())
        {
            Database.SaveResult[] lsr = Database.insert(accountLstForinsert,false);
            
            for(string key:uniqueKeyAccountInsertMap.keySet())
            {
                if (lsr[uniqueKeyAccountInsertMap.get(key)].isSuccess()) {
                    uniqueIdAccIdMap.put(key,lsr[uniqueKeyAccountInsertMap.get(key)].getId());
                }else{
                    errorString='';
                    for(Database.Error err : lsr[uniqueKeyAccountInsertMap.get(key)].getErrors()) {
                        errorString= errorString==''? err.getStatusCode() + ': ' + err.getMessage(): errorString+'\n '+ err.getStatusCode() + ': ' + err.getMessage();
                    }
                    SDI=SDIRecForMatchingMap.get(key);
                    SDI.Status__c='Failed';
                    SDI.Error_Message__c=errorString;
                    SDIRecForMatchingMap.put(key,SDI);
                    
                    for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(SDI.Unique_Key__c))
                    {
                        errRec.Status__c='Failed';
                        errRec.Error_Message__c=errorString;
                    }
                    
                }
            }
            
        }
        
        Map<string,Id> uniqueIdConIdMap= new map<string,Id>(); 
        if(!contactLstForinsert.isEmpty())
        {
            for(string key:uniqueKeyContactInsertMap.keySet())
            {
                if(contactLstForinsert[uniqueKeyContactInsertMap.get(key)].accountId==null)
                {
                    if(uniqueIdAccIdMap.containsKey(key))
                    {
                        contactLstForinsert[uniqueKeyContactInsertMap.get(key)].accountId=uniqueIdAccIdMap.get(key);
                    }else if(SDIRecForMatchingMap.get(key).Status__c !='Failed'){
                        SDI=SDIRecForMatchingMap.get(key);
                        SDI.Status__c='Failed';
                        SDI.Error_Message__c= SDI.Error_Message__c !=null ? SDI.Error_Message__c+ '\n Unable to create related account.':SDI.Error_Message__c;
                        SDIRecForMatchingMap.put(key,SDI);
                        
                        for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(SDI.Unique_Key__c))
                        {
                            errRec.Status__c='Failed';
                            errRec.Error_Message__c= errRec.Error_Message__c !=null ? errRec.Error_Message__c+ '\n Unable to create related account.':errRec.Error_Message__c;
                        }
                    }
                }
            }
            
            
            Database.SaveResult[] lsr = Database.insert(contactLstForinsert,false);
            
            for(string key:uniqueKeyContactInsertMap.keySet())
            {
                if (lsr[uniqueKeyContactInsertMap.get(key)].isSuccess()) {
                    uniqueIdConIdMap.put(key,lsr[uniqueKeyContactInsertMap.get(key)].getId());
                }else{
                    errorString='';
                    for(Database.Error err : lsr[uniqueKeyContactInsertMap.get(key)].getErrors()) {
                        errorString= errorString==''? err.getStatusCode() + ': ' + err.getMessage(): errorString+'\n '+ err.getStatusCode() + ': ' + err.getMessage();
                    }
                    SDI=SDIRecForMatchingMap.get(key);
                    SDI.Status__c='Failed';
                    SDI.Error_Message__c=SDI.Error_Message__c !=null? SDI.Error_Message__c+'\n'+errorString:errorString;
                    SDIRecForMatchingMap.put(key,SDI);
                    
                    for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(SDI.Unique_Key__c))
                    {
                        errRec.Status__c='Failed';
                        errRec.Error_Message__c= errRec.Error_Message__c !=null ? errRec.Error_Message__c+'\n'+errorString:errorString;
                    }
                }
            }
        }
        
        service_Data__c SD= new service_Data__c();
        for(string key:SDRecForInsertMap.keySet())
        {
            SD=SDRecForInsertMap.get(key);
            if(SD.Service_Customer_Account__c==null && uniqueIdAccIdMap.containsKey(Key))
            {
                SD.Service_Customer_Account__c=uniqueIdAccIdMap.get(key);
            }
            
            if(SD.Service_Customer_Contact__c==null && uniqueIdConIdMap.containsKey(Key))
            {
                SD.Service_Customer_Contact__c=uniqueIdConIdMap.get(key);
            }
            SDRecForInsertMap.put(key,SD);
        }
        
        List<Service_Data_Item__c> SDIForInsertLst = New list<Service_Data_Item__c>();
        if(!SDRecForInsertMap.isEmpty())
        {
           insert SDRecForInsertMap.values();

           /*Database.SaveResult[] lsr = Database.insert(SDRecForInsertMap.values(),false);
           list<string> uniqKeySetLst=   New List<string>();
            uniqKeySetLst.addAll(SDRecForInsertMap.keySet()); 
            for(integer counterI =0; counterI < lsr.Size() ; counterI++ )
            {
                if (!lsr[counterI].isSuccess()) {
                    errorString='';
                    for(Database.Error err : lsr[counterI].getErrors()) {
                        errorString= errorString==''? err.getStatusCode() + ': ' + err.getMessage(): errorString+'\n '+ err.getStatusCode() + ': ' + err.getMessage();
                    }
                    system.debug('counterI '+counterI);
                    system.debug('SDRecForInsertMap.values() '+uniqKeySetLst);
                    string uniqueKeyId=uniqKeySetLst[counterI];
                    system.debug('uniqueKeyId @@'+uniqueKeyId);
                    SDI=SDIRecForMatchingMap.get(uniqueKeyId);
                    SDI.Status__c='Failed';
                    SDI.Error_Message__c=SDI.Error_Message__c !=null? SDI.Error_Message__c+'\n'+errorString:errorString;
                    SDIRecForMatchingMap.put(uniqueKeyId,SDI);
                    
                    for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(uniqueKeyId))
                    {
                        errRec.Status__c='Failed';
                        errRec.Error_Message__c= errRec.Error_Message__c !=null ? errRec.Error_Message__c+'\n'+errorString:errorString;
                    }
                    //SDRecForInsertMap.remove(uniqueKeyId);
                    
                }
            }*/
            // 
        } 
        
        system.debug('sdiUniqueKeyMap'+sdiUniqueKeyMap);
            //for(string key:SDRecForInsertMap.keyset())
            //{
                //SD=SDRecForInsertMap.get(key);
                //SDI=SDIRecForMatchingMap.get(key);
               Set<String> existingDMSIDInLocal = new Set<string>();
                for(string key:sdiUniqueKeyMap.keyset())
                {
                    for(Service_Data_Import__c SDIs:sdiUniqueKeyMap.get(key))
                    {
                        system.debug('SDIs 1'+SDIs);
                       if(SDRecForInsertMap.containskey(key))
                           SD=SDRecForInsertMap.get(key);
                        else if(existingSDMap.containsKey(key))
                            SD=existingSDMap.get(key);
                        else
                            break;
                        system.debug('SDIs'+SDIs);
                        system.debug('existingSDISDIdMap'+existingSDISDIdMap);
                        if( !existingDMSIDInLocal.contains(SDIs.DMS_Invoice_Ref_ID__c) && (SDIs.Status__c !='Failed' || Sdis.Error_Message__c=='Data provided is not sufficient to create/update records.') && (!existingSDISDIdMap.containsKey(SDIs.DMS_Invoice_Ref_ID__c) ||(existingSDISDIdMap.containsKey(SDIs.DMS_Invoice_Ref_ID__c) && existingSDISDIdMap.get(SDIs.DMS_Invoice_Ref_ID__c) !=SD.Id) ))
                        {
                        Service_Data_Item__c SDItem= new Service_Data_Item__c();
                        SDItem.DM_Invoice_Reference_ID__c=SDIs.DMS_Invoice_Ref_ID__c;
                        SDItem.Service_Type__c=SDIs.SR_Type__c;
                        SDItem.Description__c=SDIs.Description__c;
                        SDItem.Remarks__c=SDIs.Remarks__c;
                        SDItem.Price_Total__c=SDIs.Price_Invoice__c;
                        SDItem.Price_Parts__c=SDIs.Price_Parts__c;
                        SDItem.Price_Labour__c=SDIs.PriceLabour__c;
                        SDItem.Hours_Sold__c=SDIs.Hours_Sold__c;
                        SDItem.ServiceData__c=SD.Id;
                        SDItem.CurrencyIsoCode=SDIs.CurrencyIsoCode;
                        SDItem.Unique_Repair_Order_Number__c=SDIs.Repair_Order_Number__c;
                        SDIForInsertLst.add(SDItem);
                        existingDMSIDInLocal.add(SDIs.DMS_Invoice_Ref_ID__c);
                    }
                }
            }
            //}
            
            if(!SDIForInsertLst.isEmpty())
                insert SDIForInsertLst;
            
        //if(!accountLstForUpdate.isEmpty())
            //update accountLstForUpdate.values();
            
            
        if(!accountLstForUpdate.isEmpty())
        {
            Database.SaveResult[] lsr = Database.update(accountLstForUpdate.values(),false);
            
            for(string key:uniqueKeyAccountUpdateMap.keySet())
            {
                if(!lsr[uniqueKeyAccountUpdateMap.get(key)].isSuccess())
                {
                    errorString='';
                    for(Database.Error err : lsr[uniqueKeyAccountUpdateMap.get(key)].getErrors()) {
                        errorString= errorString==''? err.getStatusCode() + ': ' + err.getMessage(): errorString+'\n '+ err.getStatusCode() + ': ' + err.getMessage();
                    }
                    SDI=SDIRecForMatchingMap.get(key);
                    SDI.Status__c='Failed';
                    SDI.Error_Message__c='Account Update failed '+errorString;
                    SDIRecForMatchingMap.put(key,SDI);
                    
                    for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(SDI.Unique_Key__c))
                    {
                        errRec.Status__c='Failed';
                        errRec.Error_Message__c='Account Update failed '+errorString;
                    }
                    
                }
            }
        }
        
        //if(!contactLstForUpdate.isEmpty())
            //update contactLstForUpdate.values();
        
        if(!contactLstForUpdate.isEmpty())
        {

            Database.SaveResult[] lsr = Database.update(contactLstForUpdate.values(),false);
            
            for(string key:uniqueKeyContactUpdateMap.keySet())
            {
                if (!lsr[uniqueKeyContactUpdateMap.get(key)].isSuccess()) {
                    uniqueIdConIdMap.put(key,lsr[uniqueKeyContactUpdateMap.get(key)].getId());
                
                    errorString='';
                    for(Database.Error err : lsr[uniqueKeyContactUpdateMap.get(key)].getErrors()) {
                        errorString= errorString==''? err.getStatusCode() + ': ' + err.getMessage(): errorString+'\n '+ err.getStatusCode() + ': ' + err.getMessage();
                    }
                    SDI=SDIRecForMatchingMap.get(key);
                    SDI.Status__c='Failed';
                    SDI.Error_Message__c=SDI.Error_Message__c !=null? SDI.Error_Message__c+'\n Contact Update Failed'+errorString:'Contact Update Failed'+errorString;
                    SDIRecForMatchingMap.put(key,SDI);
                    
                    for(Service_Data_Import__c errRec: sdiUniqueKeyMap.get(SDI.Unique_Key__c))
                    {
                        errRec.Status__c='Failed';
                        errRec.Error_Message__c= errRec.Error_Message__c !=null ? errRec.Error_Message__c+'\n Contact Update Failed'+errorString: 'Contact Update Failed'+errorString;
                    }
                }
            }
        }
        
        list<Service_Data_Import__c> serviceDataImpForUpdate = new List<Service_Data_Import__c>();
        for(string key: sdiUniqueKeyMap.keyset())
        {
            serviceDataImpForUpdate.addAll(sdiUniqueKeyMap.get(key));
        }
        
        update serviceDataImpForUpdate;
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        list<Service_Data_Import__c> SDIRemaingLst=  [select Id,Status__c,Error_Message__c from Service_Data_Import__c where Status__c='Unprocessed'];
        if(!SDIRemaingLst.isEmpty() && !IsRerun)
        {
            Batch_ServiceDataImporter batch= new Batch_ServiceDataImporter(Label.IMS_BATCH_MENA_MARKET,True);
        	database.executeBatch(batch, 1);
        }else if(!SDIRemaingLst.isEmpty())
        {
            for(Service_Data_Import__c SDI :SDIRemaingLst)
            {
                SDI.Status__c='Failed';
                SDI.Error_Message__c='Failed due to update to invalid value mapping on Service data/ Asset existing data. Please check Asset field filters. ';
            }
            
            Update SDIRemaingLst;
        }
    }
    
    private void initBatch()
    {
        Map<String, Schema.SObjectField> schemaFieldMap1 = Schema.SObjectType.Service_Data_Import__c.fields.getMap();
        for (String fieldName: schemaFieldMap1.keySet()) {
            SDIFieldsLst.add(fieldName);
        } 
        
        Map<String, Schema.SObjectField> schemaFieldMap2 = Schema.SObjectType.Service_Data__c.fields.getMap();
        for (String fieldName: schemaFieldMap2.keySet()) {
            if(schemaFieldMap2.get(fieldName).getDescribe().isUpdateable())
                SDFieldsLst.add(fieldName);
        }
        
        List<Dispensable_Value__mdt	> invalidEmailSettingLst = [select Id, MasterLabel, Is_Full_Text__c from Dispensable_Value__mdt where Category__c='Email'];
        for(Dispensable_Value__mdt emails: invalidEmailSettingLst)
        {
            InvalidEmailAddLst.add(emails.MasterLabel);
        }
        
        for(aop_NationalityToISOCode__c IsoCodeRec: aop_NationalityToISOCode__c.getAll().values())
        {
            countryDialCodeMap.put(IsoCodeRec.aop_ISO_Code__c, IsoCodeRec.Dialing_Code__c);
        }
        
        for(user u:database.query(ownerQstring))
        {
            if(u.Account.country_ISO_Code__c !='LB' && u.Account.country_ISO_Code__c!='KW')
                secAccountOwnerMap.put(u.Account.country_ISO_Code__c, u);
            else
                secAccountOwnerMap.put(u.Account.country_ISO_Code__c+'#'+u.Account.Brand__c, u);  
        } 
    } 
}