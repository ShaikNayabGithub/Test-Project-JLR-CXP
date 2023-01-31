/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

public with sharing class GetAssetsRequestDto {


    public static final String SALE_TYPES_NEW = 'NEW';
    public static final String SALE_TYPES_DEMONSTRATOR = 'DEMONSTRATOR';
    public static final String SALE_TYPES_DEMO = 'DEMO';
    public static final String SALE_TYPES_PRE_OWNED = 'PRE_OWNED';
    public static final String SALE_TYPES_PRE_OWNED_HYPHENATED = 'PRE-OWNED';
    public static final String SALE_TYPES_APPROVED_PRE_OWNED = 'APPROVED_PRE_OWNED';
    public static final String SALE_TYPES_APO = 'APO';

    @AuraEnabled
    public String DerivativeProduct2Id { get; set; }

    @AuraEnabled
    public String SearchKey {get; set;}

    @AuraEnabled
    public String UserId {get; set;}

    //todo - need sale type
    //public Set<String> Statuses {get; set;}

    private String pSaleType;

    @AuraEnabled
    public String SaleType {
        set {
            if (value == null){
                throw new NullRequiredFieldException('SaleType cannot be null');
            }
            if (value.equalsIgnoreCase(SALE_TYPES_NEW)){
                pSaleType = SALE_TYPES_NEW;
            }
            else if (value.equalsIgnoreCase(SALE_TYPES_DEMONSTRATOR) || value.equalsIgnoreCase(SALE_TYPES_DEMO)){
                pSaleType = SALE_TYPES_DEMONSTRATOR;
            }
            else if (value.equalsIgnoreCase(SALE_TYPES_PRE_OWNED) || value.equalsIgnoreCase(SALE_TYPES_PRE_OWNED_HYPHENATED)){
                pSaleType = SALE_TYPES_PRE_OWNED;
            }
            else if (value.equalsIgnoreCase(SALE_TYPES_APPROVED_PRE_OWNED) || value.equalsIgnoreCase(SALE_TYPES_APO)){
                pSaleType = SALE_TYPES_APPROVED_PRE_OWNED;
            }
            else{
                throw new InvalidParameterValueException('SaleType', value + ' is not a valid SaleType');
            }
        }
        get {
            return pSaleType;
        }
    }
}