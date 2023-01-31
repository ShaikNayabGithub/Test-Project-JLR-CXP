public without sharing class ap_surveyController {
    
    @AuraEnabled(cacheable = true)
    public static surveywrap getSUrveyData(Id opportunityId) {
        system.debug('opportunityId'+opportunityId);
        try {
            System.debug('opportunityId--' +opportunityId);
            if (opportunityId != null) {
                String sObjName = opportunityId.getSObjectType().getDescribe().getName();
                String ISOCode = '';
                surveywrap swObj = new surveywrap();
                swObj.tradingName = '';
                swObj.errMsg = '';
                swObj.surveyConfig = new AP_Survey_Config__mdt();
                swObj.mapQIdtoAnswers = new Map < Id, List < AP_Survey_Answer__c >> ();
                swObj.mapQuestions = new Map < Id, AP_Survey_Question__c > ();
                swObj.mapQuestionsNumber = new Map < String, AP_Survey_Question__c > ();
                swObj.mapAnswers = new Map < Id, AP_Survey_Answer__c > ();
                swObj.mapQuestionswithPageNumber = new Map < String, List < AP_Survey_Question__c > > ();
                List < Opportunity > opList = new List < Opportunity > ();
                List < Service_Data__c > lstServiceData = new List < Service_Data__c > ();
                if (sObjName == 'Opportunity') {
                    
                    opList = [Select Id, AccountId, owner.Contact.Account.Trading_Name__c, AP_Purchase_Survey_Completed__c From Opportunity Where Id =: opportunityId];                    
                    swObj.OppId = opList[0].Id;
                    swObj.customerId = opList[0].AccountId;
                    swObj.surveyType = 'Purchase';
                    swObj.formHeader = Label.AP_Purchase_Survey_Form_Header;
                    if (opList[0].owner.ContactId != null) {
                        system.debug('test111');
                        List < Account > accountList = [Select Id, Trading_Name__c, Country_ISO_Code__c from Account Where Id =: [Select AccountId From Contact Where Id =: opList[0].owner.ContactId].AccountId];
                        if (accountList.size() > 0) {
                            swObj.tradingName = accountList[0].Trading_Name__c == Null ? '' : accountList[0].Trading_Name__c;
                            swObj.retailerId = accountList[0].Id;
                            if (accountList[0].Country_ISO_Code__c != null) {
                                ISOCode = accountList[0].Country_ISO_Code__c;
                                system.debug('accountList[0]'+accountList[0]);
                            }
                        }
                    }
                    ISOCode = ISOCode == '' || ISOCode == null ? 'SG' : ISOCode;
                } else { 
                    system.debug('test');
                    
                    swObj.formHeader = Label.AP_Service_Survey_Form_Header;
                    lstServiceData = [Select id, Account__c, AP_Service_Survey_Completed__c, Retailer_Name__c From Service_Data__c where id =: opportunityId];                   
                    if (lstServiceData[0].Account__c != null) {
                        swObj.customerId = lstServiceData[0].Account__c;
                        List < Account > accountList = [Select Id, Country_ISO_Code__c from Account Where Id =: lstServiceData[0].Account__c];
                        if (accountList.size() > 0) {
                            ISOCode = accountList[0].Country_ISO_Code__c;
                            system.debug('accountList[0]'+accountList[0]);
                        }
                    }
                    ISOCode = ISOCode == '' || ISOCode == null ? 'SG' : ISOCode;
                    if (lstServiceData[0].Retailer_Name__c != '') {
                        List < Account > aList = [Select Id, Trading_Name__c From Account Where Name =: lstServiceData[0].Retailer_Name__c AND RecordType.DeveloperName = 'Retailer'];
                        if (aList.size() > 0) {
                            swObj.retailerId = aList[0].Id;
                            swObj.tradingName = aList[0].Trading_Name__c == Null ? '' : aList[0].Trading_Name__c;
                        }
                    }
                    swObj.serviceId = lstServiceData[0].Id;
                    swObj.surveyType = 'Service';
                }
                List < AP_Survey_Config__mdt > surveyConfig = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, Link_Expired_Text_Message__c,
                                                               QualifiedApiName, Country_Name__c, Default_Language__c, Bilingual_Form__c, API_Name_of_Question__c, API_Name_of_Answer__c, Hint_Text_for_Text_Answers__c,
                                                               Purchase_Survey_Confirmation_Message__c, Service_Survey_Confirmation_Message__c, English_Purchase_Confirmation_Message__c,
                                                               English_Service_Confirmation_Message__c, API_Name_of_Answer_in_English__c, API_Name_of_Question_in_English__c, Text_for_Local_Language__c,
                                                               Translation_for_Required__c, Translation_for_Page__c, Translation_for_Of__c, Translation_for_Next__c, Translation_for_Submit__c,
                                                               Translation_for_Back__c, Heading_1_in_English__c, Heading_2_in_English__c, Heading_1_Translated__c, Heading_2_Translated__c, Service_Survey_Heading_2_English__c, Service_Survey_Heading_2_Translated__c,
                                                               ps_Your_details_English__c,PS_Permission_box_English__c,PS_To_agree_English__c,Sec_Header_1_English__c,Sec_Header_2_English__c,Sec_Header_3_English__c,Sec_Header_4_English__c,
                                                               Sec_Header_5_English__c,Sec_Header_6_English__c,Sec_Header_7_English__c,Sec_Header_8_English__c,Sec_Header_9_English__c,Sec_Header_10_English__c,Sec_Header_11_English__c,
                                                               Sec_Header_12_English__c,Sec_Header_13_English__c,Sec_Header_14_English__c,Sec_Header_15_English__c,Sec_Header_16_English__c,Sec_Header_17_English__c,
                                                               Sec_Header_1_Translated__c,Sec_Header_2_Translated__c,Sec_Header_3_Translated__c,Sec_Header_4_Translated__c,Sec_Header_5_Translated__c,Sec_Header_6_Translated__c,
                                                               Sec_Header_7_Translated__c,Sec_Header_8_Translated__c,Sec_Header_9_Translated__c,Sec_Header_10_Translated__c,Sec_Header_11_Translated__c,Sec_Header_12_Translated__c,
                                                               Sec_Header_13_Translated__c,Sec_Header_14_Translated__c,Sec_Header_15_Translated__c,Sec_Header_16_Translated__c,Sec_Header_17_Translated__c
                                                               
                                                               FROM AP_Survey_Config__mdt WHERE Label =: ISOCode
                                                              ];
                if (surveyConfig.size() == 0) {
                    swObj.errMsg = 'You are not allowed to participate in this survey. Please contact your retailer for more information.';                    
                    return swObj;
                }
                if (surveyConfig.size() > 0) {
                    swObj.surveyConfig = surveyConfig[0];
                    if (sObjName == 'Opportunity') {
                        if (opList[0].AP_Purchase_Survey_Completed__c) {
                            swObj.errMsg = swObj.surveyConfig.Link_Expired_Text_Message__c;
                            return swObj;
                        }
                    } else {
                        if (lstServiceData[0].AP_Service_Survey_Completed__c) {
                            swObj.errMsg = swObj.surveyConfig.Link_Expired_Text_Message__c;
                            return swObj;
                        }
                    }
                    String qFields = '';
                    String ansFields = '';
                    if (swObj.surveyConfig.Bilingual_Form__c) {
                        qFields = swObj.surveyConfig.API_Name_of_Question__c + ',' + swObj.surveyConfig.API_Name_of_Question_in_English__c;
                        ansFields = swObj.surveyConfig.API_Name_of_Answer__c + ',' + swObj.surveyConfig.API_Name_of_Answer_in_English__c;
                    } else {
                        qFields = swObj.surveyConfig.API_Name_of_Question__c;
                        ansFields = swObj.surveyConfig.API_Name_of_Answer__c;
                    }
                    
                    String surveyType = sObjName == 'Opportunity' ? 'Purchase' : 'Service';
                    List < AP_Survey__c > lstAPSurvey = [Select Id, Name From AP_Survey__c Where Active__c = true AND Survey_Type__c =: surveyType ORDER BY CreatedDate DESC LIMIT 1];
                    if (lstAPSurvey.size() == 0) {
                        swObj.errMsg = 'No active Survey found.';
                        return swObj;
                    }
                    Id surveyId = lstAPSurvey[0].Id;
                    swObj.surveyId = surveyId;
                    String queryString = 'Select Id,Name,Answer_Type__c,Survey_Form_Page_No__c,Primary_Dependent__c,Required__c	,Sort_Order__c,Question_Type__c,' + qFields + ', (Select Id,Dependent_Question__c,Question__c,Sort_Order__c,Score__c,Other_Dependent_Questions__c,Medallia_Value__c,' + ansFields + ' From AP_Survey_Answers__r ORDER BY Sort_Order__c ASC) From AP_Survey_Question__c Where AP_Survey__c =:surveyId AND Status__c = \'Active\' ORDER BY Sort_Order__c ASC';                   
                    List < AP_Survey_Answer__c > lstAnswers = new List < AP_Survey_Answer__c > ();
                    for (AP_Survey_Question__c sq: database.query(queryString)) {
                        if (!swObj.mapQuestionswithPageNumber.containskey(sq.Survey_Form_Page_No__c)) {
                            swObj.mapQuestionswithPageNumber.put(sq.Survey_Form_Page_No__c, new List < AP_Survey_Question__c > {
                                sq
                                    });
                        } else {
                            swObj.mapQuestionswithPageNumber.get(sq.Survey_Form_Page_No__c).add(sq);
                        }
                        
                        swObj.mapQuestions.put(sq.Id, sq);
                        swObj.mapQIdtoAnswers.put(sq.Id, new List < AP_Survey_Answer__c > (sq.AP_Survey_Answers__r));
                        swObj.mapQuestionsNumber.put(sq.Name, sq);
                        lstAnswers.addall(sq.AP_Survey_Answers__r);
                    }
                    for (AP_Survey_Answer__c ans: lstAnswers) {
                        swObj.mapAnswers.put(ans.Id, ans);
                    }
                    swObj.totalQuestion = swObj.mapQuestionswithPageNumber.keyset().size();
                }
                return swObj;
            }else{
                surveywrap swObj = new surveywrap();
                swObj.errMsg = 'You are not allowed to participate in this survey. Please contact your retailer for more information.';
                swObj.tradingName = '';
                swObj.formHeader = '';
                return swObj;
            }           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string saveSurveyResponses(String strResponses) {
        Savepoint sp = Database.setSavepoint();
        try {
            List < responseWrapper > lstResponses = (List < responseWrapper > ) System.JSON.deserialize(strResponses, List < responseWrapper > .class);
            system.debug('lstResponses'+lstResponses);
            system.debug('lstResponses.size()'+lstResponses.size());
            if (lstResponses.size() > 0) {
                Integer answeredCount = 0;
                Map < String, String > mapresponseWrapper = new Map < String, String > ();
                Map < String, String > mapresponseWrapperRating = new Map < String, String > ();
                for (responseWrapper response: lstResponses) {
                    if (response.qTYpe != null) {
                        if ((!response.isUnanswered) && (response.answerType == 'Radio' || response.answerType == 'Star Rating')) {                           
                            mapresponseWrapper.put(response.qTYpe, response.scoreRating);
                        }
                    }
                    if (!response.isUnanswered) {
                        answeredCount++;
                        system.debug('answeredCount'+answeredCount);
                    }
                }
                Id objId = lstResponses[0].objectId;
                String sObjName = objId.getSObjectType().getDescribe().getName();
                string redFlagEmail = '';
                List < Account > retailerAccount = [Select Sales_Point_of_Contact__c, Sales_Point_of_Contact__r.Email, Service_Point_of_Contact__c, Service_Point_of_Contact__r.Email From Account Where id =: lstResponses[0].retailerId];
                system.debug('retailerAccount'+retailerAccount);
                AP_Survey_Response__c surveyResponse = new AP_Survey_Response__c();
                surveyResponse.Customer__c = lstResponses[0].customerId;
                surveyResponse.Retailer__c = lstResponses[0].retailerId;
                surveyResponse.Survey__c = lstResponses[0].surveyId;
                surveyResponse.NPS_Rating__c = lstResponses[0].npsRating;
                system.debug('surveyResponse.Customer__c'+surveyResponse.Customer__c);
                system.debug('surveyResponse.Retailer__c'+surveyResponse.Retailer__c);
                system.debug('surveyResponse.Survey__c'+surveyResponse.Survey__c);
                system.debug('surveyResponse.NPS_Rating__c'+surveyResponse.NPS_Rating__c);
                if (sObjName == 'Opportunity') {
                    if (lstResponses[0].npsRating <= 6) {
                        if (retailerAccount[0].Sales_Point_of_Contact__c != null) {
                            surveyResponse.Red_Flag_Contact_Email__c = retailerAccount[0].Sales_Point_of_Contact__r.Email;
                        }
                    }
                    surveyResponse.Opportunity__c = lstResponses[0].objectId;
                    if (mapresponseWrapper.containsKey('Making You Feel Welcome')) {
                        if (mapresponseWrapper.get('Making You Feel Welcome') != '') {
                            surveyResponse.Making_You_Feel_Welcome__c = Integer.valueOf(mapresponseWrapper.get('Making You Feel Welcome'));
                        }
                    }
                    if (mapresponseWrapper.containsKey('Sales Consultant Recommendation')) {
                        if (mapresponseWrapper.get('Sales Consultant Recommendation') != '') {
                            surveyResponse.Sales_Consultant_Recommendation__c = Integer.valueof(mapresponseWrapper.get('Sales Consultant Recommendation'));
                        }
                    }
                    if (mapresponseWrapper.containsKey('Test Drive Experience')) {
                        if (mapresponseWrapper.get('Test Drive Experience') != '') {
                            surveyResponse.Test_Drive_Experience__c = Integer.valueOf(mapresponseWrapper.get('Test Drive Experience'));
                        }
                    }
                    if (mapresponseWrapper.containsKey('Handover Experience')) {
                        if (mapresponseWrapper.get('Handover Experience') != '') {
                            surveyResponse.Handover_Experience__c = Integer.valueOf(mapresponseWrapper.get('Handover Experience'));
                        }
                    } 
                    if (mapresponseWrapper.containsKey('Understanding Needs')) {
                        if (mapresponseWrapper.get('Understanding Needs') != '') {
                            surveyResponse.Understanding_Needs__c = Integer.valueOf(mapresponseWrapper.get('Understanding Needs'));
                        }
                    }
                    if (mapresponseWrapper.containsKey('Fulfilment of Commitments')) {
                        if (mapresponseWrapper.get('Fulfilment of Commitments') != '') {
                            surveyResponse.Fulfilment_of_Commitments__c = Integer.valueOf(mapresponseWrapper.get('Fulfilment of Commitments'));
                        }
                    }
                } else { system.debug('else');
                        if (lstResponses[0].npsRating <= 6) {
                            if (retailerAccount[0].Service_Point_of_Contact__c != null) {
                                surveyResponse.Red_Flag_Contact_Email__c = retailerAccount[0].Service_Point_of_Contact__r.Email;
                            }
                        }
                        surveyResponse.Service__c = lstResponses[0].objectId;
                        if (mapresponseWrapper.containsKey('How Quickly Vehicle was Seen')) {
                            if (mapresponseWrapper.get('How Quickly Vehicle was Seen') != '') {
                                surveyResponse.Booking_Process__c = Integer.valueOf(mapresponseWrapper.get('How Quickly Vehicle was Seen'));
                            }
                        }
                        if (mapresponseWrapper.containsKey('Service Advisor Recommendation')) {
                            if (mapresponseWrapper.get('Service Advisor Recommendation') != '') {
                                surveyResponse.Service_Advisor_Recommendation__c = Integer.valueOf(mapresponseWrapper.get('Service Advisor Recommendation'));
                            }
                        }
                        if (mapresponseWrapper.containsKey('Post Work Explanation')) {
                            if (mapresponseWrapper.get('Post Work Explanation') != '') {
                                surveyResponse.Post_Work_Explanation__c = Integer.valueOf(mapresponseWrapper.get('Post Work Explanation'));
                            }
                        }
                        if (mapresponseWrapper.containsKey('Vehicle Cleanliness and Condition')) {
                            if (mapresponseWrapper.get('Vehicle Cleanliness and Condition') != '') {
                                surveyResponse.Vehicle_Cleanliness_Condition__c = Integer.valueOf(mapresponseWrapper.get('Vehicle Cleanliness and Condition'));
                            }
                        }
                        if (mapresponseWrapper.containsKey('Value for Money')) {
                            if (mapresponseWrapper.get('Value for Money') != '') {
                                surveyResponse.Cost_of_Service_Repair__c = Integer.valueOf(mapresponseWrapper.get('Value for Money'));
                            }
                        }
                        if (mapresponseWrapper.containsKey('Fixed Right First Time')) {
                            if (mapresponseWrapper.get('Fixed Right First Time') != '') {
                                surveyResponse.Right_First_Time__c = Integer.valueOf(mapresponseWrapper.get('Fixed Right First Time'));
                            }
                        }
                       }
                system.debug('lstResponses[0].language'+lstResponses[0].language);
                surveyResponse.Language__c = lstResponses[0].language;
                surveyResponse.Response_Date__c = System.today();
                surveyResponse.Total_Answers__c = answeredCount;
                system.debug('lstResponses[0].language'+ surveyResponse);
                insert surveyResponse;
                system.debug('surveyResponse' +surveyResponse);
                List < AP_Survey_Responses_Lines__c > lstSurveyResponse = new List < AP_Survey_Responses_Lines__c > ();
                
                for (responseWrapper response: lstResponses) {
                    AP_Survey_Responses_Lines__c lines = new AP_Survey_Responses_Lines__c();
                    lines.Survey_Response__c = surveyResponse.Id;
                    lines.Question_Type__c = response.qTYpe;
                    system.debug('lines.Question_Type__c' +lines.Question_Type__c);
                    // lines.Answer__c = response.score;
                    lines.Response_Type__c = response.answerType == 'Text' || response.answerType == 'Checkbox' ? 'Text' : 'Number';
                    if (response.answerType == 'Text' || response.answerType == 'Checkbox') {
                        system.debug('response.answerType' +response.answerType);
                        system.debug('lines.Response_Type__c' +lines.Response_Type__c);
                        system.debug('response.scoreRating' +response.scoreRating);
                        
                        lines.Answer_Verbatim__c = response.scoreRating;
                        if(response.answerType == 'Checkbox'){
                            if(response.medalliaValue != null && string.isNotBlank(response.medalliaValue)){
                                system.debug('response.medalliaValue' +response.medalliaValue);
                                String y = response.medalliaValue.Substring(0,response.medalliaValue.length()-1);
                                if(string.isNotBlank(y) && y != 'undefined' && !response.isUnanswered){
                                    system.debug('y' +y);
                                    lines.Medallia_Value__c = y; 
                                    system.debug('y' +lines.Medallia_Value__c);
                                    
                                }
                            }
                        }
                        
                    } else { system.debug('else2');
                            if (response.scoreRating != '') {
                                system.debug('response.scoreRating' +response.scoreRating);
                                lines.Answer_Rating__c = Integer.valueOf(response.scoreRating);
                            } else { system.debug('response.scoreText' +response.scoreText);
                                    lines.Answer_Verbatim__c = response.scoreText;
                                   }
                            
                            if( !response.isUnanswered && response.medalliaValue != null && string.isNotBlank(response.medalliaValue)){
                                system.debug('response.medalliaValue' +response.medalliaValue);
                                String y = response.medalliaValue.Substring(0,response.medalliaValue.length()-1);
                                if(string.isNotBlank(y) && y != 'undefined'){
                                    lines.Medallia_Value__c = y; 
                                    system.debug('y' +lines.Medallia_Value__c);
                                }
                            }
                           }
                    
                    lines.AP_Survey_Question__c = response.questionId;
                    system.debug(' lines.AP_Survey_Question__c' +lines.AP_Survey_Question__c);
                    lines.Unanswered__c = response.isUnanswered;
                    system.debug('lines'+lines);
                    lstSurveyResponse.add(lines);
                }
                Insert lstSurveyResponse;
                system.debug('lines'+lstSurveyResponse.size());
                if (sObjName == 'Opportunity') {
                    Opportunity op = new Opportunity();
                    op.AP_Purchase_Survey_Completed__c = true;
                    op.AP_Purchase_Survey_Completed_Date__c = System.today();
                    op.Id = lstResponses[0].objectId;
                    update op;
                } else {
                    Service_Data__c service = new Service_Data__c();
                    service.id = lstResponses[0].objectId;
                    service.AP_Service_Survey_Completed_Date__c = System.today();
                    service.AP_Service_Survey_Completed__c = true;
                    update service;
                    
                }
                
            }
            return 'success';
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage()+e.getLineNumber());
        }
    }
    
    
    public class surveywrap {
        @AuraEnabled
        public string tradingName {
            get;
            set;
        }
        
        @AuraEnabled
        public string surveyType {
            get;
            set;
        }
        
        @AuraEnabled
        public AP_Survey_Config__mdt surveyConfig {
            get;
            set;
        }
        
        @AuraEnabled
        public List < String > country {
            get;
            set;
        }
        
        @AuraEnabled
        public string errMsg {
            get;
            set;
        }
        
        @AuraEnabled
        public string formHeader {
            get;
            set;
        }
        
        @AuraEnabled
        public Map < Id, List < AP_Survey_Answer__c >> mapQIdtoAnswers {
            get;
            set;
        }
        
        @AuraEnabled
        public Map < Id, AP_Survey_Question__c > mapQuestions {
            get;
            set;
        }
        
        @AuraEnabled
        public Map < String, AP_Survey_Question__c > mapQuestionsNumber {
            get;
            set;
        }
        
        @AuraEnabled
        public Map < String, List < AP_Survey_Question__c > > mapQuestionswithPageNumber {
            get;
            set;
        }
        
        
        @AuraEnabled
        public Integer totalQuestion {
            get;
            set;
        }
        
        @AuraEnabled
        public Id OppId {
            get;
            set;
        }
        @AuraEnabled
        public Id serviceId {
            get;
            set;
        }
        
        @AuraEnabled
        public Id surveyId {
            get;
            set;
        }
        
        @AuraEnabled
        public Id customerId {
            get;
            set;
        }
        
        @AuraEnabled
        public Id retailerId {
            get;
            set;
        }
        
        @AuraEnabled
        public Map < Id, AP_Survey_Answer__c > mapAnswers {
            get;
            set;
        }
        
    }
    
    public class responseWrapper {
        public String customerId;
        public String retailerId;
        public String surveyId;
        public Id objectId;
        public String language;
        public String questionId;
        public String selectedRadioAnswer;
        public String selectedTextAnswer;
        public String selectedStarAnswer;
        public String answerType;
        public String qTYpe;
        public String scoreRating;
        public String scoreText;
        public Boolean isUnanswered;
        public Integer npsRating;
        public String medalliaValue;
    }
}