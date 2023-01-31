@IsTest
public class AvokaFormInformation_Retriever_Test {
    
    @testSetup 
    static void setup(){
        List<AvokaFormMapping_Local__c> avokaLocal = new List<AvokaFormMapping_Local__c>();
        
        AvokaFormMapping_Local__c localIN = new AvokaFormMapping_Local__c();
        localIN.name = 'in';
        localIN.Country_ISO_Code__c = 'IN';
        localIN.Currency__c = 'INR';
        
        AvokaFormMapping_Local__c localDZ = new AvokaFormMapping_Local__c();
        localDZ.name = 'dz';
        localDZ.Country_ISO_Code__c = 'DZ';
        localDZ.Currency__c = 'DZD';
        
        avokaLocal.add(localIN);
        avokaLocal.add(localDZ);
        
        insert avokaLocal;
        
        AvokaFormMapping_Brand__c avokaBrand = new AvokaFormMapping_Brand__c();
        avokaBrand.Name = 'jag';
        avokaBrand.Salesforce_Value__c = ' Jaguar';
        insert avokaBrand;
        
        List<AvokaRequestTypeToLeadRecordType__c> avokaRecordTypes = new List<AvokaRequestTypeToLeadRecordType__c>();
        
        AvokaRequestTypeToLeadRecordType__c testDriveRT = new AvokaRequestTypeToLeadRecordType__c();
        testDriveRT.Name = 'tdsf';
        testDriveRT.AssignToRetailerQueue__c = True;
        testDriveRT.Lead_Record_Type__c = 'Test_Drive_Request';
        
        AvokaRequestTypeToLeadRecordType__c genericRT = new AvokaRequestTypeToLeadRecordType__c();
        genericRT.Name = 'peb';
        genericRT.AssignToRetailerQueue__c = True;
        genericRT.Lead_Record_Type__c = 'Generic';
        
        avokaRecordTypes.add(testDriveRT);
        avokaRecordTypes.add(genericRT);
        
        insert avokaRecordTypes;
    }
    
    @IsTest
    public static void Retrieve_ReturnsAnAvokaFormInformationObject_WhenPassedAString(){
        AvokaFormInformation_Retriever avokaFormInfo_Retriever = new AvokaFormInformation_Retriever();
        
        Request__c request = TestClass_RequestCreator.Build();
        
        AvokaFormInformation actualObject = avokaFormInfo_Retriever.Retrieve(request);
        
        System.assertNotEquals(null, actualObject);
    }
    
    @IsTest
    public static void Retrieve_ReturnsAnAvokaFormInformationObject_MENATest(){
        AvokaFormInformation_Retriever avokaFormInfo_Retriever = new AvokaFormInformation_Retriever();
        
        Request__c request = TestClass_RequestCreator.Build();
        
        request.Request_Source__c = 'jag-peb-me-en';
        request.Country_Code__c = 'DZ';
        
        AvokaFormInformation actualObject = avokaFormInfo_Retriever.Retrieve(request);
        
        System.assertNotEquals(null, actualObject);
    }
    
}