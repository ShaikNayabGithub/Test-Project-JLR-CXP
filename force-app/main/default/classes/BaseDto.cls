/**
 * Created by caleb.manning on 2019-08-13.
 */

public virtual class BaseDto
{
    @AuraEnabled
    public string Identifier { get; set; }
    @AuraEnabled
    public string Name { get; set; }
}