@IsTest
private class CalendarInvite_Test {
    public static final Date ONE_WEEK_LATER = Date.today().addDays(7);
    public static final String testDesc = 'Text Event';
    public static final Datetime  startDateTime = System.now().addminutes(10);
    public static final Datetime  endDateTime = System.now().addminutes(40);
    
    @Istest
    static void CreateMeetingInvite_test(){
        Id corporateId = AccountUtilities.RecordTypes.get('Corporate').Id;
        Account acct1=new Account(Name = 'testAccount1', recordtypeId = corporateId);
    Contact newContact = new Contact(LastName = 'Bananas', FirstName = 'Sharon', Email = 'potato@farm.com');
    Event newEvent = new Event();
    newEvent.ActivityDateTime = startDateTime;
    newEvent.StartDatetime = startDateTime;
    newEvent.EndDatetime = endDateTime;
    newEvent.Subject = testDesc;
    newEvent.Description = testDesc;    
    Test.startTest();
        insert acct1;
        newContact.AccountId = acct1.Id;
        insert newContact;
        newEvent.whoId = newContact.Id;
        insert newEvent;
     Test.stopTest();        
    }
}