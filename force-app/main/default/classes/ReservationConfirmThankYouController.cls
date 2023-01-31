/*** 
Requirement : ReservationConfirmThankYou Page 
Author : 
Test class: ReservationConfirmThankYouTest
Description: Controller class with methods to call different sections from Thank you page 

***/
public without sharing class ReservationConfirmThankYouController {
public VehicleWrapper wrapper { get;set; }
public Boolean IsJaguar { get; set; }
public Boolean IsAPO { get; set; }
public CreateSavedVehicleDto dto {get; set;}
public String mainSiteLink { get; set; }
public String market { get; set; }
public string language { get; set; }
public string brand { get; set; }
public string id { get; set; }
public String CurrencySym{ get; set; }
public ReservationConfirmThankYouController()
{
        id = ApexPages.currentPage().getParameters().get('vid');
        brand = ApexPages.currentPage().getParameters().get('brand');
        language = ApexPages.currentPage().getParameters().get('lang');
        market = JUDAANUtil.getSimpleMarket();
        System.debug('id :: '+id+'brand :: '+brand+'language :: '+language);
        mainSiteLink = JUDAANUtil.getApoDxLink();
        IsAPO = JUDAANUtil.getAPOorNot();
        System.debug('IsAPO :: '+IsAPO);
        CurrencySym= JUDAANUtil.getCurrencySymbol(); 
       
}

public PageReference init()
        {
          String MyBrand = ApexPages.currentPage().getParameters().get('brand'); 
           IsJaguar = MyBrand == 'jaguar' ? true : false;
          String assetId = ApexPages.currentPage().getParameters().get('vid'); 
          List<Asset> assetList = AssetDao.getAssetById(id);
          System.debug('assetList :: '+assetList);
          this.wrapper = new VehicleWrapper(assetList.get(0));
          return JUDAANUtil.brandCheck();
        }
public PageReference getCustomerAccount()
{
      PageReference customerPage;
      if(!IsAPO) 
      customerPage = Page.CustomerAccountPage_New;
      else
       customerPage = Page.CustomerAccountPage;   
      customerPage.getParameters().put('market', this.market);
      customerPage.getParameters().put('brand', this.brand);
      customerPage.getParameters().put('lang', this.language);
      customerPage.getParameters().put('id', this.id);
      customerPage.setRedirect(true);
      return  customerPage;
  
}
public PageReference getSearchPage()
{
       PageReference searchPage;
        if(!IsAPO){
            searchPage= Page.VehicleSearch;
        }else{
            searchPage= Page.APOVehicleSearch;
        }
        searchPage.getParameters().put('brand',this.brand);
        searchPage.getParameters().put('lang', this.language);
        searchPage.getParameters().put('market', this.market);
        /*searchPage.getParameters().put('id', this.id);
        searchPage.getParameters().put('svid', ApexPages.currentPage().getParameters().get('svid'));*/
        searchPage.setRedirect(true);
        return searchPage;
}

public class VehicleWrapper{
 public String model { get; set; }
 public String bodystyle { get; set; }
 public String specification { get; set; }
 public String registration { get; set; } 
 public Decimal price { get; set; }
 public Id vid {get;set;}
 public String extColor { get; set; }
 public String orderNo { get; set; }
 public String intColor { get; set; }
 public String fuelType { get; set; }
 public String transmission { get; set; }
 public String engine { get; set; }
 public String PowerOutput { get; set; }
 public String drive { get; set; }
 public String image {get;set;}
 public List<String> images { get; set; }
 public List<String> Options {get;set;}
 public String option { get; set; }
 public String city { get; set; }
 public List<String> optionList {get;set;}
   public VehicleWrapper(Asset asset)
   {
            this.vid = asset.Id;
            this.model = asset.Product2.Model_Alternative__c;
            this.bodystyle = asset.Product2.APO_Body_Style_Alternative__c;
            this.specification = asset.Product2.Specification_Pack_Alternative__c;
           if(asset.Product2.Model_Year_Alternative__c != null &&  JUDAANUtil.getAPOorNot() == true)
			this.registration = Label.ManufactureYear + asset.Product2.Model_Year_Alternative__c.right(2);
            else
            {
                if(asset.Product2.Registration_Year_Alternative__c != null && JUDAANUtil.getAPOorNot() == false)
                this.registration= Label.ManufactureYear + asset.Product2.Registration_Year_Alternative__c.right(2);
            }  
       		this.city = asset.Account.billingCity;
            this.extColor = asset.Exterior_Colour__c;
            this.intColor = asset.Interior_Color__c;
            this.price = asset.Local_price__c;
            this.fuelType = asset.Product2.Fuel_Type_Alternative__c;
            this.transmission = asset.Product2.Transmission_Alternative__c;
            this.engine= asset.Product2.Engine_Name_Alternative__c ;
            this.PowerOutput= asset.Product2.Power_Output_Alternative__c;
            this.drive = asset.Product2.Wheel_Driven_Alternative__c;
            this.images = new List<String>();
            this.orderNo = asset.Order_Number__c;
            if(asset.pictures__c != null)
            {
               this.images = asset.pictures__c.split(',');
               if(!images.isEmpty()){
                    this.image = images[0];
                }
            }
       		else
            {
                this.image = asset.Vehicle_Image_L__c;
            }
       
            this.option = asset.Options__c; 
            this.Options = StringUtil.splitMultiplePickList( StringUtil.getValue( asset.Options__c ) );
            
            if(Option != null){
                    this.optionList = Option.split(';');
            }else{
                this.optionList = new List<String>();
            }
   } 
}
}