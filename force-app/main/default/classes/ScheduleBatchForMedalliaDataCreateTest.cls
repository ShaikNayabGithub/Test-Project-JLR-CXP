@isTest
public class ScheduleBatchForMedalliaDataCreateTest {
    @testSetup static void setup() {
        Account testAccount = new Account();
        testAccount.LastName = 'Testrec Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'testrec@test.test';
        testAccount.Customer_Journey_Stage__c = 'Take Ownership';
        insert testAccount;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Handover';
        opp.Brand__c = vehicleSpec1.Id;
        opp.AccountId = testAccount.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        //opp.OwnerId=user.id;
        insert opp;
        Account ac2 = new Account(name ='Grazittitest2') ;
        insert ac2; 
        
        AP_Survey__c objAP_Survey = new AP_Survey__c(Active__c = true,Survey_Type__c='Purchase');
        insert objAP_Survey;
        
        List<AP_Survey_Question__c> qusList = new List<AP_Survey_Question__c>();
        AP_Survey_Question__c apQus;
        
        apQus = new AP_Survey_Question__c();
        apQus.Answer_Type__c = 'Star Rating';
        apQus.AP_Survey__c = objAP_Survey.Id;
        apQus.Status__c = 'Active';
        apQus.Question_Type__c = 'Likelihood to Recommend Retailer';
        apQus.Medallia_Field_API__c = 'q_jlr_sales_ltr_scale11';
        apQus.English__c = 'Based on your recent purchase experience, how likely is it that you will recommend the Retailer?';
        qusList.add(apQus);
        
        apQus = new AP_Survey_Question__c();
        apQus.Answer_Type__c = 'Text';
        apQus.AP_Survey__c = objAP_Survey.Id;
        apQus.Status__c = 'Active';
        apQus.Question_Type__c = 'Why do you say that';
        apQus.Medallia_Field_API__c = 'q_jlr_ltr_cmt';
        apQus.English__c = 'Please Tell us Why You Say That';
        qusList.add(apQus);
        
        apQus = new AP_Survey_Question__c();
        apQus.Answer_Type__c = 'Radio';
        apQus.AP_Survey__c = objAP_Survey.Id;
        apQus.Status__c = 'Active';
        apQus.Question_Type__c = 'Post Sales Contact';
        apQus.Medallia_Field_API__c = 'q_jlr_sales_contact_scale11na';
        apQus.Medallia_Field_API_2__c = 'q_jlr_sales_contact_sv_alt';
        apQus.English__c = 'Retailer contact after Delivery / Handover of your new vehicle';
        qusList.add(apQus);
        
        apQus = new AP_Survey_Question__c();
        apQus.Answer_Type__c = 'Checkbox';
        apQus.AP_Survey__c = objAP_Survey.Id;
        apQus.Status__c = 'Active';
        apQus.Question_Type__c = 'Further details';
        apQus.Medallia_Field_API__c = 'q_jlr_sales_furtherinfo_alt';
        apQus.Medallia_Field_API_2__c = 'q_jlr_sales_contact_sv_alt';
        apQus.English__c = 'If you would like to provide any further details about your experience at the retailer';
        qusList.add(apQus);
        
        Insert qusList;
        
        AP_Survey_Response__c objAP_Survey_Response = new AP_Survey_Response__c(Survey__c = objAP_Survey.Id, Opportunity__c = opp.Id, Customer__c = ac2.Id);
        Insert objAP_Survey_Response;
        List<AP_Survey_Responses_Lines__c> objAP_Survey_Response_Line_List = new List<AP_Survey_Responses_Lines__c>();
        
        AP_Survey_Responses_Lines__c objAP_Survey_Response_Line;
        objAP_Survey_Response_Line = new AP_Survey_Responses_Lines__c();
        objAP_Survey_Response_Line.AP_Survey_Question__c = qusList[0].Id;
        objAP_Survey_Response_Line.Answer_Rating__c = 7;
        objAP_Survey_Response_Line.Survey_Response__c = objAP_Survey_Response.Id;
        objAP_Survey_Response_Line_List.add(objAP_Survey_Response_Line);
        
        
        objAP_Survey_Response_Line = new AP_Survey_Responses_Lines__c();
        objAP_Survey_Response_Line.AP_Survey_Question__c = qusList[1].Id;
        objAP_Survey_Response_Line.Answer_Rating__c = 7;
        objAP_Survey_Response_Line.Survey_Response__c = objAP_Survey_Response.Id;
        objAP_Survey_Response_Line_List.add(objAP_Survey_Response_Line);
        
        
        objAP_Survey_Response_Line = new AP_Survey_Responses_Lines__c();
        objAP_Survey_Response_Line.AP_Survey_Question__c = qusList[2].Id;
        objAP_Survey_Response_Line.Answer_Rating__c = 7;
        objAP_Survey_Response_Line.Survey_Response__c = objAP_Survey_Response.Id;
        objAP_Survey_Response_Line_List.add(objAP_Survey_Response_Line);
        
        objAP_Survey_Response_Line = new AP_Survey_Responses_Lines__c();
        objAP_Survey_Response_Line.AP_Survey_Question__c = qusList[2].Id;
        objAP_Survey_Response_Line.Answer_Rating__c = 7;
        objAP_Survey_Response_Line.Answer_Verbatim__c = 'Test Answer Verbatim';
        objAP_Survey_Response_Line.Survey_Response__c = objAP_Survey_Response.Id;
        objAP_Survey_Response_Line.Medallia_Value__c = '1,2';
        objAP_Survey_Response_Line_List.add(objAP_Survey_Response_Line);
        
        objAP_Survey_Response_Line = new AP_Survey_Responses_Lines__c();
        objAP_Survey_Response_Line.AP_Survey_Question__c = qusList[3].Id;
        objAP_Survey_Response_Line.Answer_Verbatim__c = 'Courtesy car (Jaguar);Other(Test Other Option)';
        objAP_Survey_Response_Line.Survey_Response__c = objAP_Survey_Response.Id;
        objAP_Survey_Response_Line_List.add(objAP_Survey_Response_Line);
        
        objAP_Survey_Response_Line = new AP_Survey_Responses_Lines__c();
        objAP_Survey_Response_Line.AP_Survey_Question__c = qusList[3].Id;
        objAP_Survey_Response_Line.Answer_Verbatim__c = 'Other(Test Other Option)';
        objAP_Survey_Response_Line.Survey_Response__c = objAP_Survey_Response.Id;
        objAP_Survey_Response_Line_List.add(objAP_Survey_Response_Line);
        
        insert objAP_Survey_Response_Line_List;
    }
    
    @IsTest
    static void Test_MedalliaDataCreateTypePurchase(){
        List<Medallia_Data__c> mdList = [Select Id from Medallia_Data__c];
        system.assertEquals(0, mdList.size());
        
        test.startTest();
        ScheduleBatchForMedalliaDataCreate testsche = new ScheduleBatchForMedalliaDataCreate();
        testsche.execute(null);
        test.stopTest();
        
        List<Medallia_Data__c> mdListupdated = [Select Id from Medallia_Data__c];
        system.assertEquals(1, mdListupdated.size());
        
    }
    
    @IsTest
    static void Test_MedalliaDataCreateTypeService(){        
        AP_Survey__c objAP_Survey = [Select Id, Active__c,Survey_Type__c From AP_Survey__c Limit 1];
        objAP_Survey.Survey_Type__c = 'Service';
        update objAP_Survey;
        
        List<Medallia_Data__c> mdList = [Select Id from Medallia_Data__c];
        system.assertEquals(0, mdList.size());
        
        test.startTest();
        ScheduleBatchForMedalliaDataCreate testsche = new ScheduleBatchForMedalliaDataCreate();
        testsche.execute(null);
        test.stopTest();
        
        List<Medallia_Data__c> mdListupdated = [Select Id from Medallia_Data__c];
        system.assertEquals(1, mdListupdated.size());
    }  
}