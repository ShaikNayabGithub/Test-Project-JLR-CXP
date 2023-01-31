public with sharing class CalendarInvite {
    
    public Id sourceRecordId {get;set;}
    public String uid {get;set;}
    public Datetime dtstamp {get;set;}
    public Datetime dtstart {get;set;}
    public String summary {get;set;}
    public String category {get;set;}
    public String account {get;set;}
    public String asset {get;set;}
    public Integer duration{get;set;}
    public String description {get;set;}
    public Datetime eventDate {get;set;}
    public Datetime eventStartDate {get;set;}
    public Datetime eventEndDate {get;set;}
    public Participant organiser {get;set;}
    public Datetime created {get;set;}
    public Datetime lastmodified {get;set;}
    public List<Participant> attendees {get;set;}

    public void sendmeeting(Id recordId){
        Event evt = GetEventDetails(recordId);
		User organiser = GetUser(evt.ownerId);
		List<String> attendees = GetAttendees(organiser);
		CreateMeetingInvite(evt, organiser, attendees);
	}
	
	public static Event GetEventDetails(id recid){
	return [select id, ActivityDate, CreatedDate, Description, DurationInMinutes, Subject, StartDateTime, EndDateTime, who.firstname,who.lastname, OwnerId from event WHERE id = :recid LIMIT 1];
	}
	
    public static user GetUser(id userid){
	return [SELECT id, Name, email from user where id = :userId LIMIT 1];}
    
	public static user GetUser(){
	return [SELECT id, Name, email from user where id = :userinfo.getUserId() LIMIT 1];}
	
	public static List<String> GetAttendees(User organiser){
	List<String> attendees = new List<String>();
	attendees.add(organiser.email);
	return attendees;
	}
	
    @AuraEnabled
    public static String downloadinvite(id recordId){
        Event evt = GetEventDetails(recordId);
		User organiser = GetUser();
		List<String> attendees = GetAttendees(organiser);
        CalendarInvite invite = new CalendarInvite(evt, organiser, attendees);
        return invite.CreateIcs().toString();
    }
   
    
    public static void CreateMeetingInvite (Event evt, User org, List<String> attendees) {
        CalendarInvite invite = new CalendarInvite(evt, org, attendees);

        Messaging.reserveSingleEmailCapacity(invite.attendees.size() + 1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<String> toAddresses = new List<String>();
        toAddresses.add(org.email);
        
        mail.setToAddresses(toAddresses);

        String fromAddress = 'noreply@jaguarexperience.com';
		mail.setReplyTo(fromAddress);
        String orgName = 'CXP';
        mail.setSenderDisplayName(orgName);

        mail.setSubject(invite.summary);
        system.debug('Description'+invite.Description);
     
        mail.setHtmlBody(invite.Description);

        

        Messaging.EmailFileAttachment ics = new Messaging.EmailFileAttachment();
        ics.body = invite.CreateIcs();
        ics.contenttype = 'text/calendar;charset=utf-8';
        ics.filename = 'Appointment.ics';

        mail.fileattachments = new List<Messaging.EmailFileAttachment>{ics};
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }

    public CalendarInvite() {}

    public CalendarInvite(Event evt, User organiser, List<String> attendees) {
        this.initialise(evt, organiser, attendees);
    }

    public Blob CreateIcs() {
        InternetCalendar.Calendar ical = createICal();
        String ics = InternetCalendar.render(ical);
        /*String txtInvite = '';
        txtInvite += 'BEGIN:VCALENDAR\n';
        txtInvite += 'PRODID:-//Microsoft Corporation//Outlook 16.0 MIMEDIR//EN\n';
        txtInvite += 'VERSION:2.0\n';
        txtInvite += 'CALSCALE:GREGORIAN\n';
        txtInvite += 'METHOD:REQUEST\n';
        txtInvite += 'REPLAY:ACCEPTED\n';
        txtInvite += 'BEGIN:VEVENT\n';
        txtInvite += 'ATTENDEE\n';
        txtInvite += 'CN=' + this.summary + '\n';
         for (Participant p: this.attendees) {
             txtInvite += 'ATTENDEE:' + p.email + '\n';
         }
        txtInvite += 'X-MS-OLK-FORCEINSPECTOROPEN:TRUE\n';
        txtInvite += 'X-WR-RELCALID:{0000002E-9CDF-9CE8-AD4C-66FC0A5A25F7}\n';
        txtInvite += 'CLASS:PUBLIC\n';
        txtInvite += 'CREATED:' + this.eventDate+'\n';
        txtInvite += 'DTEND:' + this.eventEndDate+'\n';
        txtInvite += 'DTSTART:' + this.eventStartDate+'\n';
        //txtInvite += 'LAST-MODIFIED:' + lastmodifiedDatTime+'\n';
        //txtInvite += 'ORGANIZER;CN=' + name + ':mailto:' + Organiser + '\n';
        //txtInvite += 'RSVP=TRUE\n';
        //txtInvite += 'ROLE=REQ-PARTICIPANT\n';
        //txtInvite += 'PARTSTAT=NEEDS-ACTION\n';
       // txtInvite += 'CN=' + ical.subject + ':mailto:' + Organiser + '\n';
        txtInvite += 'LOCATION:Skype\n';
        txtInvite += 'PRIORITY:5\n';
        txtInvite += 'SEQUENCE:0\n';
        txtInvite += 'SUMMARY:'+this.summary+'\n';
        //txtInvite += 'STATUS:NEEDS-ACTION\n';
        txtInvite += 'LANGUAGE=en-us:\n';
        txtInvite += 'TRANSP:OPAQUE\n';
        txtInvite += 'UID:'+this.uid;
        txtInvite += 'X-ALT-DESC;FMTTYPE=text/html:<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"><HTML><HEAD><META NAME="Generator" CONTENT="MS Exchange Server version 08.00.0681.000"><TITLE></TITLE></HEAD><BODY><!-- Converted from text/plain format --></BODY></HTML>\n';
       // txtInvite += 'X-MICROSOFT-CDO-BUSYSTATUS:BUSY\n';
       // txtInvite += 'X-MICROSOFT-CDO-IMPORTANCE:1\n';
       String resultdesc ='';
       if(this.description!=null){
      
        resultdesc=this.description.replace('<br>','\r\n');
      
       }
       system.debug('resultdesc'+resultdesc);
       txtInvite += 'DESCRIPTION:'+resultdesc;
        //txtInvite += 'BEGIN:VALARM\n';
        //txtInvite += 'TRIGGER:-PT15M\n';
        //txtInvite += 'ACTION:DISPLAY\n';
        //txtInvite += 'STATUS:CONFIRMED\n';
       // txtInvite += 'DESCRIPTION:'+this.description;
        //txtInvite += 'END:VALARM\n';
        txtInvite += 'END:VEVENT\n';
        txtInvite += 'END:VCALENDAR';
        return Blob.valueOf(txtInvite);*/
        return Blob.valueOf(ics);
    }
    
    private InternetCalendar.Calendar createICal() {
        InternetCalendar.Calendar cal = new InternetCalendar.Calendar();
        InternetCalendar.Event event = new InternetCalendar.Event();
        
        cal.components = new List<InternetCalendar.Component>();
        cal.forceSingleEvent = new InternetCalendar.BooleanPropertyValue(true);
        cal.method = InternetCalendar.METHOD_REQUEST;

        cal.components.add(event);

        String tzId = UserInfo.getTimeZone().getID();

        event.uid = new InternetCalendar.TextPropertyValue(this.uid);
        event.dtstamp = new InternetCalendar.DateTimePropertyValue(Datetime.now(), tzId);
        event.summary = new InternetCalendar.TextPropertyValue(this.summary);
        event.created = new InternetCalendar.DateTimePropertyValue(this.eventDate, tzId);
        event.dtstart = new InternetCalendar.DateTimePropertyValue(this.eventStartDate, tzId);
        event.duration = new InternetCalendar.IntegerPropertyValue(this.duration);
        event.dtend = new InternetCalendar.DateTimePropertyValue(this.eventEndDate, tzId);
        event.description = new InternetCalendar.TextPropertyValue(this.description);

       /*
         
        event.attendees = new List<InternetCalendar.Attendee>();

        if (this.attendees != null && this.attendees.size() > 0) {
            for (Participant participant : this.attendees) {
                event.attendees.add(participant.createAttendee());
            }
        }
*/
        return cal;
    }
    
    private void initialise(Event evt, User organiser, List<String> attendees) {
        this.sourceRecordId = evt.Id;
        //this.uid = UidUtility.uidFromId(evt.Id);
        this.uid = evt.Id;
        this.dtstamp= evt.CreatedDate;
        this.duration = evt.DurationInMinutes;
        String fname;
        //If(evt.who.firstname != null) {fname = evt.who.firstname.left(4);}
        If(evt.who.lastname != null) {fname = evt.who.lastname.left(4);
                                     this.summary = evt.subject + ' - ' + fname;}
        else {this.summary = evt.subject ;}
        this.summary = evt.subject + ' - ' + fname;
        this.category = 'salesforce.com';
        this.created = evt.ActivityDate;
        this.lastmodified = evt.ActivityDate;
       
        String resultDesc='';
        if(evt.Description!=null){
        String[] descarr=evt.Description.split('\r\n');
      
        for(String val:descarr){
            resultDesc=resultDesc+val;
            resultDesc=resultDesc+'<br>';
        }
        }
         this.description = evt.Subject + ' <br><br>'+ resultDesc;
        this.eventdate = evt.ActivityDate;
        this.eventStartDate = evt.StartDateTime;
        this.eventEndDate = evt.EndDateTime;
        this.organiser = new Participant(organiser);

        this.attendees = new List<Participant>();
        for (String attendee : attendees) {
            this.attendees.add(new Participant(attendee));
        }

       
           
           
       
    }

    public class Participant {

        public String name {get;set;}
        public String email {get;set;}

        public Participant(String name, String email) {
            this.Name = name;
            this.Email = email;
        }

      public Participant(String email) {
            this.Email = email;
        }

        public Participant(User user) {
            this.Name = user.Name;
            this.Email = user.Email;
        }

        public Participant(Contact contact) {
            this.Name = contact.Name;
            this.Email = contact.Email;
        }
/*
        public InternetCalendar.Attendee createAttendee() {
            InternetCalendar.Attendee result = new InternetCalendar.Attendee();
            result.address = new InternetCalendar.TextPropertyValue(this.email);
            result.commonName = new InternetCalendar.TextPropertyValue(this.name);
            result.rsvpRequested = new InternetCalendar.BooleanPropertyValue(true);
            return result;
        }
*/
      
    }
/*
    public class Request {
        @InvocableVariable(label='Event Id' description='Id of the Event Record used for the basis of the Invite.' required=true)
        public Id eventId;

        @InvocableVariable(label='Attach To Id' description='Id of the Record to attach the Calendar Invite to.' required=true)
        public Id attachToId;

        @InvocableVariable(label='Filename' description='Name to assign to the invite.' required=true)
        public String filename;
    }
*/
    public class EventNotFoundException extends Exception {}
    public class OrganiserNotFoundException extends Exception {}
    public class MoreThanOneEventException extends Exception {}   
 }