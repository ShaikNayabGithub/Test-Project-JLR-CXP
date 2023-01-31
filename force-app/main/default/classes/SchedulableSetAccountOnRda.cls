/**
 * Created by caleb@argologic.com.au on 5/08/2020.
 */

public with sharing class SchedulableSetAccountOnRda implements Schedulable
{
    public void execute(SchedulableContext ctx) {
        List<RDA__c> rdas = [
                SELECT Id
                FROM RDA__c
                WHERE Account__r.Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
                AND Dealership__c = NULL
                AND LastModifiedDate >= :Datetime.now().addDays(-1)
        ];
        List<String> rdaIds = new List<String>();
        for (Rda__c rda : rdas)
        {
            rdaIds.add(rda.Id);
        }
        InvocableSetAccountOnRda.setRetailerOnRda(rdaIds);
    }

    public static void scheduleHourly()
    {
        String CRON_EXP = '0 0 * * * ?';
        system.schedule('Hourly Set Dealership ' + Datetime.now(), CRON_EXP, new SchedulableSetAccountOnRda());

    }
}