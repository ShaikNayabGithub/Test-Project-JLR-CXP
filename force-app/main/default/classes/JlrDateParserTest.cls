/**
 * Created by caleb@argologic.com.au on 12/10/2020.
 */

@IsTest
public with sharing class JlrDateParserTest
{
    @IsTest
    public static void dateTest()
    {
        try { Date d1 = JlrDateParser.parseStringAsDate('12/18/10'); } catch (DateParsingException ex) {}
        try { Date d2 = JlrDateParser.parseStringAsDate('12-18-10'); } catch (DateParsingException ex) {}
        try { Date d3 = JlrDateParser.parseStringAsDate('12182010'); } catch (DateParsingException ex) {}
        try { Date d4 = JlrDateParser.parseStringAsDate('7/02/2009'); } catch (DateParsingException ex) {}
    }

    @IsTest
    public static void dateTimeTest()
    {
        try { DateTime d1 = JlrDateParser.parseStringAsDatetime('20-JUN-1990 08:03:00'); } catch (DateParsingException ex) {}
        try { DateTime d2 = JlrDateParser.parseStringAsDate('1990-06-20 08:03'); } catch (DateParsingException ex) {}
        try { DateTime d3 = JlrDateParser.parseStringAsDate('7/25/2013 6:37:31 PM'); } catch (DateParsingException ex) {}
        try { DateTime d4 = JlrDateParser.parseStringAsDate('1994-11-05T13:15:30Z'); } catch (DateParsingException ex) {}
    }
}