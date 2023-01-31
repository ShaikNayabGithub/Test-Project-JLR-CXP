@isTest

public class JLR_FileUploadServiceScheduler_Test
{

    @testSetup static void setup() {  
        JLR_MobilStyx_Data__c objData = new JLR_MobilStyx_Data__c(Name='MobilStyx',JLR_Endpoint__c='http://132.148.132.131/JLRFileUploadService.asmx');
        insert objData;
    } 

    private static SchedulableContext  SCT;
   
    public static testmethod void UnitTest()
    {
        Test.setMock(WebServiceMock.class, new JLRFileUploadService_Mock()); 
        Test.starttest();
        JLR_FileUploadServiceScheduler obj = new JLR_FileUploadServiceScheduler();
        obj.execute(SCT);
        JLR_FileUploadServiceScheduler.WebserviceCaller();
        Test.stoptest();
    }
}