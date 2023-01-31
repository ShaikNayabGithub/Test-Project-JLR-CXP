public class LC_ProcessInstanceComment_Controller {
    
        @AuraEnabled
    public static string getComment(String recordId) {
       if(recordId == null || recordId.trim() == ''){
            return null;
        }
      //  String soqlQuery = 'SELECT Comments FROM ProcessInstanceStep where id =\''+Id+'\'';
        
       ProcessInstanceStep prHistory = [SELECT Comments FROM ProcessInstanceStep where Id =:recordId];
       
        return prHistory.Comments;

    }

}