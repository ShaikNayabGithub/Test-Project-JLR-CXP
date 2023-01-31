@isTest
public class JLRFileUploadService_Test
{
  public static testmethod void testrun()
    {
        JLR_MobilStyx_Data__c objData = new JLR_MobilStyx_Data__c();
        objData.Name = 'MobilStyx';
        objData.JLR_Endpoint__c = 'http://132.148.132.131/JLRFileUploadService.asmx';
        insert objData;
        Test.setMock(WebServiceMock.class, new JLRFileUploadService_Mock());
        JLRFileUploadService.UploadFilesToSFResponse_element  objUPSFRE = new JLRFileUploadService.UploadFilesToSFResponse_element();
        JLRFileUploadService.UploadFilesToSF_element objUPSFE = new JLRFileUploadService.UploadFilesToSF_element();
        JLRFileUploadService.JLRFileUploadServiceSoap objJLRFUSS = new JLRFileUploadService.JLRFileUploadServiceSoap();
        test.starttest(); 
        string s= objJLRFUSS.UploadFilesToSF();   
        test.stoptest();
        system.assertEquals(s,'Test');
    }
}