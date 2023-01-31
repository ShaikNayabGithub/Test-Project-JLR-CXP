/**
 * Created by caleb@argologic.com.au on 26/02/2021.
 */

@IsTest
public with sharing class InvocableGetCommunityUrlTest
{
    @IsTest(SeeAllData=true)
    public static void test1()
    {
        Test.startTest();
        InvocableGetCommunityUrl.getCommunityUrl();
        Test.stopTest();
    }
}