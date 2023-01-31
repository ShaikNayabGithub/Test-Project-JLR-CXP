/**
 * Created by Ethan Sargent on 16/10/19.
 */

public with sharing class QantasController {

    public static final String QANTAS_LOYALTY_SCHEME = 'Qantas';

    public static QantasFrequentFlyerResponseDto FetchQantasFrequentFlyerTransactions(GetQantasFrequentFlyerRequestDto request) {

        System.debug('>> FetchQantasFrequentFlyerTransactions(startDatetime = ' + JSON.serialize(request) + ')');
        List<Loyalty_Points_Transaction__c> pointTransactions = [
                SELECT
                        Id,
                        CreatedDate,
                        Transaction_Date__c,
                        Base_Points__c,
                        Bonus_Points__c,
                        Total_Points__c,
                        RDA__r.Account__r.FirstName,
                        RDA__r.Account__r.LastName,
                        RDA__r.Account__r.PersonTitle,
                        RDA__r.Asset__r.Product2.Name,
                        RDA__r.Opportunity__r.Amount,
                        RDA__r.Account__r.Loyalty_Scheme_Reference__c
                FROM Loyalty_Points_Transaction__c
                WHERE (CreatedDate >= :request.StartDatetime
                AND Loyalty_Points__r.Loyalty_Scheme__r.Name = :QANTAS_LOYALTY_SCHEME
                AND Transaction_Delivery_Status__c = :Constants.LOYALTY_TRANSACTION_WAITING
                AND Loyalty_Points__r.Loyalty_type__c = :Constants.LOYALTY_TYPE_PERSON_ACCOUNT)
        ];
        System.debug(pointTransactions.size() + ' Records Found');
        QantasFrequentFlyerResponseDto response = new QantasFrequentFlyerResponseDto(pointTransactions);
        System.debug('<< FetchQantasFrequentFlyerTransactions()');
        return response;
    }

    public static QantasBusinessRewardsResponseDto FetchQantasBusinessRewardsTransactions(GetQantasBusinessRewardsRequestDto request) {
        System.debug('>> FetchQantasBusinessRewardsTransactions(startDatetime = ' + JSON.serialize(request) + ')');
        List<Loyalty_Points_Transaction__c> pointTransactions = [
                SELECT
                        Id,
                        CreatedDate,
                        RDA__r.Account__r.ABN__c,
                        RDA__r.Account__r.Name,
                        RDA__r.Account__r.Id,
                        RDA__r.Product_Name__c,
                        Transaction_Date__c,
                        RDA__r.Opportunity__r.Amount,
                        Base_Points__c,
                        Bonus_Points__c,
                        Loyalty_Scheme_Reference__c,
                        Total_Points__c,
                        RDA__r.Account__r.Retailer_Email__c,
                        RDA__r.Contact__r.FirstName,
                        RDA__r.Contact__r.LastName,
                        RDA__r.Contact__r.MobilePhone,
                        RDA__r.Contact__r.HomePhone,
                        RDA__r.Contact__r.Phone,
                        RDA__r.Contact__r.Email
                FROM Loyalty_Points_Transaction__c
                WHERE (CreatedDate >= :request.startDatetime
                AND Loyalty_Points__r.Loyalty_Scheme__r.Name = :QANTAS_LOYALTY_SCHEME
                AND Transaction_Delivery_Status__c = :Constants.LOYALTY_TRANSACTION_WAITING
                AND Loyalty_Points__r.Loyalty_type__c = :Constants.LOYALTY_TYPE_CORPORATE_ACCOUNT)
        ];
        System.debug(pointTransactions.size() + ' Records Found');
        QantasBusinessRewardsResponseDto response = new QantasBusinessRewardsResponseDto(pointTransactions);
        System.debug('<< FetchQantasBusinessRewardsTransactions()');
        return response;
    }

    public static CreateLoyaltyVerificationResponseDto createLoyaltyProgramVerification(CreateLoyaltyVerificationRequestDto request) {
        System.debug('>> createLoyaltyProgramVerification(request: ' + JSON.serialize(request));
        CreateLoyaltyVerificationResponseDto response = new CreateLoyaltyVerificationResponseDto();
        for (LoyaltyVerificationResourceDto resource : request.Data) {
            response.Data.add(resource);
            //process each verification result;

            if (resource.Type == Constants.LOYALTY_VERIFICATION_TYPE_QFF) {
                //Create a BusinessVerification Platform Event

                Loyalty_Verification_Event__e lve = buildLoyaltyVerificationEvent(resource);

                Database.SaveResult sr = EventBus.publish(lve);

                if (!sr.IsSuccess()) {

                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                err.getStatusCode() + ' - ' +
                                err.getMessage());
                        ErrorDto error = new ErrorDto();
                        error.Code = String.valueOf(err.getStatusCode());
                        error.Detail = err.getMessage();
                        response.addError(error);
                    }
                } else {
                    resource.Id = sr.getId();
                }
            } else if (resource.Type == Constants.LOYALTY_VERIFICATION_TYPE_QBR) {
                //Create a LoyaltyVerification Platform Event

                try {
                    Business_Verification_Event__e bve = buildBusinessVerificationResult(resource);

                    Database.SaveResult sr = EventBus.publish(bve);

                    if (!sr.IsSuccess()) {

                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +
                                    err.getStatusCode() + ' - ' +
                                    err.getMessage());
                            ErrorDto error = new ErrorDto();
                            error.Code = String.valueOf(err.getStatusCode());
                            error.Detail = err.getMessage();
                            response.Errors.add(error);
                        }
                    } else {
                        resource.Id = sr.getId();
                    }

                } catch (DateParsingException ex) {
                    ErrorDto error = new ErrorDto();
                    error.Code = String.valueOf(ex.getLineNumber());
                    error.Detail = ex.DateString + 'is not a valid date';
                    response.addError(error);
                }
            } else {
                throw new InvalidParameterValueException('Resource.Type', resource.Type);
            }


        }
        System.debug('<< createLoyaltyProgramVerification() response: ' + JSON.serialize(response));
        return response;
    }

    private static Business_Verification_Event__e buildBusinessVerificationResult(LoyaltyVerificationResourceDto resource) {
        Business_Verification_Event__e bve = new Business_Verification_Event__e();
        bve.Reason_For_Rejection__c = resource.Attributes.ReasonForRejection;
        //Result
        if (resource.Attributes.AcceptReject == 'A') {
            bve.Is_Accepted__c = true;
        } else {
            bve.Is_Accepted__c = false;
        }
        bve.Points_Earned_Base__c = resource.Attributes.PointsEarnedBase;
        bve.Amount_Gross__c = resource.Attributes.AmountGross;
        bve.Amount_Net__c = resource.Attributes.AmountNet;
        bve.Banner_Brand__c = resource.Attributes.BannerBrand;
        bve.Business_Account_Number__c = resource.Attributes.BusinessAccountNumber;
        bve.Business_Name__c = resource.Attributes.BusinessName;
        bve.Business_Taxation_Number__c = resource.Attributes.BusinessTaxationNumber;
        bve.Card_Sequence_Number__c = resource.Attributes.CardSequenceNumber;
        bve.Discount_Base__c = resource.Attributes.DiscountBase;
        bve.Discount_Bonus__c = resource.Attributes.DiscountBonus;
        bve.Location__c = resource.Attributes.Location;
        bve.Points_Earned_Bonus__c = resource.Attributes.PointsEarnedBonus;
        bve.Points_Earned_Base__c = resource.Attributes.PointsEarnedBase;
        bve.Points_Earned_Bonus_Basis__c = resource.Attributes.PointsEarnedBonusBasis;
        bve.Points_Earned_Total__c = resource.Attributes.PointsEarnedTotal;
        bve.Rebate_Base__c = resource.Attributes.RebateBase;
        bve.Rebate_Bonus__c = resource.Attributes.RebateBonus;
        try {
            bve.Transaction_Date_End__c = JlrDateParser.parseStringAsDate(resource.Attributes.TransactionDateEnd);
        } catch (DateParsingException ex) {
            ex.setMessage(ex.getMessage() + ' - TransactionDateEnd');
            throw ex;
        }
        try {
            bve.Transaction_Date_Start__c = JlrDateParser.parseStringAsDate(resource.Attributes.TransactionDateStart);
        } catch (DateParsingException ex) {
            ex.setMessage(ex.getMessage() + ' - TransactionDateStart');
            throw ex;
        }
        bve.Transaction_Id__c = resource.Attributes.TransactionId;
        return bve;
    }

    private static Loyalty_Verification_Event__e buildLoyaltyVerificationEvent(LoyaltyVerificationResourceDto resource) {
        Loyalty_Verification_Event__e loyaltyVerificationEvent = new Loyalty_Verification_Event__e();
        //Info
        loyaltyVerificationEvent.Product_Description__c = resource.Attributes.ProductDescription;
        loyaltyVerificationEvent.Record_Number__c = resource.Attributes.RecordNumber;
        loyaltyVerificationEvent.Filler__c = resource.Attributes.Filler;
        loyaltyVerificationEvent.Partner_Reference__c = resource.Attributes.PartnerReference;
        loyaltyVerificationEvent.Payment_Amount_In_Cents__c = resource.Attributes.PaymentAmountInCents;
        try {
            loyaltyVerificationEvent.Transaction_Date__c = JlrDateParser.parseStringAsDate(resource.Attributes.TransactionDate);
        } catch (DateParsingException ex) {
            ex.setMessage(ex.getMessage() + ' - TransactionDate');
            throw ex;
        }

        //Contact
        loyaltyVerificationEvent.Contact_Name_Title__c = resource.Attributes.ContactNameTitle;
        loyaltyVerificationEvent.Contact_Name_First_Initial__c = resource.Attributes.ContactNameFirstInitial;
        loyaltyVerificationEvent.Contact_Name_Last__c = resource.Attributes.ContactNameLast;
        loyaltyVerificationEvent.Contact_Loyalty_Number__c = resource.Attributes.ContactLoyaltyNumber;

        //Result
        if (resource.Attributes.AcceptReject == 'A') {
            loyaltyVerificationEvent.Is_Accepted__c = true;
        } else {
            loyaltyVerificationEvent.Is_Accepted__c = false;
        }

        loyaltyVerificationEvent.Reason_For_Rejection__c = resource.Attributes.ReasonForRejection;

        //Points
        loyaltyVerificationEvent.Points_Earned_Base__c = resource.Attributes.PointsEarnedBase;
        loyaltyVerificationEvent.Points_Earned_Bonus__c = resource.Attributes.PointsEarnedBonus;
        loyaltyVerificationEvent.Points_Earned_Total__c = resource.Attributes.PointsEarnedTotal;
        return loyaltyVerificationEvent;
    }
}