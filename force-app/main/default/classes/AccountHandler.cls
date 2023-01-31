public class AccountHandler {
    
    public static Boolean IgnoreTerritorySetter = false;
    public static Boolean IgnoreCaseValidation = false;
    public static Boolean doNotRun = false;
    
    private static final Map<String, Map<SObjectType, String>> fieldMapping = new Map<String, Map<SObjectType, String>>{
        Schema.Account.PersonFirstNameLocal.getDescribe().getName()=>new Map<SObjectType, String>{ 
            Schema.Task.SObjectType=>Schema.Task.First_Name_Local__c.getDescribe().getName(),
                Schema.Event.SObjectType=>Schema.Event.First_Name_Local__c.getDescribe().getName()},
                    Schema.Account.PersonLastNameLocal.getDescribe().getName()=>new Map<SObjectType, String>{ 
                        Schema.Task.SObjectType=>Schema.Task.Last_Name_Local__c.getDescribe().getName(),
                            Schema.Event.SObjectType=>Schema.Event.Last_Name_Local__c.getDescribe().getName()}};
                                
                                private static final Map<SObjectType, String> childRelationshipMap = new Map<SObjectType, String>{
                                    Schema.Task.SObjectType=>Schema.Task.WhoId.getDescribe().getName(),
                                        Schema.Event.SObjectType=>Schema.Event.WhoId.getDescribe().getName()};
                                            
                                            
                                            public void PreCreate(List<Account> accounts)
                                        {
                                            List<Account> accountstoBeCloned = new List<Account>();
                                            if (UserInfo.getUserType()=='Standard' || UserInfo.getUserType()=='PowerPartner') {
                                                SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
                                                sObjectCountrySetter.SetCountryFromOwner(accounts,  new List<Schema.DescribeFieldResult> { Account.BillingCountry.getDescribe() });
                                            }
                                            
                                            //AccountAndContactOwnerAndShare_Setter accountOwnerSetter = new AccountAndContactOwnerAndShare_Setter();
                                            //accountOwnerSetter.SetAccountOwnerToGeneric(accounts);
                                            
                                            AccountQueueIdSetter queueCreator = new AccountQueueIdSetter();
                                            queueCreator.CreateQueues(accounts);
                                            
                                            List<Account> consentCreateList = new List<Account>();
                                            List<Account> consentUpdateList = new List<Account>();
                                            Map<Id, Id> primaryAccountMap = new Map<Id, Id>();
                                            
                                            RecordType primaryRecordType = AccountUtilities.RecordTypes.get('Individual_Golden_Record');
                                            RecordType individualRecordType = AccountUtilities.RecordTypes.get('Individual');
                                            
                                            
                                            //Added By Masthan Andela on May2019 as part of CXPDA-450
                                            AccountPreferencesUpdater.preferencesUpdateOnPreInsert(accounts);
                                            
                                            //Live agent opt out flag
                                            for(Account acc : accounts){
                                                if(acc.Create_Secondary_Account__c != null && acc.Create_Secondary_Account__c == true && acc.Primary_Account__c != null ){
                                                    System.debug('To be cloned');
                                                    accountstoBeCloned.add(acc);
                                                }
                                                
                                                if (acc.RecordTypeId == individualRecordType.Id && acc.PersonIndividualId == null && acc.Primary_Account__c != null) primaryAccountMap.put(acc.Primary_Account__c, null);
                                                
                                                acc.Pseudo_Account_Owner__c = acc.OwnerId;
                                                
                                                /*if( acc.LiveAgent_OptOut__c != null && acc.LiveAgent_OptOut__c == 'J' ){
acc.Jaguar_Opt_Out__pc = true;
acc.Jaguar_Phone_Opt_Out__pc = true;
acc.Jaguar_Whitemail_Opt_Out__pc = true;
acc.Jaguar_Email_Opt_Out__pc = true;
acc.Jaguar_SMS_Opt_Out__pc = true;
}
if( acc.LiveAgent_OptOut__c != null && acc.LiveAgent_OptOut__c == 'LR' ){
acc.Land_Rover_Opt_Out__pc = true;
acc.Land_Rover_Phone_Opt_Out__pc = true;
acc.Land_Rover_Whitemail_Opt_Out__pc = true;
acc.Land_Rover_Email_Opt_Out__pc = true;
acc.Land_Rover_SMS_Opt_Out__pc = true;
}*/
                                                
                                                if (acc.RecordTypeId == primaryRecordType.Id && acc.PersonIndividualId == null) consentCreateList.add(acc);
                                            }
                                            
                                            if (!primaryAccountMap.isEmpty()) for (Account pa : [Select Id, PersonIndividualId From Account Where Id in :primaryAccountMap.keySet()]) primaryAccountMap.put(pa.Id, pa.PersonIndividualId);
                                            
                                            if (!consentCreateList.isEmpty()) ConsentHandler.setConsents(consentCreateList);
                                            
                                            if(!accountstoBeCloned.isEmpty()){
                                                System.debug('Found following Accounts to be cloned '+Json.serializePretty(accountstoBeCloned));
                                                Account_Secondary_Account_Creator asac = new Account_Secondary_Account_Creator();
                                                asac.createclonedSecondary(accountstoBeCloned);
                                            }          
                                            
                                            //updating Primary Account -- Added By Masthan Andela as part of Golden Record Change
                                            PrimaryAccountUpserter.SetOwnerRetailer(accounts, null);
                                            PrimaryAccountUpserter.AccountPreInsert(accounts);
                                            
                                            PrimaryAccountUpserter.primaryAccountOwnerValidation(accounts, null);
                                            
                                            consentCreateList.clear();    
                                            
                                            for(Account acc : accounts){
                                                if (acc.RecordTypeId == individualRecordType.Id && acc.PersonIndividualId == null && acc.Primary_Account__c != null) acc.PersonIndividualId = primaryAccountMap.get(acc.Primary_Account__c);
                                                
                                                if (acc.RecordTypeId == individualRecordType.Id && acc.PersonIndividualId == null) consentCreateList.add(acc);
                                            }
                                            
                                            if (!consentCreateList.isEmpty()) ConsentHandler.setConsents(consentCreateList);

                                            //Added By Suhan Jain on June2020 as part of CXPD-714
                                            AccountPhoneNumberFormatter.phoneFormatterOnInsertUpdate(accounts);

                                            AccountSubTeamHandler.setAccountSubteamForEnabledMarkets(accounts);
                                        }
    
    public void PreUpdate(List<Account> currentAccounts, List<Account> oldAccounts, Map<Id, Account> oldAccountMap) 
    {
        // CXPD-1683 - Ingore Case Validation at Event Trigger 
        IgnoreCaseValidation = true;
        
        System.debug('***********************');
        PrimaryAccountUpserter.primaryAccountOwnerValidation(currentAccounts, oldAccountMap);
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        ChildSObjectLocalFieldUpdater childSObjectLocalFieldUpdater = new ChildSObjectLocalFieldUpdater(fieldMapping, childRelationshipMap, new SObjectMapper_PersonAccount());
        
        if(!IgnoreTerritorySetter && UserInfo.getUserType()=='Standard'){
            Account_TerritoryResetter_F territoryResetterFactory = new Account_TerritoryResetter_F();
            Account_TerritoryResetter territoryResetter = territoryResetterFactory.Create();
        }
        
        sObjectCountrySetter.EqualiseCountryAndCodes(currentAccounts, oldAccounts, Account.BillingCountry.getDescribe());
        childSObjectLocalFieldUpdater.UpdateChildren(currentAccounts, oldAccounts);
        
        //AccountAndContactOwnerAndShare_Setter accountOwnerSetter = new AccountAndContactOwnerAndShare_Setter();
        //AccountRelatedObjectOwnerSetter relatedObjectOwnerSetter = new AccountRelatedObjectOwnerSetter();
        CustomerJourneySetterStatusAccount CJSA = new CustomerJourneySetterStatusAccount();
        currentAccounts = CJSA.findLapsedCustomerAccount(currentAccounts,oldAccountMap);
        //Get non-retailer accounts where owner has changed
        //Map<string, Map<Id,Account>> changedAccounts = accountOwnerSetter.GetAccountsWhereOwnerHasChanged(currentAccounts, oldAccountMap);
        //Map<Id,Account> oldAccs = changedAccounts.get('old');
        //Map<Id,Account> newAccs = changedAccounts.get('new');
        //If (!oldAccs.isEmpty() && !newAccs.isEmpty())
        //{
        //AccountPseudoOwnerController apoController = new AccountPseudoOwnerController();
        //apoController.CheckIfCanEditPseudoOwner(currentAccounts, oldAccounts);
        // accountOwnerSetter.CreateAccountShareForPseudoOwner(changedAccounts.get('old'), changedAccounts.get('new').values());
        //accountOwnerSetter.RemoveSharesToPreviousOwner(changedAccounts.get('old').values());
        //relatedObjectOwnerSetter.ReassignRelatedObjectsToNewOwner(changedAccounts.get('old').values(), changedAccounts.get('new'));
        //relatedObjectOwnerSetter.ReassignContactRelatedObjectsToNewAccountOwner(changedAccounts.get('old'), changedAccounts.get('new'));
        //}
        
        for(Account a : currentAccounts){
            Account oldAccount = oldAccountMap.get(a.Id);
            if(a.OwnerId != oldAccount.OwnerId){
                a.Pseudo_Account_Owner__c = a.OwnerId;
            }

            //Update Contactability Last Modified Date
            if (a.PersonEmail != oldAccount.PersonEmail || a.Phone != oldAccount.Phone || a.PersonMobilePhone != oldAccount.PersonMobilePhone) a.Contactability_Last_Modified_Date__pc = Datetime.now();
        }
        
        Territory_REST_Update.CheckForTerritoryChanges(currentAccounts,oldAccountMap);
        PrimaryAccountUpserter.SetOwnerRetailer(currentAccounts, oldAccountMap);
        
        
        //Added By Masthan Andela on May2019 as part of CXPDA-450
        AccountPreferencesUpdater.preferencesUpdateOnPreUpdate(currentAccounts, oldAccountMap);
        
        //Added By Suhan Jain on June2020 as part of CXPD-714
        AccountPhoneNumberFormatter.phoneFormatterOnInsertUpdate(currentAccounts);
        
        VehicleOwnersController.UpdateImportantInfoHasChangedOnAccount(currentAccounts, oldAccountMap);
        
        // CXPD-1688 Update Contact Information fields to blank when any field cleared
        VerifyContactDataController.updateContactVerifyFields(currentAccounts, oldAccountMap);

        AccountSubTeamHandler.setAccountSubteamForEnabledMarkets(currentAccounts);
    }
    
    public void PostCreate(List<Account> accounts, Map<Id, Account> oldAccountMap)
    {
        List<Account> retailerAccounts = new List<Account>();
        List<Account> nonRetailers = new List<Account>();
        List<Account> consentUpdateList = new List<Account>();
        
        for (Account acct : accounts) {
            if (acct.RecordTypeId == AccountUtilities.RecordTypes.get('Retailer').Id && acct.Name != 'test retailer') {
                retailerAccounts.add(acct);
            }
            else {
                nonRetailers.add(acct);
            } 
            
            if (acct.Retailer_Id__c != null && acct.PersonIndividualId != null) consentUpdateList.add(acct);
        }
        //AccountAndContactOwnerAndShare_Setter accountOwnerSetter = new AccountAndContactOwnerAndShare_Setter();
        //accountOwnerSetter.CreateAccountShareForPseudoOwner(oldAccountMap, accounts);
        
        SetRetailerForRetailerAccount setRetailerForRetailerAccount = new SetRetailerForRetailerAccount();
        setRetailerForRetailerAccount.setRetailer(nonRetailers);
        
        if (!consentUpdateList.isEmpty()) ConsentHandler.updateConsents(consentUpdateList);
        
        SObjectCountrySetter sObjectCountrySetter = new SObjectCountrySetter();
        
        List<Contact> contacts = AccountUtility.GetPersonContactCountrys(accounts);
        if (UserInfo.getUserType()=='Standard' || UserInfo.getUserType()=='PowerPartner') 
            sObjectCountrySetter.SetCountryFromOwner(contacts,  new List<Schema.DescribeFieldResult> { Contact.MailingCountry.getDescribe(), Contact.aop_Country__c.getDescribe() });
        
        update contacts;
        
        RecordSharer sharer = new RecordSharer();   
        try{          
            sharer.Share_Accounts(accounts); //when a new Account is created, create a Record Share to share it with User's who have requested sharing of a particular Retailer's Accounts
        }  
        catch (Exception  e){} 
        
        System.debug('MBMB**********');
        System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()));
        System.debug(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Enable_Primary_Account_Creation__c);
        
        //Creating Primary Account -- Added By Masthan Andela as part of Golden Record Change 
        //if(System.Label.Is_Create_Primary_Account.equalsIgnoreCase('true')){
        if(TriggerFramework__c.getInstance(UserInfo.getUserId()).Is_Enable_Primary_Account_Creation__c){
            
            // If Korean Data loaded by Data Loader user then block creation of primary accounts
            // Workaround here applies only to data loader and user and assume all records processed in transaction 
            // are for the same market
            if(!isDataLoadForKoreanAccounts(accounts)) {
                System.debug('Primary Account Creation applied.');
                PrimaryAccountUpserter.AccountPostInsert(accounts); 
            } else {
                System.debug('Primary Account Creation skipped for Data Loader user loading Korean Data.');
            } 
            
        }
        
    }
    
    //updating Primary Account -- Added By Masthan Andela as part of Golden Record Change
    public void PostUpdate(List<Account> currentAccounts,List<Account> oldAccounts, Map<Id, Account> oldAccountMap)
    {         
        RecordType primaryRecordType = AccountUtilities.RecordTypes.get('Individual_Golden_Record');
        RecordType individualRecordType = AccountUtilities.RecordTypes.get('Individual');
        
        //if the OwnerId of the Account has changed, determine the record shares for the new Owner
        //need to isolate the Accounts that have a modified OwnerId
        List<Account> accountsWithChangedOwner = new List<Account>();
        List<Account> consentUpdateList = new List<Account>();
        for(Account a : currentAccounts){
            if(UserInfo.getUserId() == '0051o00000Cng1nAAB' || Test.isRunningTest()) {
                system.debug('##For Acc Id: '+ a.Id);
                system.debug('##New EmailOptOut: '+ a.PersonHasOptedOutOfEmail);
                system.debug('##Old EmailOptOut: '+ oldAccountMap.get(a.Id).PersonHasOptedOutOfEmail);
                system.debug('##New Jaguar_Email_Opt_Out__pc: '+ a.Jaguar_Email_Opt_Out__pc);
                system.debug('##Old Jaguar_Email_Opt_Out__pc: '+ oldAccountMap.get(a.Id).Jaguar_Email_Opt_Out__pc);
                system.debug('##New Land_Rover_Email_Opt_Out__pc: '+ a.Land_Rover_Email_Opt_Out__pc);
                system.debug('##Old Land_Rover_Email_Opt_Out__pc: '+ oldAccountMap.get(a.Id).Land_Rover_Email_Opt_Out__pc);
                system.debug('##New Acc: '+ a);
                system.debug('##Old Acc: '+ oldAccountMap.get(a.Id));
            }

            Account oldAccount = oldAccountMap.get(a.Id);
            if(a.OwnerId != oldAccount.OwnerId){
                accountsWithChangedOwner.add(a);
            }
            
            if (a.RecordTypeId != primaryRecordType.Id && a.RecordTypeId != individualRecordType.Id) continue;
            
            //if((UserInfo.getUserType().contains('Customer') || UserInfo.getUserType() == 'Guest' || Test.isRunningTest()) && a.PersonHasOptedOutOfEmail != oldAccount.PersonHasOptedOutOfEmail) consentUpdateList.add(a);
            //if((UserInfo.getName().contains('MCC')) && (a.PersonHasOptedOutOfEmail != oldAccount.PersonHasOptedOutOfEmail || a.PersonDoNotCall != oldAccount.PersonDoNotCall || a.et4ae5__HasOptedOutOfMobile__pc != oldAccount.et4ae5__HasOptedOutOfMobile__pc || a.Direct_Mail_Opt_Out__pc != oldAccount.Direct_Mail_Opt_Out__pc)) consentUpdateList.add(a);
            if(ConsentHandler.syncConsents && (a.PersonHasOptedOutOfEmail != oldAccount.PersonHasOptedOutOfEmail || a.PersonDoNotCall != oldAccount.PersonDoNotCall || a.et4ae5__HasOptedOutOfMobile__pc != oldAccount.et4ae5__HasOptedOutOfMobile__pc || a.Direct_Mail_Opt_Out__pc != oldAccount.Direct_Mail_Opt_Out__pc)) consentUpdateList.add(a);
            if(ConsentHandler.allCommunicationConsent && a.All_Communications_opt_out__pc != oldAccount.All_Communications_opt_out__pc) consentUpdateList.add(a);
        }
        if(!accountsWithChangedOwner.isEmpty()){
            RecordSharer sharer = new RecordSharer();
            // sharer.UnShareAccounts(oldAccountMap,currentAccounts);
            sharer.Share_Accounts(accountsWithChangedOwner);
        }
        PrimaryAccountUpdateHandler.CheckAccountsForUpdatedPII(currentAccounts, oldAccountMap);
        if (!consentUpdateList.isEmpty()) ConsentHandler.updateConsents(consentUpdateList);
        if(!system.isFuture() && !system.isBatch()){
            String accJsonStr = json.serialize(currentAccounts);
            String oldAccJsonStr = json.serialize(oldAccountMap);
            AccountJagANDLRStatusHandler.handleJaguarAndLandRoverStatusAccount(accJsonStr, oldAccJsonStr);
        }
    }
    
    public void duplicateChecker(List<Account> newAccounts){
        Schema.DescribeSObjectResult r = Account.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        String currentUrl = String.valueOf(URL.getCurrentRequestUrl()).toLowerCase();
        System.debug('currentUrl = '+currentUrl);
        if(!(currentUrl.containsIgnoreCase('/'+keyPrefix+'/e') || currentUrl.containsIgnoreCase('/aura'))){
            for(Account acct: newAccounts){
                acct.Pass_Duplicate_Rule__c = true;
            }
        }
    }
    
    private Boolean isDataLoadForKoreanAccounts(List<Account> accounts) {
        Boolean dataLoadForKoreanAccounts = false;
        if(accounts[0].Country_ISO_Code__c == 'KR') {
            Id userProfileId = UserInfo.getProfileId();
            Map<Id, Profile> dataLoaderProfileIds = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name = 'MMIT Read only Dataloader']);
            if(dataLoaderProfileIds.size() > 0) {
                dataLoadForKoreanAccounts = dataLoaderProfileIds.keySet().contains(userProfileId);
            }
        }
        return dataLoadForKoreanAccounts;
    }
    
}