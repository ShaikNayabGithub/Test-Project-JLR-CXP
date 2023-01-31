/**
 * Created by caleb@argologic.com.au on 13/08/2021.
 */

@IsTest
public with sharing class LWCUtilityTest
{
    @IsTest
    public static void queryTest()
    {
        LWCUtility.query('SELECT Id FROM Account');
    }

    @IsTest
    public static void upTest()
    {
        List<Account> acc = new List<Account> { TestClass_AccountCreator.createPersonAccount() };
        LWCUtility.up(acc);
    }
}