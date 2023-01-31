/**
 * Created by caleb on 11/09/2019.
 */

global with sharing class CreateIntegrationEventRequestDto
{
    public enum EventType { Success, Failure }

    public CreateIntegrationEventRequestDto()
    {

    }

    public CreateIntegrationEventRequestDto(EventType EventType, String Message)
    {
        this();
        this.EventType = EventType;
        this.Message = Message;
    }

    public EventType EventType {get; set;}

    public string Message {get; set;}

    public List<String> Emails {get; set;}
}