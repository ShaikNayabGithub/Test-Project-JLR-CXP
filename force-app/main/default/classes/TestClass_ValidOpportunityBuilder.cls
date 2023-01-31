@isTest(SeeAllData=true)

public class TestClass_ValidOpportunityBuilder {
    public static Opportunity buildOpportunityWithCorporateAccount()
    {
        //Vehicle_Specification__c derivative = TestClass_VehicleSpecificationBuilder.BuildDerivative();
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';
        opportunity.AccountId = CreateAccount().Id;
        opportunity.Brand__c = make.Id;
        opportunity.Primary_Model_Interest__c = model.Id;
        //opportunity.Derivative__c = derivative.Id;
        opportunity.CloseDate = Date.today();
        opportunity.StageName = 'Contacted';
        opportunity.type = 'Purchase';
        opportunity.Purchase_Type__c = 'New Vehicle';
        opportunity.DMS_Opportunity_ID__c = 'dmsId';
        return opportunity; 
    }
   

    private static Account CreateAccount()
    {
        Account account = new Account();
        account.RecordType = AccountUtilities.RecordTypes.get('Corporate');
        account.Name = 'test';
        account.phone=getRandom();
        account.billingcity='London';
        account.BillingState ='testState';
        account.billingpostalcode='SW1635HJ';
        account.billingcountry='United Kingdom';
        account.billingstreet='address 1';
        account.retailer_email__c=getRandom()+'@test1223.com';
        insert account;
        return account;
    }
        
    public static string getRandom()
{
    Integer len=10;
    final String chars='0123456789';
    String randStr='';
    
    while(randStr.length()<len)
    {
        Integer idx=math.mod(math.abs(Crypto.getrandominteger()),chars.length());
        randstr+=chars.substring(idx,idx+1);
    
    }
return randstr;
}
  public static Opportunity opportunityWithLineItem() {
        return opportunityWithLineItem(false);

    }
    public static Opportunity opportunityWithLineItem(Boolean doUsePersonAccount) {
    
      // Vehicle_Specification__c derivative = TestClass_VehicleSpecificationBuilder.BuildDerivative();
       Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
       // Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        
      
       // Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        //make.RecordTypeId = [select Id from RecordType where Name = 'Make' and SObjectType = 'Vehicle_Specification__c' limit 1].id; 
       // make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        //make.Name = 'Jaguar'; 
        //insert make; 
       
        Product2 model = new Product2(Name='TestModel');
       
        model.Make__c = make.Id;
        insert model;
        
        Product2 derivative = new Product2(Name='TestDerivative');
        derivative.Make__c = make.Id;
        derivative.isactive=true;
       
        derivative.Model__c = model.Id;
        insert derivative;
       
     

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';
        opportunity.AccountId = CreateAccount().Id;
        opportunity.Brand__c = make.Id;
        system.debug('Model Id'+model.Id);
        //opportunity.Primary_Model_Interest__c = model.Id;
        //opportunity.Derivative__c = derivative.Id;
        opportunity.CloseDate = Date.today();
        opportunity.StageName = 'Contacted';
        opportunity.DMS_Opportunity_ID__c = 'dmsId';
       
    
        //Product2 prod= new Product2();
        //prod.make__c=make.id;
        //prod.model__c=model.id;
        //prod.name='test1prod';
        //prod.productcode='PROD123';
      //  prod.isactive=true;
    //    insert prod;
    
        pricebook2 pb= new pricebook2();
        pb.name='test';
        pb.isactive=true;
        insert pb;
       
        
       pricebookentry standardPBE = new PricebookEntry(Pricebook2Id =Test.getStandardPricebookId(), Product2Id = derivative.id, UnitPrice = 0, IsActive = true,UseStandardPrice=false);
       insert standardPBE;     
       
         
       pricebookentry pbe=new pricebookentry();
       pbe.pricebook2id=pb.id;
       pbe.unitprice=1;
       pbe.product2id=derivative.id;
       pbe.UseStandardPrice=false;
       pbe.isactive=true;
       insert pbe;                                                 
     
        Asset asset1=new asset();
        asset1.name='SALJ343411';
        asset1.brand__c=make.id;
        //asset1.model__c=model2.id;
        asset1.accountid= opportunity.AccountId;
        insert asset1;
        
        insert opportunity;
        
      
        OpportunityLineItem op= new OpportunityLineItem();
        op.product2=derivative;
        op.model__c=derivative.model__c;
        op.opportunityid=opportunity.id;
        op.brand__c=derivative.make__c;
        op.quantity=1;
        op.TotalPrice=1;
        op.pricebookentryid=pbe.id;
        op.vista_order_number__c='123446';
        
        insert op;
        
        op.asset__c=asset1.id;
        update op;
                
        return opportunity; 
    }
    
    
    
     public static Opportunity Build()
    {
        //Vehicle_Specification__c derivative = TestClass_VehicleSpecificationBuilder.BuildDerivative();
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';
        opportunity.AccountId = CreateAccount().Id;
        opportunity.Brand__c = make.Id;
        opportunity.Primary_Model_Interest__c = model.Id;
        //opportunity.Derivative__c = derivative.Id;
        opportunity.CloseDate = Date.today();
        opportunity.StageName = 'Contacted';
        opportunity.type = 'Purchase';
        opportunity.Purchase_Type__c = 'New Vehicle';
        opportunity.DMS_Opportunity_ID__c = 'dmsId';
        return opportunity; 
    }
    
    
    // Copy of Build, but doesn't create a new account
    // allowing other types of users to create the acc
    // without conflicting with other objects such as Make n Model
    public static Opportunity BuildWithAccount(Id accId)
    {
        //Vehicle_Specification__c derivative = TestClass_VehicleSpecificationBuilder.BuildDerivative();
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';
        opportunity.AccountId = accId;
        opportunity.Brand__c = make.Id;
        opportunity.Primary_Model_Interest__c = model.Id;
        //opportunity.Derivative__c = derivative.Id;
        opportunity.CloseDate = Date.today();
        opportunity.StageName = 'Contacted';
        opportunity.type = 'Purchase';
        opportunity.Purchase_Type__c = 'New Vehicle';
        opportunity.DMS_Opportunity_ID__c = 'dmsId';
        return opportunity; 
    }
  
    
    public static Opportunity opportunityWithopportunityitem(){
    
      // Vehicle_Specification__c derivative = TestClass_VehicleSpecificationBuilder.BuildDerivative();
       Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
       // Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        
      
       // Vehicle_Specification__c make = new Vehicle_Specification__c(); 
        //make.RecordTypeId = [select Id from RecordType where Name = 'Make' and SObjectType = 'Vehicle_Specification__c' limit 1].id; 
       // make.RecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        //make.Name = 'Jaguar'; 
        //insert make; 
       
        Product2 model = new Product2(Name='TestModel');
       
        model.Make__c = make.Id;
        insert model;
        
        Product2 derivative = new Product2(Name='TestDerivative');
        derivative.Make__c = make.Id;
        derivative.isactive=true;
       
        derivative.Model__c = model.Id;
        insert derivative;
       
     

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'test';
        opportunity.AccountId = CreateAccount().Id;
        opportunity.Brand__c = make.Id;
        system.debug('Model Id'+model.Id);
        //opportunity.Primary_Model_Interest__c = model.Id;
        //opportunity.Derivative__c = derivative.Id;
        opportunity.CloseDate = Date.today();
        opportunity.StageName = 'Contacted';
        opportunity.DMS_Opportunity_ID__c = 'dmsId';
       
    
        //Product2 prod= new Product2();
        //prod.make__c=make.id;
        //prod.model__c=model.id;
        //prod.name='test1prod';
        //prod.productcode='PROD123';
      //  prod.isactive=true;
    //    insert prod;
    
        pricebook2 pb= new pricebook2();
        pb.name='test';
        pb.isactive=true;
        insert pb;
       
        
       pricebookentry standardPBE = new PricebookEntry(Pricebook2Id =Test.getStandardPricebookId(), Product2Id = derivative.id, UnitPrice = 0, IsActive = true,UseStandardPrice=false);
       insert standardPBE;     
       
         
       pricebookentry pbe=new pricebookentry();
       pbe.pricebook2id=pb.id;
       pbe.unitprice=1;
       pbe.product2id=derivative.id;
       pbe.UseStandardPrice=false;
       pbe.isactive=true;
       insert pbe;                                                 
     
        Asset asset1=new asset();
        asset1.name='SALJ343411';
        asset1.brand__c=make.id;
        //asset1.model__c=model2.id;
        asset1.accountid= opportunity.AccountId;
        insert asset1;
        
        insert opportunity;
        
      
        OpportunityLineItem op= new OpportunityLineItem();
        op.product2=derivative;
        op.model__c=derivative.model__c;
        op.opportunityid=opportunity.id;
        op.brand__c=derivative.make__c;
        op.quantity=1;
        op.TotalPrice=1;
        op.pricebookentryid=pbe.id;
        op.vista_order_number__c='123446';
        
        insert op;
        
        op.asset__c=asset1.id;
        update op;
                
        return opportunity; 
    }
    
    
    
    

}