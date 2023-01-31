/**
 * Created by caleb@argologic.com.au on 26/02/2021.
 */

@IsTest
public with sharing class CommunityNotificationControllerTest
{
    @IsTest
    public static void test1()
    {
        // ASSERT
        Community_Notification__c cn = new Community_Notification__c();
        cn.Start_Date_Time__c = Date.today().addDays(-10);
        cn.End_Date_Time__c = Date.today().addDays(10);
        cn.Audience__c = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        insert cn;

        // ACT
        Test.startTest();
        List<Community_Notification__c> res = CommunityNotificationController.GetActiveNotifications();
        Test.stopTest();

        // ASSERT
        System.assertEquals(1, res.size());
    }

    @IsTest
    public static void test2()
    {
        // ASSERT
        Community_Notification__c cn = new Community_Notification__c();
        cn.Start_Date_Time__c = Date.today().addDays(-10);
        cn.End_Date_Time__c = Date.today().addDays(10);
        cn.Audience__c = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        insert cn;

        // ACT
        Test.startTest();
        CommunityNotificationController.MarkAsViewed(new List<string> { cn.Id });
        Test.stopTest();
    }
}