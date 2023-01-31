@IsTest
public class TestClass_AccountCreator {
    private static Integer RetailerCount = 0;
    
    
    public static Account CreateRetailer()
    {
        Account retailer = BuildRetailer();
            insert retailer;
        return retailer;
    }

    public static Account CreateRetailer(User user)
    {
        Account retailer = BuildRetailer();
        // Insert account as current user
        System.runAs (user) {
            QueueSobject queue = BuildQueueSobject();
            retailer.Queue_ID__c = queue.QueueId;
            insert retailer;
        }
        return retailer;
    }


    public static QueueSobject BuildQueueSobject(){

        //Create Group
        Group gp = new Group();
        gp.Name = 'Test Group';
        gp.Type = 'Queue';
        insert gp;

        //Create Queue
        QueueSobject queue = new QueueSobject();
        queue.QueueId = gp.Id;
        queue.SobjectType = 'Case';
        insert queue;
        return queue;
    }

    public static Account BuildRetailer()
    {
        Account retailer = new Account();
            retailer.Name = 'test retailer';
            retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailer.Dealer_CI_Code__c = 'test retailer';
            retailer.Primary_Dealer_Code__c = 'test retailer' + RetailerCount;
            retailer.Secondary_Dealer_Code__c = 'test retailer' + RetailerCount;
            retailer.Alternative_Key__c = 'test retailer';
            RetailerCount++;
        return retailer;
    }
    
    public static Account createPersonAccount()
    {
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        System.assertNotEquals(null, acc.RecordTypeId);
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        acc.LastName = '';
        for(Integer i=0; i<10; i++){
            Integer randomNum = (Integer)(Math.random() * 26);
            acc.LastName += chars.substring(randomNum, randomNum+1);
        }
        acc.FirstName = 'Valid Firstname';
        acc.PersonMailingStreet = 'Valid Street';
        acc.PersonMailingPostalCode = 'Valid PostalCode';
        acc.PersonMailingState = 'Valid State';
        acc.PersonMailingCity = 'Valid City';        
        acc.PersonEmail = 'testurvora@rediffmail.com';
        acc.PersonOtherPhone = '1122334455';
        acc.Country_ISO_Code__pc = 'IN';
        acc.Country_ISO_Code__c = 'IN';

        insert acc;
        //System.assert(acc.IsPersonAccount);
        return acc;
    }
	public static Account createPrimaryAccount()
    {
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        System.assertNotEquals(null, acc.RecordTypeId);
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        acc.LastName = '';
        for(Integer i=0; i<10; i++){
            Integer randomNum = (Integer)(Math.random() * 26);
            acc.LastName += chars.substring(randomNum, randomNum+1);
        }
        acc.FirstName = 'Valid Firstname';
        acc.PersonMailingStreet = 'Valid Street';
        acc.PersonMailingPostalCode = 'Valid PostalCode';
        acc.PersonMailingState = 'Valid State';
        acc.PersonMailingCity = 'Valid City';        
        acc.PersonEmail = 'test123@test.com';
        acc.Country_ISO_Code__pc = 'IN';
        acc.Country_ISO_Code__c = 'IN';

        insert acc;
        //System.assert(acc.IsPersonAccount);
        return acc;
    }
    public static Account createPersonAccount_Australia()
    {
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.RECORD_TYPE_NAME_ACCOUNT_INDIVIDUAL).getRecordTypeId();
       
          system.debug('Account befor is recordtype '+acc.RecordTypeId);
        System.assertNotEquals(null, acc.RecordTypeId);
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        acc.LastName = '';
        for(Integer i=0; i<10; i++){
            Integer randomNum = (Integer)(Math.random() * 26);
            acc.LastName += chars.substring(randomNum, randomNum+1);
        }
        acc.FirstName = 'Valid Firstname';
        acc.PersonMailingStreet = 'Valid Street';
        acc.PersonMailingPostalCode = 'Valid PostalCode';
        acc.PersonMailingState = 'Valid State';
        acc.PersonMailingCity = 'Valid City';
        acc.PersonEmail = 'test123@test.com';
        acc.Country_ISO_Code__pc = 'AU';
        acc.Country_ISO_Code__c = 'AU';

        insert acc;
        //System.assert(acc.IsPersonAccount);
         system.debug('Account inserted is recordtype '+acc.RecordTypeId);
        return acc;
        
    }

    public static Account GenerateCorporateAccount()
    {
        Account account = new Account();

        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = '';
        for(Integer i=0; i<10; i++){
            Integer randomNum = (Integer)(Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum+1);
        }
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'IN';
        account.Corporate_Code__c = 'TEST';

        insert account;
        return account;
    }

    public static Account GenerateCorporateAccountAustralia()
    {
        Account account = buildCorporateAccountAustralia();

        insert account;
        return account;
    }

    public static Account GenerateCorporateAccountAustralia(string accName)
    {
        Account account = buildCorporateAccountAustralia();
        account.Name = accName;
        insert account;
        return account;
    }

    private static Account buildCorporateAccountAustralia() {
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = '';
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }
        return account;
    }

    public static List<Account> generateAccounts(Integer count, String recordTypeId, String prefectures, String wards)
    {
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < count; i++)
        {
            Account acc = new Account(Name = 'Retailer' + i, Region_or_Market__c = 'JP', RecordTypeId = recordTypeId, Brand__c = 'Land Rover', Record_Sub_Type__c = 'Branded', merchant_id__c = '72637', service_id__c = '001', c_udaan_marketarea1__c = prefectures, c_udaan_marketarea2__c = wards);
            accList.add(acc);
        }
        insert accList;
        return accList;
    }

}