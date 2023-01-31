@isTest
private class Vista_RequestWrapper_Test {
    static testMethod void testOrderByCreatedDateIfEventDateTimeIsNull(){
       DateTime longAgo =  DateTime.now().addDays(-20);
        DateTime littleAgo =  DateTime.now().addDays(-10);
          DateTime justAgo =  DateTime.now().addDays(-1);
        Vista_RequestWrapper[] reqList = new List<Vista_RequestWrapper>(); 
           reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
            MetaOrderNumber__c = '3'            
        
        )));
        
        reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = longAgo,
            MetaOrderNumber__c = '1'            
        
        )));
         reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = littleAgo,
            MetaOrderNumber__c = '2'            
        
        )));
          reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
            MetaOrderNumber__c = '3'            
        
        )));
        system.debug('Before Sort: '+reqList);
        reqList.sort();
        System.debug('After Sort '+reqList);
        system.debug('1 '+reqList[0]);
        system.assert(reqList[0].req.MetaOrderNumber__c == '3' );
        
        
    }

    static testMethod void testOrderByEventDateIfEventDateTimeIsNull(){
       DateTime longAgo =  DateTime.now().addDays(-20);
        DateTime littleAgo =  DateTime.now().addDays(-10);
          DateTime justAgo =  DateTime.now().addDays(-1);
        DateTime longAgoE =  DateTime.now().addDays(-20);
        DateTime littleAgoE =  DateTime.now().addDays(-10);
          DateTime justAgoE =  DateTime.now().addDays(-1);
        Vista_RequestWrapper[] reqList = new List<Vista_RequestWrapper>(); 
           reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
              EventDateTime__c = justAgoE,
            MetaOrderNumber__c = '3'            
        
        )));
        
        reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
               EventDateTime__c = longAgoE,
            MetaOrderNumber__c = '1'            
        
        )));
         reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
                EventDateTime__c = littleAgoE,
            MetaOrderNumber__c = '2'            
        
        )));
        system.debug('Before Sort: '+reqList);
        reqList.sort();
        System.debug('After Sort '+reqList);
        system.debug('1 '+reqList[0]);
        system.assert(reqList[0].req.MetaOrderNumber__c == '3' );
        
        
    }
      static testMethod void testOrderByEventDateIfEventDateTimeIsMissingOnSome(){
       DateTime longAgo =  DateTime.now().addDays(-20);
        DateTime littleAgo =  DateTime.now().addDays(-10);
          DateTime justAgo =  DateTime.now().addDays(-1);
        DateTime longAgoE =  DateTime.now().addDays(-20);
        DateTime littleAgoE =  DateTime.now().addDays(-10);
          DateTime justAgoE =  DateTime.now().addDays(-1);
        Vista_RequestWrapper[] reqList = new List<Vista_RequestWrapper>(); 
           reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
            
            MetaOrderNumber__c = '3'            
        
        )));
        
        reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
               EventDateTime__c = longAgoE,
            MetaOrderNumber__c = '1'            
        
        )));
         reqList.add(new Vista_RequestWrapper(new Vista_Request__C(
        CreatedDate = justAgo,
                EventDateTime__c = littleAgoE,
            MetaOrderNumber__c = '2'            
        
        )));
        system.debug('Before Sort: '+reqList);
        reqList.sort();
        System.debug('After Sort '+reqList);
        system.debug('1 '+reqList[0]);
        system.assert(reqList[0].req.MetaOrderNumber__c == '3' );
        
        
    }
    
    
    
}