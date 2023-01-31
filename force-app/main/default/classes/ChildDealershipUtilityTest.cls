/**
 * Created by caleb@argologic.com.au on 16/03/2020.
 */

@IsTest
public with sharing class ChildDealershipUtilityTest
{
    @IsTest
    public static void test1()
    {
        // ARRANGE
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Account childJag = TestClass_AccountCreator.CreateRetailer();
        childJag.ParentId = acc.Id;
        update childJag;

        // ACT
        Test.startTest();
        String res = ChildDealershipUtility.getChildDealership(acc.Id, true);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
    }

    @IsTest
    public static void test2()
    {
        // ARRANGE
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Account childJag = TestClass_AccountCreator.CreateRetailer();
        childJag.ParentId = acc.Id;
        update childJag;

        // ACT
        Test.startTest();
        String res = ChildDealershipUtility.getChildDealership(acc.Id, false);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
    }

    @IsTest
    public static void test3()
    {
        // ARRANGE
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Account childJag = TestClass_AccountCreator.CreateRetailer();
        childJag.ParentId = acc.Id;
        update childJag;

        // ACT
        Test.startTest();
        Map<String, Account> res = ChildDealershipUtility.getParentToChildDealershipMap(new List<String> { acc.Id }, true);
        Test.stopTest();

        // ASSERT
        System.assertEquals(childJag.Id, res.get(acc.Id).Id);
    }

    @IsTest
    public static void test4()
    {
        // ARRANGE
        Account acc = TestClass_AccountCreator.CreateRetailer();
        Account childJag = TestClass_AccountCreator.CreateRetailer();
        childJag.ParentId = acc.Id;
        update childJag;

        // ACT
        Test.startTest();
        Map<String, Account> res = ChildDealershipUtility.getParentToChildDealershipMap(new List<String> { acc.Id }, false);
        Test.stopTest();

        // ASSERT
        System.assertEquals(childJag.Id, res.get(acc.Id).Id);
    }
}