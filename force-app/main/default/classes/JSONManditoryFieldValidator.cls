/**
 * Created by caleb@argologic.com.au on 6/11/2019.
 */

public with sharing class JSONManditoryFieldValidator
{
    public static List<String> getMissingFields(Object dto, List<String> requiredFields)
    {
        Map<String, Object> fieldsToValue;
        try
        {
            fieldsToValue = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(dto));
        }
        catch (Exception ex)
        {
            throw new TypeException('Dto must be a class');
        }

        List<String> result = new List<String>();
        for (String s : requiredFields)
        {
            if (fieldsToValue.get(s) == null)
            {
                result.add(s);
            }
        }
        return result;
    }
}