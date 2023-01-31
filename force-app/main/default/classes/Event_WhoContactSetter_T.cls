@isTest
public class Event_WhoContactSetter_T {
	static testmethod void SetWhoContact_SetsWhoContactToContact1_GivenEventWithWhoSetToContact1()
    {
    	Event_WhoContactSetter whoContactSetter = new Event_WhoContactSetter();

    	Contact contact1 = TestClass_ValidContactBuilder.Build();
    	Event event1 = new Event(WhoId = contact1.Id);

    	List<Event> events = new List<Event>{ event1 };


    	whoContactSetter.SetWhoContact(events);


    	System.assertEquals(contact1.Id, event1.Who_Contact__c);
    }

    static testmethod void SetWhoContact_DoesNotSetWhoContact_GivenEventWithWhoSetToLead1()
    {
    	Event_WhoContactSetter whoContactSetter = new Event_WhoContactSetter();

    	Lead lead1 = TestClass_LeadCreator.CreateLead();
    	Event event1 = new Event(WhoId = lead1.Id);

    	List<Event> events = new List<Event>{ event1 };


    	whoContactSetter.SetWhoContact(events);


    	System.assert(String.isEmpty(event1.Who_Contact__c));
    }

    static testmethod void SetWhoContact_DoesNotSetWhoContact_GivenEventWithNoWhoSet()
    {
    	Event_WhoContactSetter whoContactSetter = new Event_WhoContactSetter();

    	Event event1 = new Event();

    	List<Event> events = new List<Event>{ event1 };


    	whoContactSetter.SetWhoContact(events);


    	System.assert(String.isEmpty(event1.Who_Contact__c));
    }
}