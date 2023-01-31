@isTest
private class VerifyContactDataControllerTest {
    
    @testSetup static void setup() {
        Account retailer = new Account();
        retailer.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
        retailer.LastName = 'test';
        retailer.FirstName = 'Valid Firstname';
        retailer.PersonMailingStreet = 'Valid Street';
        retailer.PersonMailingPostalCode = 'Valid PostalCode';
        retailer.PersonMailingState = 'Valid State';
        retailer.PersonMailingCity = 'Valid City';        
        retailer.Country_ISO_Code__c = 'IN';
        retailer.Phone = '9876543211';
        retailer.PersonMobilePhone = '9876543211';
        retailer.PersonHomePhone = '9876543211';
        retailer.PersonEmail = 'testPersonEmail@test.com';
        retailer.Email2__pc = 'testEmail2@test.com';
        retailer.Email3__pc = 'testEmail3@test.com';
        insert retailer;
        
        System.assertNotEquals(retailer.Id, null);
    }
    
    @isTest
    static void testMethod1() {
        Map < String, Boolean > checkboxMap = new Map < String, Boolean > ();
        checkboxMap.put('Phone', true);
        checkboxMap.put('Mobile', true);
        checkboxMap.put('HomePhone', true);
        checkboxMap.put('PersonEmail', true);
        checkboxMap.put('Email2', true);
        checkboxMap.put('Email3', true);
        
        Account accountObj = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        	accountObj = VerifyContactDataController.getAccountDetail(accountObj.Id);
        	String message = VerifyContactDataController.updateAccountDetail(accountObj, checkboxMap);
        	System.assertEquals(message, 'Success');
        
        	// Set all flags to false
        	checkboxMap.put('Phone', false);
            checkboxMap.put('Mobile', false);
            checkboxMap.put('HomePhone', false);
            checkboxMap.put('PersonEmail', false);
            checkboxMap.put('Email2', false);
            checkboxMap.put('Email3', false);
        
        	message = VerifyContactDataController.updateAccountDetail(accountObj, checkboxMap);
        	System.assertEquals(message, 'Success');
        
        	accountObj.Phone = null;
            accountObj.PersonMobilePhone = null;
            accountObj.PersonHomePhone = null;
            accountObj.PersonEmail = null;
            accountObj.Email2__pc = null;
            accountObj.Email3__pc = null;
        
        	update accountObj;
        Test.stopTest();
    }
    
}