@isTest
public class aopcom_MiniProfileCmpTest {
    static testMethod void validategetPortraitUrl(){
        //It takes a specific record type
        List<RecordType> rt=[SELECT Id FROM RecordType WHERE DeveloperName='Corporate'];
        //It creates a new Account with the record type obtained before
        Account acc=new Account (Account_Score__c = 0.0 , 
                                International_Account__c =false, Name='TestClass',RecordTypeId=rt.get(0).Id);        insert acc;
        //It creates a new Contact related to the Account created before
        Contact cont = new Contact (AccountId =acc.Id, aop_Country__c='Italy',  
                                      DoNotCall=false,Email='standardcontact@testorg.com', 
                                      FirstName='Test', LastName='Test', Gender__c='Male',HasOptedOutOfEmail=false,
                                      HasOptedOutOfFax=false,HomePhone='918232323',Jaguar_Email_Opt_Out__c=false, Jaguar_Gold_Starred__c=false,
                                      Jaguar_Opt_Out__c=false,Language__c='Czech' ,aop_Is_Qualified_for_Events__c=true, aop_Suspended_for_Events__c=false
                                   );
        //It inserts a new Contact
        insert cont;
        //It creates a new Attachment related to the first Contact
        Attachment attach = new Attachment (Body=Blob.valueOf('testBody'), Name='test Attachment', ParentId=cont.Id, ContentType='image/png');
        //It inserts the new Attachment
        insert attach;
        //It obtains the profile related to "Customer Community Login User"
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User'];
        //It creates a new User whose profile was obtained before. The user is related to the first Contact
        User user1 = new User(Alias = 'userTest', Email='stand@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, ContactId=cont.Id, TimeZoneSidKey='America/Los_Angeles', UserName='stand@testorg.com');
        //It creates a new User whose profile was obtained before. The user is related to the Contact created before
        System.RunAs(new User(Id=UserInfo.getUserId())){
        insert user1;
        }
        //It runs in a context with user1 and it tests a Contact related to an Attachment. It also tests a Contact not related to an Attachment
        System.runAs(user1){
            aopcom_MiniProfileCmp.getPortraitURL();
        }
    }
}