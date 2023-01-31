global without sharing class PostChatController{
    
    @RemoteAction
    global static String saveFeedback(String chatKey, String comments, String satisfied, String enquiryAnswered, String rating){
        try{        
           Live_Agent_Feedback__c  feedback = new Live_Agent_Feedback__c();
           feedback.Chat_Key__c = chatKey;
           feedback.Comments__c = comments;
           feedback.Rating__c = rating; 
           feedback.Was_your_enquiry_answered__c = enquiryAnswered;
           feedback.Were_you_satisfied__c = satisfied;
           insert feedback;   
           
           
           //force the linking to the transcript if it is already created
           List<LiveChatTranscript> records = [Select chatkey,Feedback_Rating__c,Feedback_Comments__c,Feedback_Satisfied__c,Feedback_enquiry_answered__c
                                              From LiveChatTranscript
                                              Where chatkey =: chatKey];
           
           if(records.size() > 0){
               LiveChatTranscriptTrigger_Handler h = new LiveChatTranscriptTrigger_Handler();
               h.LinkFeedback(records);
               update records;
           }
           
           
           return 'Success';     
        }catch(Exception e){
            throw e;
            //return 'Error';
        }
    
    }
    

}