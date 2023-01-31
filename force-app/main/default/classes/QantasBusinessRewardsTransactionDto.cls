/**
 * Created by Ethan Sargent on 16/10/19.
 */

global with sharing class QantasBusinessRewardsTransactionDto
{
    public static final String QBR_DESCRIPTION = 'JAGUAR LAND ROVER AUSTRALIA';

    public QantasBusinessRewardsTransactionDto(Loyalty_Points_Transaction__c pointsTransaction, Integer recordNumber)
    {
        System.debug('>> QantasBusinessRewardsTransactionDto(' + JSON.serialize(pointsTransaction) + ')');
        this.Abn = pointsTransaction.RDA__r.Account__r.ABN__c;
        this.BusinessName = pointsTransaction.RDA__r.Account__r.Name;
        this.AccountId = pointsTransaction.RDA__r.Account__r.Id;
        this.Description = QBR_DESCRIPTION;
        this.TransactionStartDate = pointsTransaction.CreatedDate.format('yyyy-MM-dd');
        this.TransactionEndDate = pointsTransaction.CreatedDate.format('yyyy-MM-dd');
        this.OpportunityGrossAmount = 0;
        this.OpportunityNetAmount = 0;
        this.BasePoints = pointsTransaction.Base_Points__c != null ? Integer.valueOf(pointsTransaction.Base_Points__c) : null;
        this.BonusPoints = pointsTransaction.Bonus_Points__c != null ? Integer.valueOf(pointsTransaction.Bonus_Points__c) : null;
        this.BonusPointsBasis = null;
        this.TotalPoints = pointsTransaction.Total_Points__c != null ? Integer.valueOf(pointsTransaction.Total_Points__c) : null;
        this.TransactionId = pointsTransaction.Id;
        this.RecordNumber = recordNumber;
        String ref = pointsTransaction.Id;
        this.PartnerReference = ref.substring(ref.length() - Constants.LOYALTY_PARTNER_REF_LENGTH, ref.length());

        this.BaseDiscount = 0;
        this.BonusDiscount = 0;
        this.BaseRebate = 0;
        this.BonusRebate = 0;

        // Individual Info
        if (pointsTransaction.RDA__r.Contact__r != null)
        {
            this.NameFirst = pointsTransaction.RDA__r.Contact__r.FirstName;
            this.NameLast = pointsTransaction.RDA__r.Contact__r.LastName;
            this.PhoneMobile = pointsTransaction.RDA__r.Contact__r.MobilePhone;
            this.PhoneHome = pointsTransaction.RDA__r.Contact__r.HomePhone;
            this.PhoneWork = pointsTransaction.RDA__r.Contact__r.Phone;
            this.Email = pointsTransaction.RDA__r.Contact__r.Email;
        }

        System.debug('<< QantasBusinessRewardsTransactionDto()');
    }

    public String ABN {get; set;}

    public String BusinessName {get; set;}

    public String TransactionId {get; set;}

    public String AccountId {get; set;}

    public String Description {get; set;}

    public String BannerOrBrand {get; set;}

    public String PartnerReference {get; set;}

    public String Location {get; set;}

    public String TransactionStartDate {get; set;}

    public String TransactionEndDate {get; set;}

    public Integer OpportunityGrossAmount {get; set;}

    public Integer OpportunityNetAmount {get; set;}

    public Integer BaseDiscount {get; set;}

    public Integer BonusDiscount {get; set;}

    public Integer BaseRebate {get; set;}

    public Integer BonusRebate {get; set;}

    public Integer BasePoints {get; set;}

    public Integer BonusPoints {get; set;}

    public String BonusPointsBasis {get; set;}

    public Integer TotalPoints {get; set;}

    public String Email {get; set;}

    public Integer RecordNumber {get; set;}

    public String NameFirst {get; set;}

    public String NameLast {get; set;}

    public String PhoneMobile {get; set;}

    public String PhoneWork {get; set;}

    public String PhoneHome {get; set;}
}