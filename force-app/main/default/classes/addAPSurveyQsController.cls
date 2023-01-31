public with sharing class addAPSurveyQsController {
   
    @AuraEnabled(cacheable = true)
    public static wrapClass getdata(String qId) {
        wrapClass wcObj = new wrapClass();
        wcObj.existingQuestion = new List<String>();
        wcObj.strSurveyName = '';
        if(qId != null){
            AP_Survey__c survey = [Select Id, Name,Survey_Type__c, (Select Id, Name From AP_Survey_Questions__r ) From AP_Survey__c Where Id =: qId];
            wcObj.strSurveyName =  survey.Survey_Type__c;
            wcObj.strSurveyId = survey.Name;
            if(survey.AP_Survey_Questions__r.size()>0){
                for(AP_Survey_Question__c sq : survey.AP_Survey_Questions__r){
                    wcObj.existingQuestion.add(sq.Name);                  
                }
            }
            return wcObj;
         }
      return wcObj;
    }

    public class wrapClass {
        @AuraEnabled
        public list<String> existingQuestion{get;set;}
        @AuraEnabled
        public string strSurveyName{get;set;}
        @AuraEnabled
        public string strSurveyId{get;set;}
        
}
}