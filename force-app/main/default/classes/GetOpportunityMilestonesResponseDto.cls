/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 14/10/2019.
 */

public with sharing class GetOpportunityMilestonesResponseDto {

    @AuraEnabled
    public Boolean IsQualificationComplete {get; set;}
    @AuraEnabled
    public Boolean IsQualificationInProgress {get; set;}
    @AuraEnabled
    public String QualificationId {get; set;}

    @AuraEnabled
    public Boolean IsAppraisalComplete {get; set;}
    @AuraEnabled
    public Boolean IsAppraisalInProgress{get; set;}
    @AuraEnabled
    public String AppraisalId {get; set;}

    @AuraEnabled
    public Boolean IsTestDriveComplete {get; set;}
    @AuraEnabled
    public Boolean IsTestDriveInProgress {get; set;}
    @AuraEnabled
    public String TestDriveId {get; set;}

    @AuraEnabled
    public Boolean IsVehicleSelectionComplete {get; set;}
    @AuraEnabled
    public Boolean IsVehicleSelectionInProgress{get; set;}
    @AuraEnabled
    public String VehicleSelectionId {get; set;}

    @AuraEnabled
    public Boolean IsHandoverComplete {get; set;}
    @AuraEnabled
    public Boolean IsHandoverInProgress {get; set;}
    @AuraEnabled
    public String HandoverId {get; set;}

    @AuraEnabled
    public Boolean IsOrderTakenComplete {get; set;}
    @AuraEnabled
    public Boolean IsOrderTakenInProgress {get; set;}
    @AuraEnabled
    public String OrderTakenId {get; set;}

    @AuraEnabled
    public Boolean IsNegotiationComplete {get; set;}
    @AuraEnabled
    public Boolean IsNegotiationInProgress {get; set;}
    @AuraEnabled
    public String NegotiationId {get; set;}
}