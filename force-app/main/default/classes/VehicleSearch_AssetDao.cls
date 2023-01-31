public without sharing class VehicleSearch_AssetDao {

    String brandName;
    String market;
    private Integer resultCount;
    String strState;

    public final String SECTION_MODEL = 'Model';
    public final String SECTION_RECOMMEND = 'Recommend';
    public final String SECTION_BODYSTYLE = 'BodyStyle';
    public final String SECTION_ENGINE = 'Engine';
    public final String SECTION_EXTERIORGROUPCOLOUR = 'ExteriorGroupColour';
    public final String SECTION_EXTERIORDETAILCOLOUR = 'ExteriorDetailColour';
    public final String SECTION_INTERIORCOLOUR = 'InteriorColour';
    public final String SECTION_SPECIFICATION = 'Specification';
    public final String SECTION_OPTION = 'Option';
    public final String SECTION_VEHICLE = 'Vehicle';
    
     public final String RECOMMEND_RECORDTYPE =Label.Recommended_Choice;
    public final String PROMOTIONAL_BANNER_RECORDTYPE =Label.Promotional_Banner;
    
    public VehicleSearch_AssetDao( String brandName ) {
        this.brandName = brandName;
        this.resultCount = 0;
    }
    
    public VehicleSearch_AssetDao( String brandName, String market)
    {
        this.brandName = brandName;
        this.market = market;
        this.resultCount = 0;
        strState = ApexPages.currentPage().getParameters().get('statename');
        System.debug( '------------- strState'+strState);
        system.debug('$$$$market in the constructor:' + this.market + '/' + market);
    }
    
    public Integer getCount() {
        return( this.resultCount );
    }
    
    public List<Product2> selectProducts() {
        System.debug( '------------- selectModels' );
        String brandName = this.brandName;
        String market = this.market;
        if(strState  == 'None') strState = null;
        
        List<Product2> products = new List<Product2>();
        for( Product2 product : [Select Id , Model_Alternative__c ,Model__r.Model_Alternative__c, Vehicle_Image_L__c , Name_plate_display_order__c , BodyStyle_Alternative__c,Monthly_Price_From__c,Previous_Monthly_Price_From__c
                                 , Engine_Capacity_Alternative__c , Fuel_Type_Alternative__c , Transmission_Alternative__c , Wheel_Driven_Alternative__c
                                 , Specification_Pack_Alternative__c , Power_Output_Alternative__c
                                 , KMILink__c
                                 , (Select Id , pictures__c,New_Display__c,APO_Display__c,Monthly_Price__c,Exterior_Colour__c , Interior_Color__c ,product2.Monthly_Price_From__c,product2.Previous_Monthly_Price_From__c, Options__c,Previous_Price__c
                                        , Product2.Model_Alternative__c , Product2.Name_plate_display_order__c , Product2.BodyStyle_Alternative__c
                                        , Product2.Engine_Capacity_Alternative__c , Product2.Fuel_Type_Alternative__c , Product2.Transmission_Alternative__c , Product2.Wheel_Driven_Alternative__c
                                        , Product2.Specification_Pack_Alternative__c , Product2.Registration_Year_Alternative__c , Vehicle_Image_L__c , Vehicle_Image_M__c , Model__c
                                        , Product2.Power_Output_Alternative__c ,vin__c,account.name,Model__r.Model_Alternative__c,account.City_Name_Local__c ,account.billingcity, account.billingstate,Local_price__c,Order_Number__c
                                    From assets 
                                    Where Approved_On_Udaan__c = true and New_Display__c = true and APO__c = false and Account.Country_ISO_Code__c= :market And Model__r.OSA_Country_ISO_Code__c includes (:market) and Account.Regional_State_Code__c =: strState )
                                 From Product2
                                 Where Model_Alternative__c != null
                                 And Make__r.Name = :brandName 
                                 And New_Vehicle__c = true 
                                 And Model__r.OSA_Country_ISO_Code__c includes (:market)
                                
                                 Order by Model_Alternative__c
                                ]) {
            products.add( product );
        }
        return( products);
    }
    
    
    public List<Asset> selectData( VehicleSearchInputParameters parameters , String section ) {
        System.debug( '------------- section = ' + section );

        String brandName = this.brandName;
        String market = this.market;
        
        strState = ApexPages.currentPage().getParameters().get('statename');

        String soql = 'Select id, Monthly_Price__c,New_Display__c,APO__c, APO_Display__c,ToLabel( Exterior_Colour_Group__c ) , ToLabel( Exterior_Colour__c ) , Interior_Color_Image__c, Search_Key__c , Search_Key_Text__c, Name '
                    + ' ,Master_Colour__c,Model__c,Body_Style_Image_M__c , ToLabel( Interior_Color__c ) '
                    + ' , Asset_Specification_Pack__c , Asset_Detail_Specification_Pack__c '
                    + ' , Exterior_Detail_Color_Image__c , Specification_Image_1__c , Specification_Image_2__c , Specification_Image_3__c '
                    + ' , Option_Image_Root__c , ToLabel( Options__c ) , Interior_colour_code__c , Colour__c, Exterior_Colour_Code__c '
                    + ' ,Vehicle_Image_L__c ,pictures__c, Vehicle_Image_M__c , Model_Year__c , Fuel_TypeValue__c , TransmissionValue__c , OptionsValue__c , Exterior_Colour_GroupValue__c '
                    + ' , ToLabel( Product2.BodyStyle_Alternative__c ) ,  Product2.Model__r.Model_Alternative__c, Product2.Engine_Capacity_Alternative__c , product2.Monthly_Price_From__c,product2.Previous_Monthly_Price_From__c,ToLabel( Product2.Fuel_Type_Alternative__c ) , Product2.Model_Alternative__c '
                    + ' , Product2.Registration_Year_Alternative__c , Product2.Specification_Pack_Alternative__c , ToLabel( Product2.Transmission_Alternative__c ) , ToLabel( Product2.Wheel_Driven_Alternative__c ) '
                    + ' , Product2.Engine__c , Body_Style_Value__c , ToLabel( Product2.Power_Output_Alternative__c ) , Product2.Name_plate_display_order__c '
                    + ' , Local_price__c , vin__c,Order_Number__c, Model__r.Model_Alternative__c, account.name, account.City_Name_Local__c,account.billingcity,account.billingstate,Power_Output_Value__c , Drive_Value__c,Previous_Price__c,Product2.Vehicle_Image_L__c,Product2.KMILink__c '
                    + ' From Asset '
                    + ' Where Product2.Make__r.Name =:brandName '
                    + ' And Account.Country_ISO_Code__c =:market '
                    + ' And Model__r.OSA_Country_ISO_Code__c includes (:market)'
                    
                    + ' And Approved_On_Udaan__c = true '
                    + ' And New_Display__c = true '
                    + ' And APO__c = false '
                    + ' And Product2.New_Vehicle__c = true '
                    + ' And Account.Regional_State_Code__c =: strState'
                    + ' AND Product2.Model_Alternative__c != null ';
                    
        if( SECTION_RECOMMEND.equals( section )|| SECTION_BODYSTYLE.equals( section ) || SECTION_ENGINE.equals( section ) || SECTION_EXTERIORGROUPCOLOUR.equals( section ) 
            || SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
                || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            List<String> models = parameters.models;
            System.debug( '----------- where models = ' + models );
            soql += ' And Product2.Model_Alternative__c in :models ';
            //soql += ' And Product2.Model__r.Model_Alternative__c in :models ';
           
        }
        
        if( SECTION_ENGINE.equals( section ) || SECTION_EXTERIORGROUPCOLOUR.equals( section ) 
            || SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
                || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            
            List<String> bodyStyles = parameters.styles;
            System.debug( '----------- where bodyStyles = ' + bodyStyles );
            if(bodyStyles != null && !bodyStyles.isEmpty())
            soql += ' And Product2.Body_Style_Key__c in :bodyStyles ';
        }

        if( SECTION_ENGINE.equals( section ) || SECTION_EXTERIORGROUPCOLOUR.equals( section ) 
            || SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
                || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            if( ! String.isEmpty( parameters.selectedFuel ) ) {
                String fuelType = parameters.selectedFuel;
                System.debug( '----------- where fuelType = ' + fuelType );
          
                soql += ' And Product2.Fuel_Type_Alternative__c = :fuelType ';
            }
        }
        
        if( SECTION_ENGINE.equals( section ) || SECTION_EXTERIORGROUPCOLOUR.equals( section ) 
            || SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
                || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            if( ! String.isEmpty( parameters.selectedDrive ) ) {
                String drive = parameters.selectedDrive;
                System.debug( '----------- where drive = ' + drive );
                
                soql += ' And Product2.Wheel_Driven_Alternative__c = :drive ';
            }
        }
        
        if( SECTION_ENGINE.equals( section ) || SECTION_EXTERIORGROUPCOLOUR.equals( section ) 
            || SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
                || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            if( ! String.isEmpty( parameters.selectedEngineSize ) ) {
                String engineSize = parameters.selectedEngineSize;
                System.debug( '----------- where engineSize = ' + engineSize );
                 
                soql += ' And Product2.Engine_Capacity_Alternative__c = :engineSize ';
            }
        }
        
        if( SECTION_ENGINE.equals( section ) || SECTION_EXTERIORGROUPCOLOUR.equals( section ) 
            || SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
                || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            if( ! String.isEmpty( parameters.selectedTransmission ) ) {
                String transmission = parameters.selectedTransmission;
                System.debug( '----------- where transmission = ' + transmission );
                
                soql += ' And Product2.Transmission_Alternative__c = :transmission ';
            }
        }
        
        if( SECTION_EXTERIORGROUPCOLOUR.equals( section ) 
            || SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
                || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            List<String> engines = parameters.engines;
            System.debug( '----------- where engine = ' + engines );
               if(engines != null && !engines.isEmpty())
            soql += ' And Engine_Key__c in :engines ';
        }
        
        if( SECTION_EXTERIORDETAILCOLOUR.equals( section ) || SECTION_INTERIORCOLOUR.equals( section ) 
            || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            List<String> exteriorGroupColours = parameters.exteriorGroupColours;
            System.debug( '----------- where exteriorGroupColours = ' + exteriorGroupColours );
               if(exteriorGroupColours != null && !exteriorGroupColours.isEmpty())
            soql += ' And Exterior_Colour_Group__c in :exteriorGroupColours ';
        }
        
        if( SECTION_INTERIORCOLOUR.equals( section ) 
            || SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            List<String> exteriorDetailColours = parameters.exteriorDetailColours;
            System.debug( '------------ where exteriorDetailColours = ' + exteriorDetailColours );
             if(exteriorDetailColours != null && !exteriorDetailColours.isEmpty())
            soql += ' And Exterior_Colour_Code__c in :exteriorDetailColours ';
        }
        
        if( SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            List<String> interiorColours = parameters.interiorColours;
            System.debug( '------------ where interiorColours = ' + interiorColours );
                if(interiorColours != null && !interiorColours.isEmpty())
            soql += ' And Interior_colour_code__c in :interiorColours ';
        }
        
        if( SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            if( parameters.budget != null ) {
                Decimal budget = parameters.budget;
                soql += ' And Local_price__c <= :budget';
            }
        }
        if( SECTION_SPECIFICATION.equals( section ) || SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            System.debug('parameters.minBudget:: '+parameters.minBudget);
            if( parameters.minBudget != null ) {
                Decimal minBudget = parameters.minBudget;
                soql += ' And Local_price__c >= :minBudget';
            }
        }
        
        if( SECTION_OPTION.equals( section ) || SECTION_VEHICLE.equals( section ) ) {
            List<String> specifications = parameters.specifications;
            System.debug( '------------ where specifications = ' + specifications );
                 if(specifications != null && !specifications.isEmpty())
            soql += ' And Specification_Key__c in :specifications';
        }
        
        if( SECTION_VEHICLE.equals( section ) && ! parameters.options.isEmpty() ) {
            String optionWord = '';
            for( String tmp : parameters.options ) {
                optionWord += tmp.replaceAll( '\'' , '\\\'' ) + ';';
            }
            System.debug( '-------------- where options = ' + optionWord );
            soql += ' AND Options__c includes ( \'' + optionWord + '\' ) ' ;
        }
        
        soql += ' Order by Name_Plate__c , Body_Style__c ';
        
        System.debug( '----------- soql = ' + soql );

        //List<Asset> assets = Database.query( soql );
        Map<Id,Asset> mapIdToAsset = new Map<id,Asset>((List<Asset>)Database.query(soql));
       
        return( mapIdToAsset.values() );
    }

    /*
     *  get model for initialize
     */
    public List<VehicleSearchBean.Model> getDistinctModel( VehicleSearchInputParameters parameters ) {
        Map<String , VehicleSearchBean.Model> distinct = new Map<String , VehicleSearchBean.Model>();
        List<Asset> assets = new List<Asset>();
        for( Product2 tmp : this.selectProducts() ) {
            VehicleSearchBean.Model model = new VehicleSearchBean.Model( tmp, parameters.deepModel );
            assets.addAll( model.assets );

            if( distinct.containsKey( model.getDistinctKey() ) ) {
                VehicleSearchBean.Model exist = distinct.get( model.getDistinctKey() );
                if( exist.Price == null || model.Price < exist.Price ) {
                    distinct.put( model.getDistinctKey() , model );
                } 
            } else {                
                distinct.put( model.getDistinctKey() , model );
            }
        }

        Map<String , VehicleSearchBean.Vehicle> distinctCount = new Map<String , VehicleSearchBean.Vehicle>();
        for( Asset tmp : assets ) {
            VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
            distinctCount.put( vehicle.getCountDistinctKey() , vehicle );
        }

        this.resultCount = distinctCount.size();
        

        
        //  sort
        List<VehicleSearchBean.Model> sorted = new List<VehicleSearchBean.Model>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.Model) tmp );
        }
       

        
        return( sorted ); 
    }

    /*
     *  get bodystyle's select option values
     */
    public List<VehicleSearchBean.Model> getDistinctRecommended( VehicleSearchInputParameters parameters ) {
        Map<String , VehicleSearchBean.Model> distinct = new Map<String , VehicleSearchBean.Model>();
        JUDAAN_Campaign__c campaign1 = new JUDAAN_Campaign__c();
        
        List<Asset> assets = this.selectData( parameters , SECTION_RECOMMEND  );
        List<String> productIds = new List<String>();
         for( Asset tmp : assets ) {
             productIds.add(tmp.Model__c);
         }
         
          Map<String , VehicleSearchBean.Vehicle> distinctCount = new Map<String , VehicleSearchBean.Vehicle>();
        /*start 
         
        Map<Id, List<JUDAAN_Campaign__c>> campaignMap = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdListCampaign( productIds,market,RECOMMEND_RECORDTYPE );

        
        Map<String , VehicleSearchBean.Vehicle> distinctCount = new Map<String , VehicleSearchBean.Vehicle>();
        
        
        for( Asset tmp : assets ) {
          
            List<JUDAAN_Campaign__c> lstcampaign = campaignMap.get(tmp.model__c); 
            if(lstcampaign != null && !lstcampaign.isEmpty()) {  
                campaign1 = new VehicleSingleController().checkCampaign(tmp , new List<JUDAAN_Campaign__c> {lstcampaign[0]});
           
                if(tmp.model__c == campaign1.product__c){
                    VehicleSearchBean.Model model = new VehicleSearchBean.Model( tmp , parameters.deepModel );
                   
    
                    if( distinct.containsKey( model.getDistinctKey() ) ) {
                        VehicleSearchBean.Model exist = distinct.get( model.getDistinctKey() );
                        if( exist.Price == null || model.Price < exist.Price ) {
                            distinct.put( model.getCountDistinctKey() , model );
                        } 
                    } else {                
                        distinct.put( model.getCountDistinctKey() , model );
                    }
                    
                     VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
                     distinctCount.put( vehicle.getCountDistinctKey() , vehicle );
                }
            }
        }
         this.resultCount = distinctCount.size();
        end here
        */
       
        
        List<String> lstModels = new List<String>();
        List<String> lstStyles = new List<String>();
        List<String> lstSpecifications = new List<String>();
        List<String> lstInteriorColours = new List<String>();
        List<String> lstExteriorDetailColours  = new List<String>();
        List<String> lstModelYear  = new List<String>();
        
        
        List<JUDAAN_Campaign__c> lstCampaign = JUDAAN_CampaignDao.getActiveCampaignListByProductId( productIds,market,RECOMMEND_RECORDTYPE );

        
        Map<Id, List<JUDAAN_Campaign__c>> campaignMap = new Map<Id, List<JUDAAN_Campaign__c>>();
        for(JUDAAN_Campaign__c objCamapaign: lstCampaign){
            
            if(objCamapaign.product__c != null){
              lstModels.add(objCamapaign.product__c);
              if(!campaignMap.containskey(objCamapaign.Product__c ))
              campaignMap.put(objCamapaign.Product__c, new List<JUDAAN_Campaign__c> {objCamapaign});
              else{
               campaignMap.get(objCamapaign.Product__c).add(objCamapaign);
               
              }
            
            }
            if(objCamapaign.Body_Style__c != null)
            lstStyles.add(objCamapaign.Body_Style__c);
            
            if(objCamapaign.Specification_Pack_Alternative__c != null)
            lstSpecifications.add(objCamapaign.Specification_Pack_Alternative__c);
            
            if(objCamapaign.Interior_Colour__c != null)
            lstInteriorColours.add(objCamapaign.Interior_Colour__c);
            
            if(objCamapaign.Exterior_Colour__c != null)
            lstExteriorDetailColours.add(objCamapaign.Exterior_Colour__c);
            
            if(objCamapaign.Model_Year__c != null)
            lstModelYear.add(objCamapaign.Model_Year__c);
            
            
            
        }
        
        List<Asset> lstAssetRecommend = selectData(lstModels,lstStyles,lstSpecifications,lstInteriorColours,lstExteriorDetailColours,lstModelYear);
        if( lstAssetRecommend  != null && !lstAssetRecommend.isEmpty() ){
            for( Asset tmp : lstAssetRecommend ) {
                /*Reommened code */
                  
                  
                List<JUDAAN_Campaign__c> lstcampaignRecommend = campaignMap.get(tmp.model__c); 
                if(lstcampaignRecommend != null && !lstcampaignRecommend .isEmpty()  ) { 

                
                  
                    for(JUDAAN_Campaign__c objCamapaign : lstcampaignRecommend ){ 
                        if(tmp.model__c == objCamapaign.product__c){
                             
                              
                           VehicleSearchBean.Model model = new VehicleSearchBean.Model( tmp , parameters.deepModel );
                   
    
                            if( distinct.containsKey( model.getDistinctKey() ) ) {
                                VehicleSearchBean.Model exist = distinct.get( model.getDistinctKey() );
                                if( exist.Price == null || model.Price < exist.Price ) {
                                    distinct.put( model.getCountDistinctKey() , model );
                                } 
                            } else {                
                                distinct.put( model.getCountDistinctKey() , model );
                            }
                            system.debug('-distinct--'+distinct);
                             VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
                             distinctCount.put( vehicle.getCountDistinctKey() , vehicle );
                        
                        }
                    }
                }
                /* End code */
                 
            }
        }
         this.resultCount = distinctCount.size();
        /*
        Map<String , VehicleSearchBean.Vehicle> distinctCount = new Map<String , VehicleSearchBean.Vehicle>();
        for( Asset tmp : assets ) {
            VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
            distinctCount.put( vehicle.getCountDistinctKey() , vehicle );
        }
        
        this.resultCount = distinctCount.size();
        */
       
        
        //  sort
       
        List<VehicleSearchBean.Model> sorted = new List<VehicleSearchBean.Model>();
         if(distinct  != null && !distinct.isEmpty())
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.Model) tmp );
        }

         system.debug('-sorted--'+sorted);
        
        return( sorted );
    }

    /*
     *  get bodystyle's select option values
     */
    public List<VehicleSearchBean.BodyStyle> getDistinctBodyStyle( VehicleSearchInputParameters parameters ) {
        Map<String , VehicleSearchBean.BodyStyle> distinct = new Map<String , VehicleSearchBean.BodyStyle>();
        Map<String , VehicleSearchBean.BodyStyle> distinctCount = new Map<String , VehicleSearchBean.BodyStyle>();

        List<Asset> assets = this.selectData( parameters , SECTION_BODYSTYLE );
       
        for( Asset tmp : assets ) {
            VehicleSearchBean.BodyStyle bodyStyle = new VehicleSearchBean.BodyStyle( tmp );
           
            if( distinct.containsKey( bodyStyle.getDistinctKey() ) ) {
                VehicleSearchBean.BodyStyle exist = distinct.get( bodyStyle.getDistinctKey() );
                if( exist.price == null || bodyStyle.price < exist.price ) {
                    distinct.put( bodyStyle.getDistinctKey() , bodyStyle );
                }
            } else {
                distinct.put( bodyStyle.getDistinctKey() , bodyStyle );
            }
            distinctCount.put( bodyStyle.getCountDistinctKey() , bodyStyle );
            
             
        }
        
        
        

        //  sort
        List<VehicleSearchBean.BodyStyle> sorted = new List<VehicleSearchBean.BodyStyle>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.BodyStyle) tmp );
        }

        this.resultCount = distinctCount.size();

//        this.resultCount = this.getVehicleCount( assets );
        
        return( sorted );
    }

    /*
     *  get engine's select option values
     */
    public List<VehicleSearchBean.Engine> getDistinctEngine( VehicleSearchInputParameters parameters ) {
        Map<String , VehicleSearchBean.Engine> distinct = new Map<String , VehicleSearchBean.Engine>();
        Map<String , VehicleSearchBean.Engine> distinctCount = new Map<String , VehicleSearchBean.Engine>();
        List<Asset> assets = this.selectData( parameters , SECTION_ENGINE );
        for( Asset tmp : assets ) {
            VehicleSearchBean.Engine engine = new VehicleSearchBean.Engine( tmp );
            if( distinct.containsKey( engine.getDistinctKey() ) ) {
                VehicleSearchBean.Engine exist = distinct.get( engine.getDistinctKey() );
                if( exist.Price == null || engine.Price < exist.Price ) {
                    distinct.put( engine.getDistinctKey() , engine );
                }
            } else {
                distinct.put( engine.getDistinctKey() , engine );
            }

            distinctCount.put( engine.getCountDistinctKey() , engine );
            
            
            
        }

        //  sort
        List<VehicleSearchBean.Engine> sorted = new List<VehicleSearchBean.Engine>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.Engine) tmp );
        }

        this.resultCount = distinctCount.size();
//        this.resultCount = this.getVehicleCount( assets );

        return( sorted );
    }

    /*
     *  get exterior group colour select option values
     */
    public List<VehicleSearchBean.ExteriorGroupColour> getDistinctExteriorColourGroup( VehicleSearchInputParameters parameters ) {
        this.resultCount = 0;
        Map<String , VehicleSearchBean.ExteriorGroupColour> distinct = new Map<String , VehicleSearchBean.ExteriorGroupColour>();
        Map<String , VehicleSearchBean.ExteriorGroupColour> distinctCount = new Map<String , VehicleSearchBean.ExteriorGroupColour>();
        List<Asset> assets = this.selectData( parameters , SECTION_EXTERIORGROUPCOLOUR );
        for( Asset tmp : assets ) {
            this.resultCount++;
            if(parameters.deepColor != null && parameters.deepColor == tmp.Exterior_Colour_Group__c.toLowerCase()  ) {
                system.debug('-----parameters.deepColor '+parameters.deepColor );
                system.debug('-----tmp.Exterior_Colour_Group__c  '+tmp.Exterior_Colour_Group__c );
                VehicleSearchBean.ExteriorGroupColour colour = new VehicleSearchBean.ExteriorGroupColour( tmp );
                colour.checked = true;
                distinct.put( colour.getDistinctKey() , colour );
                distinctCount.put( colour.getCountDistinctKey() , colour );
            }
            else{
                VehicleSearchBean.ExteriorGroupColour colour = new VehicleSearchBean.ExteriorGroupColour( tmp );
                distinct.put( colour.getDistinctKey() , colour );
                distinctCount.put( colour.getCountDistinctKey() , colour );
                }
        }
        
        //  sort
        List<VehicleSearchBean.ExteriorGroupColour> sorted = new List<VehicleSearchBean.ExteriorGroupColour>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.ExteriorGroupColour) tmp );
        }

        this.resultCount = distinctCount.size();
//        this.resultCount = this.getVehicleCount( assets );

        return( sorted );
    }
    
    /*
     *  get exterior detail colour select option values
     */
    public List<VehicleSearchBean.ExteriorColour> getDistinctExteriorColourDetail( VehicleSearchInputParameters parameters ) {
        System.debug( '--------------- getDistinctExteriorColourDetail' );

        Map<String , VehicleSearchBean.ExteriorColour> distinct = new Map<String , VehicleSearchBean.ExteriorColour>();
        Map<String , VehicleSearchBean.ExteriorColour> distinctCount = new Map<String , VehicleSearchBean.ExteriorColour>();
        List<Asset> assets = this.selectData( parameters , SECTION_EXTERIORDETAILCOLOUR );
        for( Asset tmp : assets ) {

            VehicleSearchBean.ExteriorColour colour = new VehicleSearchBean.ExteriorColour( tmp );
            if( ! String.isEmpty( tmp.Exterior_Colour__c ) ) {
                distinct.put( colour.getDistinctKey() , colour );
            }
            distinctCount.put( colour.getCountDistinctKey() , colour );
        }
        
        //  sort
        List<VehicleSearchBean.ExteriorColour> sorted = new List<VehicleSearchBean.ExteriorColour>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.ExteriorColour) tmp );
        }

        this.resultCount = distinctCount.size();
//        this.resultCount = this.getVehicleCount( assets );

        return( sorted );
    }
    
    /*
     *  get interior detail colour select option values
     */
    public List<VehicleSearchBean.InteriorColour> getDistinctInteriorColour( VehicleSearchInputParameters parameters ) {
        System.debug( '------------------- getDistinctInteriorColour ' );

        Map<String , VehicleSearchBean.InteriorColour> distinct = new Map<String , VehicleSearchBean.InteriorColour>();
        Map<String , VehicleSearchBean.InteriorColour> distinctCount = new Map<String , VehicleSearchBean.InteriorColour>();
        List<Asset> assets = this.selectData( parameters , SECTION_INTERIORCOLOUR );
        for( Asset tmp : assets ) {
            VehicleSearchBean.InteriorColour colour = new VehicleSearchBean.InteriorColour( tmp );
            if( ! String.isEmpty( tmp.Interior_Color__c ) ) {
             system.debug('----colour.getDistinctKey()'+colour.getDistinctKey() + 'assetid'+tmp.id);
                distinct.put( colour.getDistinctKey() , colour );
            }
            distinctCount.put( colour.getCountDistinctKey() , colour );
        }
        

          system.debug('---distinct'+distinct.size() + 'distinct---'+distinct);


        //  sort
        List<VehicleSearchBean.InteriorColour> sorted = new List<VehicleSearchBean.InteriorColour>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            
            sorted.add( (VehicleSearchBean.InteriorColour) tmp );
        }




        this.resultCount = distinctCount.size();
//        this.resultCount = this.getVehicleCount( assets );

        return( sorted );
    }
    
    /*
     *  get specification select option values
     */
    public List<VehicleSearchBean.Specification> getDistinctSpecification( VehicleSearchInputParameters parameters ) {
        System.debug( '----------------- VehicleSearch_AssetDao.getDistinctSpecification' );
        Map<String , VehicleSearchBean.Specification> distinct = new Map<String , VehicleSearchBean.Specification>();
        Map<String , VehicleSearchBean.Specification> distinctCount = new Map<String , VehicleSearchBean.Specification>();
        List<Asset> assets = this.selectData( parameters , SECTION_SPECIFICATION );
        for( Asset tmp : assets ) {
            VehicleSearchBean.Specification specification = new VehicleSearchBean.Specification( tmp );
            if( ! String.isEmpty( tmp.Product2.Specification_Pack_Alternative__c ) ) {
                distinct.put( specification.getDistinctKey() , specification );
            }
            distinctCount.put( specification.getCountDistinctKey() , specification );
        }
        

        
        //  sort
        List<VehicleSearchBean.Specification> sorted = new List<VehicleSearchBean.Specification>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.Specification) tmp );
        }


        
        this.resultCount = distinctCount.size();
//        this.resultCount = this.getVehicleCount( assets );

        return( sorted );
    }

    /*
     *
     */
    public List<VehicleSearchBean.Option> getDistinctOptions( VehicleSearchInputParameters parameters ) {

        Map<String , VehicleSearchBean.Option> distinct = new Map<String , VehicleSearchBean.Option>();
        Map<String , VehicleSearchBean.Vehicle> distinctCount = new Map<String , VehicleSearchBean.Vehicle>();
        List<Asset> assets = this.selectData( parameters , SECTION_OPTION );
        for( Asset tmp : assets ) {
            if( ! String.isEmpty( tmp.Options__c) ) {
                Integer index = 0;
                List<String> optionValues = StringUtil.splitMultiplePickList( tmp.Options__c ); 
               
                /*   for( String option : StringUtil.splitMultiplePickList( tmp.OptionsValue__c ) ) {
                    VehicleSearchBean.Option op = new VehicleSearchBean.Option( optionValues.get( index ) , option , tmp.Option_Image_Root__c , tmp );
                    distinct.put( op.getDistinctKey() , op );
                    index++;
                }*/
                
                 for( String option : StringUtil.splitMultiplePickList( tmp.OptionsValue__c ) ) {
                    
                    String option_name = '';
                    
                    
                      if(optionValues.contains(option)){
                         Integer result =  optionValues.indexOf(option) ;
                    
                         option_name  = optionValues.get( result );
                      }
                    
                    
                        if(option_name  != null && option_name   != '' ){
                         VehicleSearchBean.Option op = new VehicleSearchBean.Option( option_name   , option , tmp.Option_Image_Root__c , tmp );
                         distinct.put( op.getDistinctKey() , op );
                        
                        }
                        
                        //Checked for not matched options
                        else{
                      
                         VehicleSearchBean.Option op = new VehicleSearchBean.Option( optionValues.get(index), option , tmp.Option_Image_Root__c , tmp );
                         distinct.put( op.getDistinctKey() , op );
                       } 
                       
                      index++;
                }
            }
            VehicleSearchBean.Vehicle ve = new VehicleSearchBean.Vehicle( tmp );
            distinctCount.put( ve.getCountDistinctKey() , ve );
        }
        
        //  sort
        List<VehicleSearchBean.Option> sorted = new List<VehicleSearchBean.Option>();
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.Option) tmp );
        }

        this.resultCount = distinctCount.size();
//        this.resultCount = this.getVehicleCount( assets );

        return( sorted );
    }

    /*
     *  get available vehicle
     */
    public List<VehicleSearchBean.Vehicle> getAvailableVehicle( VehicleSearchInputParameters parameters ) {
        System.debug( '------------ getAvailableVehicle'+parameters );
        
      
        String models ,isRecommended,specialmodelname  ;
         
        if(ApexPages.CurrentPage().getParameters().containskey( 'models'))
        models = ApexPages.CurrentPage().getParameters().get( 'models');
        if(ApexPages.CurrentPage().getParameters().containskey( 'isRecommended'))
        isRecommended =  ApexPages.CurrentPage().getParameters().get( 'isRecommended');
        JUDAAN_Campaign__c campaign1 = new JUDAAN_Campaign__c();
        Map<String , VehicleSearchBean.Vehicle> distinct = new Map<String , VehicleSearchBean.Vehicle>();
        
        /*
        List<String> lstModels = new List<String>();
        List<String> lstStyles = new List<String>();
        List<String> lstSpecifications = new List<String>();
        List<String> lstInteriorColours = new List<String>();
        List<String> lstExteriorDetailColours  = new List<String>();
        List<String> lstModelYear  = new List<String>();
         
       */
        if(ApexPages.CurrentPage().getParameters().containskey( 'modelname') &&  ApexPages.CurrentPage().getParameters().get( 'modelname') != null ){
           specialmodelname = ApexPages.CurrentPage().getParameters().get( 'modelname');
        
            parameters.models = new List<String>();
            System.debug( '------------ specialmodelname'+specialmodelname);
            parameters.models.add(specialmodelname);
        }
        List<Asset> assets = this.selectData( parameters , SECTION_VEHICLE );
        System.debug( '------------ assets'+assets );
        
         List<String> productIds = new List<String>();
         for( Asset tmp : assets ) {
             productIds.add(tmp.Model__c);
         }
         Map<Id, List<JUDAAN_Campaign__c>> campaignMap = new Map<Id, List<JUDAAN_Campaign__c>>();
        /*  
        List<JUDAAN_Campaign__c> lstCampaign = JUDAAN_CampaignDao.getActiveCampaignListByProductId( productIds,market,RECOMMEND_RECORDTYPE );

        
        //Map<Id, List<JUDAAN_Campaign__c>> campaignMap = new Map<Id, List<JUDAAN_Campaign__c>>();
        for(JUDAAN_Campaign__c objCamapaign: lstCampaign){
            
            if(objCamapaign.product__c != null){
              lstModels.add(objCamapaign.product__c);
              if(!campaignMap.containskey(objCamapaign.Product__c ))
              campaignMap.put(objCamapaign.Product__c, new List<JUDAAN_Campaign__c> {objCamapaign});
              else{
               campaignMap.get(objCamapaign.Product__c).add(objCamapaign);
               
              }
            
            }
            if(objCamapaign.Body_Style__c != null)
            lstStyles.add(objCamapaign.Body_Style__c);
            
            if(objCamapaign.Specification_Pack_Alternative__c != null)
            lstSpecifications.add(objCamapaign.Specification_Pack_Alternative__c);
            
            if(objCamapaign.Interior_Colour__c != null)
            lstInteriorColours.add(objCamapaign.Interior_Colour__c);
            
            if(objCamapaign.Exterior_Colour__c != null)
            lstExteriorDetailColours.add(objCamapaign.Exterior_Colour__c);
            
            if(objCamapaign.Model_Year__c != null)
            lstModelYear.add(objCamapaign.Model_Year__c);
          
        }
        
        List<Asset> lstAssetRecommend = selectData(lstModels,lstStyles,lstSpecifications,lstInteriorColours,lstExteriorDetailColours,lstModelYear);
        */
        
        List<Asset> lstAssetRecommend  = getRecommendedAsset(productIds, market,campaignMap );
        
        if(lstAssetRecommend != null && !lstAssetRecommend.isEmpty() )
        if(models != null && isRecommended == 'true' && !lstAssetRecommend.isEmpty() ){
            for( Asset tmp : lstAssetRecommend ) {
                /*Reommened code */
               
                List<JUDAAN_Campaign__c> lstcampaignRecommend = campaignMap.get(tmp.model__c); 
                if(lstcampaignRecommend != null && !lstcampaignRecommend .isEmpty() && models != null && isRecommended == 'true' ) { 

               
                    //campaign1 = new VehicleSingleController().checkCampaign(tmp , new List<JUDAAN_Campaign__c> {lstcampaign[0]});
                                     
                    for(JUDAAN_Campaign__c objCamapaign : lstcampaignRecommend ){ 
                        if(tmp.model__c == objCamapaign.product__c){
                             
                              
                           VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
                            vehicle.recommendedVehicle = true;
                            if( distinct.containsKey( vehicle.getDistinctKey() ) ) {
                                VehicleSearchBean.Vehicle exist = distinct.get( vehicle.getDistinctKey() );
                                if( vehicle.Price < exist.Price ) {
                                    distinct.put( vehicle.getDistinctKey() , vehicle );
                                }
                            } else {
                                distinct.put( vehicle.getDistinctKey() , vehicle );
                            }
                        
                        }
                    }
                }
                /* End code */
                 
            }
        }
        else{
            for( Asset tmp : assets ) {
               
                    VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
                    system.debug('-----vehicle'+vehicle);
                     vehicle.recommendedVehicle = false;
                     
                     
                    
                    if(ApexPages.CurrentPage().getParameters().get( 'market') == 'br'){
                      
                          if( distinct.containsKey( vehicle.getDistinctKey()+tmp.AccountId  ) ) {
                            VehicleSearchBean.Vehicle exist = distinct.get( vehicle.getDistinctKey()+tmp.AccountId  );
                            if( vehicle.Price < exist.Price ) {
                                distinct.put( vehicle.getDistinctKey()+tmp.AccountId  , vehicle );
                            }
                        } else {
                            distinct.put( vehicle.getDistinctKey()+tmp.AccountId  , vehicle );
                        }
                    } 
                    if(ApexPages.CurrentPage().getParameters().get( 'market') != 'br'){ 
                        if( distinct.containsKey( vehicle.getDistinctKey()  ) ) {
                            VehicleSearchBean.Vehicle exist = distinct.get( vehicle.getDistinctKey() );
                            if( vehicle.Price < exist.Price ) {
                                distinct.put( vehicle.getDistinctKey() , vehicle );
                            }
                        } else {
                            distinct.put( vehicle.getDistinctKey() , vehicle );
                        }
                    }
                    
                       
            }
        
        }
         
       /*  
        Map<Id, List<JUDAAN_Campaign__c>> campaignMap = JUDAAN_CampaignDao.getActiveCampaignMapByProductIdListCampaign( productIds,market);

       
        
        
        for( Asset tmp : assets ) {
            Reommened code 
              
              
            List<JUDAAN_Campaign__c> lstcampaign = campaignMap.get(tmp.model__c); 
            if(lstcampaign != null && !lstcampaign.isEmpty() && models != null && isRecommended == 'true' ) {  
            campaign1 = new VehicleSingleController().checkCampaign(tmp , new List<JUDAAN_Campaign__c> {lstcampaign[0]});
               
                if(tmp.model__c == campaign1.product__c){
                
                   VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
        
                    if( distinct.containsKey( vehicle.getDistinctKey() ) ) {
                        VehicleSearchBean.Vehicle exist = distinct.get( vehicle.getDistinctKey() );
                        if( vehicle.Price < exist.Price ) {
                            distinct.put( vehicle.getDistinctKey() , vehicle );
                        }
                    } else {
                        distinct.put( vehicle.getDistinctKey() , vehicle );
                    }
                
                }
            }
             End code 
            else{
                VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
    
                if( distinct.containsKey( vehicle.getDistinctKey() ) ) {
                    VehicleSearchBean.Vehicle exist = distinct.get( vehicle.getDistinctKey() );
                    if( vehicle.Price < exist.Price ) {
                        distinct.put( vehicle.getDistinctKey() , vehicle );
                    }
                } else {
                    distinct.put( vehicle.getDistinctKey() , vehicle );
                }
            }   
        }
        */

        
        //  sort
        List<VehicleSearchBean.Vehicle> sorted = new List<VehicleSearchBean.Vehicle>();
       // sorted.addAll((List<VehicleSearchBean.Vehicle>) this.sort( distinct ));
        for( VehicleSearchBean.SearchSection tmp : this.sort( distinct ) ) {
            sorted.add( (VehicleSearchBean.Vehicle) tmp );
        }


        this.resultCount = distinct.size();
        //this.resultCount = this.getVehicleCount( assets );

        return( sorted );
    }

    /*
     *  sort 
     */    
    private List<VehicleSearchBean.SearchSection> sort( Map<String , VehicleSearchBean.SearchSection> records ) {
        Set<String> keys = new Set<String>();
        Map<String, VehicleSearchBean.SearchSection>  mapKeyToRecordValues= new Map<String, VehicleSearchBean.SearchSection>();
        for( VehicleSearchBean.SearchSection tmp : records.values() ) {
           
            keys.add( (String) tmp.getSortKey() );
           //mapKeyToRecordValues.put((String)tmp.getSortKey(), tmp);
        }
        List<String> sortList = new List<String>( keys );
        sortList.sort();

        List<VehicleSearchBean.SearchSection> sorted = new List<VehicleSearchBean.SearchSection>();
        
        for( String tmp : sortList ) {
          system.debug('----tmp '+tmp );
          
            for( VehicleSearchBean.SearchSection section : records.values() ) {
               system.debug('----section.getSortKey()'+section.getSortKey());
               
                //if( tmp.contains( section.getSortKey() ) )
                if( tmp == section.getSortKey()  )
                
                {
                    system.debug('111111'+section.getSortKey());
                    sorted.add( section );
              
                }
               
            }

        
        }
        return( sorted );
    }   
 
    private Integer getVehicleCount( List<Asset> assets ) {
        Map<String , VehicleSearchBean.Vehicle> distinct = new Map<String , VehicleSearchBean.Vehicle>();
       
        for( Asset tmp : assets ) {
            
            VehicleSearchBean.Vehicle vehicle = new VehicleSearchBean.Vehicle( tmp );
            distinct.put( vehicle.getDistinctKey() , vehicle );
         }
        
        return( distinct.size() );
    }
    
     private JUDAAN_Campaign__c getCampaign(Id productId, string marketName){
        JUDAAN_Campaign__c campaign = new JUDAAN_Campaign__c();
        for(JUDAAN_Campaign__c c : JUDAAN_CampaignDao.getActiveCampaignByProductId(productId,marketName)){
                campaign = c;
        }
        return campaign;
    }
    
    //This method for getting Asset record for Special offer and Recommened choice
    public List<Asset> selectData( 
        List<String> lstModels,
        List<String> lstStyles,
        List<String> lstSpecifications,
        List<String> lstInteriorColours,
        List<String> lstExteriorDetailColours,
        List<String> lstModelYear ) {
       

        String brandName = this.brandName;
        String market = this.market;
       
        String soql = 'Select id, Monthly_Price__c,New_Display__c ,APO__c ,APO_Display__c,ToLabel( Exterior_Colour_Group__c ) , ToLabel( Exterior_Colour__c ) , Interior_Color_Image__c, Search_Key__c , Search_Key_Text__c, Name '
                    + ' ,Master_Colour__c,Model__c,Body_Style_Image_M__c , ToLabel( Interior_Color__c ) '
                    + ' , Asset_Specification_Pack__c , Asset_Detail_Specification_Pack__c '
                    + ' , Exterior_Detail_Color_Image__c , Specification_Image_1__c , Specification_Image_2__c , Specification_Image_3__c '
                    + ' , Option_Image_Root__c , ToLabel( Options__c ) , Interior_colour_code__c , Colour__c, Exterior_Colour_Code__c '
                    + ' ,Vehicle_Image_L__c ,pictures__c, Vehicle_Image_M__c , Model_Year__c , Fuel_TypeValue__c , TransmissionValue__c , OptionsValue__c , Exterior_Colour_GroupValue__c '
                    + ' , ToLabel( Product2.BodyStyle_Alternative__c ) , Product2.Engine_Capacity_Alternative__c , product2.Monthly_Price_From__c,product2.Previous_Monthly_Price_From__c,ToLabel( Product2.Fuel_Type_Alternative__c ) , Product2.Model_Alternative__c '
                    + ' , Product2.Registration_Year_Alternative__c , Product2.Specification_Pack_Alternative__c , ToLabel( Product2.Transmission_Alternative__c ) , ToLabel( Product2.Wheel_Driven_Alternative__c ) '
                    + ' , Product2.Engine__c , Body_Style_Value__c , ToLabel( Product2.Power_Output_Alternative__c ) , Product2.Name_plate_display_order__c '
                    + ' , Local_price__c ,vin__c,account.billingcity,account.billingstate,account.City_Name_Local__c , Power_Output_Value__c , Drive_Value__c,Previous_Price__c,Product2.Vehicle_Image_L__c,Product2.KMILink__c,Images__c,Vehicle_interior_image_L__c,Product2.Make__r.Name,Link_for_detail_page_on_DX__c,Link_for_used_car_page_on_DX__c,Link_for_finance_page_on_DX__c,Is_Available_on_Website__c,Order_Number__c,AccountId,Account.Address_local__c,Account.NameLocal'
                    + ' From Asset '
                    + ' Where Product2.Make__r.Name =:brandName '
                    + '  And Account.Country_ISO_Code__c =:market '
                    
                    + ' And Approved_On_Udaan__c = true '
                    + ' And New_Display__c = true'
                    + ' And APO__c = false '
                    + ' And Product2.New_Vehicle__c = true '
                    + ' AND Product2.Model_Alternative__c != null ';
                 
                 system.debug('--market -'+market );
                    system.debug('--brandName -'+brandName );
                     
         system.debug('-lstModels---'+lstModels);
         system.debug('-lstStyles---'+lstStyles);
          system.debug('-lstSpecifications---'+lstSpecifications);
           system.debug('-lstInteriorColours---'+lstInteriorColours);
    
        if( lstModels != NULL && !lstModels.isEmpty() ) {
            List<String> models = lstModels;

            soql += ' And model__c  in :models ';
        }
        
        if( lstStyles != NULL && !lstStyles.isEmpty() ) {
           
           
            soql += ' And Product2.BodyStyle_Alternative__c in :lstStyles ';
        }
        
        if( lstModelYear != NULL && !lstModelYear.isEmpty() ) {
            
            soql += ' And Product2.Registration_Year_Alternative__c in :lstModelYear ';
        }
        
        if( lstInteriorColours != NULL && !lstInteriorColours.isEmpty() ) {
           
            soql += ' And Interior_Color__c in :lstInteriorColours ';
        }
        
        if( lstExteriorDetailColours != NULL && !lstExteriorDetailColours.isEmpty() ) {
           
            soql += ' And Exterior_Colour__c in :lstExteriorDetailColours ';
        }
        
        
        if( lstSpecifications != NULL && !lstSpecifications.isEmpty() ) {
            
            soql += ' And Product2.Specification_Pack_Alternative__c in :lstSpecifications ';
        }
        
        
       system.debug('--soql-'+soql);
       Map<Id,Asset> mapIdToAsset = new Map<id,Asset>((List<Asset>)Database.query(soql));

     
        

        
        return( mapIdToAsset.values() );
    }
    
    //Get Recommend related asset from product id and market
    public List<Asset> getRecommendedAsset(List<String> productIds, String market, Map<Id, List<JUDAAN_Campaign__c>> campaignMap ){
        this.market = market;
        
        List<String> lstModels = new List<String>();
        List<String> lstStyles = new List<String>();
        List<String> lstSpecifications = new List<String>();
        List<String> lstInteriorColours = new List<String>();
        List<String> lstExteriorDetailColours  = new List<String>();
        List<String> lstModelYear  = new List<String>();
        system.debug('-productIds---'+productIds);
         system.debug('-market---'+market);
         
        List<JUDAAN_Campaign__c> lstCampaign = JUDAAN_CampaignDao.getActiveCampaignListByProductId( productIds,market,RECOMMEND_RECORDTYPE );
        system.debug('-lstCampaign---'+lstCampaign);
        //Map<Id, List<JUDAAN_Campaign__c>> campaignMap = new Map<Id, List<JUDAAN_Campaign__c>>();
        for(JUDAAN_Campaign__c objCamapaign: lstCampaign){
           
            if(objCamapaign.product__c != null){
              lstModels.add(objCamapaign.product__c);
              if(!campaignMap.containskey(objCamapaign.Product__c ))
              campaignMap.put(objCamapaign.Product__c, new List<JUDAAN_Campaign__c> {objCamapaign});
              else{
               campaignMap.get(objCamapaign.Product__c).add(objCamapaign);
               
              }
            
            }
            if(objCamapaign.Body_Style__c != null)
            lstStyles.add(objCamapaign.Body_Style__c);
            
            if(objCamapaign.Specification_Pack_Alternative__c != null)
            lstSpecifications.add(objCamapaign.Specification_Pack_Alternative__c);
            
            if(objCamapaign.Interior_Colour__c != null)
            lstInteriorColours.add(objCamapaign.Interior_Colour__c);
            
            if(objCamapaign.Exterior_Colour__c != null)
            lstExteriorDetailColours.add(objCamapaign.Exterior_Colour__c);
            
            if(objCamapaign.Model_Year__c != null)
            lstModelYear.add(objCamapaign.Model_Year__c);
            
            
        }
        system.debug('-lstModels---'+lstModels);
         system.debug('-lstStyles---'+lstStyles);
          system.debug('-lstSpecifications---'+lstSpecifications);
           system.debug('-lstInteriorColours---'+lstInteriorColours);
        List<Asset> lstAssetRecommend = selectData(lstModels,lstStyles,lstSpecifications,lstInteriorColours,lstExteriorDetailColours,lstModelYear);
        
        return lstAssetRecommend ;
    
    
    }
    
    public set<String> getStateValues(){
     system.debug('---getStateValues---'+[Select RecordType.name,Regional_State_Code__c  from Account  where RecordType.Developername = 'Retailer' and country_ISO_Code__c =: this.market and Regional_State_Code__c != '' ]);
     List<Account> lstAcc = [Select RecordType.name,Regional_State_Code__c  from Account  where RecordType.Developername = 'Retailer' and country_ISO_Code__c =: this.market and Regional_State_Code__c != '' ];
     Set<String> setStateName = new Set<String>();
     for(Account objAcc : lstAcc  ){
     setStateName.add(objAcc.Regional_State_Code__c  );
     }
     return setStateName;
    }
    
   
}