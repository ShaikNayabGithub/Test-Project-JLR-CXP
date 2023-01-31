/**
 * Created by Ethan Sargent on 18/2/20.
 */

@IsTest
private class FlowContactSelectionControllerTest
{
    @TestSetup
    static void setup()
    {
        Account account = TestClass_AccountCreator.CreateRetailer();
        List<Contact> contacts = TestClass_ValidContactBuilder.createContactsList();
        for (Contact con: contacts)
        {
            con.AccountId = account.Id;
        }
        update contacts;
    }

    @IsTest
    static void testGetContacts()
    {
        // ARRANGE
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> cons = [SELECT Id FROM Contact];
        // ACT
        Test.startTest();
        List<Contact> result = FlowContactSelectionController.getContacts(acc.Id);
        Test.stopTest();

        // ASSERT
        System.assertEquals(cons.size(), result.size());

    }
}