public class CustomLabels {
    
    private static CustomLabels me;
    private Map<String , String> labelMap;
    
    public static CustomLabels getInstance() {
        if( me == null ) {
            me = new CustomLabels();
        }        
        return( me );
    }
    
    private CustomLabels() {
        this.labelMap = new Map<String , String>();
        this.labelMap.put( 'ADAPTIVE_CRUISE_CONTROL' , System.label.ADAPTIVE_CRUISE_CONTROL );
        this.labelMap.put( 'ADAPTIVE_CRUISE_CONTROL_NAME' , System.label.ADAPTIVE_CRUISE_CONTROL_NAME );
        this.labelMap.put( 'BLACK_PACK' , System.label.BLACK_PACK );
        this.labelMap.put( 'POWERED_TAILGATE' , System.label.Powered_Tailgate );
        this.labelMap.put( 'FRONT_FOG_LIGHTS' , System.label.FRONT_FOG_LIGHTS);
        this.labelMap.put( 'KEYLESS_ENTRY' , System.label.KEYLESS_ENTRY);
        this.labelMap.put( 'GESTURE_TAILGATE' , System.label.GESTURE_TAILGATE);
        this.labelMap.put( 'BLACK_CONTRAST_ROOF' , System.label.BLACK_CONTRAST_ROOF);
        this.labelMap.put( 'GRAINED_LEATHER_SEATS' , System.label.GRAINED_LEATHER_SEATS);
        this.labelMap.put( 'CONFIGURABLE_DYNAMICS' , System.label.CONFIGURABLE_DYNAMICS);
        this.labelMap.put( 'UPGRADED_ALLOY_WHEELS' , System.label.UPGRADED_ALLOY_WHEELS);
        this.labelMap.put( 'INTERACTIVE_DRIVER_DISPLAY' , System.label.INTERACTIVE_DRIVER_DISPLAY);
        this.labelMap.put( 'POWER_RECLINE_REAR_SEATS' , System.label.POWER_RECLINE_REAR_SEATS);
        
        this.labelMap.put( 'ADAPTIVE_DYNAMICS' , System.label.ADAPTIVE_DYNAMICS);
        this.labelMap.put( 'TYRE_PRESSURE_MONITORING_SYSTEM' , System.label.TYRE_PRESSURE_MONITORING_SYSTEM);
        this.labelMap.put( 'PREMIUM_METALLIC_PAINT' , System.label.PREMIUM_METALLIC_PAINT);//cosa-120 stops
        this.labelMap.put( 'BLACK_PACK_NAME' , System.label.BLACK_PACK_NAME );
        this.labelMap.put( 'BONUS_AMOUNT' , System.label.BONUS_AMOUNT );
        this.labelMap.put( 'DISCOVERY_FIRST_EDITION' , System.label.DISCOVERY_FIRST_EDITION );
        this.labelMap.put( 'DISCOVERY_HSE' , System.label.DISCOVERY_HSE );
        this.labelMap.put( 'DISCOVERY_HSE_LUXURY' , System.label.DISCOVERY_HSE_LUXURY );
        this.labelMap.put( 'DISCOVERY_SPORT_HSE' , System.label.DISCOVERY_SPORT_HSE );
        this.labelMap.put( 'DISCOVERY_SPORT_HSE_LUXURY' , System.label.DISCOVERY_SPORT_HSE_LUXURY );
        this.labelMap.put( 'DISCOVERY_SPORT_SE' , System.label.DISCOVERY_SPORT_SE );
        this.labelMap.put( 'DISCOVERY_SE' , System.label.DISCOVERY_SE );
        this.labelMap.put( 'AUTO_DIMMING_INTERIOR_MIRROR' , System.label.AUTO_DIMMING_INTERIOR_MIRROR );
        this.labelMap.put( 'FIXED_PANORAMIC_ROOF' , System.label.FIXED_PANORAMIC_ROOF );
        this.labelMap.put( 'FIXED_PANORAMIC_ROOF_NAME' , System.label.FIXED_PANORAMIC_ROOF_NAME );
        this.labelMap.put( 'E_PACE_FIRST_EDITION' , System.label.E_PACE_E_PACE_FIRST_EDITION );
        this.labelMap.put( 'E_PACE_R_DYNAMIC_S' , System.label.E_PACE_E_PACE_R_DYNAMIC_S );
        this.labelMap.put( 'E_PACE_R_DYNAMIC_SE' , System.label.E_PACE_E_PACE_R_DYNAMIC_SE );
        this.labelMap.put( 'E_PACE_R_DYNAMIC' , System.label.E_PACE_E_PACE_R_DYNAMIC );
        this.labelMap.put( 'E_PACE_S' , System.label.E_PACE_E_PACE_S );
        this.labelMap.put( 'E_PACE_SE' , System.label.E_PACE_E_PACE_SE );
        this.labelMap.put( 'F_PACE_FIRST_EDITION' , System.label.F_PACE_F_PACE_FIRST_EDITION );
        this.labelMap.put( 'F_PACE_PRESTIGE' , System.label.F_PACE_F_PACE_PRESTIGE );
        this.labelMap.put( 'F_PACE_PURE' , System.label.F_PACE_F_PACE_PURE );
        this.labelMap.put( 'F_PACE_R_SPORT' , System.label.F_PACE_F_PACE_R_SPORT );
        this.labelMap.put( 'F_PACE_S' , System.label.F_PACE_F_PACE_S );
        this.labelMap.put( 'F_TYPE_400_SPORT_CONVERTIBLE' , System.label.F_TYPE_F_TYPE_400_SPORT_CONVERTIBLE );
        this.labelMap.put( 'F_TYPE_400_SPORT' , System.label.F_TYPE_F_TYPE_400_SPORT_COUPE );
        this.labelMap.put( 'F_TYPE_CONVERTIBLE' , System.label.F_TYPE_F_TYPE_CONVERTIBLE );
        this.labelMap.put( 'F_TYPE_COUPE' , System.label.F_TYPE_F_TYPE_COUPE );
        this.labelMap.put( 'F_TYPE_R_CONVERTIBLE' , System.label.F_TYPE_F_TYPE_R_CONVERTIBLE );
        this.labelMap.put( 'F_TYPE_R' , System.label.F_TYPE_F_TYPE_R_COUPE );
        this.labelMap.put( 'F_TYPE_R_DYNAMIC_CONVERTBILE' , System.label.F_TYPE_F_TYPE_R_DYNAMIC_CONVERTBILE );
        this.labelMap.put( 'F_TYPE_R_DYNAMIC' , System.label.F_TYPE_F_TYPE_R_DYNAMIC_COUPE );
        this.labelMap.put( 'F_TYPE_SVR_CONVERTIBLE' , System.label.F_TYPE_F_TYPE_SVR_CONVERTIBLE );
        this.labelMap.put( 'F_TYPE_SVR' , System.label.F_TYPE_F_TYPE_SVR_COUPE );
        this.labelMap.put( 'F_TYPE_S' , System.label.F_TYPE_F_TYPE_S );
        this.labelMap.put( 'F_TYPE_SPECIAL_EDITION' , System.label.F_TYPE_F_TYPE_SPECIAL_EDITION );
        this.labelMap.put( 'F_TYPE_F_TYPE' , System.label.F_TYPE_F_TYPE_F_TYPE );
        this.labelMap.put( 'F_TYPE_JAGUAR' , System.label.F_TYPE_F_TYPE_JAGUAR );
        this.labelMap.put( 'F_TYPE_SPORT_LE' , System.label.F_TYPE_F_TYPE_SPORT_LE );
        this.labelMap.put( 'I_PACE_FIRST_EDITION' , System.label.I_PACE_I_PACE_FIRST_EDITION );
        this.labelMap.put( 'RANGE_ROVER_AUTOBIOGRAPHY' , System.label.RANGE_ROVER_AUTOBIOGRAPHY );
        this.labelMap.put( 'RANGE_ROVER_EVOQUE_AUTOBIOGRAPHY' , System.label.RANGE_ROVER_EVOQUE_AUTOBIOGRAPHY );
        this.labelMap.put( 'RANGE_ROVER_EVOQUE_HSE' , System.label.RANGE_ROVER_EVOQUE_HSE );
        this.labelMap.put( 'RANGE_ROVER_EVOQUE_HSE_DYNAMIC' , System.label.RANGE_ROVER_EVOQUE_HSE_DYNAMIC );
        this.labelMap.put( 'RANGE_ROVER_EVOQUE_SE' , System.label.RANGE_ROVER_EVOQUE_SE );
        this.labelMap.put( 'RANGE_ROVER_EVOQUE_SE_PLUS' , System.label.RANGE_ROVER_EVOQUE_SE_PLUS );
        this.labelMap.put( 'RANGE_ROVER_EVOQUE_LANDMARK_EDITION' , System.label.RANGE_ROVER_EVOQUE_RANGE_ROVER_EVOQUE_LANDMARK_EDITION );        
        this.labelMap.put( 'RANGE_ROVER_SPORT_AUTOBIOGRAPHY_DYNAMIC' , System.label.RANGE_ROVER_SPORT_AUTOBIOGRAPHY_DYNAMIC );
        this.labelMap.put( 'RANGE_ROVER_SPORT_HSE' , System.label.RANGE_ROVER_SPORT_HSE );
        this.labelMap.put( 'RANGE_ROVER_SPORT_HSE_DYNAMIC' , System.label.RANGE_ROVER_SPORT_HSE_DYNAMIC );
        this.labelMap.put( 'RANGE_ROVER_SPORT_SE' , System.label.RANGE_ROVER_SPORT_SE );
        this.labelMap.put( 'RANGE_ROVER_SPORT_SVR' , System.label.RANGE_ROVER_SPORT_SVR );
        this.labelMap.put( 'RANGE_ROVER_SVAutobiography_DYNAMIC' , System.label.RANGE_ROVER_SVAutobiography_DYNAMIC );
        this.labelMap.put( 'RANGE_ROVER_SVAutobiography_LONG_WHEELBASE' , System.label.RANGE_ROVER_SVAutobiography_LONG_WHEELBASE );
        this.labelMap.put( 'RANGE_ROVER_VELAR_VELAR' , System.label.RANGE_ROVER_VELAR_VELAR );
        this.labelMap.put( 'RANGE_ROVER_VELAR_FIRST_EDITION' , System.label.RANGE_ROVER_VELAR_VELAR_FIRST_EDITION );
        this.labelMap.put( 'RANGE_ROVER_VELAR_HSE' , System.label.RANGE_ROVER_VELAR_VELAR_HSE );
        this.labelMap.put( 'RANGE_ROVER_VELAR_R_DYNAMIC' , System.label.RANGE_ROVER_VELAR_VELAR_R_DYNAMIC );
        this.labelMap.put( 'RANGE_ROVER_VELAR_R_DYNAMIC_HSE' , System.label.RANGE_ROVER_VELAR_VELAR_R_DYNAMIC_HSE );
        this.labelMap.put( 'RANGE_ROVER_VELAR_R_DYNAMIC_S' , System.label.RANGE_ROVER_VELAR_VELAR_R_DYNAMIC_S );
        this.labelMap.put( 'RANGE_ROVER_VELAR_R_DYNAMIC_SE' , System.label.RANGE_ROVER_VELAR_VELAR_R_DYNAMIC_SE );
        this.labelMap.put( 'RANGE_ROVER_VELAR_S' , System.label.RANGE_ROVER_VELAR_VELAR_S );
        this.labelMap.put( 'RANGE_ROVER_VELAR_SE' , System.label.RANGE_ROVER_VELAR_VELAR_SE );
        this.labelMap.put( 'RANGE_ROVER_VOGUE' , System.label.RANGE_ROVER_VOGUE );
        this.labelMap.put( 'REVERSE_TRAFFIC_DETECTION_BSM_CVS' , System.label.REVERSE_TRAFFIC_DETECTION_BSM_CVS );
        this.labelMap.put( 'REVERSE_TRAFFIC_DETECTION_BSM_CVS_NAME' , System.label.REVERSE_TRAFFIC_DETECTION_BSM_CVS_NAME );
        this.labelMap.put( 'SLIDING_PANORAMIC_ROOF' , System.label.SLIDING_PANORAMIC_ROOF );
        this.labelMap.put( 'SLIDING_PANORAMIC_ROOF_NAME' , System.label.SLIDING_PANORAMIC_ROOF_NAME );
        this.labelMap.put( 'XE_PORTFOLIO' , System.label.XE_XE_PORTFOLIO );
        this.labelMap.put( 'XE_PRESTIGE' , System.label.XE_XE_PRESTIGE );
        this.labelMap.put( 'XE_PURE' , System.label.XE_XE_PURE );
        this.labelMap.put( 'XE_R_SPORT' , System.label.XE_XE_R_SPORT );
        this.labelMap.put( 'XE_S' , System.label.XE_XE_S );
        this.labelMap.put( 'XE_SE' , System.label.XE_XE_SE );
        this.labelMap.put( 'XE_JET_EDITION' , System.label.XE_XE_JET_EDITION );
        this.labelMap.put( 'XF_PORTFOLIO' , System.label.XF_XF_PORTFOLIO_SALOON );
        this.labelMap.put( 'XF_PRESTIGE' , System.label.XF_XF_PRESTIGE_SALOON );
        this.labelMap.put( 'XF_PRESTIGE_SPORTBRAKE' , System.label.XF_XF_PRESTIGE_SPORTBRAKE );
        this.labelMap.put( 'XF_PURE' , System.label.XF_XF_PURE_SALOON );
        this.labelMap.put( 'XF_R_SPORT' , System.label.XF_XF_R_SPORT_SALOON );
        this.labelMap.put( 'XF_S' , System.label.XF_XF_S_SALOON );
        this.labelMap.put( 'XJ_R' , System.label.XJ_XJR );
        this.labelMap.put( 'XJ_AUTOBIOGRAPHY' , System.label.XJ_XJ_AUTOBIOGRAPHY );
        this.labelMap.put( 'XJ_LUXURY' , System.label.XJ_XJ_LUXURY );
        this.labelMap.put( 'XJ_PORTFOLIO' , System.label.XJ_XJ_PORTFOLIO );
        this.labelMap.put( 'XJ_PREMIUM_LUXURY' , System.label.XJ_XJ_PREMIUM_LUXURY );
        this.labelMap.put( 'XJ_R_SPORT' , System.label.XJ_XJ_R_SPORT );
        this.labelMap.put( 'XJ_R575' , System.label.XJ_XJ_R575 );
        
        this.labelMap.put( '360_PARK_DISTANCE_CONTROL' , System.label.X360_PARK_DISTANCE_CONTROL);
        this.labelMap.put( '360_PARK_DISTANCE_CONTROL_NAME' , System.label.X360_PARK_DISTANCE_CONTROL_NAME);
        this.labelMap.put( 'LANE_DEPARTURE_WARNING' , System.label.LANE_DEPARTURE_WARNING);
        this.labelMap.put( 'LANE_DEPARTURE_WARNING_NAME' , System.label.LANE_DEPARTURE_WARNING_NAME);
        
        this.labelMap.put( 'BLACK_PACK_J' , System.label.BLACK_PACK_J);
        this.labelMap.put( 'BLACK_PACK_J_NAME' , System.label.BLACK_PACK_J_NAME);
        this.labelMap.put( 'BLACK_PACK_LR' , System.label.BLACK_PACK_LR);
        this.labelMap.put( 'BLACK_PACK_LR_NAME' , System.label.BLACK_PACK_LR_NAME);
        this.labelMap.put( '7_SEATER' , System.label.X7_SEATER);
        this.labelMap.put( '7_SEATER_NAME' , System.label.X7_SEATER_NAME);
        this.labelMap.put( 'UPGRADED_ALLOY_WHEELS_J' , System.label.UPGRADED_ALLOY_WHEELS_J);
        this.labelMap.put( 'UPGRADED_ALLOY_WHEELS_J_NAME' , System.label.UPGRADED_ALLOY_WHEELS_NAME); 
        this.labelMap.put( 'UPGRADED_ALLOY_WHEELS_LR' , System.label.UPGRADED_ALLOY_WHEELS_LR);
        this.labelMap.put( 'UPGRADED_ALLOY_WHEELS_LR_NAME' , System.label.UPGRADED_ALLOY_WHEELS_NAME);        
        this.labelMap.put( 'PARK_ASSIST' , System.label.PARK_ASSIST);    
        this.labelMap.put( 'PARK_ASSIST_NAME' , System.label.PARK_ASSIST_NAME);     
        this.labelMap.put( 'SURROUND_CAMERA_SYSTEM' , System.label.SURROUND_CAMERA_SYSTEM);    
        this.labelMap.put( 'ACTIVITY_KEY' , System.label.ACTIVITY_KEY);  
        this.labelMap.put( 'PREMIUM_EXTERIOR_PACK' , System.label.PREMIUM_EXTERIOR_PACK);   
        
        this.labelMap.put( 'DEFENDER' , System.label.DEFENDER);  
        this.labelMap.put( 'NEW_DEFENDER' , System.label.NEW_DEFENDER);  
        this.labelMap.put( 'I_PACE' , System.label.I_PACE);  
        this.labelMap.put( 'DISCOVERY_SPORT' , System.label.DISCOVERY_SPORT); 
        this.labelMap.put( 'RANGE_ROVER_VOGUE' , System.label.RANGE_ROVER_VOGUE); 
        this.labelMap.put( 'DISCOVERY' , System.label.DISCOVERY); 
        this.labelMap.put( 'E_PACE' , System.label.E_PACE); 
        this.labelMap.put( 'F_TYPE' , System.label.F_TYPE); 
        this.labelMap.put( 'F_PACE' , System.label.F_PACE); 
        this.labelMap.put( 'XJ' , System.label.XJ); 
        this.labelMap.put( 'XF' , System.label.XF); 
        this.labelMap.put( 'XE' , System.label.XE); 
        this.labelMap.put( 'RANGE_ROVER' , System.label.RANGE_ROVER); 
        this.labelMap.put( 'RANGE_ROVER_EVOQUE' , System.label.RANGE_ROVER_EVOQUE ); 
        this.labelMap.put( 'RANGE_ROVER_SPORT' , System.label.RANGE_ROVER_SPORT); 
        this.labelMap.put( 'RANGE_ROVER_VELAR' , System.label.RANGE_ROVER_VELAR); 
        
        this.labelMap.put( 'RANGE_ROVER_EVOQUE_TH' , System.label.RANGE_ROVER_EVOQUE_TH ); 
        this.labelMap.put( 'RANGE_ROVER_SPORT_TH' , System.label.RANGE_ROVER_SPORT_TH ); 
    }
    
    public String getValue( String key ) {
        return( this.labelMap.get( key ) );
    }
    
}