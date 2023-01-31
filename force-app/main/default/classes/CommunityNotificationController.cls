/**
 * Created by caleb@argologic.com.au on 23/12/2020.
 */

public without sharing class CommunityNotificationController
{
    @AuraEnabled
    public static List<Community_Notification__c> GetActiveNotifications()
    {
        string userId = UserInfo.getUserId();
        User u = [SELECT Id, Name, Profile.Name, ProfileId FROM User WHERE Id = :userId];
        List<Community_Notification__c> notifications = [
                SELECT
                        Id,
                        Body__c,
                        Audience__c
                FROM Community_Notification__c
                WHERE Start_Date_Time__c < :Datetime.now()
                AND End_Date_Time__c > :Datetime.now()
                AND Id NOT IN (
                        SELECT
                                Community_Notification__c
                        FROM Community_Notification_User__c WHERE User__c = :userId
                )
        ];

        // now we need to check this user has a profile that is in the audience csv
        List<Community_Notification__c> notificationsFiltered = new List<Community_Notification__c>();
        for (Community_Notification__c cn : notifications)
        {
            List<String> profiles = splitAndTrim(cn.Audience__c, '\n');
            System.debug('u.Profile.Name = ' + u.Profile.Name);
            System.debug('profiles = ' + JSON.serialize(profiles));
            if (profiles.contains(u.Profile.Name) || profiles.contains(u.ProfileId))
            {
                notificationsFiltered.add(cn);
            }
        }
        System.debug(JSON.serialize(notificationsFiltered));

        return notificationsFiltered;
    }

    public static List<string> splitAndTrim(String str, String sep)
    {
        if (str == null) return new List<String>();
        List<string> sections = str.split(sep);
        List<string> result = new List<String>();
        for (string s : sections)
        {
            result.add(s.trim());
        }
        return result;
    }

    @AuraEnabled
    public static void MarkAsViewed(List<string> notificationIds)
    {
        string userId = UserInfo.getUserId();
        List<Community_Notification_User__c> toInsert = new List<Community_Notification_User__c>();
        for (string notificationId : notificationIds)
        {
            Community_Notification_User__c cnu = new Community_Notification_User__c();
            cnu.User__c = userId;
            cnu.Community_Notification__c = notificationId;
            toInsert.add(cnu);
        }
        insert toInsert;
    }


}