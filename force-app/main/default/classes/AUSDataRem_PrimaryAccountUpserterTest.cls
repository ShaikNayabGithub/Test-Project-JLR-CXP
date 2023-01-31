@isTest
public class AUSDataRem_PrimaryAccountUpserterTest {

    @IsTest
    public static void createAccountMapTest()        
    {
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
       
        System.debug(accounts);
        
        AUSDataRem_PrimaryAccountUpserter.createAccountMap(accounts);
    }
    
}