/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 24/09/2019.
 */

public with sharing class ServiceEventController {

    public static CreateRoadsideServiceEventResponseDto create(CreateRoadsideServiceEventRequestDto request){

        CreateRoadsideServiceEventResponseDto response = new CreateRoadsideServiceEventResponseDto(request.Data);
        // create a map used to assign vehicles
        List<String> vins = new List<String>();
        for (RoadsideServiceEventResourceDto s : request.Data)
        {
            vins.add(s.Attributes.VehicleIdentificationNumber);
        }
        Map<String, Asset> vinToAssetMap = getVinMap(vins);

        For (RoadsideServiceEventResourceDto resource : request.Data){
            Roadside_Event__c evt = new Roadside_Event__c();
            //owner
            evt.Caller_Name__c = resource.Attributes.IncidentCallerName;
            evt.Caller_Number__c = resource.Attributes.IncidentCallerNumber;
            evt.VIN__c = resource.Attributes.VehicleIdentificationNumber;
            evt.Model__c = resource.Attributes.VehicleModel;
            evt.Registration__c = resource.Attributes.VehicleRegistration;
            evt.Club__c = resource.Attributes.RoadsideServiceClub;
            evt.Location__c = resource.Attributes.Location;
            evt.Incident_ID__c = resource.Attributes.IncidentId;
            evt.Incident_Date__c = JlrDateParser.parseStringAsDate(resource.Attributes.IncidentDate);
            evt.Job_Type__c = resource.Attributes.IncidentJobType;
            evt.Breakdown__c = resource.Attributes.IncidentBreakdownDescription;
            evt.Tow_to_Destination__c = resource.Attributes.IncidentTowDestination;
            evt.Authorisation_Number__c = resource.Attributes.RoadsideServiceAuthorisationNumber;
            evt.Plan_Code__c = resource.Attributes.RoadsideServicePlanCode;
            evt.Tow_Required__c = resource.Attributes.TowRequired == 'Yes' ? true : false;
            if (resource.Attributes.RoadsideServiceNomStatus != null) 
            {
                evt.Nom_Status__c = resource.Attributes.RoadsideServiceNomStatus.name();
            }
			evt.Expiry_Date__c = JlrDateParser.parseStringAsDate(resource.Attributes.RoadsideServiceExpiryDate);        
            evt.Repeat_Incident__c = resource.Attributes.IncidentIsRepeat;
            evt.Incident_Location__c = resource.Attributes.IncidentLocation;
            evt.Breakdown_Reason__c = resource.Attributes.BreakdownReason;
            evt.Breakdown_Explanation__c = resource.Attributes.BreakdownExplanation;
            evt.Tow_Destination__c = resource.Attributes.TowDestination;
            evt.Location_GPS_Coordinates__c = resource.Attributes.IncidentLocationGpsCoordinates;

            // assign vehicle
            if (vinToAssetMap.containsKey(resource.Attributes.VehicleIdentificationNumber))
            {
                evt.Vehicle__c = vinToAssetMap.get(resource.Attributes.VehicleIdentificationNumber).Id;
            }

            //evt.Comments__c = resource.Attributes.Comments;
            //evt.Incident_Breakdown_Description__c = resource.Attributes.IncidentBreakdownDescription;
            //evt.Incident_Caller_Name__c = resource.Attributes.IncidentCallerName;
            //evt.Incident_Date__c = JlrDateParser.parseStringAsDate(resource.Attributes.IncidentDate);
            //evt.Incident_Id__c = resource.Attributes.IncidentId;
            //evt.Incident_Is_Repeat__c = resource.Attributes.IncidentIsRepeat;
            //evt.Incident_Job_Type__c = resource.Attributes.IncidentJobType;
            //evt.Incident_Location__c = resource.Attributes.IncidentLocation;
            //evt.Incident_Location_Gps_Coordinates__c = resource.Attributes.IncidentLocationGpsCoordinates;
            //evt.Incident_Tow_Destination__c = resource.Attributes.IncidentTowDestination;
            //evt.Incident_Caller_Number__c = resource.Attributes.IncidentCallerNumber;
            //evt.Roadside_Service_Authorisation_Number__c = resource.Attributes.RoadsideServiceAuthorisationNumber;
            //evt.Roadside_Service_Club__c = resource.Attributes.RoadsideServiceClub;
            //evt.Roadside_Service_Expiry_Date__c = JlrDateParser.parseStringAsDate(resource.Attributes.RoadsideServiceExpiryDate);
            //evt.Roadside_Service_Nom_Status__c = resource.Attributes.RoadsideServiceNomStatus.name();
            //evt.Roadside_Service_Plan_Code__c = resource.Attributes.RoadsideServicePlanCode;

            //Database.SaveResult sr = EventBus.publish(evt);
            Database.upsertResult upsertResult = Database.upsert(evt, Roadside_Event__c.Authorisation_Number__c);

            if (upsertResult.IsSuccess())
            {
                System.debug('Successfully published event.');
            }
            else
            {
                for(Database.Error err : upsertResult.getErrors())
                {
                    System.debug('Error returned: ' +
                            err.getStatusCode() + ' - ' +
                            err.getMessage());
                    ErrorDto error = new ErrorDto();
                    error.Code = String.valueOf(err.getStatusCode());
                    error.Detail = err.getMessage();
                    response.Errors.add(error);
                }

            }
        }
        return response;
    }
    public static CreateServiceEventResponseDto create(CreateServiceEventRequestDto request) {
        CreateServiceEventResponseDto response = new CreateServiceEventResponseDto();
        // create a map used to assign vehicles
        List<String> vins = new List<String>();
        for (ServiceEventResourceDto s : request.Data)
        {
            vins.add(s.Attributes.VehicleIdentificationNumber);
        }
        Map<String, Asset> vinToAssetMap = getVinMap(vins);

        for (ServiceEventResourceDto resource : request.Data) {
            ServiceEventAttributesDto attributes = resource.Attributes;
            try {
                // service data
                Service_Event__c serviceEvent = extractServiceEvent(attributes);

                // assign vehicle
                if (vinToAssetMap.containsKey(resource.Attributes.VehicleIdentificationNumber))
                {
                    serviceEvent.Asset__c = vinToAssetMap.get(resource.Attributes.VehicleIdentificationNumber).Id;
                }
                

                //insert service data
                System.debug('Inserting ServiceData : ' + JSON.serialize(serviceEvent));
                Database.UpsertResult insertServiceDataResult = Database.upsert(serviceEvent);
                System.debug('Insert Result : ' + JSON.serialize(insertServiceDataResult));
                if (insertServiceDataResult.isSuccess()) {
                    resource.Id = insertServiceDataResult.getId();
                    response.Data.add(resource);
                } else {
                    response.Errors.add(new ErrorDto(
                            'There was a problem with VIN : ' + attributes.VehicleIdentificationNumber,
                            insertServiceDataResult.getErrors()
                    )
                    );
                }
            } catch (DateParsingException ex) {
                System.debug('Caught: DateParsingException: ' + ex);
                ErrorDto err = new ErrorDto(ex);
                response.Errors.add(err);

                continue;
            } catch (QueryException ex) {
                System.debug('Caught: QueryException: ' + ex);
                ErrorDto err = new ErrorDto(ex);
                response.Errors.add(err);
                continue;
            } catch (Exception ex) {
                System.debug('Caught: Exception: ' + ex);
                ErrorDto err = new ErrorDto(ex);
                response.Errors.add(err);
                continue;
            }
        }
        return response;
    }

    /*
    private static Account extractAccount(ServiceEventAttributesDto attributes) {
        Account acc = new Account();
        acc.Name = attributes.CompanyName;
        acc.Corporate_Account_Indicator__c = attributes.CorporateAccIndicator;
        return acc;
    }
    */

    private static Service_Event__c extractServiceEvent(ServiceEventAttributesDto attributes) {
        Service_Event__c serviceEvent = new Service_Event__c();
        serviceEvent.Database_Reference_ID__c = attributes.DatabaseReferenceId;
        serviceEvent.DMS_ID__c = attributes.VehicleDmsId;
        serviceEvent.Repair_Order_Number__c = attributes.RepairOrderNumber;
        serviceEvent.Job_Booked_Date__c = JlrDateParser.parseStringAsDate(attributes.EventDateJobBooked);
        serviceEvent.Service_Repair_Date__c = JlrDateParser.parseStringAsDate(attributes.EventDateRepaired);
        serviceEvent.Dealer_Code_JLR__c = attributes.EventDealerCodeJlr;
        serviceEvent.Repairing_Retailer_Name__c = attributes.EventRepairingRetailerName;
        serviceEvent.SR_Type__c = attributes.SrType;
        serviceEvent.Description__c = attributes.Description;
        serviceEvent.Mileage__c = Decimal.valueOf(attributes.VehicleMileage);
        serviceEvent.Mileage_Date__c = JlrDateParser.parseStringAsDate(attributes.VehicleMileageDate);
        serviceEvent.Mileage_UOM__c = attributes.VehicleMileageUnitOfMeasure;
        serviceEvent.Price_Invoice__c = Decimal.valueOf(attributes.PriceInvoice);
        serviceEvent.Price_Parts__c = Decimal.valueOf(attributes.PriceParts);
        serviceEvent.Price_Labour__c = Decimal.valueOf(attributes.PriceLabour);
        serviceEvent.Repeat_Repair__c = attributes.IsRepeatRepair;
        serviceEvent.DMS_Invoice_Ref_ID__c = attributes.VehicleDmsInvoiceRefId;
        serviceEvent.Job_Code__c = attributes.JobCode;
        serviceEvent.Registration_Number__c = attributes.VehicleRegistrationNumber;
        serviceEvent.Service_Advisor_Name__c = attributes.ServiceAdvisorName;
        serviceEvent.Work_Order_Contact_Title__c = attributes.WorkOrderContactTitle;
        serviceEvent.Work_Order_Contact_First_Name__c = attributes.WorkOrderContactFirstName;
        serviceEvent.Work_Order_Contact_Surname__c = attributes.WorkOrderContactLastName;
        serviceEvent.Work_Order_Contact_Home_Phone__c = attributes.WorkOrderContactPhoneHome;
        serviceEvent.Work_Order_Contact_Work_Phone__c = attributes.WorkOrderContactPhoneWork;
        serviceEvent.Work_Order_Contact_Mobile_Phone__c = attributes.WorkOrderContactPhoneMobile;
        serviceEvent.Work_Order_Contact_Email_Address__c = attributes.WorkOrderContactEmail;
        serviceEvent.VIN__c = attributes.VehicleIdentificationNumber;
        return serviceEvent;
    }
    /*
    private static Asset extractAsset(ServiceEventAttributesDto attributes, Product2 derivative) {
        Asset ass = new Asset();
        ass.New_or_Used__c = attributes.VehicleType; // todo - check this is the right mapping
        ass.VIN__c = attributes.VehicleIdentificationNumber;
        ass.Registration_Number__c = attributes.VehicleRegistrationNumber;
        ass.MOT_Inspection_Date__c = JlrDateParser.parseStringAsDate(attributes.VehicleRoadworthinessInspectionDate);
        ass.Last_Registration_Date__c = JlrDateParser.parseStringAsDate(attributes.VehicleLatestRegistrationDate);
        ass.Brand__c = derivative.Make__c;
        ass.Model__c = derivative.Model__c;
        ass.Derivative__c = derivative.Id;
        return ass;
    }

    private static Contact extractContact(ServiceEventAttributesDto attributes) {
        Contact con = new Contact();
        con.Title = attributes.ContactTitle;
        con.FirstName = attributes.ContactNameFirst;
        con.LastName = attributes.ContactNameLast;
        con.Email = attributes.ContactEmail;
        con.MobilePhone = attributes.ContactPhoneMobile;
        con.HomePhone = attributes.ContactPhoneHome;
        con.Phone = attributes.ContactPhoneWork;
        con.MailingStreet = attributes.AddressLine1 + ';' + attributes.AddressLine2;
        con.MailingCity = attributes.AddressSuburb;
        con.MailingState = attributes.AddressState;
        con.MailingPostalCode = attributes.AddressPostCode;
        con.MailingCountry = attributes.AddressCountry;

        con.Privacy_Code__c = attributes.PrivacyCode;
        con.Service_advisor_name__c = attributes.ServiceAdvisorName;
        con.Work_Order_contact_Email_Address__c = attributes.WorkOrderContactEmail;
        con.Work_Order_contact_First_Name__c = attributes.WorkOrderContactFirstName;
        con.Work_Order_contact_Home_Phone__c = attributes.WorkOrderContactPhoneHome;
        con.Work_Order_contact_Mobile_Phone__c = attributes.WorkOrderContactPhoneMobile;
        con.Work_Order_contact_Surname__c = attributes.WorkOrderContactLastName;
        con.Work_Order_contact_Title__c = attributes.WorkOrderContactTitle;
        con.Work_Order_contact_Work_Phone__c = attributes.WorkOrderContactPhoneWork;
        return con;
    }
    */

    private static Map<String, Asset> getVinMap(List<String> vins)
    {
        List<Asset> vehicles = [
                SELECT Id, VIN__c
                FROM Asset
                WHERE VIN__c IN :vins];
        Map<String, Asset> vinToAsset = new Map<String, Asset>();
        for (Asset a : vehicles)
        {
            vinToAsset.put(a.VIN__c, a);
        }
        return vinToAsset;
    }
}