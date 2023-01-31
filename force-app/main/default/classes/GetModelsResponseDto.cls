/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 13/08/2019.
 */

public with sharing class GetModelsResponseDto extends SimpleResourceResponseDto{

    public GetModelsResponseDto(){
        super();
    }

    public GetModelsResponseDto(List<AggregateResult> results){
        this();
        Map<Id, String> models = new Map<Id, String>();
        for(AggregateResult result : results){
            models.put((Id)result.get(Product2.fields.Model__c.getDescribe().name), (String)result.get(Product2.fields.Model_Alternative__c.getDescribe().name));
        }

        transformMap(models);
    }

    public GetModelsResponseDto(List<Vehicle_Specification__c> vehicleSpecifications){
        this();
        Map<Id, String> models = new Map<Id, String>();
        for(Vehicle_Specification__c spec : vehicleSpecifications){
            models.put(spec.Id, spec.Name);
        }

        transformMap(models);
    }

    private void transformMap(Map<Id, String> models) {
        for (Id key : models.keySet()) {
            this.Data.add(new SimpleResourceDto(key, models.get(key)));
        }
    }
}