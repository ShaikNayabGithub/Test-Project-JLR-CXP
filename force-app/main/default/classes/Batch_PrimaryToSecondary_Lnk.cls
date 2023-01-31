/*
Name : Batch_PrimaryToSecondary_Lnk.apxc

Author: Suhan Jain - NTT Data

Purpose: Update the primary accounts into seconday and create new Primary account. 

Created Date : 04/11/2020
*/
global class Batch_PrimaryToSecondary_Lnk  implements Database.Batchable<sObject>, database.Stateful {
    Id individualPrmyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    Id CorporatePrmyId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    
    Id RetailerRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();
    Id JlRRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('JLR Contact').getRecordTypeId();
    List<string> IsoCountryCodeLst= label.BATCH_COUNTRY_FOR_ACCOUNT_MERGE.split(';');    
    List<string> accFieldLst= new List<String>();
    List<string> prsnAccFieldLst= new List<String>();
    List<string> conFieldLst= new List<String>();
    Map<string,User> secAccountOwnerMap= New Map<String,User>();
    
    string Qstring ='Select Id, recordTypeId, isPersonAccount, (SELECT id from Retailer_Accounts__r limit 1 ) '+
        'From Account where (is_Primary__c=true OR recordTypeId=:individualPrmyId OR recordTypeId=:CorporatePrmyId) '+
        'AND (Preferred_Sales_Retailer__r.Country_ISO_Code__c IN:IsoCountryCodeLst OR owner.Market__c=\'MENA\' OR Country_ISO_Code__c IN:IsoCountryCodeLst) ';
    
    string ownerQstring='select id, market__c, AccountId, Account.Brand__c, Account.country_ISO_Code__c from user where name like \'dummyimp%\' AND Account.Brand__c !=\'Branded\' AND isactive=true';
    Id primaryAccountOwnerId='0051o00000AZeY5';
    boolean ischeckOnly =False;
    public string header = 'Record Id, isPersonAccount, Preffered Country ISO Code, Country ISO Code, Owner Market, Has Asset, Review Required \n';
    public string finalstr = header ;
    
    public Batch_PrimaryToSecondary_Lnk(string Qstring, string ownerQstring, Id primaryAccountOwnerId, boolean ischeckOnly){
        if(Qstring!=null && string.isNotEmpty(Qstring)){
            this.Qstring=Qstring; 
        }
        
        if(ownerQstring!=null && string.isNotEmpty(ownerQstring)){
            this.ownerQstring=ownerQstring; 
        }
        if(primaryAccountOwnerId!=null && string.isNotEmpty(primaryAccountOwnerId)){
            this.primaryAccountOwnerId=primaryAccountOwnerId; 
        }
        this.ischeckOnly=ischeckOnly;
        if(!ischeckOnly)
            initBatch();
    }
    
    public Batch_PrimaryToSecondary_Lnk(){
        initBatch();
    }
    
    private void initBatch(){
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Account.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
            prsnAccFieldLst.add(fieldName);
            if(!fieldName.endsWithIgnoreCase('__pc'))
                accFieldLst.add(fieldName);
        } 
        
        Map<String, Schema.SObjectField> schemaFieldConMap = Schema.SObjectType.Contact.fields.getMap();
        for (String fieldName: schemaFieldConMap.keySet()) {
            conFieldLst.add(fieldName);
        } 
        
        for(user u:database.query(ownerQstring))
        {
            if(u.Account.country_ISO_Code__c !='LB' && u.Account.country_ISO_Code__c!='KW')
                secAccountOwnerMap.put(u.Account.country_ISO_Code__c, u);
            else
                secAccountOwnerMap.put(u.Account.country_ISO_Code__c+'#'+u.Account.Brand__c, u);  
        } 
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Qstring);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountLst) {
        
        if(ischeckOnly)
        {
            for(Account acc:  accountLst)
            {
                if(acc.Retailer_Accounts__r.size() ==0)
                {
                    string hasAsset =acc.Assets.size() ==1 ?'True':'False';
                    string recordString = '"'+acc.id+'","'+acc.isPersonAccount+'","'+acc.Preferred_Sales_Retailer__r.Country_ISO_Code__c+'","'+acc.Country_ISO_Code__c+'","'+acc.owner.Market__c+'","'+hasAsset+'","'+acc.Review_Required__c+'" \n';
                    
                    finalstr = finalstr +recordString;
                }
            }            
        }else{
            set<Id> primaryIndvAcc= New set<Id>();
            set<Id> primaryCorpAcc= New set<Id>();
            list<account> accountForUpdate =new List<Account>();
            
            list<account> IndAccountForUpdate =new List<Account>();
            list<account> corpAccountForUpdate =new List<Account>();
            
            list<account> IndAccountForInsert =new List<Account>();
            list<account> corpAccountForInsert =new List<Account>();
            boolean isLandRover=false;
            boolean isJaguar=false;
            
            list<Contact> contactForUpdate =new List<Contact>();
            list<Contact> contactForInsert =new List<Contact>();
            
            for(account acc:accountLst)
            {
                if(acc.Retailer_Accounts__r.size()==0){
                    if(acc.IsPersonAccount)
                        primaryIndvAcc.add(acc.id);
                    else
                        primaryCorpAcc.add(acc.id);
                }
            }
            
            
            if(!primaryCorpAcc.isEmpty())
            {
                for(Account acc:database.query('select '+string.join(accFieldLst, ', ')+' , Preferred_Sales_Retailer__r.Country_ISO_Code__c, (select Id, Brand__r.Name from Assets where Brand__c !=null AND (Account.Preferred_Sales_Retailer__r.Country_ISO_Code__c IN (\'KW\',\'LB\') OR Account.Country_ISO_Code__c IN (\'KW\',\'LB\') ) limit 200 ) From Account Where ID In:primaryCorpAcc'))
                {
                    string countryIsoCode= acc.Preferred_Sales_Retailer__c !=null && acc.Preferred_Sales_Retailer__r.Country_ISO_Code__c !=null ?acc.Preferred_Sales_Retailer__r.Country_ISO_Code__c:acc.Country_ISO_Code__c;
                    if(countryIsoCode!=null && string.isNotBlank(countryIsoCode) && IsoCountryCodeLst.contains(countryIsoCode))
                    {
                        if(countryIsoCode !='LB' && countryIsoCode !='KW')
                        {
                            if(secAccountOwnerMap.containsKey(countryIsoCode))
                            {
                                corpAccountForInsert.add(initPrimaryAccount(acc));
                                corpAccountForUpdate.add(initSecondaryCorpAccount(acc,countryIsoCode));
                            }else{
                                accountForUpdate.add(new account(id=acc.Id,Review_Required__c=true)); 
                            }
                        }else if(acc.assets.size()>0){
                            isLandRover=false;
                            isJaguar=false;
                            
                            for(asset singleAsset:acc.assets){
                                if(singleAsset.Brand__r.Name=='Land Rover')
                                    isLandRover=true;
                                else if(singleAsset.Brand__r.Name=='Jaguar')
                                    isJaguar=true;
                            }
                            
                            if	( (isLandRover || isJaguar) && !(isLandRover && isJaguar))
                            {
                                string brandname=isLandRover ? 'Land Rover':'Jaguar';
                                if(secAccountOwnerMap.containsKey(countryIsoCode+'#'+brandname))
                                {
                                    corpAccountForInsert.add(initPrimaryAccount(acc));
                                    corpAccountForUpdate.add(initSecondaryCorpAccount(acc,countryIsoCode+'#'+brandname));
                                }
                            }
                            
                        }
                    }
                    else{
                        accountForUpdate.add(new account(id=acc.Id,Review_Required__c=true)); 
                    }
                }
            }
            
            if(!primaryIndvAcc.isEmpty())
            {
                for(Account prsnAcc:database.query('select '+string.join(prsnAccFieldLst, ', ')+' ,Preferred_Sales_Retailer__r.Country_ISO_Code__c, (select Id, Brand__r.Name from Assets where Brand__c !=null AND (Account.Preferred_Sales_Retailer__r.Country_ISO_Code__c IN (\'KW\',\'LB\') OR Account.Country_ISO_Code__c IN (\'KW\',\'LB\') ) limit 200 ) From Account Where ID In:primaryIndvAcc'))
                {
                    string countryIsoCode=prsnAcc.Preferred_Sales_Retailer__c !=null && prsnAcc.Preferred_Sales_Retailer__r.Country_ISO_Code__c !=null ?prsnAcc.Preferred_Sales_Retailer__r.Country_ISO_Code__c:prsnAcc.Country_ISO_Code__c;
                    if(countryIsoCode!=null && string.isNotBlank(countryIsoCode) && IsoCountryCodeLst.contains(countryIsoCode))
                    {
                        if(countryIsoCode !='LB' && countryIsoCode !='KW')
                        {
                            if(secAccountOwnerMap.containsKey(countryIsoCode))
                            {
                                IndAccountForInsert.add(initPrimaryAccount(prsnAcc));
                                IndAccountForUpdate.add(initSecondaryIndvAccount(prsnAcc,countryIsoCode));	
                            }else{
                                accountForUpdate.add(new account(id=prsnAcc.Id,Review_Required__c=true)); 
                            }
                        }else if(prsnAcc.assets.size()>0){
                            isLandRover=false;
                            isJaguar=false;
                            
                            for(asset singleAsset:prsnAcc.assets){
                                if(singleAsset.Brand__r.Name=='Land Rover')
                                    isLandRover=true;
                                else if(singleAsset.Brand__r.Name=='Jaguar')
                                    isJaguar=true;
                            }
                            
                            if	( (isLandRover || isJaguar) && !(isLandRover && isJaguar))
                            {
                                string brandname=isLandRover ? 'Land Rover':'Jaguar';
                                if(secAccountOwnerMap.containsKey(countryIsoCode+'#'+brandname))
                                {
                                    IndAccountForInsert.add(initPrimaryAccount(prsnAcc));
                                    IndAccountForUpdate.add(initSecondaryIndvAccount(prsnAcc,countryIsoCode+'#'+brandname));
                                }
                            }
                            
                        }
                    }
                    else{
                        accountForUpdate.add(new account(id=prsnAcc.Id,Review_Required__c=true)); 
                    }
                }
            }
            
            Map<Id,Id> oldSecPrimaryAccMap= New map<Id,Id>();
            if(!corpAccountForInsert.isEmpty())
            {
                Insert corpAccountForInsert;
                system.debug('corpAccountForInsert'+corpAccountForInsert[0].id);
                for(integer i=0;i<corpAccountForUpdate.size();i++){
                    corpAccountForUpdate[i].Primary_Account__c=corpAccountForInsert[i].Id;
                    oldSecPrimaryAccMap.put(corpAccountForUpdate[i].Id,corpAccountForInsert[i].Id);
                }
                
                update corpAccountForUpdate;
                
                for(contact con:database.query('select '+string.join(conFieldLst, ', ')+' FROM Contact where accountId In:corpAccountForUpdate'))
                {
                    contact primaryContact=con.clone(false, true, false, false);
                    primaryContact.RecordTypeId= JlRRecId;
                    primaryContact.AccountId=oldSecPrimaryAccMap.get(con.AccountId);
                    contactForInsert.add(primaryContact);
                    
                    contact secondaryContact=new contact(Id=con.id, recordTypeId=RetailerRecId);
                    contactForUpdate.add(con);
                }
                
                if(!contactForInsert.isEmpty())
                {
                    Insert contactForInsert;
                    
                    for(integer i=0; i<contactForInsert.size();i++ ){
                        contactForUpdate[i].Primary_Contact__c =contactForInsert[i].Id;
                    }
                    
                    update contactForUpdate; 
                }
            }
            
            if(!IndAccountForInsert.isEmpty())
            {
                Insert IndAccountForInsert;
                for(integer i=0;i<IndAccountForUpdate.size();i++){
                    IndAccountForUpdate[i].Primary_Account__c=IndAccountForInsert[i].Id;
                }
                
                update IndAccountForUpdate;
            }
            
            
            if(!accountForUpdate.isEmpty())
                update accountForUpdate;
        }
        
    }
    
    private account initPrimaryAccount(account acc){
        account primaryAcc=acc.clone(false, true, false, false);
        primaryAcc.OwnerId=primaryAccountOwnerId;
        primaryAcc.Review_Required__c=false;
        return primaryAcc;
    }
    
    private account initSecondaryCorpAccount(account acc, string countryIsoCode){
        Account seconderyAccount= New Account();
        seconderyAccount.id=acc.Id;
        seconderyAccount.Is_Primary__c=false;
        seconderyAccount.OwnerId=secAccountOwnerMap.get(countryIsoCode).Id;
        seconderyAccount.Owner_Retailer__c=secAccountOwnerMap.get(countryIsoCode).AccountId;
        seconderyAccount.RecordTypeId=CorporateId;
        seconderyAccount.Primary_Account__c=null;
        seconderyAccount.Corporate_Code__c=null;
        seconderyAccount.DMS_Identifier__c=null;
        seconderyAccount.Local_Market_ID__c=null;
        seconderyAccount.Primary_Dealer_Code__c=null;
        seconderyAccount.Secondary_Dealer_Code__c=null;
        seconderyAccount.Review_Required__c=false;
        return seconderyAccount;
    }
    
    private account initSecondaryIndvAccount(account acc, string countryIsoCode){
        Account seconderyAccount= New Account();
        seconderyAccount.id=acc.Id;
        seconderyAccount.Is_Primary__c=false;
        seconderyAccount.Primary_Account__c=null;
        seconderyAccount.OwnerId=secAccountOwnerMap.get(countryIsoCode).Id;
        seconderyAccount.Owner_Retailer__c=secAccountOwnerMap.get(countryIsoCode).accountId;
        seconderyAccount.RecordTypeId=individualId;
        seconderyAccount.DMS_Identifier__pc=null;
        seconderyAccount.Review_Required__c=false;
        return seconderyAccount;
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
        if(ischeckOnly)
        {
        Document doc = new Document(); 
        doc.Name = 'All Failed MENA Accounts'+system.now(); 
        doc.Body = Blob.valueOf(finalstr); 
        doc.ContentType = 'application/vnd.ms-excel';
        doc.folderId=[select id from folder where Name='Admin Test Folder'].Id;
        doc.Type = 'csv';
        insert doc;
        }
    }
}