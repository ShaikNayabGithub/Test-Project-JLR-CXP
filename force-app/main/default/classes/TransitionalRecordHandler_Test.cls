@isTest
public class TransitionalRecordHandler_Test {
    
    @isTest
    public static void testSpamEmailGetsSet(){
        //Arrange
        Transitional_Record__c tran = new Transitional_Record__c();
        tran.Email_Address_1__c = 'noEmail@email.com';
        
        //Act
        insert tran;
        
        //Assert
        Transitional_Record__c tranResult = [SELECT Id, Dummy_email__c FROM Transitional_Record__c WHERE Id = :tran.Id];
        System.assertEquals(true, tranResult.Dummy_email__c);
    }
    @isTest
    public static void testSpamPartialEmailGetsSet(){
        //Arrange
        Transitional_Record__c tran = new Transitional_Record__c();
        tran.Email_Address_1__c = 'UserProvidednoEmail@email.com';
        
        //Act
        insert tran;
        
        //Assert
        Transitional_Record__c tranResult = [SELECT Id, Dummy_email__c FROM Transitional_Record__c WHERE Id = :tran.Id];
        System.assertEquals(true, tranResult.Dummy_email__c);
    }
    @isTest
    public static void testNonSpamEmailDoesntGetSet(){
        //Arrange
        Transitional_Record__c tran = new Transitional_Record__c();
        tran.Email_Address_1__c = 'ThisIsReal@google.com';
        
        //Act
        insert tran;
        
        //Assert
        Transitional_Record__c tranResult = [SELECT Id, Dummy_email__c FROM Transitional_Record__c WHERE Id = :tran.Id];
        System.assertEquals(false, tranResult.Dummy_email__c);
    }
    @isTest
    public static void testSpacesGetStrippedFromCompanyAndSetInName(){
        //Arrange
        Transitional_Record__c tran = new Transitional_Record__c();
        tran.Company_Name__c = 'This is google';
        
        //Act
        insert tran;
        
        //Assert
        Transitional_Record__c tranResult = [SELECT Id, Stripped_Company_Name__c FROM Transitional_Record__c WHERE Id = :tran.Id];
        //if this fail check custommetadata has name entries
        System.assertEquals('Thisisgoogle', tranResult.Stripped_Company_Name__c);
    }
    @isTest
    public static void testSpacesGetStrippedFromIndividualAndSetInName(){
        //Arrange
        Transitional_Record__c tran = new Transitional_Record__c();
        tran.First_Name__c = 'Joseph William';
        tran.Surname_Field_1__c = 'Hayllar Pacman' ;
        //Act
        insert tran;
        
        //Assert
        Transitional_Record__c tranResult = [SELECT Id, Stripped_Individual_Name__c FROM Transitional_Record__c WHERE Id = :tran.Id];
        //if this fail check custommetadata has name entries
        System.assertEquals('JosephWilliamHayllarPacman', tranResult.Stripped_Individual_Name__c);
    }
    @isTest
    public static void testMessrsGetStrippedFromCompanyAndSetInName(){
        //Arrange
        Transitional_Record__c tran = new Transitional_Record__c();
        tran.Company_Name__c = 'Messrs. This is google';
        
        //Act
        insert tran;
        
        //Assert
        Transitional_Record__c tranResult = [SELECT Id, Stripped_Company_Name__c FROM Transitional_Record__c WHERE Id = :tran.Id];
        //if this fail check custommetadata has name entries
        System.assertEquals('Thisisgoogle', tranResult.Stripped_Company_Name__c);
    } 
    @isTest
    public static void testAssetGetsSetFromVin(){
        //Arrange
        Asset ass = TestClass_AssetBuilder.BuildVehicle();
        ass.VIN__c = 'Saj123654';
        insert ass;
        Transitional_Record__c tran = new Transitional_Record__c();
        tran.Company_Name__c = 'Messrs. This is google';
        tran.VIN__c = ass.VIN__c;   
        //Act
        insert tran;
        
        //Assert
        Transitional_Record__c tranResult = [SELECT Id, VIN_Lookup__c,VIN_Lookup__r.accountid,  Current_Asset_Account__c ,Current_Asset_Account_Email__c  FROM Transitional_Record__c WHERE Id = :tran.Id];
        //if this fail check custommetadata has name entries
        System.assertEquals(ass.Id, tranResult.VIN_Lookup__c);
        System.assertEquals(tranResult.Current_Asset_Account__c, tranResult.VIN_Lookup__r.accountid);
    }
    
    
}