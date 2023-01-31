public class StringUtil {

    public Map<String,String> codeMapping;
    public Map<String,String> langCodeMapping;

    public static string formatJSONoutput(string body) {
        if (String.isEmpty(body) || body.length()<=2) return null;
        string returnText;
        if (body.startsWith('['))  {
                List<Object> lM = (List<Object>) JSON.deserializeUntyped(body);
                returnText = JSON.serializePretty(lM);
           } else {
                Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(body);
                returnText = JSON.serializePretty(m);
        }

        return returnText;

    }

    public static List<String> splitMultiplePickList( String tmp ) {
        List<String> returns;
        if( ! String.isEmpty( tmp ) ) {
            returns = tmp.removeEnd(';').split(';');
        } else {
          returns = new List<String>();            
        }
        
        return( returns );
    }    
/*
    public static Map<String , String> translatedOptionValue( String objectName , String fieldName , List<String> values ) {
        Map<String , String> translatedMap = translatedOptionValue( objectName , fieldName );
        Map<String , String> returnMap = new Map<String , String>();
        for( String key : values ) {
           returnMap.put( key , translatedMap.get( key ) ); 
        }

        System.debug( '------------------- translatedMap = ' + translatedMap );
        System.debug( '------------------- returnMap = ' + returnMap );
        return( returnMap );
    }

    public static Map<String , String> translatedOptionValue( String objectName , String fieldName ) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get( objectName );
        Sobject obj = targetType.newSObject();
        Schema.sObjectType objType = obj.getSObjectType(); 
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        Map<String , String> translatedMap = new Map<String , String>();
        for( Schema.PicklistEntry entry : fieldMap.get( fieldName ).getDescribe().getPickListValues() ) {
            translatedMap.put( entry.getValue() , entry.getLabel() ); 
        }

        return( translatedMap );
    }
*/
    public static String formatCurrency( String value ) {
        if( String.isEmpty( value ) ) {
            return( '' );
        } else {
            Decimal tmp = DecimalUtil.valueOf( value );
            return( tmp.format() );
        }
        
    }

    public static String zeroPadding( Decimal value , Integer digit ) {
        String tmp = '';
        for( Integer count = 0 ; count < digit ; count++ ) {
            tmp += '0';
        }
        
        tmp += value;
        
        return( tmp.right( digit ) );
    }
    
    public static String getValue( String value ) {
        if( String.isEmpty( value ) ) {
            return( '' );
        } else {
            return( value );
        }
    }
    /**
     * This method is used to return IN operator value for SOQL query 
     * input : String - Comma separated values
     * output : String - IN operator formatted value except bracket
     */
    public static String getInOperatorValue(String value) {
        String inOperatorValue = '';
        if(String.isNotBlank(value)) {
            for(String strValue: value.split(',')) {
                inOperatorValue += '\'' + strValue.trim() + '\',';
            }
            inOperatorValue = inOperatorValue.removeEnd(',');
        }
        return inOperatorValue;
    }

    public String isoLangCode2 (String englishDescription) {
        
        if (langCodeMapping==null) {
            langCodeMapping = new Map<String,String>();
            langCodeMapping.put('Afar','AA');
            langCodeMapping.put('Abkhazian','AB');
            langCodeMapping.put('Afrikaans','AF');
            langCodeMapping.put('Akan','AK');
            langCodeMapping.put('Albanian','SQ');
            langCodeMapping.put('Amharic','AM');
            langCodeMapping.put('Arabic','AR');
            langCodeMapping.put('Aragonese','AN');
            langCodeMapping.put('Armenian','HY');
            langCodeMapping.put('Assamese','AS');
            langCodeMapping.put('Avaric','AV');
            langCodeMapping.put('Avestan','AE');
            langCodeMapping.put('Aymara','AY');
            langCodeMapping.put('Azerbaijani','AZ');
            langCodeMapping.put('Bashkir','BA');
            langCodeMapping.put('Bambara','BM');
            langCodeMapping.put('Basque','EU');
            langCodeMapping.put('Belarusian','BE');
            langCodeMapping.put('Bengali','BN');
            langCodeMapping.put('Bihari languages','BH');
            langCodeMapping.put('Bislama','BI');
            langCodeMapping.put('Tibetan','BO');
            langCodeMapping.put('Bosnian','BS');
            langCodeMapping.put('Breton','BR');
            langCodeMapping.put('Bulgarian','BG');
            langCodeMapping.put('Burmese','MY');
            langCodeMapping.put('Catalan; Valencian','CA');
            langCodeMapping.put('Czech','CS');
            langCodeMapping.put('Chamorro','CH');
            langCodeMapping.put('Chechen','CE');
            langCodeMapping.put('Chinese','ZH');
            langCodeMapping.put('Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic','CU');
            langCodeMapping.put('Chuvash','CV');
            langCodeMapping.put('Cornish','KW');
            langCodeMapping.put('Corsican','CO');
            langCodeMapping.put('Cree','CR');
            langCodeMapping.put('Welsh','CY');
            langCodeMapping.put('Czech','CS');
            langCodeMapping.put('Danish','DA');
            langCodeMapping.put('German','DE');
            langCodeMapping.put('Divehi; Dhivehi; Maldivian','DV');
            langCodeMapping.put('Dutch; Flemish','NL');
            langCodeMapping.put('Dzongkha','DZ');
            langCodeMapping.put('Greek, Modern (1453-)','EL');
            langCodeMapping.put('English','EN');
            langCodeMapping.put('Esperanto','EO');
            langCodeMapping.put('Estonian','ET');
            langCodeMapping.put('Basque','EU');
            langCodeMapping.put('Ewe','EE');
            langCodeMapping.put('Faroese','FO');
            langCodeMapping.put('Persian','FA');
            langCodeMapping.put('Fijian','FJ');
            langCodeMapping.put('Finnish','FI');
            langCodeMapping.put('French','FR');
            langCodeMapping.put('French','FR');
            langCodeMapping.put('Western Frisian','FY');
            langCodeMapping.put('Fulah','FF');
            langCodeMapping.put('Georgian','KA');
            langCodeMapping.put('German','DE');
            langCodeMapping.put('Gaelic; Scottish Gaelic','GD');
            langCodeMapping.put('Irish','GA');
            langCodeMapping.put('Galician','GL');
            langCodeMapping.put('Manx','GV');
            langCodeMapping.put('Greek, Modern (1453-)','EL');
            langCodeMapping.put('Guarani','GN');
            langCodeMapping.put('Gujarati','GU');
            langCodeMapping.put('Haitian; Haitian Creole','HT');
            langCodeMapping.put('Hausa','HA');
            langCodeMapping.put('Hebrew','HE');
            langCodeMapping.put('Herero','HZ');
            langCodeMapping.put('Hindi','HI');
            langCodeMapping.put('Hiri Motu','HO');
            langCodeMapping.put('Croatian','HR');
            langCodeMapping.put('Hungarian','HU');
            langCodeMapping.put('Armenian','HY');
            langCodeMapping.put('Igbo','IG');
            langCodeMapping.put('Icelandic','IS');
            langCodeMapping.put('Ido','IO');
            langCodeMapping.put('Sichuan Yi; Nuosu','II');
            langCodeMapping.put('Inuktitut','IU');
            langCodeMapping.put('Interlingue; Occidental','IE');
            langCodeMapping.put('Interlingua (International Auxiliary Language Association)','IA');
            langCodeMapping.put('Indonesian','ID');
            langCodeMapping.put('Inupiaq','IK');
            langCodeMapping.put('Icelandic','IS');
            langCodeMapping.put('Italian','IT');
            langCodeMapping.put('Javanese','JV');
            langCodeMapping.put('Japanese','JA');
            langCodeMapping.put('Kalaallisut; Greenlandic','KL');
            langCodeMapping.put('Kannada','KN');
            langCodeMapping.put('Kashmiri','KS');
            langCodeMapping.put('Georgian','KA');
            langCodeMapping.put('Kanuri','KR');
            langCodeMapping.put('Kazakh','KK');
            langCodeMapping.put('Central Khmer','KM');
            langCodeMapping.put('Kikuyu; Gikuyu','KI');
            langCodeMapping.put('Kinyarwanda','RW');
            langCodeMapping.put('Kirghiz; Kyrgyz','KY');
            langCodeMapping.put('Komi','KV');
            langCodeMapping.put('Kongo','KG');
            langCodeMapping.put('Korean','KO');
            langCodeMapping.put('Kuanyama; Kwanyama','KJ');
            langCodeMapping.put('Kurdish','KU');
            langCodeMapping.put('Lao','LO');
            langCodeMapping.put('Latin','LA');
            langCodeMapping.put('Latvian','LV');
            langCodeMapping.put('Limburgan; Limburger; Limburgish','LI');
            langCodeMapping.put('Lingala','LN');
            langCodeMapping.put('Lithuanian','LT');
            langCodeMapping.put('Luxembourgish; Letzeburgesch','LB');
            langCodeMapping.put('Luba-Katanga','LU');
            langCodeMapping.put('Ganda','LG');
            langCodeMapping.put('Macedonian','MK');
            langCodeMapping.put('Marshallese','MH');
            langCodeMapping.put('Malayalam','ML');
            langCodeMapping.put('Maori','MI');
            langCodeMapping.put('Marathi','MR');
            langCodeMapping.put('Malay','MS');
            langCodeMapping.put('Macedonian','MK');
            langCodeMapping.put('Malagasy','MG');
            langCodeMapping.put('Maltese','MT');
            langCodeMapping.put('Mongolian','MN');
            langCodeMapping.put('Maori','MI');
            langCodeMapping.put('Malay','MS');
            langCodeMapping.put('Burmese','MY');
            langCodeMapping.put('Nauru','NA');
            langCodeMapping.put('Navajo; Navaho','NV');
            langCodeMapping.put('Ndebele, South; South Ndebele','NR');
            langCodeMapping.put('Ndebele, North; North Ndebele','ND');
            langCodeMapping.put('Ndonga','NG');
            langCodeMapping.put('Nepali','NE');
            langCodeMapping.put('Dutch; Flemish','NL');
            langCodeMapping.put('Norwegian Nynorsk; Nynorsk, Norwegian','NN');
            langCodeMapping.put('BokmÃ¥l, Norwegian; Norwegian BokmÃ¥l','NB');
            langCodeMapping.put('Norwegian','NO');
            langCodeMapping.put('Chichewa; Chewa; Nyanja','NY');
            langCodeMapping.put('Occitan (post 1500)','OC');
            langCodeMapping.put('Ojibwa','OJ');
            langCodeMapping.put('Oriya','OR');
            langCodeMapping.put('Oromo','OM');
            langCodeMapping.put('Ossetian; Ossetic','OS');
            langCodeMapping.put('Panjabi; Punjabi','PA');
            langCodeMapping.put('Persian','FA');
            langCodeMapping.put('Pali','PI');
            langCodeMapping.put('Polish','PL');
            langCodeMapping.put('Portuguese','PT');
            langCodeMapping.put('Pushto; Pashto','PS');
            langCodeMapping.put('Quechua','QU');
            langCodeMapping.put('Romansh','RM');
            langCodeMapping.put('Romanian; Moldavian; Moldovan','RO');
            langCodeMapping.put('Romanian; Moldavian; Moldovan','RO');
            langCodeMapping.put('Rundi','RN');
            langCodeMapping.put('Russian','RU');
            langCodeMapping.put('Sango','SG');
            langCodeMapping.put('Sanskrit','SA');
            langCodeMapping.put('Sinhala; Sinhalese','SI');
            langCodeMapping.put('Slovak','SK');
            langCodeMapping.put('Slovak','SK');
            langCodeMapping.put('Slovenian','SL');
            langCodeMapping.put('Northern Sami','SE');
            langCodeMapping.put('Samoan','SM');
            langCodeMapping.put('Shona','SN');
            langCodeMapping.put('Sindhi','SD');
            langCodeMapping.put('Somali','SO');
            langCodeMapping.put('Sotho, Southern','ST');
            langCodeMapping.put('Spanish; Castilian','ES');
            langCodeMapping.put('Albanian','SQ');
            langCodeMapping.put('Sardinian','SC');
            langCodeMapping.put('Serbian','SR');
            langCodeMapping.put('Swati','SS');
            langCodeMapping.put('Sundanese','SU');
            langCodeMapping.put('Swahili','SW');
            langCodeMapping.put('Swedish','SV');
            langCodeMapping.put('Tahitian','TY');
            langCodeMapping.put('Tamil','TA');
            langCodeMapping.put('Tatar','TT');
            langCodeMapping.put('Telugu','TE');
            langCodeMapping.put('Tajik','TG');
            langCodeMapping.put('Tagalog','TL');
            langCodeMapping.put('Thai','TH');
            langCodeMapping.put('Tibetan','BO');
            langCodeMapping.put('Tigrinya','TI');
            langCodeMapping.put('Tonga (Tonga Islands)','TO');
            langCodeMapping.put('Tswana','TN');
            langCodeMapping.put('Tsonga','TS');
            langCodeMapping.put('Turkmen','TK');
            langCodeMapping.put('Turkish','TR');
            langCodeMapping.put('Twi','TW');
            langCodeMapping.put('Uighur; Uyghur','UG');
            langCodeMapping.put('Ukrainian','UK');
            langCodeMapping.put('Urdu','UR');
            langCodeMapping.put('Uzbek','UZ');
            langCodeMapping.put('Venda','VE');
            langCodeMapping.put('Vietnamese','VI');
            langCodeMapping.put('VolapÃ¼k','VO');
            langCodeMapping.put('Welsh','CY');
            langCodeMapping.put('Walloon','WA');
            langCodeMapping.put('Wolof','WO');
            langCodeMapping.put('Xhosa','XH');
            langCodeMapping.put('Yiddish','YI');
            langCodeMapping.put('Yoruba','YO');
        }

        if (langCodeMapping.containsKey(englishDescription)) {
            return langCodeMapping.get(englishDescription);
        } else { return ''; }
            
    }
        
    public String isoCountryCode3 (String isoCountryCode2) {

        if (codeMapping==null) {
            codeMapping=new Map<String,String>();
            codeMapping.put('AF','AFG');
            codeMapping.put('AX','ALA');
            codeMapping.put('AL','ALB');
            codeMapping.put('DZ','DZA');
            codeMapping.put('AS','ASM');
            codeMapping.put('AD','AND');
            codeMapping.put('AO','AGO');
            codeMapping.put('AI','AIA');
            codeMapping.put('AQ','ATA');
            codeMapping.put('AG','ATG');
            codeMapping.put('AR','ARG');
            codeMapping.put('AM','ARM');
            codeMapping.put('AW','ABW');
            codeMapping.put('AU','AUS');
            codeMapping.put('AT','AUT');
            codeMapping.put('AZ','AZE');
            codeMapping.put('BS','BHS');
            codeMapping.put('BH','BHR');
            codeMapping.put('BD','BGD');
            codeMapping.put('BB','BRB');
            codeMapping.put('BY','BLR');
            codeMapping.put('BE','BEL');
            codeMapping.put('BZ','BLZ');
            codeMapping.put('BJ','BEN');
            codeMapping.put('BM','BMU');
            codeMapping.put('BT','BTN');
            codeMapping.put('BO','BOL');
            codeMapping.put('BA','BIH');
            codeMapping.put('BW','BWA');
            codeMapping.put('BV','BVT');
            codeMapping.put('BR','BRA');
            codeMapping.put('VG','VGB');
            codeMapping.put('IO','IOT');
            codeMapping.put('BN','BRN');
            codeMapping.put('BG','BGR');
            codeMapping.put('BF','BFA');
            codeMapping.put('BI','BDI');
            codeMapping.put('KH','KHM');
            codeMapping.put('CM','CMR');
            codeMapping.put('CA','CAN');
            codeMapping.put('CV','CPV');
            codeMapping.put('KY','CYM');
            codeMapping.put('CF','CAF');
            codeMapping.put('TD','TCD');
            codeMapping.put('CL','CHL');
            codeMapping.put('CN','CHN');
            codeMapping.put('HK','HKG');
            codeMapping.put('MO','MAC');
            codeMapping.put('CX','CXR');
            codeMapping.put('CC','CCK');
            codeMapping.put('CO','COL');
            codeMapping.put('KM','COM');
            codeMapping.put('CG','COG');
            codeMapping.put('CD','COD');
            codeMapping.put('CK','COK');
            codeMapping.put('CR','CRI');
            codeMapping.put('CI','CIV');
            codeMapping.put('HR','HRV');
            codeMapping.put('CU','CUB');
            codeMapping.put('CY','CYP');
            codeMapping.put('CZ','CZE');
            codeMapping.put('DK','DNK');
            codeMapping.put('DJ','DJI');
            codeMapping.put('DM','DMA');
            codeMapping.put('DO','DOM');
            codeMapping.put('EC','ECU');
            codeMapping.put('EG','EGY');
            codeMapping.put('SV','SLV');
            codeMapping.put('GQ','GNQ');
            codeMapping.put('ER','ERI');
            codeMapping.put('EE','EST');
            codeMapping.put('ET','ETH');
            codeMapping.put('FK','FLK');
            codeMapping.put('FO','FRO');
            codeMapping.put('FJ','FJI');
            codeMapping.put('FI','FIN');
            codeMapping.put('FR','FRA');
            codeMapping.put('GF','GUF');
            codeMapping.put('PF','PYF');
            codeMapping.put('TF','ATF');
            codeMapping.put('GA','GAB');
            codeMapping.put('GM','GMB');
            codeMapping.put('GE','GEO');
            codeMapping.put('DE','DEU');
            codeMapping.put('GH','GHA');
            codeMapping.put('GI','GIB');
            codeMapping.put('GR','GRC');
            codeMapping.put('GL','GRL');
            codeMapping.put('GD','GRD');
            codeMapping.put('GP','GLP');
            codeMapping.put('GU','GUM');
            codeMapping.put('GT','GTM');
            codeMapping.put('GG','GGY');
            codeMapping.put('GN','GIN');
            codeMapping.put('GW','GNB');
            codeMapping.put('GY','GUY');
            codeMapping.put('HT','HTI');
            codeMapping.put('HM','HMD');
            codeMapping.put('VA','VAT');
            codeMapping.put('HN','HND');
            codeMapping.put('HU','HUN');
            codeMapping.put('IS','ISL');
            codeMapping.put('IN','IND');
            codeMapping.put('ID','IDN');
            codeMapping.put('IR','IRN');
            codeMapping.put('IQ','IRQ');
            codeMapping.put('IE','IRL');
            codeMapping.put('IM','IMN');
            codeMapping.put('IL','ISR');
            codeMapping.put('IT','ITA');
            codeMapping.put('JM','JAM');
            codeMapping.put('JP','JPN');
            codeMapping.put('JE','JEY');
            codeMapping.put('JO','JOR');
            codeMapping.put('KZ','KAZ');
            codeMapping.put('KE','KEN');
            codeMapping.put('KI','KIR');
            codeMapping.put('KP','PRK');
            codeMapping.put('KR','KOR');
            codeMapping.put('KW','KWT');
            codeMapping.put('KG','KGZ');
            codeMapping.put('LA','LAO');
            codeMapping.put('LV','LVA');
            codeMapping.put('LB','LBN');
            codeMapping.put('LS','LSO');
            codeMapping.put('LR','LBR');
            codeMapping.put('LY','LBY');
            codeMapping.put('LI','LIE');
            codeMapping.put('LT','LTU');
            codeMapping.put('LU','LUX');
            codeMapping.put('MK','MKD');
            codeMapping.put('MG','MDG');
            codeMapping.put('MW','MWI');
            codeMapping.put('MY','MYS');
            codeMapping.put('MV','MDV');
            codeMapping.put('ML','MLI');
            codeMapping.put('MT','MLT');
            codeMapping.put('MH','MHL');
            codeMapping.put('MQ','MTQ');
            codeMapping.put('MR','MRT');
            codeMapping.put('MU','MUS');
            codeMapping.put('YT','MYT');
            codeMapping.put('MX','MEX');
            codeMapping.put('FM','FSM');
            codeMapping.put('MD','MDA');
            codeMapping.put('MC','MCO');
            codeMapping.put('MN','MNG');
            codeMapping.put('ME','MNE');
            codeMapping.put('MS','MSR');
            codeMapping.put('MA','MAR');
            codeMapping.put('MZ','MOZ');
            codeMapping.put('MM','MMR');
            codeMapping.put('NA','NAM');
            codeMapping.put('NR','NRU');
            codeMapping.put('NP','NPL');
            codeMapping.put('NL','NLD');
            codeMapping.put('AN','ANT');
            codeMapping.put('NC','NCL');
            codeMapping.put('NZ','NZL');
            codeMapping.put('NI','NIC');
            codeMapping.put('NE','NER');
            codeMapping.put('NG','NGA');
            codeMapping.put('NU','NIU');
            codeMapping.put('NF','NFK');
            codeMapping.put('MP','MNP');
            codeMapping.put('NO','NOR');
            codeMapping.put('OM','OMN');
            codeMapping.put('PK','PAK');
            codeMapping.put('PW','PLW');
            codeMapping.put('PS','PSE');
            codeMapping.put('PA','PAN');
            codeMapping.put('PG','PNG');
            codeMapping.put('PY','PRY');
            codeMapping.put('PE','PER');
            codeMapping.put('PH','PHL');
            codeMapping.put('PN','PCN');
            codeMapping.put('PL','POL');
            codeMapping.put('PT','PRT');
            codeMapping.put('PR','PRI');
            codeMapping.put('QA','QAT');
            codeMapping.put('RE','REU');
            codeMapping.put('RO','ROU');
            codeMapping.put('RU','RUS');
            codeMapping.put('RW','RWA');
            codeMapping.put('BL','BLM');
            codeMapping.put('SH','SHN');
            codeMapping.put('KN','KNA');
            codeMapping.put('LC','LCA');
            codeMapping.put('MF','MAF');
            codeMapping.put('PM','SPM');
            codeMapping.put('VC','VCT');
            codeMapping.put('WS','WSM');
            codeMapping.put('SM','SMR');
            codeMapping.put('ST','STP');
            codeMapping.put('SA','SAU');
            codeMapping.put('SN','SEN');
            codeMapping.put('RS','SRB');
            codeMapping.put('SC','SYC');
            codeMapping.put('SL','SLE');
            codeMapping.put('SG','SGP');
            codeMapping.put('SK','SVK');
            codeMapping.put('SI','SVN');
            codeMapping.put('SB','SLB');
            codeMapping.put('SO','SOM');
            codeMapping.put('ZA','ZAF');
            codeMapping.put('GS','SGS');
            codeMapping.put('SS','SSD');
            codeMapping.put('ES','ESP');
            codeMapping.put('LK','LKA');
            codeMapping.put('SD','SDN');
            codeMapping.put('SR','SUR');
            codeMapping.put('SJ','SJM');
            codeMapping.put('SZ','SWZ');
            codeMapping.put('SE','SWE');
            codeMapping.put('CH','CHE');
            codeMapping.put('SY','SYR');
            codeMapping.put('TW','TWN');
            codeMapping.put('TJ','TJK');
            codeMapping.put('TZ','TZA');
            codeMapping.put('TH','THA');
            codeMapping.put('TL','TLS');
            codeMapping.put('TG','TGO');
            codeMapping.put('TK','TKL');
            codeMapping.put('TO','TON');
            codeMapping.put('TT','TTO');
            codeMapping.put('TN','TUN');
            codeMapping.put('TR','TUR');
            codeMapping.put('TM','TKM');
            codeMapping.put('TC','TCA');
            codeMapping.put('TV','TUV');
            codeMapping.put('UG','UGA');
            codeMapping.put('UA','UKR');
            codeMapping.put('AE','ARE');
            codeMapping.put('GB','GBR');
            codeMapping.put('US','USA');
            codeMapping.put('UM','UMI');
            codeMapping.put('UY','URY');
            codeMapping.put('UZ','UZB');
            codeMapping.put('VU','VUT');
            codeMapping.put('VE','VEN');
            codeMapping.put('VN','VNM');
            codeMapping.put('VI','VIR');
            codeMapping.put('WF','WLF');
            codeMapping.put('EH','ESH');
            codeMapping.put('YE','YEM');
            codeMapping.put('ZM','ZMB');
            codeMapping.put('ZW','ZWE');
        }

        if (codeMapping.containsKey(isoCountryCode2)) {
            return codeMapping.get(isoCountryCode2);
        } else { return isoCountryCode2; }

    }
    /* **************************************************************************************
    Method Name       : splitImageLink
    Input Parameters  : string
    Return Type       : list of string
    Method Description: This Method contains the logic to split the string value received by (,).
                        Used in APOVehicleSearch to get the url of Image from (APO) Pictures
                        field.
    ****************************************************************************************** */
    
    public static list<String> splitImageLink( String value ) {
        List<String> returns;
        if(!String.isEmpty(value)) {
            returns = value.split(',');
        } else {
          returns = new List<String>();            
        }
        
        return( returns );
        
    }

}