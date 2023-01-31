@IsTest
public class AUSDataRem_AccountHandlerTest 
{
    @IsTest
    public static void insertAccountTest()
    {
        // ARRANGE
        Account account = new Account();
        
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.BillingCity = 'Valid City';
        account.BillingCountry = 'Australia';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingStreet = 'Valid Street';
        account.Country_ISO_Code__c = 'AU';
        account.Description = 'Valid Description';
        account.FirstName = 'Valid FirstName';
        account.LastName = 'Valid LastName';
        account.OwnerId = '0051o00000DIM7LAAX';
        account.Owner_retailer__c = '0051o00000DIM7LAAX';
        account.PersonEmail = 'test@test.argologic.com.au';
        account.PersonMobilePhone = '1234567';
        account.PersonOtherPhone = '1234567';
        account.PersonTitle = '1234567';
        account.Phone = '1234567';
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
        System.debug('*****************************');
        System.debug(account.RecordTypeId);
        account.Region_or_Market__c = 'Australia';
        //account.Retailer_Email__c = 'test@test.argologic.com.au';
        
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.FirstName += chars.substring(randomNum, randomNum + 1);
            account.LastName += chars.substring(randomNum, randomNum + 1);
            account.PersonEmail += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            //account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
        }

        // ACT
        Test.startTest();
        insert account;
        
        List<Account> accounts = [SELECT Id, IsDeleted,OwnerId, BillingCountry, Owner_retailer__c, Is_primary__c, PersonMailingStreet,
                          primary_account__c, primary_account__pc, lastName, firstName, name, Mena_reference2__c, Phone,
                          personEmail, PersonMobilePhone, IsPersonAccount, Website, BillingPostalCode,
                          PersonDoNotCall, PersonHasOptedOutOfEmail        , Retailer_Email__c, Assistant_Phone_Hidden__pc,        
                                              PersonAssistantPhone, PersonHomePhone, PersonOtherPhone, Other_Phone_Hidden__pc,
                          Create_Secondary_Account__c, RecordTypeId,
                          All_communications_opt_out__pc, direct_mail_opt_out__pc, et4ae5__hasoptedoutOfMobile__pc,
                          Work_Order_contact_Home_Phone__pc, Work_Order_contact_Mobile_Phone__pc,
                          Work_Order_contact_Work_Phone__pc, BillingStreet, Country_ISO_Code__c, deceased_date__pc
                      FROM Account 
                      where id = :account.Id];
        System.debug('*****************************');
        System.debug(accounts[0].RecordTypeId);
        System.debug(accounts);
        
        for(Account acc: accounts) {
            acc.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
        }
        update accounts;
        
         List<Account> accs = [SELECT Id, IsDeleted,OwnerId, BillingCountry, Owner_retailer__c, Is_primary__c, PersonMailingStreet,
                          primary_account__c, primary_account__pc, lastName, firstName, name, Mena_reference2__c, Phone,
                          personEmail, PersonMobilePhone, IsPersonAccount, Website, BillingPostalCode,
                          PersonDoNotCall, PersonHasOptedOutOfEmail        , Retailer_Email__c, Assistant_Phone_Hidden__pc,        
                                              PersonAssistantPhone, PersonHomePhone, PersonOtherPhone, Other_Phone_Hidden__pc,
                          Create_Secondary_Account__c, RecordTypeId, All_communications_opt_out__pc, direct_mail_opt_out__pc,
                          Work_Order_contact_Home_Phone__pc, Work_Order_contact_Mobile_Phone__pc, et4ae5__hasoptedoutOfMobile__pc,
                          Work_Order_contact_Work_Phone__pc, BillingStreet, Country_ISO_Code__c, deceased_date__pc
                      FROM Account 
                      where id = :account.Id];
        System.debug('*****************************');
        System.debug(accs[0].RecordTypeId);
        System.debug(accs);
        AUSDataRem_AccountHandler handler = new AUSDataRem_AccountHandler();
            
        
        handler.PreCreate(accs);
        handler.PostCreate(accs, null);
        
        Test.stopTest();

        // ASSERT

    }
    @IsTest
    public static void insertCorporateAccountTest()
    {
        // ARRANGE
        Account account = new Account();
        account.Name = 'retailer';
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        account.Dealer_CI_Code__c = 'retailer';
        account.Primary_Dealer_Code__c = 'retailer' ;
        account.Secondary_Dealer_Code__c = 'test retailer1';
        account.Alternative_Key__c = 'retailer';
        account.Phone = '1234567890';    
        account.Retailer_Email__c ='test@test.argologic.com'; //provide an email address
        account.Owner_Retailer__c = '0051o00000DIM7LAAX'; //different Owner Retailer value
        
        
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        //account.BillingCity = 'Valid City';
        //account.BillingCountry = 'Australia';
        //account.BillingPostalCode = 'Valid PostalCode';
        //account.BillingState = 'Valid State';
        //account.BillingStreet = 'Valid Street';
        account.Country_ISO_Code__c = 'AU';
        account.Description = 'Valid Description';
        //account.FirstName = 'Valid FirstName';
        //account.LastName = 'Valid LastName';
        account.OwnerId = '0051o00000DIM7LAAX';
        //account.PersonEmail = 'test@test.argologic.com.au';
        //account.PersonMobilePhone = '1234567';
        //account.PersonOtherPhone = '1234567';
        //account.PersonTitle = '1234567';
        //account.Phone = '1234567';
        //account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        System.debug('*****************************');
        System.debug(account.RecordTypeId);
        account.Region_or_Market__c = 'Australia';
        //account.Retailer_Email__c = 'test@test.argologic.com.au';
        
       

        // ACT
        Test.startTest();
        insert account;
        
       
        
         List<Account> accs = [SELECT Id, IsDeleted,OwnerId, BillingCountry, Owner_retailer__c, Is_primary__c, PersonMailingStreet,
                          primary_account__c, primary_account__pc, lastName, firstName, name, Mena_reference2__c, Phone,
                          personEmail, PersonMobilePhone, IsPersonAccount, Website, BillingPostalCode,
                          PersonDoNotCall, PersonHasOptedOutOfEmail        , Retailer_Email__c, Assistant_Phone_Hidden__pc,        
                                              PersonAssistantPhone, PersonHomePhone, PersonOtherPhone, Other_Phone_Hidden__pc,
                          Create_Secondary_Account__c, RecordTypeId, All_communications_opt_out__pc, direct_mail_opt_out__pc,
                          Work_Order_contact_Home_Phone__pc, Work_Order_contact_Mobile_Phone__pc, et4ae5__hasoptedoutOfMobile__pc,
                          Work_Order_contact_Work_Phone__pc, BillingStreet, Country_ISO_Code__c, deceased_date__pc
                      FROM Account 
                      where id = :account.Id];
        System.debug('*****************************');
        System.debug(accs[0].RecordTypeId);
        System.debug(accs);
        AUSDataRem_AccountHandler handler = new AUSDataRem_AccountHandler();
            
        handler.PreCreate(accs);
        handler.PostCreate(accs, null);
        
        Test.stopTest();

        // ASSERT

    }
}