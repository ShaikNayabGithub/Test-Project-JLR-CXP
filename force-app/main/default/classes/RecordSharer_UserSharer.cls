/**
 * Created by lbrindle on 01/08/2018.
 */

public with sharing class RecordSharer_UserSharer implements Database.Batchable<SObject>, Schedulable {

    public void execute(Database.BatchableContext param1, List<Record_Share__c> shares){
        ProcessSahres(shares);
    }

    public void finish(Database.BatchableContext param1){

    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('Select Id, retailer__c, User__c,User__r.Contact.AccountId From Record_Share__c where User__r.IsActive = true');
    }


    public static void execute(SchedulableContext ctx) {
        RecordSharer_UserSharer shareBatch = new RecordSharer_UserSharer();
        database.executeBatch(shareBatch,50);
    }

    public static void ProcessSahres(List<Record_Share__c> shares){
        Map<Id,List<SObject>> sharesByRetailer = SObjectUtilities.MapByIdField(shares,Schema.Record_Share__c.Retailer__c.getDescribe());
        system.debug(sharesByRetailer.size());


        List<String> shortIds = new List<String>();
        for(Id retailerId : sharesByRetailer.keySet()){
            shortIds.add(string.valueOf(retailerId).left(15));
        }

        system.debug(sharesByRetailer.keySet());

        List<User> allRetailerUsers = [Select Id, Contact_Company_Id__c From User where Contact_Company_Id__c In : shortIds ];
        Map<Id,List<SObject>> usersByRetailer = SObjectUtilities.MapByIdField(allRetailerUsers, Schema.User.Contact_Company_Id__c.getDescribe());
        system.debug('allret :' + allRetailerUsers.size());
        

        List<UserShare> newUserShares = new  List<UserShare>();

        //for each possible retailer
        for(Id retailerId : sharesByRetailer.keySet()){
            String shortId = string.valueOf(retailerId).left(15);

            if(!usersByRetailer.containsKey(shortId)) continue;

            for(Sobject userInRetailer : usersByRetailer.get(shortId)){

                //add a record share for each user who this retailer is shared with
                List<SObject> recordSharesForRetailer = sharesByRetailer.get(retailerId);

                for(SObject recordShare : recordSharesForRetailer){
                    Record_Share__c share = (Record_Share__c)recordShare;
                    if(userInRetailer.id == share.User__c) continue; //don't need to give access to themselves
                    if(share.User__r.ContactId == null) continue; //don't give internal users access to other users as OWD is public read-only
                    if(retailerId == share.User__r.Contact.AccountId) continue; // don't need to give them access to users in their own retailer

                    UserShare newShare = new UserShare();
                    newShare.UserId = userInRetailer.id; // this is the user to be shared
                    newShare.UserAccessLevel = 'Read';
                    newShare.UserOrGroupId = share.User__c;
                    newShare.RowCause = 'Manual';
                    newUserShares.add(newShare);

                }



            }

        }
        system.debug(newUserShares.size());

        Database.SaveResult[] res = database.insert(newUserShares,true);
    }

}