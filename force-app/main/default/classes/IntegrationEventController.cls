/**
 * Created by caleb on 11/09/2019.
 */

public with sharing class IntegrationEventController
{
     public static final String EMAIL_OPT_OUT_POLICY = 'FILTER';

    public static CreateIntegrationEventResponseDto createEvent(CreateIntegrationEventRequestDto req)
    {
        System.debug('>> createEvent(req : ' + JSON.serialize(req) + ')');
        if (String.isBlank(req.Message)){
         NullRequiredFieldException ex = new NullRequiredFieldException();
            ex.setMessage('Message cannot be empty or null');
            ErrorDto err = new ErrorDto(ex);
            return new CreateIntegrationEventResponseDto(err);
        }
        Integration_Event__e integrationEvent = new Integration_Event__e(
            Emails__c = req.Emails == null ? null : String.join(req.Emails, ','),
            Message__c = req.Message,
            Event_Type__c = req.EventType.name()
        );
        Database.SaveResult sr = EventBus.publish(integrationEvent);

        if (sr.isSuccess())
        {
            System.debug('Successfully published event.');
            return new CreateIntegrationEventResponseDto(true);
        }
        else
        {
            CreateIntegrationEventResponseDto response = new CreateIntegrationEventResponseDto(false);
            for(Database.Error err : sr.getErrors())
            {
                System.debug('Error returned: ' +
                    err.getStatusCode() + ' - ' +
                    err.getMessage());
                ErrorDto error = new ErrorDto();
                error.Code = String.valueOf(err.getStatusCode());
                error.Detail = err.getMessage();
                response.Errors.add(error);
            }
            return response;
        }
    }

    public static void sendEmail(Integration_Event__e event)
    {
        System.debug('>> sendEmail()');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = event.Emails__c.split(',');
        message.optOutPolicy = EMAIL_OPT_OUT_POLICY;
        message.subject = 'Integration ' + event.Event_Type__c;
        message.plainTextBody = event.Message__c;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        for (Messaging.SendEmailResult result : results)
        {
            if (!result.success) System.debug('The email failed to send: ' + results[0].errors[0].message);
            else System.debug('Email sent');
        }
        System.debug('<< sendEmail()');
    }
}