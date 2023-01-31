/**
 * Created by caleb@argologic.com.au on 15/07/2021.
 */

public with sharing class LWCUtility
{
    @AuraEnabled
    public static List<SObject> query(string q)
    {
        return Database.query(q);
    }

    @AuraEnabled
    public static void up(List<SObject> toUpdate)
    {
        Database.update(toUpdate);
    }
}