/**
 * Created by caleb on 05/05/2022.
 */

@IsTest
public with sharing class RetailerDisallowedMobileControllerTest
{
    @IsTest
    public static void test1()
    {
        // ACT
        Test.startTest();
        List<String> xs = RetailerDisallowedMobileController.get();
        Test.stopTest();
    }
}