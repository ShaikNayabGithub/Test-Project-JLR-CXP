/**
 * Created by caleb@argologic.com.au on 6/11/2019.
 */

global with sharing class MissingRequiredFieldException extends Exception
{
    public List<String> MissingFields {get; set;}

    public MissingRequiredFieldException(List<String> missingFields)
    {
        this('Missing Fields = ' + missingFields);
        this.MissingFields = missingFields;
    }
}