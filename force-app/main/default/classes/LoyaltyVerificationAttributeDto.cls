/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 24/10/2019.
 */

global with sharing class LoyaltyVerificationAttributeDto extends AttributesDto {

    //Info
    public String PartnerReference {get; set;}
    public String Filler {get; set;}
    public String ProductDescription {get; set;}
    public integer RecordNumber {get; set;}
    public Integer CardSequenceNumber {get; set;}

    //Contact
    public String ContactNameTitle {get; set;}
    public String ContactNameLast {get; set;}
    public String ContactNameFirstInitial {get; set;}
    public String ContactLoyaltyNumber {get; set;}

    //Result
    public Long PaymentAmountInCents {get; set;}
    public String AcceptReject {get; set;}
    public String ReasonForRejection {get; set;}


    //Points
    public Long PointsEarnedBase {get; set;}
    public Long PointsEarnedBonus {get; set;}
    public Long PointsEarnedTotal {get; set;}
    public String PointsEarnedBonusBasis {get; set;}


    //business
    public String BusinessName {get; set;}
    public String BusinessAccountNumber {get; set;}
    public String BusinessTaxationNumber {get; set;}

    //transaction
    public String TransactionId {get; set;}
    public String TransactionDate {get; set;}
    public String TransactionDateStart {get; set;}
    public String TransactionDateEnd {get; set;}

    public String BannerBrand {get; set;}
    public String Location {get; set;}

    //Amounts
    public Decimal DiscountBase {get; set;}
    public Decimal DiscountBonus {get; set;}
    public Decimal RebateBase {get; set;}
    public Decimal RebateBonus {get; set;}
    public Decimal AmountNet {get; set;}
    public Decimal AmountGross {get; set;}

}