/**
 * Created by Ethan Sargent on 16/10/19.
 */

global with sharing class QantasFrequentFlyerTransactionDto
{
    public static final String DESCRIPTION = 'JAGUAR LAND ROVER AUSTRALIA';

    public QantasFrequentFlyerTransactionDto(Loyalty_Points_Transaction__c pointsTransaction, Integer recordNumber)
    {
        System.debug('>> QantasFrequentFlyerTransactionDto(' + JSON.serialize(pointsTransaction) + ')');
        this.ContactNameLast = pointsTransaction.RDA__r.Account__r.LastName;
        this.ContactNameFirstInitial = pointsTransaction.RDA__r.Account__r.FirstName;
        this.Title = pointsTransaction.RDA__r.Account__r.PersonTitle;
        this.QantasFrequentFlyerNumber = pointsTransaction.RDA__r.Account__r.Loyalty_Scheme_Reference__c;
        this.ProductDescription = DESCRIPTION;
        this.TransactionDate = pointsTransaction.CreatedDate.format('yyyy-MM-dd');
        this.PaymentAmountInCents = 0;
        this.BasePointsEarned = pointsTransaction.Base_Points__c != null ? Integer.valueOf(pointsTransaction.Base_Points__c) : null;
        this.BonusPointsEarned = pointsTransaction.Bonus_Points__c != null ? Integer.valueOf(pointsTransaction.Bonus_Points__c) : null;
        this.TotalPointsEarned = pointsTransaction.Total_Points__c != null ? Integer.valueOf(pointsTransaction.Total_Points__c) : null;
        this.TransactionId = pointsTransaction.Id;
        this.RecordNumber = recordNumber;
        String ref = pointsTransaction.Id;
        this.PartnerReference = ref.substring(ref.length() - Constants.LOYALTY_PARTNER_REF_LENGTH, ref.length());
        System.debug('<< QantasFrequentFlyerTransactionDto()');
    }

    public String ContactNameLast {get; set;}

    public String ContactNameFirstInitial {get; set;}

    public String Title {get; set;}

    public String QantasFrequentFlyerNumber {get; set;}

    public String TransactionDate {get; set;}

    public String ProductDescription {get; set;}

    public String PartnerReference {get; set;}

    public String TransactionId {get; set;}

    public Integer PaymentAmountInCents {get; set;}

    public Integer BasePointsEarned {get; set;}

    public Integer BonusPointsEarned {get; set;}

    public Integer TotalPointsEarned {get; set;}

    public Integer RecordNumber {get; set;}
}