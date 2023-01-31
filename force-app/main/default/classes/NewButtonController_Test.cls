@IsTest
public class NewButtonController_Test{
    @IsTest
    public static void RedirectToSearchPage_AssignsTheCorrectRecordType_ToTheNewPageReferenceObject(){
        
        Lead lead = new Lead();
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        NewButtonController buttonController = new NewButtonController(controller);
                
        String expectedRecordType = 'Generic';

        PageReference pageRef = Page.newLead;
        pageRef.getParameters().put('RecordType', expectedRecordType);
        Test.setCurrentPage(pageRef);

        PageReference searchPage = buttonController.redirectToSearchPage();
        String actualRecordType = searchPage.getParameters().get('RecordType');

        System.assertEquals(expectedRecordType, actualRecordType);
    }

    @IsTest
    public static void RedirectToSearchPage_InstantiatesThePageReferenceVariable_AsAPageDotSecrhFirstObject(){
        
        Lead lead = new Lead();
        ApexPages.StandardController controller = new ApexPages.StandardController(lead);
        NewButtonController buttonController = new NewButtonController(controller);
        PageReference expectedPageRef = Page.searchFirst;

        PageReference actualPageRef = buttonController.redirectToSearchPage();

        System.assertEquals(expectedPageRef.getUrl(), actualPageRef.getUrl());
    }
}