/**
 * Created by caleb@argologic.com.au on 27/07/2020.
 */

@IsTest
public with sharing class ContactTransformerTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        Contact con = new Contact();
        Account acc = new Account();
        con.Account = acc;

        // ACT
        Test.startTest();
        ContactTransformer.transform(new List<Contact> { con });
        Test.stopTest();
    }
}