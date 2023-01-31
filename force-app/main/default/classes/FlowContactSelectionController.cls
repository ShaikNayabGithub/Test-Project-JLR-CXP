/**
 * Created by Ethan Sargent on 18/2/20.
 */

public with sharing class FlowContactSelectionController
{
    @AuraEnabled(Cacheable=true)
    public static List<Contact> getContacts(Id accId) {
        if (String.isBlank(accId)) return null;
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Email, MobilePhone FROM Contact WHERE AccountId = :accId];
        for (Contact con: contacts) {
            // Due to issues with object non-extensibility in JS this unfortunately is done in the backend instead of the frontend.
            if (con.Email == null) con.Email = '';
            if (con.MobilePhone == null) con.MobilePhone = '';

        }
        return contacts;
    }
}