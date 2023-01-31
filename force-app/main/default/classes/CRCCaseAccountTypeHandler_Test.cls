@IsTest
public class CRCCaseAccountTypeHandler_Test {
    static testmethod void validateAccountType_noCRCRecordType_InsertedForAUUSer() {
        //ARRANGE
        User currentUser = new User(Id=UserInfo.getUserId());
        Account account = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        
        User user;
        Case caseRecord;
        
        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contact);
            user.Country_ISO_Code__c = 'AU';
            update user;
        }
        
        //ACT
        test.startTest();
        List<Case> cases = new List<Case>();
        System.runAs(user){   
            Account indi =  TestClass_AccountCreator.createPersonAccount_Australia();
            cases.add(TestClass_CaseCreator.CreateWithAcc(indi));
        
        }
     
        test.stopTest();
        //ASSERT
        List<Case> retrievedCases = [Select id from case];
        system.assertEquals(1,retrievedCases.size());
        
    }
    
    static testmethod void validateAccountType_nonAusUser_InsertsOk() {
        //ARRANGE
        User currentUser = new User(Id=UserInfo.getUserId());
        Account account = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        
        User user;
        Case caseRecord;
        
        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contact);
            user.Country_ISO_Code__c = 'IN';
            update user;
        }
        
        //ACT
        test.startTest();
        List<Case> cases = new List<Case>();
        System.runAs(user){   
            Account indi =  TestClass_AccountCreator.createPersonAccount_Australia();
            cases.add(TestClass_CaseCreator.CreateCRC(indi)); 
            //  cases.add(TestClass_CaseCreator.CreateCRC());
            //  cases.add(TestClass_CaseCreator.CreateCRC());
        }
     
        test.stopTest();
        //ASSERT
        List<Case> retrievedCases = [Select id from case];
        system.assertEquals(1,retrievedCases.size());
        
    }
   
    static testmethod void validateAccountType_accountPrimaryType_IsAllowed(){
        //ARRANGE
        User currentUser = new User(Id=UserInfo.getUserId());
        Account account = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        boolean stopped = false;
        User user;
        Case caseRecord;
        
        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contact);
            user.Country_ISO_Code__c = 'AU';
            update user;
        }
        
        //ACT
        test.startTest();
        List<Case> cases = new List<Case>();
        System.runAs(currentUser){   
           Account prim =  TestClass_AccountCreator.createPrimaryAccount();
           //inserting primary account and using that in the crc creation you may need to do as your user and insert accountshare
           cases.add(TestClass_CaseCreator.CreateCRC(prim));
        }
        
        test.stopTest();
        //ASSERT
        List<Case> retrievedCases = [Select id from case];
        system.assertEquals(1,retrievedCases.size());
        
	}
    static testmethod void validateAccountType_ausUserCRCNonPrimaryAccount_throwsError() {
        //ARRANGE
        User currentUser = new User(Id=UserInfo.getUserId());
        Account account = TestClass_AccountCreator.CreateRetailer(currentUser);
        Contact contact = TestClass_ValidContactBuilder.Build(account);
        string errorMessage;
        User user;
        Case caseRecord;
        
        System.runAs(currentUser){
            user = TestClass_UserCreator.CreateRetailerUser(contact);
            user.Country_ISO_Code__c = 'AU';
            update user;
        }
        
        //ACT
        test.startTest();
        List<Case> cases = new List<Case>();
        System.runAs(user){   
            Try{
                Account indi =  TestClass_AccountCreator.createPersonAccount_Australia();
            	cases.add(TestClass_CaseCreator.CreateCRC(indi)); 
            } catch(DMLException e) {
                system.debug('e '+e);
                system.debug('e '+e.getMessage());
                errorMessage = e.getMessage();
            }
           
            
        }
        
        test.stopTest();
        //ASSERT
        List<Case> retrievedCases = [Select id from case];
        system.assertEquals(0,retrievedCases.size());
      //  system.assertEquals('Wrong Account Type',errorMessage);
    }
}