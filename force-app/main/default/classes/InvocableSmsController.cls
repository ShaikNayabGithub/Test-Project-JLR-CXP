/**w
 * Created by caleb@argologic.com.au on 17/02/2020.
 */

public with sharing class InvocableSmsController
{
    public static final String MAILJET_SMS_ENDPOINT = 'https://api.mailjet.com/v4/sms-send';

    private static final String RESPONSE_ERROR_MESSAGE = 'ErrorMessage';
    private static final String ERROR_MESSAGE = 'Please Contact Your System Administrator For More Details';

    private static final String API_KEY = '00c35f25526e4f7a891ab5e55130164b';

    @AuraEnabled
    public static void SendToMailjet(SmsSendRequestDto request)
    {
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + API_KEY);
        req.setHeader('Content-Type', 'application/json');

        String body = JSON.serialize(request);
        body = body.replace('"SenderName"', '"From"');
        req.setBody(body);
        System.debug(req.getBody());

        req.setMethod('POST');
        req.setEndpoint(MAILJET_SMS_ENDPOINT);

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug(res.getBody());

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        if (res.getStatusCode() == 200)
        {
            CreateSMSActivity(request.ContactId, request.CaseId, request.Text);
        }
        else
        {
            if (responseMap.containsKey(RESPONSE_ERROR_MESSAGE))
            {
                throw new JlrCustomException(responseMap.get(RESPONSE_ERROR_MESSAGE) + ' ' + ERROR_MESSAGE);
            }
            else
            {
                throw new JlrCustomException(ERROR_MESSAGE);
            }
        }
    }

    public static void CreateSMSActivity(String WhoId, String WhatId, String MessageContents)
    {
        final String TASK_COMPLETED_STATUS = 'Completed';

        Task task = new Task();
        task.WhoId = WhoId;
        task.WhatId = WhatId;
        task.Status = TASK_COMPLETED_STATUS;
        task.Subject = 'SMS';
        task.Description = MessageContents;
        insert task;
    }
}