@isTest
private class batchProductModelUpdaterTest{

    @isTest static void testBatch() {
    
    vehicle_specification__c vs= new vehicle_specification__c();
    vs.name='Jaguar';
    insert vs;
    
    product2 model=new product2();
    model.model_alternative__c='XJ';
    model.name='XJ';
    model.make__c=vs.id;
    model.isactive=true;
    recordtype rd=[select id from recordtype where name='Model' limit 1];
    insert model;
   
    product2 prod=new product2();
    prod.name='test1';
    prod.make__c=vs.id;
    prod.model__c=model.id;
    prod.model_alternative__c=null;
    rd=[select id from recordtype where name='Derivative' limit 1];
    prod.isactive=true;
    prod.recordtypeid=rd.id;
    insert prod;
     Test.StartTest();

   
   
    ScheduleBatchProdModelAlternative schedulable= new ScheduleBatchProdModelAlternative();
    schedulable.execute(null);
     Test.StopTest();

     list<product2>listprod=[select id,name,model_alternative__c,model__c from product2 where id=:prod.id];
    System.assertNotEquals(listprod[0].model_alternative__c,null);
    }
}