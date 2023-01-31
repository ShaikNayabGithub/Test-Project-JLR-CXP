@isTest
public class LiveChatTranscriptAccountLogic_T {
    
    @isTest
    Public static void TestInsertLiveChatTranscriptTriggerWithContactPopulatesAccountId(){
        //TO DO 
          Profile prof2 = [SELECT Id FROM Profile WHERE Name = 'JLR System Administrator'];
        User newuser = new User();
        newuser.FirstName = 'Little';
        newuser.LastName = 'Man';
        newuser.Email = 'Scared@you.com';
        newuser.Country_ISO_Code__c = 'IN';
        newuser.Market__c = 'IN';
        newuser.Username = 'Lilman@yoursevice.com';
		newuser.Alias  = 'LilM';
		newuser.CommunityNickname  = 'nappy';
		newuser.TimeZoneSidKey  = 'Europe/London';
		newuser.LocaleSidKey = 'en_US';
		newuser.EmailEncodingKey = 'UTF-8';
		newuser.ProfileId  = prof2.id;
		newuser.LanguageLocaleKey = 'en_US';
		System.RunAs(new User(Id=userinfo.getUserId())){        
        insert newuser;
        }
        Contact cont = new Contact();
        cont.FirstName = 'Big';
        cont.LastName = 'Man';
        cont.Email = 'Running@you.com';
        cont.LA_Opt_In__c = 'LN';
        cont.OwnerId = newuser.id;
        insert cont;
        LiveChatVisitor vistor = new LiveChatVisitor();
      
        insert vistor;
        LiveChatTranscript transcript = new LiveChatTranscript();
   
        transcript.OwnerId = newuser.id; 
        transcript.LiveChatVisitorId = vistor.id;
        insert transcript;
        test.startTest();
         LiveChatTranscript updatetranscript = new LiveChatTranscript();   
        updatetranscript.ContactId = cont.Id;
        updatetranscript.Id = transcript.Id;
        update updatetranscript;
        test.stopTest();
        LiveChatTranscript tt = [Select id, accountId, contactid from LiveChatTranscript where id=:transcript.Id];
        system.debug('tt '+ tt);
        System.assert(tt.AccountId != null);
        
        
    }
    

}