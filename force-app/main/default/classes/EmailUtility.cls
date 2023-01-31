public class EmailUtility {

    private static void SendEmailWorker(List<String> toAddresses, String senderName, String Subject,  
                                 String bodyHTML, String bodyText, String replyToEmail, Boolean insertTask, Id TaskParentId, Boolean sendAsNoReply) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        
        mail.setToAddresses(toAddresses);
        //mail.setBccAddresses(CRMUtils.GetBccTo());
        mail.saveAsActivity = false;
        mail.setSubject(Subject);
        mail.setHtmlBody(bodyHTML);
        mail.setCharset('UTF-8');                             
        if (!String.isBlank(bodyText)) mail.setPlainTextBody(bodyText);    
        if (!String.isBlank(replyToEmail)) mail.setReplyTo(replyToEmail);

        if(sendAsNoReply){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@jaguarexperience.com'];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
        }   

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        System.debug('email created via apex'); 
        if (insertTask && TaskParentId!=null) {
        
            Task t = new Task(
                WhatId = TaskParentId,
                Subject='Email: ' + Subject,
                Description=bodyHTML,
                Status='Completed',
                Type='Email'
            );
            
            insert t;
               
        }
        
    }
    
    public static void SendEmail(String toAddress, String senderName, String Subject, 
                                 String bodyHTML) { 
        List<String> Recipients = new List<String>();
        if (toAddress.contains(',')) {
            Recipients = toAddress.split(',');
        } else if (toAddress.contains(';')) {
            Recipients = toAddress.split(';');
        } else {
            Recipients.add(toAddress);
        }
        SendEmailWorker(Recipients, senderName, Subject, bodyHTML, null, null, false, null,false);                             
    }    

    public static void SendEmail(List<String> toAddresses, String senderName, String Subject, 
                                 String bodyHTML) { 
        SendEmailWorker(toAddresses, senderName, Subject, bodyHTML, null, null, false, null,false);           
    }
    
    public static void SendEmail(List<String> toAddresses, String senderName, String Subject, 
                                 String bodyHTML, String bodyText, String replyToEmail, Boolean insertTask, Id TaskParentId){
        SendEmailWorker(toAddresses, senderName, Subject, bodyHTML, bodyText, replyToEmail, insertTask, taskParentId,false);                             
    }
    
    public static void SendEmail(List<String> toAddresses, String senderName, String Subject, 
                                 String bodyHTML, String bodyText, String replyToEmail, Boolean insertTask, Id TaskParentId, Boolean SendAsNoReply) { 
        SendEmailWorker(toAddresses, senderName, Subject, bodyHTML, bodyText, replyToEmail, insertTask, TaskParentId, SendAsNoReply);                                 
    }
     
    public static boolean validateEmail(String sEmail) {
    
        if (String.isBlank(sEmail)) return false;
    
        Boolean res = true; 
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(sEmail);
    
        if (!MyMatcher.matches()) 
            res = false;
        return res; 
    } 
    
}