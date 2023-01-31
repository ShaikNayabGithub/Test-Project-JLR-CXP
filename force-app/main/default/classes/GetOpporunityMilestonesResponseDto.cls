/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 14/10/2019.
 */

public with sharing class GetOpporunityMilestonesResponseDto {

    public Boolean IsQualificationComplete {get; set;}
    public Boolean IsModelOfInterestComplete {get; set;}
    public Boolean IsTestDriveComplete {get; set;}
    public Boolean IsVehicleSelectionComplete {get; set;}
}