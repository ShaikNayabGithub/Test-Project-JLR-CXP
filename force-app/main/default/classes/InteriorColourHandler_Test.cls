@isTest
private class InteriorColourHandler_Test {
    @isTest
    static void updateAssetsWithNewColour() {
    
    
    Vehicle_Specification__c vs= new Vehicle_Specification__c();
    vs.name='Jaguar';
    insert vs;
    
    List<Vehicle_Specification__c> brandList = [Select Name From Vehicle_Specification__c];
  
    asset asset= new asset();
    asset.vin__c='SALJXXX35343';
    asset.Interior_Colour_Code_Vista__c='TXT';
    asset.brand__c=brandList[0].id;
    asset.name='SALJXXX35343';
    
    account acc1=new account(name='test',retailer_email__c='test1234@fdasffd.com',country_iso_code__c='JP');
    insert acc1;
    
    asset.accountid=acc1.id;
    insert asset;

    Interior_colour__c intColour= new Interior_colour__c();
    intColour.source_code__c='TXT';
    intColour.cxp_code__c='CPX';
    intColour.market__c='JP';
    insert intColour;
    
    intColour.cxp_code__c='CPX';
    update intColour;
       
    
    }
    
    
}