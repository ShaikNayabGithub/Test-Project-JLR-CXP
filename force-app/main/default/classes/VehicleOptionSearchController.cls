public with sharing class VehicleOptionSearchController {

  @AuraEnabled(cacheable=true)
  public static Boolean showVehicleOptionsSearch(){
    return FeatureManagement.checkPermission('KR_Retailer_Admin');
  }

  @AuraEnabled(cacheable=true)
  public static List<AggregateResult> getProductMaster() {
    try {
      List<AggregateResult> productList = [
        SELECT
          Make__r.Name,
          Model__r.Model_Alternative__c,
          ProductCode,
          Alternative_Name__c
        FROM Product2
        WHERE KR_Model_Year__c != NULL
        AND Alternative_Name__c != NULL
        GROUP BY
          Make__r.Name,
          Model__r.Model_Alternative__c,
          ProductCode,
          Alternative_Name__c
      ];
      return productList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage(
        
      ));
    }
  }

  @AuraEnabled
  public static List<OpportunityLineItem> getOpptyLineItemsByOpptyId(
    Id recordId
  ) {
    try {
      List<OpportunityLineItem> opptyLineItemList = [
        SELECT id, Product2.ProductCode, Product2.RecordType.DeveloperName
        FROM OpportunityLineItem
        WHERE OpportunityId = :recordId
      ];

      return opptyLineItemList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public static Map<Id, Asset> getAssetMapByOptionCodes(
    String code5000,
    Set<String> optionCodesSet
  ) {
    try {
      Map<Id, Asset> assetMap = new Map<Id, Asset>(
        [
          SELECT
            id,
            name,
            status,
            VIN__c,
            Vista_Status__c,
            Common_Sale_Type__c,
            Account.NameLocal,
            Order_Number__c,
            (
              SELECT id
              FROM childassets
              WHERE product2.productcode IN :optionCodesSet
            )
          FROM asset
          WHERE
            Status = 'For Sale'
            AND RecordType.DeveloperName = 'Vehicle'
            AND Account.RecordType.DeveloperName = 'Retailer'
            AND Account.Record_Sub_Type__c = 'Dual Brand'
            AND Account.Country_ISO_Code__c = 'KR'
            AND Arrival_Date__c != NULL
            AND Product2.ProductCode = :code5000
            AND Id NOT IN (
              SELECT Asset__c
              FROM OpportunityLineItem
              WHERE
                Has_Asset__c = TRUE
                AND Asset__r.RecordType.DeveloperName = 'Vehicle'
            )
        ]
      );

      return assetMap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  // Map<Option Code, Option Price>
  @AuraEnabled(cacheable=true)
  public static Map<String, ProductWrapper> getOptionPriceBy5000Code(String code5000, Boolean isProductMasterLoaded) {
    try {
      List<Product_Option_Mapping__c> optionMappingList = [
        SELECT id, Option__r.ProductCode, Option_Derivative_Price_Override__c, Option__r.Name
        FROM Product_Option_Mapping__c
        WHERE
          Product__r.ProductCode = :code5000
          AND Option_Derivative_Price_Override__c != NULL
          ORDER BY Option_Derivative_Price_Override__c DESC
      ];

      PricebookEntry derivativeProduct = [
        SELECT Id, Name, Pricebook2.Name, UnitPrice, Product2.Alternative_Name__c
        FROM PricebookEntry
        WHERE
          Product2.ProductCode = :code5000
          AND Pricebook2.Name = 'Korea, Republic of'
          LIMIT 1
      ];
      ProductWrapper derivativeProductWrap = new ProductWrapper();
      derivativeProductWrap.price = derivativeProduct.UnitPrice;
      derivativeProductWrap.productName = derivativeProduct.Product2.Alternative_Name__c;
      Map<String, ProductWrapper> code2ProductMap = new Map<String, ProductWrapper>{
        code5000 => derivativeProductWrap
      };

      for (Product_Option_Mapping__c tmpOptionPriceMap : optionMappingList) {
        ProductWrapper prodWrapper = new ProductWrapper();
        prodWrapper.productName = tmpOptionPriceMap.Option__r.Name;
        prodWrapper.price = tmpOptionPriceMap.Option_Derivative_Price_Override__c;
        
        code2ProductMap.put(
          tmpOptionPriceMap.Option__r.ProductCode, prodWrapper
        );
      }
      return code2ProductMap;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static List<AssetWrapper> generateDatatableList(
    String code5000,
    List<String> optionCodeList
  ) {
    try {

        List<AssetWrapper> assetWrapList = new List<AssetWrapper>();
      Set<String> optionCodeSet = new Set<String>(optionCodeList);
      Map<Id, Asset> assetMap = getAssetMapByOptionCodes(
        code5000,
        optionCodeSet
      );

      for (Id tmpAssetId : assetMap.keySet()) {
        if (
          assetMap.get(tmpAssetId).childassets.size() != optionCodeSet.size()
        ) {
          assetMap.remove(tmpAssetId);
        }
      }

      Map<Id, List<Decimal>> asset2PriceListMap = new Map<Id, List<Decimal>>();
      Map<Id, List<String>> asset2CodeListMap = new Map<Id, List<String>>();

      for (Asset tmpAsset : [
        SELECT ParentId, Product2.ProductCode, Parent.ProductCode
        FROM Asset
        WHERE
          RecordType.DeveloperName = 'Vehicle_Option'
          AND ParentId IN :assetMap.keySet()
      ]) {
        String optionCode = tmpAsset.Product2.ProductCode;
        Id parentAssetId = tmpAsset.ParentId;

        if (asset2CodeListMap.containsKey(parentAssetId)) {
          asset2CodeListMap.get(parentAssetId).add(optionCode);
        } else {
          asset2CodeListMap.put(parentAssetId, new List<String>{ code5000, optionCode });
        }
      }


      for (Id tmpAssetId : assetMap.keySet()) {
        AssetWrapper assetWrapper = new AssetWrapper();
        assetWrapper.assetId = tmpAssetId;
        assetWrapper.vin = assetMap.get(tmpAssetId)?.VIN__c;
        assetWrapper.retailerName = assetMap.get(tmpAssetId).Account.NameLocal;
        assetWrapper.code5000 = code5000;
        assetWrapper.saleType = assetMap.get(tmpAssetId)?.Common_Sale_Type__c;
        assetWrapper.orderNumber = assetMap.get(tmpAssetId)?.Order_Number__c;
        assetWrapper.optionList = asset2CodeListMap.get(tmpAssetId);
        assetWrapList.add(assetWrapper);

      }


      return assetWrapList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  public class AssetWrapper {
    @AuraEnabled
    public String assetId { get; set; }
    @AuraEnabled
    public String vin { get; set; }
    @AuraEnabled
    public String code5000 { get; set; }
    @AuraEnabled
    public String saleType { get; set; }
    @AuraEnabled
    public String orderNumber { get; set; }
    @AuraEnabled
    public String retailerName { get; set; }
    @AuraEnabled
    public List<String> optionList { get; set; }
  }

  public class ProductWrapper {
    @AuraEnabled
    public String productName { get; set; }
    @AuraEnabled
    public Decimal price { get; set; }

  }

}