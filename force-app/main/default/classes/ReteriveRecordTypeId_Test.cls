@isTest(seeAlldata=true)
public class ReteriveRecordTypeId_Test
{
    static testMethod void testRecordType()
    {
        List<RecordType> listOfRecordType = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE And sObjectType = 'Event'];
        ReteriveRecordTypeId recordtypeId = new ReteriveRecordTypeId();
        system.assertNotEquals(recordtypeId.showroomAppointmentId, null);
        
    }

}