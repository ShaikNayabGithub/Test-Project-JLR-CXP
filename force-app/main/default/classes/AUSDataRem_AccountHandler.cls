public class AUSDataRem_AccountHandler {

  public static Boolean IgnoreTerritorySetter = false;
    
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
        
        //Live agent opt out flag
        for(Account acc : accounts){
            if(acc.Create_Secondary_Account__c != null && acc.Create_Secondary_Account__c == true && acc.Primary_Account__c != null ){
                System.debug('To be cloned');
                accountstoBeCloned.add(acc);
            }
            acc.Pseudo_Account_Owner__c = acc.OwnerId;
        }
        if(!accountstoBeCloned.isEmpty()){
            System.debug('Found following Accounts to be cloned '+Json.serializePretty(accountstoBeCloned));
            Account_Secondary_Account_Creator asac = new Account_Secondary_Account_Creator();
            asac.createclonedSecondary(accountstoBeCloned);
        }          
        //updating Primary Account -- Added By Masthan Andela as part of Golden Record Change
        AUSDataRem_PrimaryAccountUpserter.SetOwnerRetailer(accounts, null);
        AUSDataRem_PrimaryAccountUpserter.AccountPreInsert(accounts);
        AUSDataRem_PrimaryAccountUpserter.primaryAccountOwnerValidation(accounts, null);
        
        //Added By Masthan Andela on May2019 as part of CXPDA-450
        //AccountPreferencesUpdater.preferencesUpdateOnPreInsert(accounts);
        
        //Added By Suhan Jain on June2020 as part of CXPD-714
        AccountPhoneNumberFormatter.phoneFormatterOnInsertUpdate(accounts);
    }
    
        
    public void PostCreate(List<Account> accounts, Map<Id, Account> oldAccountMap)
    {
        List<Account> retailerAccounts = new List<Account>();
        List<Account> nonRetailers = new List<Account>();
        
        for (Account acct : accounts) {
            if (acct.RecordTypeId == AccountUtilities.RecordTypes.get('Retailer').Id && acct.Name != 'test retailer') {
                retailerAccounts.add(acct);
            }
            else {
                nonRetailers.add(acct);
            } 
        }
        //AccountAndContactOwnerAndShare_Setter accountOwnerSetter = new AccountAndContactOwnerAndShare_Setter();
        //accountOwnerSetter.CreateAccountShareForPseudoOwner(oldAccountMap, accounts);
        
        SetRetailerForRetailerAccount setRetailerForRetailerAccount = new SetRetailerForRetailerAccount();
        setRetailerForRetailerAccount.setRetailer(nonRetailers);
        
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
        
        //Creating Primary Account -- Added By Masthan Andela as part of Golden Record Change 
        //if(System.Label.Is_Create_Primary_Account.equalsIgnoreCase('true')){
       
        
        AUSDataRem_PrimaryAccountUpserter.AccountPostInsert(accounts);   
         
    }
}