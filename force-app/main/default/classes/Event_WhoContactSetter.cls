public class Event_WhoContactSetter {
	public void SetWhoContact(List<Event> events)
	{
		for(Event event : events) {
			if(event.WhoId != null && event.WhoId.getSobjectType() == Schema.Contact.SObjectType &&
					event.Who_Contact__c != event.WhoId) {
				event.Who_Contact__c = event.WhoId;
			}
		}
	}
}