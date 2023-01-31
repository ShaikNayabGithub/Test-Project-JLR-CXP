@isTest
public class LiveAgentTranscriptTriggerHandler_Test {
    
   
    
        //this test is purely to obtain at least 1% code coverage for trigger in order to facilitate deployment in preprod
    static testMethod void testCreateFeedbackPopulatesCreateOfTranscript() {
        //Set<String> chatKeys = SObjectUtilities.GetFieldValues(records, 'chatKey');
        Live_Agent_Feedback__c feed = new Live_Agent_Feedback__c();
       		 feed.chat_key__c = '123456789';
             feed.rating__c = '5';
             feed.Were_you_satisfied__c = 'Yes';
             insert feed;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        Test.startTest();
       
        LiveChatTranscript lct = new LiveChatTranscript(LiveChatVisitorId = lcv.Id);
        lct.chatKey = '123456789';
        insert lct;
         Test.stopTest();
        LiveChatTranscript lchts = [Select Id, Feedback_Rating__c, Feedback_enquiry_answered__c from LiveChatTranscript where Id =:lct.Id];
       System.assertEquals('5', lchts.Feedback_Rating__c);
        /*
  chat.Feedback_Rating__c = feedback.rating__c;
                chat.Feedback_Comments__c = feedback.comments__c;
                chat.Feedback_Satisfied__c = feedback.Were_you_satisfied__c;
                chat.Feedback_enquiry_answered__c = feedback.Was_your_enquiry_answered__c;  


*/
        
       
    }

    
}