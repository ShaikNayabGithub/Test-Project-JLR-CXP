@isTest
public class aopcom_EditProfileCmpTest {

    static testMethod void validateMethods(){
        //It takes a specific record type
        List<RecordType> rt=[SELECT Id FROM RecordType WHERE DeveloperName='Corporate'];
        //It creates a new Account with the record type obtained before
        Account acc=new Account (Account_Score__c = 0.0 , 
                                International_Account__c =false, Name='TestClass',RecordTypeId=rt.get(0).Id);
        //It inserts the new Account
        insert acc;
        //It creates a new Contact related to the Account created before
        Contact cont = new Contact (AccountId =acc.Id, aop_Country__c='Italy',  
                                    DoNotCall=false,Email='standardcontact@testorg.com', 
                                    FirstName='Test', LastName='Test', Gender__c='Male',HasOptedOutOfEmail=false,
                                    HasOptedOutOfFax=false,HomePhone='918232323',Jaguar_Email_Opt_Out__c=false, Jaguar_Gold_Starred__c=false,
                                    Jaguar_Opt_Out__c=false,Language__c='Czech', MobilePhone='674732812', MailingStreet='testStreet', MailingCity='testCity',
                                    MailingState='testState', MailingPostalCode='78654', aopcom_contactPortrait__c='545646545642jkkghjg');
        //It inserts the new Contact
        insert cont;
        //It creates another Contact related to the Account created before with no Attachment
        Contact contNoAttach = new Contact (AccountId =acc.Id, aop_Country__c='Italy',  
                                            DoNotCall=false,Email='standardcontact@testorg.com', 
                                            FirstName='Test', LastName='Test', Gender__c='Male',HasOptedOutOfEmail=false,
                                            HasOptedOutOfFax=false,HomePhone='918232323',Jaguar_Email_Opt_Out__c=false, Jaguar_Gold_Starred__c=false,
                                            Jaguar_Opt_Out__c=false,Language__c='Czech', MobilePhone='674732812', MailingStreet='testStreet', MailingCity='testCity',
                                            MailingState='testState', MailingPostalCode='78654');
        //It inserts the new Contact
        insert contNoAttach;
        //It creates a new Attachment related to the first Contact (cont)
        Attachment attach = new Attachment (Body=Blob.valueOf('testBody'), Name='test Attachment', ParentId=cont.Id, ContentType='image/png');
        //It inserts the new Attachment
        insert attach;
        //It obtains the profile related to "Customer Community Login User"
        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Login User'];
        //It creates a new User whose profile was obtained before. The user is related to the first Contact (cont)
        User user1 = new User(Alias = 'userTest', Email='stand@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id, ContactId=cont.Id, TimeZoneSidKey='America/Los_Angeles', UserName='stand@testorg.com');
        //It inserts the new User
        System.RunAs(new User(Id=UserInfo.getUserId())){
        insert user1;
        }
        
        //It runs in a context with user1 and it tests a Contact related to an Attachment and it also tests a Contact not related to an Attachment       
        System.runAs(user1){
            aopcom_EditProfileCmp.getPortraitURL();
            /*aopcom_EditProfileCmp.sendData('Test', 'Test', 'TestCountry', 'Test@test.com','918234532', '657843921', 'test street', 'testTown','testState','99999');*/
            
            aopcom_EditProfileCmp.getProfilePicture(cont.Id);
            aopcom_EditProfileCmp.saveAttachment(cont.Id, 'testFileName', 'AAAAAAAAA', 'image/png');
            aopcom_EditProfileCmp.saveAttachment(contNoAttach.Id, 'testFileName', 'AAAAAAAAA', 'image/png');
            aopcom_EditProfileCmp.sendData('Javi', 'Perez', 'Spain', 'Manoteras', 
                                '5454545', '454545', 'Madrid', 'Madrid', 'Madrid', 
                                '28016', '545646545642jkkghjg');
        }
    }
    
}