public class InternetCalendar {
    public final static TextPropertyValue METHOD_PUBLISH = new TextPropertyValue('PUBLISH');
    public final static TextPropertyValue METHOD_REQUEST = new TextPropertyValue('REQUEST');
    public final static TextPropertyValue METHOD_CANCEL = new TextPropertyValue('CANCEL');
    
    public final static TextPropertyValue EVENT_CLASS_PUBLIC = new TextPropertyValue('PUBLIC');
    public final static TextPropertyValue EVENT_CLASS_PRIVATE = new TextPropertyValue('PRIVATE');
    public final static TextPropertyValue EVENT_CLASS_CONFIDENTIAL = new TextPropertyValue('CONFIDENTIAL');

    public final static TextPropertyValue EVENT_STATUS_TENTATIVE = new TextPropertyValue('TENTATIVE');
    public final static TextPropertyValue EVENT_STATUS_CONFIRMED = new TextPropertyValue('CONFIRMED');
    public final static TextPropertyValue EVENT_STATUS_CANCELLED = new TextPropertyValue('CANCELLED');

    public final static TextPropertyValue ROLE_CHAIR = new TextPropertyValue('CHAIR');
    public final static TextPropertyValue ROLE_REQUIRED = new TextPropertyValue('REQ-PARTICIPANT');
    public final static TextPropertyValue ROLE_OPT_PARTICIPANT = new TextPropertyValue('OPT-PARTICIPANT');
    public final static TextPropertyValue ROLE_NON_PARTICIPANT = new TextPropertyValue('NON-PARTICIPANT');

    public static final TextPropertyValue PROD_ID = new TextPropertyValue('-//salesforce.com//Calendar//EN');
    public static final TextPropertyValue VERSION  = new TextPropertyValue('2.0');

    public static String render(InternetCalendar.Component component) {
        String result = 'BEGIN:' + component.tagName() + '\n';

        for (Property property : component.properties()) {
            result += property.propertyLine();
        }

        if (component.getcomponents() != null) {
            for (InternetCalendar.Component childComponent : component.getcomponents()) {
                result += render(childComponent) + '\n';
            }
        }

        result += 'END:' + component.tagName();

        return result;
    }

    public class Calendar implements InternetCalendar.Component {
        public List<InternetCalendar.Component> components {get;set;}

        public TextPropertyValue method {get;set;}
        public BooleanPropertyValue forceSingleEvent {get;set;}

        public String tagName() {
            return 'VCALENDAR';
        }

        public List<Property> properties() {
            List<Property> properties = new List<Property>();
            properties.add(new Property('VERSION', InternetCalendar.VERSION));
            properties.add(new Property('PRODID', InternetCalendar.PROD_ID));
            //properties.add(new Property('METHOD', this.method));
            //properties.add(new Property('X-MS-OLK-FORCEINSPECTOROPEN', this.forceSingleEvent));
            
            return properties;
        }

        public List<InternetCalendar.Component> getComponents() {
            return this.components;
        }

    }

    public class Event implements InternetCalendar.Component {
        public List<InternetCalendar.Component> components {get;set;}

        // In the case of an InternetCalendar object that specifies a
        // "METHOD" property, this property specifies the date and time that
        // the instance of the InternetCalendar object was created.  In the case of
        // an InternetCalendar object that doesn't specify a "METHOD" property, this
        // property specifies the date and time that the information
        // associated with the calendar component was last revised in the
        // calendar store.
        // Example DTSTAMP:19971210T080000Z
        public DateTimePropertyValue dtstamp {get;set;}

        // This property defines the persistent, 
        // globally unique identifier for the calendar component.
        public TextPropertyValue uid {get;set;}

        // This property specifies when the calendar component begins.
        public DateTimePropertyValue dtstart {get;set;}

        // This property defines the access classification for a
        // calendar component.
        // valid values are defined in the "EventClass" object
       // public TextPropertyValue eventClass {get;set;}

        // This property specifies the date and time that the calendar
        // information was created by the calendar user agent in the calendar
        // store.
        public DateTimePropertyValue created {get;set;}

        // This property is used in the "VEVENT" to
        // capture lengthy textual descriptions associated with the activity.
        public TextPropertyValue description {get;set;}

        // This property specifies the date and time that the
        // information associated with the calendar component was last
        // revised in the calendar store.
        public DateTimePropertyValue lastModified {get;set;}

        //  This property defines the intended venue for the activity
        // defined by a calendar component.
        //public TextPropertyValue location {get;set;}

        // This property defines the organizer for a calendar
        // component.  
        //public Organizer organizer {get;set;}

        // This property defines the relative priority for a calendar
        // component.
        //
        // This priority is specified as an integer in the range 0
        // to 9.  A value of 0 specifies an undefined priority.  A value of 1
        // is the highest priority.  A value of 2 is the second highest
        // priority.  Subsequent numbers specify a decreasing ordinal
        // priority.  A value of 9 is the lowest priority.
        //
        // A CUA with a three-level priority scheme of "HIGH", "MEDIUM", and
        // "LOW" is mapped into this property such that a property value in
        // the range of 1 to 4 specifies "HIGH" priority.  A value of 5 is
        // the normal or "MEDIUM" priority.  A value in the range of 6 to 9
        // is "LOW" priority.
        //public IntegerPropertyValue priority {get;set;}

        // This property defines the revision sequence number of the
        // calendar component within a sequence of revisions.  
        //public IntegerPropertyValue sequence {get;set;}

        // This property defines the overall status or confirmation
        // for the calendar component.
        // Event statuses are defined in the "EventStatus" object
        public TextPropertyValue status {get;set;}

        // This property defines a short summary or subject for the
        // calendar component.
        public TextPropertyValue summary {get;set;}
        public TextPropertyValue category {get;set;}

        // This property defines whether or not an event is
        // transparent to busy time searches
        //public TransparentPropertyValue transparent {get;set;}

        // This property defines a Uniform Resource Locator (URL)
        // associated with the InternetCalendar object.  
        //public String url {get;set;}

        // The full range of calendar components specified by a
        // recurrence set is referenced by referring to just the "UID"
        // property value corresponding to the calendar component.  The
        // "RECURRENCE-ID" property allows the reference to an individual
        // instance within the recurrence set.  
        // public String recuranceId {get;set;}
        //
        // This property defines a rule or repeating pattern for
        // recurring events, to-dos, journal entries, or time zone
        // definitions.
        //public String rrule {get;set;}

        // This property specifies the date and time that a calendar
        // component ends.  
        public DateTimePropertyValue dtend {get;set;}

        // This property specifies a positive duration of time.
        public IntegerPropertyValue duration {get;set;}

        //public String attach {get;set;}

        // This property defines an "Attendee" within a calendar
        // component.
        //public List<Attendee> attendees {get;set;}

        // This property is used to specify categories or subtypes
        // of the calendar component.  The categories are useful in searching
        // for a calendar component of a particular type and category.
        // Within the "VEVENT", "VTODO", or "VJOURNAL" calendar components,
        // more than one category can be specified as a COMMA-separated list
        // of categories.
        // public List<String> categories {get;set;}

        // This property specifies non-processing information intended
        // to provide a comment to the calendar user.  
        // public String comment {get;set;}

        // property is used to represent contact information or
        // alternately a reference to contact information associated with the
        // calendar component.  
        //public String contact {get;set;}

        // This property defines the list of DATE-TIME exceptions for
        // recurring events, to-dos, journal entries, or time zone
        // definitions.
        //public DateTime exdate {get;set;}

        // This property defines the status code returned for a
        // scheduling request.  
        //public String rstatus {get;set;}

        // This property defines the equipment or resources
        // anticipated for an activity specified by a calendar component.
        //public String resources {get;set;}

        // This property defines the list of DATE-TIME values for
        // recurring events, to-dos, journal entries, or time zone
        // definitions.
        //public String rdate {get;set;}

        public String tagName() {
            return 'VEVENT';
        }

        public List<Property> properties() {
            List<Property> properties = new List<Property>();
            properties.add(new Property('UID', this.uid));
            properties.add(new Property('DTSTAMP', this.dtstamp));
            properties.add(new Property('SUMMARY', this.summary));
            properties.add(new Property('CATEGORIES', this.category));
            properties.add(new Property('CREATED', this.created));
            properties.add(new Property('LAST-MODIFIED', this.lastModified));
            properties.add(new Property('STATUS', this.status));
            properties.add(new Property('DTSTART', this.dtstart));
            properties.add(new Property('DURATION', this.duration));
            properties.add(new Property('DTEND', this.dtend));
            properties.add(new Property('DESCRIPTION', this.description));
  /*          
            properties.add(new Property('LOCATION', this.location));
            //properties.add(new Property('ORGANIZER', this.organizer));
            properties.add(new Property('PRIORITY', this.priority));
            properties.add(new Property('SEQUENCE', this.sequence));
            properties.add(new Property('STATUS', this.status));
            
            properties.add(new Property('TRANSP', this.transparent));
            properties.add(new Property('DTEND', this.dtend));

            for (Attendee attendee : this.attendees) {
                properties.add(new Property('ATTENDEE', attendee));
            }
*/
            return properties;
        }

        public List<InternetCalendar.Component> getComponents() {
            return this.components;
        }


    }
/*
    public class TimeZone implements InternetCalendar.Component {
        public List<InternetCalendar.Component> components {get;set;}

        public TextPropertyValue tzid {get;set;}
        public DateTimePropertyValue lastModified {get;set;}

        public String tagName() {
            return 'VTIMEZONE';
        }

        public List<Property> properties() {
            List<Property> properties = new List<Property>();
            properties.add(new Property('TZID', this.tzid));
            properties.add(new Property('LAST-MODIFIED', this.lastModified));

            return properties;
        }

        public List<InternetCalendar.Component> getComponents() {
            return this.components;
        }

    }

    public class TimeZoneComponent implements InternetCalendar.Component {
        public List<InternetCalendar.Component> components {get;set;}

        public boolean isDaylightSavings {get;set;}
        public DateTimePropertyValue dtstart {get;set;}
        public DateTimePropertyValue dtend {get;set;}
        public TextPropertyValue tzoffsetfrom {get;set;}
        public TextPropertyValue tzoffsetto {get;set;}

        public String tagName() {
            if (this.isDaylightSavings == true) {
                return 'DAYLIGHT';
            }
            else {
                return 'STANDARD';
            }
        }

        public List<Property> properties() {
            List<Property> properties = new List<Property>();
            properties.add(new Property('DTSTART', this.dtstart));
            properties.add(new Property('TZOFFSETFROM', this.tzoffsetfrom));
            properties.add(new Property('TZOFFSETTO', this.tzoffsetto));

            return properties;
        }

        public List<InternetCalendar.Component> getComponents() {
            return this.components;
        }
    }
*/
    public virtual interface Component {
        String tagName();
        List<Property> properties();
        List<InternetCalendar.Component> getcomponents();
    } 

    public class Property {
        public string key {get;set;}
        public PropertyValue value {get;set;}

        public Property(string Key, PropertyValue Value) {
            this.key = key;
            this.value = value;
        }

        public String seperator() {
            if (this.value != null && this.value.isCompoundValue()) {
                return ';';
            }
            else {
                return ':';
            }
        }

        public String propertyLine() {
            if (this.value == null) {
                return '';
            }
            String valueText = this.value.valueText();
            if (String.isBlank(valueText)) {
                return '';
            }

            return this.key + this.seperator() + valueText + '\n';
        }
    }
/*
    public class Organizer implements PropertyValue {
        public calendarAddress calendarAddress {get;set;}
        public calendarAddress sentBy {get;set;}

        public String valueText() {
            String valueText = '';

            if (this.sentBy != null) {
                valueText += 'SENT-BY=' + this.sentBy.valueText() + ':';
            }
            if (this.calendarAddress != null) {
                valueText += this.calendarAddress.valueText();
            }

            return valueText;
        }

        public Boolean isCompoundValue() {
            return true;
        }
    }

    public class Attendee extends CalendarAddress {
        

        //Defined in the ROLE object
        public TextPropertyValue role {get;set;}

        public BooleanPropertyValue rsvpRequested {get;set;}

        public override String valueText() {
            String valueText = '';

            if (this.CommonName != null) {
                valueText = 'CN="' + this.commonName.valueText() + '";';
            }
            if (this.rsvpRequested != null) {
                valueText += 'RSVP=' + this.rsvpRequested.valueText() + ':';
            }
            if (this.role != null) {
                valueText += 'ROLE=' + this.role.valueText() + ':';
            }
            if (this.Address != null) {
                valueText += 'mailto:' + this.address.valueText();
            }

            return valueText;
        }

    }
*/
    public virtual class CalendarAddress implements PropertyValue {
        public TextPropertyValue commonName {get;set;}
        public TextPropertyValue address {get;set;}

        public CalendarAddress() {}
    
        public CalendarAddress(String commonName, String address) {
            this.commonName = new TextPropertyValue(commonName);
            this.address = new TextPropertyValue(address);
        }

        public virtual String valueText() {
            String valueText = '';
            
            if (this.CommonName != null) {
                valueText = 'CN="' + this.commonName.valueText() + '":';
            }
            if (this.Address != null) {
                valueText += 'mailto:' + this.address.valueText();
            }

            return valueText;
        }

        public Boolean isCompoundValue() {
            return true;
        }
    }

    public class TextPropertyValue implements PropertyValue {
        public String value {get;set;}

        public TextPropertyValue(String value) {
            this.value = value;
        }

        public String valueText() {
            if (String.isNotBlank(this.value)) {
                return this.value.replaceAll('\\n', '\\n\n');
            }
            return this.value;
        }

        public Boolean isCompoundValue() {
            return false;
        }
    }

    public class IntegerPropertyValue implements PropertyValue {
        public Integer value {get;set;}

        public IntegerPropertyValue(Integer value) {
            this.value = value;
        }

        public String valueText() {
            return String.valueOf(this.value);
        }

        public Boolean isCompoundValue() {
            return false;
        }
    }

    public class BooleanPropertyValue implements PropertyValue {
        public Boolean value {get;set;}

        public BooleanPropertyValue(Boolean value) {
            this.value = value;
        }

        public String valueText() {
            if (this.value == true) {
                return 'TRUE';
            }
            else {
                return 'FALSE';
            }
        }

        public Boolean isCompoundValue() {
            return false;
        }
    }

    public class DateTimePropertyValue implements PropertyValue {
        public DateTime value {get;set;}
        public String timezoneId {get;set;}

        public DateTimePropertyValue(DateTime value) {
            this.value = value;
        }

        public DateTimePropertyValue(DateTime value, String timezoneId) {
            this.timezoneId = timezoneId;
            this.value = value;
        }

        public String valueText() {
            if (!String.isBlank(timezoneId)) {
                return 'TZID=' + timezoneId + ':' + value.format('yyyyMMdd') + 'T' + value.format('HHmmss');
            }
            else {
                return value.formatGmt('yyyyMMdd') + 'T' + value.formatGmt('HHmmss') + 'Z';
            }
        }

        public Boolean isCompoundValue() {
            return (!String.isBlank(timezoneId));
        }
    }
/*
    public class TransparentPropertyValue implements PropertyValue {
        public Boolean transparent {get;set;}

        public TransparentPropertyValue(Boolean value) {
            this.transparent = value;
        }

        public String valueText() {
            if (this.transparent == true) {
                return 'TRANSPARENT';
            }
            else {
                return 'OPAQUE';
            }
        }

        public Boolean isCompoundValue() {
            return false;
        }
    }
*/
    public virtual interface PropertyValue {
        String valueText();
        Boolean isCompoundValue();
    } 

}