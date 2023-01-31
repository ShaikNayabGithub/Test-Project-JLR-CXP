public class Vista_AssetBuilder {
    private final Map<String, Vista_AssetBuilder_A> eventHandlers;


    public Vista_AssetBuilder(Map<String, Vista_AssetBuilder_A> eventHandlers)
    {
        this.eventHandlers = eventHandlers;
    }


    public void Build(Vista_RequestCollection requestCollection)
    {
        Map<string,Sales_Person_CI_Code_Mapping__c> SalesPersonCodeMap= New Map<String,Sales_Person_CI_Code_Mapping__c>();
        for(Sales_Person_CI_Code_Mapping__c SPCode:[select Id, Name, Country_ISO_Code__c, Jaguar_Code__c, LandRover_Code__c, Sales_Employee_Name__c, Unique_Key__c from Sales_Person_CI_Code_Mapping__c]){
            SalesPersonCodeMap.put(SPCode.Unique_Key__c, SPCode);
        }
        for(String orderNumber : requestCollection.RecordGroups.KeySet()){
            List<Vista_RecordGroup> requests = requestCollection.RecordGroups.get(orderNumber);

            for(Vista_RecordGroup request : requests) {
                Vista_AssetBuilder_A eventHandler = this.eventHandlers.get(request.VistaVehicleOrder.EventCode);
                if(eventHandler != null) { eventHandler.Build(request, requestCollection, SalesPersonCodeMap); }
            }
        }
    }
}