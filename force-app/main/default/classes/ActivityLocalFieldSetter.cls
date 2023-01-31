public class ActivityLocalFieldSetter {
    private final LocalNameRetriever localNameRetriever = new LocalNameRetriever();
    private final LocalNameSetter localNameSetter= new LocalNameSetter();
    
    private static final String whoFieldName = Task.WhoId.getDescribe().getName();
    private static final String firstNameLocalFieldName = Task.First_Name_Local__c.getDescribe().getName();
    private static final String lastNameLocalFieldName = Task.Last_Name_Local__c.getDescribe().getName();
    
    
    public void SetLocalFields(List<SObject> activities)
    {
        Set<String> whoIds = SObjectUtilities.GetFieldValues(activities, whoFieldName);
        
        Set<Id> contactIds = StringExtensions.GetSobjectIds(Schema.Contact.SObjectType, whoIds);
        Set<Id> leadIds = StringExtensions.GetSobjectIds(Schema.Lead.SObjectType, whoIds);
        
        List<SObject> contacts = this.localNameRetriever.RetrieveContacts(contactIds);
        List<SObject> leads = this.localNameRetriever.RetrieveLeads(leadIds);
        
        Map<Id, SObject> parentObjectMap = new Map<Id, SObject>(contacts);
        parentObjectMap.PutAll(leads);
        
        Map<String, String> fieldMap = new Map<String, String>();
        fieldMap.put('FirstNameLocal', firstNameLocalFieldName);
        fieldMap.put('LastNameLocal', lastNameLocalFieldName);
        
        this.localNameSetter.SetLocalNames(parentObjectMap, activities, fieldMap, whoFieldName);
    }
    
    public void SetLocalFields(List<SObject> currentActivities, List<SObject> oldActivities)
    {
        List<SObject> activitiesWithModifiedWho = SObjectUtilities.GetChanged(currentActivities, oldActivities, new Set<String>{whoFieldName});
        this.SetLocalFields(activitiesWithModifiedWho);
    }
}