public class LiveChatTranscriptTrigger_Handler {

    public void LinkFeedback(List<LiveChatTranscript> records){    
   
        Set<String> chatKeys = SObjectUtilities.GetFieldValues(records, 'chatKey');
        List<SObject> feedbackRecords = [Select id, chat_key__c, rating__c, comments__c,
                                                        Was_your_enquiry_answered__c, Were_you_satisfied__c
                                                       	From Live_Agent_Feedback__c 
                                                        where chat_key__c in : chatKeys];
        
        Map<String, List<SObject>> feedbackByChatKey = SObjectUtilities.MapByField(feedbackRecords, Schema.Live_Agent_Feedback__c.chat_key__c.getDescribe());
    
        for(LiveChatTranscript chat: records){
            String chatKey = '' + chat.chatkey;
            
            if(feedbackByChatKey.containsKey(chatKey)){
            	Live_Agent_Feedback__c feedback = (Live_Agent_Feedback__c)feedbackByChatKey.get(chatKey)[0];
                chat.Feedback_Rating__c = feedback.rating__c;
                chat.Feedback_Comments__c = feedback.comments__c;
                chat.Feedback_Satisfied__c = feedback.Were_you_satisfied__c;
                chat.Feedback_enquiry_answered__c = feedback.Was_your_enquiry_answered__c;                   
            }            
        }    
}
    
}