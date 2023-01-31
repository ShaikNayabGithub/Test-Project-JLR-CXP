@IsTest
public class ContactSecondaryContactCreator_Test {

    @IsTest
    public static void cloneContactTest()
    {
    	Account primAcc = new Account();
        primAcc.Name = 'test123';
        insert primAcc;
        Account secAcc = new Account();
        secAcc.Name = 'test123';
        insert secAcc;
        Contact primContact = new Contact();
        primContact.Email = 'test@123.com';
        primContact.Phone = '123213123';
        primContact.Primary_Account__c = primAcc.Id; // secAcc.Id;
        primContact.AccountId = primAcc.Id;
        primContact.LastName = 'lastName';
        insert primContact;
        
        Test.startTest();
        /*Contact secContact = primContact.clone(false,false,false,false);
        secContact.Primary_Account__c = PrimAcc.Id; // secAcc.Id;
        secContact.AccountId = secAcc.Id; // acc.Id
        secContact.Primary_Contact__c = primContact.Id;
        insert secContact;*/
        ContactSecondaryContactCreator cscc = new ContactSecondaryContactCreator();
        Contact secContact = cscc.createClonedSecondaryContact(primContact, primAcc, secAcc);
        Test.stopTest();
        
        Contact result = [SELECT Phone, Primary_Account__c, AccountId, Primary_Contact__c FROM Contact WHERE Id= :secContact.Id];
        System.assertEquals('123213123', result.Phone);
        System.assertEquals(secAcc.Id, result.AccountId);
        System.assertEquals(primAcc.Id, result.Primary_Account__c);
        System.assertEquals(primContact.Id, result.Primary_Contact__c);
        
    }
}