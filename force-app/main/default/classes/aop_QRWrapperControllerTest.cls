@isTest
private class aop_QRWrapperControllerTest {

    static testMethod void TestConvertLastNameToUpperReturnsUpperOfString() {
       	string lastName = 'Barnes';
       	
        QRWrapperController qrController = new QRWrapperController();
        qrController.setLastNameString(lastName);
        
        string result = qrController.getUpperLastName();
        
        System.assertEquals('BARNES', result);
    }
    
    static testMethod void TestConvertNameToUpperReturnsUpperOfString() {
       	string lastName = 'Holly';
       	
        QRWrapperController qrController = new QRWrapperController();
        qrController.setFirstNameString(lastName);
        
        string result = qrController.getUpperName();
        
        System.assertEquals('HOLLY', result);
    }
    
    static testMethod void TestgetFormatDateReturnsDateString() {
       	DateTime newDate = DateTime.newInstance(2001,1,1);
       	System.debug(newDate);
       	aop_TimeZone_Offsets__c campTimeZone = new aop_TimeZone_Offsets__c(Name = 'GMT', aop_Campaign_TimeZone__c = 'GMT');
       	Campaign newCamp = new Campaign(Name = 'newCamp', ExpectedResponse = 3, aop_Event_TimeZone__c = 'GMT', Market_ID__c = 'IN');
       	insert newCamp;
       	insert campTimeZone;
       	
        QRWrapperController qrController = new QRWrapperController();
        qrController.setUnFormatDate(newDate);
        qrController.setCampId(newCamp.Id);
        qrController.setCampTimeZone('GMT');
        
        string result = qrController.getformatDate();
        
        System.assertEquals('01/01/2001', result);
    }
    
    static testMethod void TestConvertEventNameToUpperReturnsUpperString() {
       	string lastName = 'Event';
       	
        QRWrapperController qrController = new QRWrapperController();
        qrController.setEventNameString(lastName);
        
        string result = qrController.getUpperEventName();
        
        System.assertEquals('EVENT', result);
    }
}