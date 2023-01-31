/**
 * Created by caleb@argologic.com.au on 17/02/2020.
 */

public with sharing class SmsSendRequestDto
{
    public static final Integer SMS_CHARACTER_LIMIT = 160;

    private String internalMobileNumber;

    @AuraEnabled
    public String To {
        get {
            return internalMobileNumber;
        }
        set {
            String newValue = value.replaceAll('[\\s-]*','').replaceFirst('^04','+614');
            System.debug(value);
            Pattern ausMobileValidationPattern = Pattern.compile('^\\+614[0-9]{8}$');
            Matcher validateMobileNumber = ausMobileValidationPattern.matcher(newValue);
            if (!validateMobileNumber.matches()) {
                throw new JlrCustomException('Mobile number is not a valid Australian mobile number.');
            }
            internalMobileNumber = newValue;

        }
    }

    @AuraEnabled
    public String SenderName {get; set;}

    private String internalMessage;

    @AuraEnabled
    public String Text
    {
        get
        {
            return internalMessage;
        }
        set
        {
            if (value.length() > SMS_CHARACTER_LIMIT)
            {
                throw new JlrCustomException('Message cannot be more than ' + SMS_CHARACTER_LIMIT + ' characters');
            }
            internalMessage = value;
        }
    }

    @AuraEnabled
    public String ContactId {get; set;}

    @AuraEnabled
    public String CaseId {get; set;}
}