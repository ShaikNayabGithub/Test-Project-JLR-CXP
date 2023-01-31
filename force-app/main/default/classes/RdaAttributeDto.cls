/**
 * Created by caleb@argologic.com.au on 1/07/2020.
 */

public with sharing class RdaAttributeDto
{
    public String Vin {get; set;}

    public Date HandoverDate {get; set;}

    public String Make {get; set;}

    public String Model {get; set;}

    public String RegistrationNumber {get; set;}

    public String SalesPersonRda {get; set;}

    public String RecordType {get; set;}

    public String CommonSaleType {get; set;}

    public String Status {get; set;}

    public String ServicePlanType {get; set;}

    public Date WarrantyStartDate {get; set;}

    public Datetime CreatedDate {get; set;}
}