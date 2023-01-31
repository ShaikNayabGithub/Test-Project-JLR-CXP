@isTest

public class webToLeadLookUpSetterTest {
    static TestMethod void TestBrandVehicleMappingInsert()
    {
  //test refactor this to not be query the recordtype
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){         
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake();       
            Account retailerAccount = new Account(Country_ISO_Code__c = 'MY', Name = 'ret a', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111' );     
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert retailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(LastName = 'UNIT Test', Country_ISO_Code__c ='MY', Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Brand__c = 'Jaguar', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = 'TestModel', Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53');
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, Brand__c FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals(jagId.Id, leadcreated.Brand__c);
        }
    }
    
    static TestMethod void TestModelVehicleMappingInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );       
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            Account retailerAccount = new Account(Country_ISO_Code__c = 'MY', Name = 'ret a', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111' );     
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert retailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Brand__c = 'Jaguar', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = 'TestModel');
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, Primary_Model_Interest__c FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals(newCar.Id, leadcreated.Primary_Model_Interest__c);
        }
    }
    
    static TestMethod void TestModelSecondaryVehicleMappingInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );       
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            Account retailerAccount = new Account(Country_ISO_Code__c = 'MY', Name = 'ret a', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111' );     
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert retailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Brand__c = 'Jaguar', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Secondary_Model_of_Interest__c = 'TestModel');
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, Secondary_Model_Interest__c FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals(newCar.Id, leadcreated.Secondary_Model_Interest__c);
        }
    }
    
    static TestMethod void TestRetailerMappingInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
                
        System.runAs(testUser){ 
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );           
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            //Account retailerAccount = [SELECT Id, Secondary_Dealer_Code__c FROM Account WHERE RecordTypeId =: rtRetailer.Id AND Queue_ID__c != '' AND Secondary_Dealer_Code__c != '' LIMIT 1];
            Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
           
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(LastName = 'UNIT Test', Country_ISO_Code__c ='MY',Brand__c=newCar.Make__c, Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = newCar.Name, Mapping_Preferred_Retailer__c = retailerAccount.Secondary_Dealer_Code__c, Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53');
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, Preferred_Retailer__c FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals(retailerAccount.Id, leadcreated.Preferred_Retailer__c);
        }
    }
    

    static TestMethod void TestCiCodeMappingInsert()
    {
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
                
        System.runAs(testUser){ 
            Account retailerAccount = TestClass_AccountCreator.CreateRetailer(); 

            Group g1 = new Group(Name='xxxxx', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;

            retailerAccount.Queue_ID__c = String.ValueOf(g1.id);
            update retailerAccount;
            
            Lead webToLead = new Lead(LastName = 'UNIT Test', Country_ISO_Code__c ='JP', Email = 'Unique@12345.com', 
                                      RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', 
                                      Mapping_CI_Code__c = 'test retailer', Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53');
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, Preferred_Retailer__c FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals(retailerAccount.Id, leadcreated.Preferred_Retailer__c);
        }
    }       
    
    static TestMethod void TestEmptyRetailerMappingInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){ 
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake();        
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
           
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(LastName = 'UNIT Test', Country_ISO_Code__c ='MY', Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Brand__c = 'Jaguar', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = 'TestModel', Mapping_Preferred_Retailer__c = 'empty', Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53');
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, Preferred_Retailer__c FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals( null , leadcreated.Preferred_Retailer__c);
        }
    }
    
    static TestMethod void TestCurrentVehicleBrand()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );       
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            Account retailerAccount = new Account(Country_ISO_Code__c = 'MY', Name = 'ret a', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111' );     
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert retailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Brand__c = 'Jaguar', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Secondary_Model_of_Interest__c = 'TestModel');
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, Current_Vehicle_Brand__c FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals(newBrand.Id, leadcreated.Current_Vehicle_Brand__c);
        }
    }
    
    static TestMethod void TestOwnershipMappingInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){
            //Create the temporary Queue to be referenced on the parent account
            Group g1 = new Group(Name='Unit Test Queue', type='Queue');
            insert g1;
            //Allow leads to be added to the queue
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            
            //Create the Parent and child account objects
            Account parentRetailerAccount = new Account(Country_ISO_Code__c = 'MY', Name = 'ret parent', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111p', Queue_ID__c = g1.id );     
            Account childRetailerAccount = new Account(Country_ISO_Code__c = 'MY', Name = 'ret child', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111c' );     
            
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );       
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert parentRetailerAccount;
            //Add the parent reference to the child
            childRetailerAccount.parentId = parentRetailerAccount.id;
            insert childRetailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Country_ISO_Code__c ='MY',Brand__c=newCar.Make__c, Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = newCar.Name, Mapping_Preferred_Retailer__c = childRetailerAccount.Secondary_Dealer_Code__c);
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, ownerId FROM Lead where Id =: webToLead.Id ];
                    
            System.assertEquals(g1.id, leadcreated.ownerId);
        }
    }
       static TestMethod void TestOwnershipMappingForBrazilDoesNotGoToRetailerQueueOnInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){
            //Create the temporary Queue to be referenced on the parent account
            Group g1 = new Group(Name='Unit Test Queue', type='Queue');
            insert g1;
            //Allow leads to be added to the queue
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            
            //Create the Parent and child account objects
            Account parentRetailerAccount = new Account(Country_ISO_Code__c = 'BR', Name = 'ret parent', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111p', Queue_ID__c = g1.id );     
            Account childRetailerAccount = new Account(Country_ISO_Code__c = 'BR', Name = 'ret child', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111c' );     
            
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );       
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert parentRetailerAccount;
            //Add the parent reference to the child
            childRetailerAccount.parentId = parentRetailerAccount.id;
            insert childRetailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Country_ISO_Code__c ='BR',Brand__c=newCar.Make__c, Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = newCar.Name, Mapping_Preferred_Retailer__c = childRetailerAccount.Secondary_Dealer_Code__c);
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, ownerId FROM Lead where Id =: webToLead.Id ];
             
            System.assertNotEquals(g1.id, leadcreated.ownerId);
        }
    }
    static TestMethod void TestOwnershipMappingForHOTBrazilDoesGoToRetailerQueueOnInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){
            //Create the temporary Queue to be referenced on the parent account
            Group g1 = new Group(Name='Unit Test Queue', type='Queue');
            insert g1;
            //Allow leads to be added to the queue
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            
            //Create the Parent and child account objects
            Account parentRetailerAccount = new Account(Country_ISO_Code__c = 'BR', Name = 'ret parent', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111p', Queue_ID__c = g1.id );     
            Account childRetailerAccount = new Account(Country_ISO_Code__c = 'BR', Name = 'ret child', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111c' );     
            
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );       
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert parentRetailerAccount;
            //Add the parent reference to the child
            childRetailerAccount.parentId = parentRetailerAccount.id;
            insert childRetailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53',Rating = 'Hot', LastName = 'UNIT Test', Country_ISO_Code__c ='BR',Brand__c=newCar.Make__c, Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = newCar.Name, Mapping_Preferred_Retailer__c = childRetailerAccount.Secondary_Dealer_Code__c);
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, ownerId FROM Lead where Id =: webToLead.Id ];
             
            System.assertEquals(g1.id, leadcreated.ownerId);
        }
    }
    static TestMethod void TestOwnershipMappingForCOLDIndiaDoesGoToMarketingQueueOnInsert()
    {
        RecordType rtmodel = VehicleSpecificationUtilities.RecordTypes.get('Model');
        RecordType rtmake = VehicleSpecificationUtilities.RecordTypes.get('Make');
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        RecordType rtRetailer = AccountUtilities.RecordTypes.get('Retailer');
        Profile jlrSystemAdministratorprofile = ProfileUtilities.Profiles.get('JLR System Administrator');
        
        User testUser = TestClass_UserCreator.CreateUser(jlrSystemAdministratorprofile);
        
        System.runAs(testUser){
            //Create the temporary Queue to be referenced on the parent account
            Group g1 = new Group(Name='Unit Test Queue', type='Queue');
            insert g1;
            //Allow leads to be added to the queue
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
            
            //Create the Parent and child account objects
            Account parentRetailerAccount = new Account(Country_ISO_Code__c = 'IN', Name = 'ret parent', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111p', Queue_ID__c = g1.id );     
            Account childRetailerAccount = new Account(Country_ISO_Code__c = 'IN', Name = 'ret child', RecordTypeId = rtRetailer.Id, Secondary_Dealer_Code__c = 'XX11111c' );     
            
            Vehicle_Specification__c newBrand = new Vehicle_Specification__c(Name = 'TestMake', RecordTypeId = rtmake.Id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );       
            Vehicle_Specification__c jagId = TestClass_VehicleSpecificationBuilder.BuildMake(); 
            Vehicle_Specification__c newCar = new Vehicle_Specification__c(Name = 'TestModel', RecordTypeId = rtmodel.Id, Make__c = jagId.id, aop_JLR_Owned__c = true, Is_India__c = True, Is_Currently_Sold__c = True, Is_APIO__c= true );
            
            insert parentRetailerAccount;
            //Add the parent reference to the child
            childRetailerAccount.parentId = parentRetailerAccount.id;
            insert childRetailerAccount;
            insert newBrand;       
            insert newCar;
            
            Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53',Rating = 'Cold', LastName = 'UNIT Test', Country_ISO_Code__c ='IN',Brand__c=newCar.Make__c, Email = 'Unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = 'OEM Website', Mapping_Current_Vehicle__c = 'TestMake', Mapping_Primary_Model_of_Interest__c = newCar.Name, Mapping_Preferred_Retailer__c = childRetailerAccount.Secondary_Dealer_Code__c);
            
            Test.StartTest();
            insert webToLead;
            Test.StopTest();
            
            Lead leadcreated = [Select Id, ownerId FROM Lead where Id =: webToLead.Id ];
             
            System.assertNotEquals(g1.id, leadcreated.ownerId);
        }
    }
}