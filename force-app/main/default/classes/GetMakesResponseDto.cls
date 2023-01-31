/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 15/08/2019.
 */

global with sharing class GetMakesResponseDto extends SimpleResourceResponseDto{

    public GetMakesResponseDto(){
        super();
    }

    public GetMakesResponseDto(List<Vehicle_Specification__c> vehicleSpecifications){
        this();
        Map<Id, String> makes = new Map<Id, String>();
        for(Vehicle_Specification__c spec : vehicleSpecifications){
            makes.put(spec.Id, spec.Name);
        }
        transformMap(makes);
    }

    public GetMakesResponseDto(List<AggregateResult> results){
        this();
        Map<Id, String> makes = new Map<Id, String>();
        for(AggregateResult result : results){
            makes.put((Id)result.get('Make__c'), (String)result.get('Name'));
        }
        transformMap(makes);
    }

    private void transformMap(Map<Id, String> makes) {
        for (Id key : makes.keySet()) {
            this.Data.add(new SimpleResourceDto(key, makes.get(key)));
        }
    }

}