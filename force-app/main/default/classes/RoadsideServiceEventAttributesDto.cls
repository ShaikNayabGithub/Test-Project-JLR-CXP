/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 1/11/2019.
 */

global with sharing class RoadsideServiceEventAttributesDto extends  AttributesDto {

    global RoadsideServiceEventAttributesDto(){
        super();
        init();
    }

    private void init(){

    }

    public String VehicleOwner { get; set; }

    public String VehicleIdentificationNumber { get; set; }

    public String VehicleRegistration { get; set; }

    public String VehicleModel { get; set; }

    public String IncidentId { get; set; }

    public String IncidentDate { get; set; }

    public String IncidentCallerName { get; set; }

    public String IncidentCallerNumber { get; set; }

    public String IncidentLocation { get; set; }

    public String IncidentLocationGpsCoordinates { get; set; }

    public String IncidentJobType { get; set; }

    public String IncidentBreakdownDescription { get; set; }

    public String IncidentTowDestination { get; set; }

    public Boolean IncidentIsRepeat { get; set; }

    public String RoadsideServiceClub { get; set; }

    public String RoadsideServiceAuthorisationNumber { get; set; }

    public String RoadsideServicePlanCode { get; set; }

    public enum NomStatuses {
        ACTIVE, LAPSED
    }

    public NomStatuses RoadsideServiceNomStatus { get; set; }

    public String RoadsideServiceExpiryDate { get; set; }
    
    public String IncidentLocation2 { get; set; }
    
    public String BreakdownReason { get; set; }
    
    public String BreakdownExplanation { get; set; }
    
    public String TowDestination { get; set; }

    public String Comments { get; set; }
    
    public String Location { get; set; }

    public String TowRequired { get; set; }
}