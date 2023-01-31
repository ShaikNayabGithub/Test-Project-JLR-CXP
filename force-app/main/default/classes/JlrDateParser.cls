/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 23/10/2019.
 */

public with sharing class JlrDateParser {

    public static DateTime parseStringAsDatetime(string dt) {
        if (String.isBlank(dt)){
            throw new DateParsingException('Cannot parse: supplied string is blank');
        }
        try {
            return getDateTimeFromstring(dt);
        } catch (Exception ex) {
            DateParsingException dtex = new DateParsingException('Cannot parse: ' + dt, ex);
            dtex.DateString = dt;
            throw dtex;
        }
    }

    public static Date parseStringAsDate(string dt) {
        if (String.isBlank(dt)){
            return null;
        }
        try {
            return getDateFromString(dt);
        } catch (Exception ex) {
            DateParsingException dtex = new DateParsingException('Cannot parse: ' + dt, ex);
            dtex.DateString = dt;
            throw dtex;
        }
    }

    private static Datetime getDateTimeFromString(String dateString) {
        System.debug('>> getDateTimeFromString(dateString: ' + dateString + ')');

        //try parsing as date time
        try {
            System.debug('Trying Datetime.parse(' + dateString + ')');
            return Datetime.parse(dateString);
        } catch (Exception ex) {
            System.debug('Failed : Datetime.parse(' + dateString + ')');
        }

        //try the valueof function
        try {
            System.debug('Trying Datetime.valueOf(' + dateString + ')');
            return Datetime.valueOf(dateString);
        } catch (Exception ex) {
            System.debug('Failed : Datetime.valueOf(' + dateString + ')');
        }

        try {
            System.debug('Trying (Datetime)JSON.deserialize(' + dateString + ', Datetime.class)');
            return (Datetime)JSON.deserialize('"' + dateString + '"', Datetime.class);
        } catch (Exception ex) {
            System.debug('Failed : (Datetime)JSON.deserialize(' + dateString + ', Datetime.class)');
        }

        //try parsing just the date
        try {
            System.debug('Trying Date.parse(' + dateString + ')');
            return buildDateTimeFromDate(Date.parse(dateString));
        } catch (Exception ex) {
            System.debug('Failed : Date.parse(' + dateString + ')');
            System.debug('Trying Date.valueOf(' + dateString + ')');

            //try valueOf just the date
            try {
                return buildDateTimeFromDate(Date.valueOf(dateString));
            } catch (Exception innerEx) {
                System.debug('Failed : Date.valueOf(' + dateString + ')');
                throw innerEx;
            }
        }
    }

    private static Date getDateFromString(String dateString) {
        System.debug('>> getDateTimeFromString(dateString: ' + dateString + ')');

        //try parsing just the date
        try {
            System.debug('Trying Date.parse(' + dateString + ')');
            return Date.parse(dateString);
        } catch (Exception ex) {
            System.debug('Failed : Date.parse(' + dateString + ')');
            System.debug('Trying Date.valueOf(' + dateString + ')');

            //try valueOf just the date
            try {
                return Date.valueOf(dateString);
            } catch (Exception innerEx) {
                System.debug('Failed : Date.valueOf(' + dateString + ')');
                throw innerEx;
            }
        }
    }

    private static Datetime buildDateTimeFromDate(Date dt) {
        return Datetime.newInstance(dt, Time.newInstance(0, 0, 0, 0)
        );
    }
}