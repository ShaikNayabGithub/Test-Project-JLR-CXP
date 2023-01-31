@isTest(seeAllData=false)
public class FileUpload_Controller_Test {

    static testmethod void Service_FileUpload(){
        staticResource objSr =[select Id, Body FROM StaticResource WHERE Name = 'Service_Upload' LIMIT 1 ];
        Test.startTest();
		
        Id [] fixedSearchResults= new Id[]{'01p5E0000002LA3QAM','01p2400000DAN5UAAX','01p2400000DAN5ZAAX','01p1o00000DjB4HAAV','01p2400000DAN5jAAH','01p2400000DAN5YAAX','01p2400000DAN5VAAX','01p1o00000DjB4nAAF','01p1o00000DeKwbAAF','01p1o00000DeKwXAAV'};
       	Test.setFixedSearchResults(fixedSearchResults);
        FileUpload_Controller controller = new FileUpload_Controller();
        controller.getProcessors();
        controller.file=objSr.Body;
        controller.fileName='TestFile.csv';
        controller.contentType='.csv';
        controller.processorName='Service';
        controller.Upload();
        Test.stopTest();
    }
    
    static testmethod void Finance_FileUpload(){
        staticResource objSr =[select Id, Body FROM StaticResource WHERE Name = 'Service_Upload' LIMIT 1 ];
        Test.startTest();
		
        Id [] fixedSearchResults= new Id[]{'01p5E0000002LA3QAM','01p2400000DAN5UAAX','01p2400000DAN5ZAAX','01p1o00000DjB4HAAV','01p2400000DAN5jAAH','01p2400000DAN5YAAX','01p2400000DAN5VAAX','01p1o00000DjB4nAAF','01p1o00000DeKwbAAF','01p1o00000DeKwXAAV'};
       	Test.setFixedSearchResults(fixedSearchResults);
        FileUpload_Controller controller = new FileUpload_Controller();
        controller.getProcessors();
        controller.file=objSr.Body;
        controller.fileName='TestFile.csv';
        controller.contentType='.csv';
        controller.processorName='Finance';
        controller.Upload();
        Test.stopTest();
    }
    
    static testmethod void Roadside_FileUpload(){
        staticResource objSr =[select Id, Body FROM StaticResource WHERE Name = 'Service_Upload' LIMIT 1 ];
        Test.startTest();
		
        Id [] fixedSearchResults= new Id[]{'01p5E0000002LA3QAM','01p2400000DAN5UAAX','01p2400000DAN5ZAAX','01p1o00000DjB4HAAV','01p2400000DAN5jAAH','01p2400000DAN5YAAX','01p2400000DAN5VAAX','01p1o00000DjB4nAAF','01p1o00000DeKwbAAF','01p1o00000DeKwXAAV'};
       	Test.setFixedSearchResults(fixedSearchResults);
        FileUpload_Controller controller = new FileUpload_Controller();
        controller.getProcessors();
        controller.file=objSr.Body;
        controller.fileName='TestFile.csv';
        controller.contentType='.csv';
        controller.processorName='Roadside';
        controller.Upload();
        Test.stopTest();
    }
}