/**
 * Created by caleb@argologic.com.au on 5/02/2020.
 */

public with sharing class UpdateActivityRequestDto
{
    @AuraEnabled
    public String ActivityId { get; set; }

    @AuraEnabled
    public String ActivityType { get; set; }

    @AuraEnabled
    public Boolean IsCompleted { get; set; }

}