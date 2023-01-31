public class LiveChatTranscriptTriggerHandler {
    /*
     public void PreCreate(List<LiveChatTranscript> chats)
    {
         System.debug('PreCreate CHAT: '+JSON.serializePretty(chats));
    }
     
    public void PostCreate(List<LiveChatTranscript> chats, Map<Id, LiveChatTranscript> oldChatMap)
    {
          
        System.debug('Post CHAT: '+JSON.serializePretty(chats));
        System.debug('mape '+  JSON.serializePretty(oldChatMap));    
    }
    public void PreUpdate(List<LiveChatTranscript> chats)
    {
        System.debug('PreUpdate CHAT: '+JSON.serializePretty(chats));    
    }
     */
    public void PostUpdate(List<LiveChatTranscript> chats, Map<Id, LiveChatTranscript> oldChatMap)
    {
        System.debug('Post Update: chat'+JSON.serializePretty(chats));
           System.debug('Oldchat'+JSON.serializePretty(oldChatMap));
        
        List<LiveChatTranscript> chatsToSetAccount = new List<LiveChatTranscript>();
           for(LiveChatTranscript newchat : chats){
               System.debug('Contains Id '+oldChatMap.ContainsKey(newchat.id));
               if(newchat.id != null && oldChatMap!= null && oldChatMap.ContainsKey(newchat.id)){
                   System.debug('Not null id and gas the key');
               LiveChatTranscript oldchat = oldChatMap.get(newchat.id);
                   System.debug('newchat.ContactId'+newchat.ContactId);
                    System.debug('oldchat.ContactId'+oldchat.ContactId);
                    System.debug('newchat.AccountId'+newchat.AccountId);
                    System.debug('oldchat'+oldchat);
                  
               if(oldchat != null && newchat.ContactId != null && oldchat.ContactId == null && newchat.AccountId == null){
                   System.debug('old chat is not null and contact id is not null and oldchat is empty and account ');
                   LiveChatTranscriptAccountLogic logic = new LiveChatTranscriptAccountLogic();
                   id accountId = logic.convertContactIntoPersonAccount(newchat.ContactId,  newchat.OwnerId);
                    LiveChatTranscript toUpdate = new  LiveChatTranscript();
                   toUpdate.Id = newChat.Id;
                   SYSTem.debug('THE ACCOUNT  '+accountId);
                   toUpdate.AccountId = accountId;
                   chatsToSetAccount.add(toUpdate);
               }
                   
               }
       
        }
        if(chatsToSetAccount.Size()>0){
            update chatsToSetAccount;
        }

    }

}