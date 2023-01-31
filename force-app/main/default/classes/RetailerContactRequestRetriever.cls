public class RetailerContactRequestRetriever {
      public static Id GetQueueId(Request__c requestRecord){  
          if(string.valueof(requestRecord.Retailer_Contact__c) != 'false' && requestRecord.Preferred_Retailer_Code__c != null){
             List<Account> retailer;
             Id rt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
              if(requestRecord.Brand__c == 'Jaguar'){
                  //Query requires Country ISO Code filter, dealer ci code are not just unique to one market, possible conflicts (Line 9 and 16)
                  retailer = [Select queue_id__c from Account Where recordTypeID =:rt AND queue_id__c != null AND Dealer_CI_Code__c=:requestRecord.Preferred_Retailer_Code__c limit 1];  
                  if(retailer.size() == 1){
                      return retailer[0].queue_id__c;
                  }
              }
                
              if(requestRecord.Brand__c == 'Land Rover'){
                  retailer = [Select queue_id__c from Account Where recordTypeID =:rt AND queue_id__c != null AND Dealer_CI_Code_2__c=:requestRecord.Preferred_Retailer_Code__c limit 1];  
                  if(retailer.size() == 1){
                      return retailer[0].queue_id__c;
                  }
              }
          }
          return null;
    }
}