// 
//Used by aopcom_LoginPage
//
global without sharing class aopcom_LoginPageController  {
    
    global String username{get;set;}
    global String password{get;set;}
    global String phone{get;set;}
    global String mail{get;set;}
    global String urlCheckfront{get;set;}
    global String CommunityUrl{get;set;}
    global List<SelectOption> items{get;set;}

    //
    //Constructor that initializes items list attribute
    //
    global aopcom_LoginPageController  () {        
        try{
            items=new List<SelectOption>();
            //It takes the proper data from "aop_NationalityToISOCode__c" object
            List<aop_NationalityToISOCode__c> countryMap= [SELECT Name, aop_Checkfront_Instance__c FROM aop_NationalityToISOCode__c ORDER BY Name];//aop_NationalityToISOCode__c.getAll().values();
            for(integer i=0; i<countryMap.size();i++){
                aop_NationalityToISOCode__c elem=countryMap.get(i);
                System.debug('*********Id: '+i);
                System.debug('*********Name: '+elem.aop_Checkfront_Instance__c);
                //It fills items list with values obtained from "aop_NationalityToISOCode__c" object
                items.add(new SelectOption(String.valueOf(elem.aop_Checkfront_Instance__c), String.valueOf(elem.Name)));
            }
        }catch(Exception e){
            System.debug('*********Error message: '+e.getMessage());
        }
    }
    
    //
    //It returns a reference to a custom login page
    //
   /* global  PageReference forwardToCustomAuthPage() {
        return new PageReference( '/CustomLogin'); 
    }*/
    
    //
    //It returns a reference to the default login page
    //
    global  PageReference login() {     
        
        PageReference pRef = Site.login(username, password, null);
        if (pRef==null) {
           return null;
        }else{
           return pRef;
        }
    } 
    
    //
    //It obtains the values of mail and phone attributes
    //
    global  void selectPhone(){
        
        System.debug('++++++++++++++++ Value: '+urlCheckfront);
        //It takes email and phone values from an "aop_Area_Configuration__c" object that is related to "urlCheckfront"
        List<aop_Area_Configuration__c> aConf=[SELECT aop_NSC_Contact_Email__c,aop_NSC_Contact_Phone__c FROM aop_Area_Configuration__c WHERE aop_Checkfront_Instance__c=:urlCheckfront];
        System.debug('++++++++++++++++ List size: '+aConf.size());
        //It stores values obtained before in mail and phone attributes
        if(aConf != null && aConf.size() >0){
            mail=aConf.get(0).aop_NSC_Contact_Email__c;
            phone =aConf.get(0).aop_NSC_Contact_Phone__c;
            System.debug('++++++++++++++++ Mail: '+mail);
            System.debug('++++++++++++++++ Phone: '+phone);
        }        
    }
    
}