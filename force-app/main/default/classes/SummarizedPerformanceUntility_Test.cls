@isTest
private class SummarizedPerformanceUntility_Test {
    @isTest
    private static void SetDatePropertiesIndia_Test() {
        //Arrange
        Summarised_Pipeline_Performance_Metric__c metric = new Summarised_Pipeline_Performance_Metric__c(
            Country_ISO_Code__c = 'IN'
            
        );
        insert metric;
        DateTime createdDate = DateTime.newInstanceGMT(2016, 7, 3, 20, 0, 0);
        Test.setCreatedDate(metric.Id, createdDate);
        //Act
        List<Summarised_Pipeline_Performance_Metric__c> snapshots = [Select Id, Country_ISO_Code__c, CreatedDate from Summarised_Pipeline_Performance_Metric__c WHERE Id=:metric.id];
        List<Summarised_Pipeline_Performance_Metric__c> updatedSnapshots = SummarizedPerformanceUtility.SetDateProperties(snapshots); 
        //Assert
        System.assertEquals(1, updatedsnapshots.size(), 'Expected 1 record in the results set');
        System.assertequals(createdDate.year(), updatedsnapshots[0].Year__c, 'Expected the year to remain unchanged.');
        System.assertequals(createdDate.month(), updatedsnapshots[0].Month__c, 'Expected the Month to remain unchanged.');
        System.assertequals(createdDate.day() + 1, updatedsnapshots[0].Day__c, 'Expected the Day to increase by 1.');
        
    }
    
     @isTest
    private static void SetDatePropertiesSG_Test() {
        //Arrange
        Summarised_Pipeline_Performance_Metric__c metric = new Summarised_Pipeline_Performance_Metric__c(
            Country_ISO_Code__c = 'SG'
            
        );
        insert metric;
        DateTime createdDate = DateTime.newInstanceGMT(2016, 7, 3, 20, 0, 0);
        Test.setCreatedDate(metric.Id, createdDate);
        //Act
        List<Summarised_Pipeline_Performance_Metric__c> snapshots = [Select Id, Country_ISO_Code__c, CreatedDate from Summarised_Pipeline_Performance_Metric__c WHERE Id=:metric.id];
        List<Summarised_Pipeline_Performance_Metric__c> updatedSnapshots = SummarizedPerformanceUtility.SetDateProperties(snapshots); 
        //Assert
        System.assertEquals(1, updatedsnapshots.size(), 'Expected 1 record in the results set');
        System.assertequals(createdDate.year(), updatedsnapshots[0].Year__c, 'Expected the year to remain unchanged.');
        System.assertequals(createdDate.month(), updatedsnapshots[0].Month__c, 'Expected the Month to remain unchanged.');
        System.assertequals(createdDate.day() + 1, updatedsnapshots[0].Day__c, 'Expected the Day to increase by 1.');
        
    }
    
     @isTest
    private static void SetDatePropertiesJP_Test() {
        //Arrange
        Summarised_Pipeline_Performance_Metric__c metric = new Summarised_Pipeline_Performance_Metric__c(
            Country_ISO_Code__c = 'JP'
            
        );
        insert metric;
        DateTime createdDate = DateTime.newInstanceGMT(2016, 7, 3, 20, 0, 0);
        Test.setCreatedDate(metric.Id, createdDate);
        //Act
        List<Summarised_Pipeline_Performance_Metric__c> snapshots = [Select Id, Country_ISO_Code__c, CreatedDate from Summarised_Pipeline_Performance_Metric__c WHERE Id=:metric.id];
        List<Summarised_Pipeline_Performance_Metric__c> updatedSnapshots = SummarizedPerformanceUtility.SetDateProperties(snapshots); 
        //Assert
        System.assertEquals(1, updatedsnapshots.size(), 'Expected 1 record in the results set');
        System.assertequals(createdDate.year(), updatedsnapshots[0].Year__c, 'Expected the year to remain unchanged.');
        System.assertequals(createdDate.month(), updatedsnapshots[0].Month__c, 'Expected the Month to remain unchanged.');
        System.assertequals(createdDate.day() + 1, updatedsnapshots[0].Day__c, 'Expected the Day to increase by 1.');
        
    }
    
     @isTest
    private static void SetDatePropertiesBR_Test() {
        //Arrange
        Summarised_Pipeline_Performance_Metric__c metric = new Summarised_Pipeline_Performance_Metric__c(
            Country_ISO_Code__c = 'BR'
            
        );
        insert metric;
        DateTime createdDate = DateTime.newInstanceGMT(2016, 7, 4, 4, 0, 0);
        Test.setCreatedDate(metric.Id, createdDate);
        //Act
        List<Summarised_Pipeline_Performance_Metric__c> snapshots = [Select Id, Country_ISO_Code__c, CreatedDate from Summarised_Pipeline_Performance_Metric__c WHERE Id=:metric.id];
        List<Summarised_Pipeline_Performance_Metric__c> updatedSnapshots = SummarizedPerformanceUtility.SetDateProperties(snapshots); 
        //Assert
        System.assertEquals(1, updatedsnapshots.size(), 'Expected 1 record in the results set');
        System.assertequals(createdDate.year(), updatedsnapshots[0].Year__c, 'Expected the year to remain unchanged.');
        System.assertequals(createdDate.month(), updatedsnapshots[0].Month__c, 'Expected the Month to remain unchanged.');
        System.assertequals(createdDate.day(), updatedsnapshots[0].Day__c, 'Expected the Day remain unchanged.');
        
    }
    
    @isTest
     private static void SetDatePropertiesBR_Test_TimeZonesAreCached() {
        //Arrange
         List<Summarised_Pipeline_Performance_Metric__c> metrics = new List<Summarised_Pipeline_Performance_Metric__c>(); 
         metrics.add(new Summarised_Pipeline_Performance_Metric__c(
            Country_ISO_Code__c = 'BR'
            
        ));  
        metrics.add(new Summarised_Pipeline_Performance_Metric__c(
            Country_ISO_Code__c = 'BR'
            
        ));
            
        insert metrics;
        DateTime createdDate = DateTime.newInstanceGMT(2016, 7, 4, 4, 0, 0);
        Test.setCreatedDate(metrics[0].Id, createdDate);
         Test.setCreatedDate(metrics[1].Id, createdDate);
        //Act
        List<Summarised_Pipeline_Performance_Metric__c> snapshots = [Select Id, Country_ISO_Code__c, CreatedDate from Summarised_Pipeline_Performance_Metric__c WHERE Id=:metrics[0].id or ID=:metrics[1].id];
        List<Summarised_Pipeline_Performance_Metric__c> updatedSnapshots = SummarizedPerformanceUtility.SetDateProperties(snapshots); 
        //Assert
        System.assertEquals(2, updatedsnapshots.size(), 'Expected 2 record in the results set');
        System.assertequals(createdDate.year(), updatedsnapshots[0].Year__c, 'Expected the year to remain unchanged.');
        System.assertequals(createdDate.month(), updatedsnapshots[0].Month__c, 'Expected the Month to remain unchanged.');
        System.assertequals(createdDate.day(), updatedsnapshots[0].Day__c, 'Expected the Day remain unchanged.');
        System.assertequals(createdDate.year(), updatedsnapshots[1].Year__c, 'Expected the year to remain unchanged.');
        System.assertequals(createdDate.month(), updatedsnapshots[1].Month__c, 'Expected the Month to remain unchanged.');
        System.assertequals(createdDate.day(), updatedsnapshots[1].Day__c, 'Expected the Day remain unchanged.');
        
    }
    
     @isTest
    private static void SetDatePropertiesNoIsoCode_Test() {
        //Arrange
        Summarised_Pipeline_Performance_Metric__c metric = new Summarised_Pipeline_Performance_Metric__c(
            Country_ISO_Code__c = ''
            
        );
        insert metric;
        DateTime createdDate = DateTime.newInstanceGMT(2016, 7, 4, 4, 0, 0);
        Test.setCreatedDate(metric.Id, createdDate);
        //Act
        List<Summarised_Pipeline_Performance_Metric__c> snapshots = [Select Id, Country_ISO_Code__c, CreatedDate from Summarised_Pipeline_Performance_Metric__c WHERE Id=:metric.id];
        List<Summarised_Pipeline_Performance_Metric__c> updatedSnapshots = SummarizedPerformanceUtility.SetDateProperties(snapshots); 
        //Assert
        System.assertEquals(1, updatedsnapshots.size(), 'Expected 1 record in the results set');
        System.assertequals(createdDate.year(), updatedsnapshots[0].Year__c, 'Expected the year to remain unchanged.');
        System.assertequals(createdDate.month(), updatedsnapshots[0].Month__c, 'Expected the Month to remain unchanged.');
        System.assertequals(createdDate.day(), updatedsnapshots[0].Day__c, 'Expected the Day remain unchanged.');
        
    }
    
    

}