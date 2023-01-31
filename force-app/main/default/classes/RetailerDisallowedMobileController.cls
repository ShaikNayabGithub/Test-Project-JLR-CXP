/**
 * Created by caleb on 05/05/2022.
 */

public with sharing class RetailerDisallowedMobileController
{
    @AuraEnabled
    public static List<String> get()
    {
        List<String> ans = new List<String>();
        List<Australia_Retailer_Disallowed_Mobile__mdt> mdts = [
                SELECT Mobile__c
                FROM Australia_Retailer_Disallowed_Mobile__mdt
        ];
        for (Australia_Retailer_Disallowed_Mobile__mdt m : mdts) ans.add(m.Mobile__c);
        return ans;
    }
}