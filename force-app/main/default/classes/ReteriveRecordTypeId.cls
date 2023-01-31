public with sharing class ReteriveRecordTypeId
{
    public String serviceAppointmnetId{get;set;}
    public String testDriveId{get;set;}
    public String showroomAppointmentId{get;set;}
    public String repairId{get;set;}
    public String roadsideId{get;set;}
    public ReteriveRecordTypeId()
    {
        List<RecordType> listOfRecordType = [SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE And sObjectType = 'Event'];
        
        for(RecordType recType : listOfRecordType )
        {
           if(recType.DeveloperName == 'Service_Appointment'){
                serviceAppointmnetId = recType.Id;
           }
           
           if(recType.DeveloperName == 'Test_Drive'){
               testDriveId = recType.Id;
           }
               
           if( recType.DeveloperName == 'Showroom_appointment'){
               showroomAppointmentId = recType.Id;
           }
           
           if(recType.DeveloperName == 'Repair'){
               repairId = recType.Id;
           }
           
           if(recType.DeveloperName == 'Roadside'){
               roadsideId = recType.Id;
           }
        }
    }
}