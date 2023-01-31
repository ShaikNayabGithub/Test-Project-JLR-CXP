/*
 * Owner : Marlabs Pvt Ltd
 * Prpose: To handle survey and email capture information at event level
 */
public class SurveyHandler {
    
    public static void jaguarSurveyHandlerForUpdate(Map<id,Jaguar_Survey__c> jsgSurveyNewLst,Map<id,Jaguar_Survey__c> jsgSurveyoldLst){
        
        Map<string,string> jaguarEventLst = new Map<String,String>();
        for(Jaguar_Survey__c jgSurv : jsgSurveyNewLst.values()){
            if(jgSurv.Event_Id__c != jsgSurveyoldLst.get(jgSurv.id).Event_Id__c && jgSurv.Event_Id__c!=null && jgSurv.Event_Id__c!=''){
                jaguarEventLst.put(jgSurv.Event_Id__c,jgSurv.id);
            }
        }
        
        List<Event> eventLst = [SELECT Id, Subject, What.Type,Survey_Email_Id__c, whatId FROM Event where id=:jaguarEventLst.keyset()];
        for(Event evnt:eventLst){
            if(evnt.Survey_Email_Id__c!=null && evnt.Survey_Email_Id__c!=''){
                evnt.Survey_Email_Id__c = evnt.Survey_Email_Id__c+','+String.valueOf(jaguarEventLst.get(evnt.id));
            }else{
                evnt.Survey_Email_Id__c = String.valueOf(jaguarEventLst.get(evnt.id));
            }
        }
        if(!eventLst.isEmpty()){
            update eventLst;
        }
    }
    
    public static void jaguarSurveyHandlerForInsert(List<Jaguar_Survey__c> jsgSurveyNewLst){
        Map<string,string> jaguarEventLst = new Map<String,String>();
        for(Jaguar_Survey__c jgSurv: jsgSurveyNewLst){
            if(jgSurv.Event_Id__c!=null && jgSurv.Event_Id__c!=''){
                jaguarEventLst.put(jgSurv.Event_Id__c,jgSurv.id);
            }
        }
        List<Event> eventLst = [SELECT Id, Subject, What.Type,Survey_Email_Id__c, whatId FROM Event where id=:jaguarEventLst.keyset()];
        for(Event evnt:eventLst){
            if(evnt.Survey_Email_Id__c!=null && evnt.Survey_Email_Id__c!=''){
                evnt.Survey_Email_Id__c = evnt.Survey_Email_Id__c+','+String.valueOf(jaguarEventLst.get(evnt.id));
            }else{
                evnt.Survey_Email_Id__c = String.valueOf(jaguarEventLst.get(evnt.id));
            }          
        }
        if(!eventLst.isEmpty()){
            update eventLst;
        }
    }
    
    public static void landroverSurveyHandlerForUpdate(Map<id,Landrover_Survey__c> lndsvrSurveyNewLst,Map<id,Landrover_Survey__c> lndsvrSurveyoldLst){
        
        Map<string,string> landroverEventLst = new Map<String,String>();
        for(Landrover_Survey__c lndrvSurv : lndsvrSurveyNewLst.values()){
            if(lndrvSurv.Event_Id__c != lndsvrSurveyoldLst.get(lndrvSurv.id).Event_Id__c && lndrvSurv.Event_Id__c!=null && lndrvSurv.Event_Id__c!=''){
                landroverEventLst.put(lndrvSurv.Event_Id__c,lndrvSurv.id);
            }
        }
        
        List<Event> eventLst = [SELECT Id, Subject, What.Type,Survey_Email_Id__c, whatId FROM Event where id=:landroverEventLst.keyset()];
        for(Event evnt:eventLst){
            if(evnt.Survey_Email_Id__c!=null && evnt.Survey_Email_Id__c!=''){
                evnt.Survey_Email_Id__c = evnt.Survey_Email_Id__c+','+String.valueOf(landroverEventLst.get(evnt.id));
            }else{
                evnt.Survey_Email_Id__c = String.valueOf(landroverEventLst.get(evnt.id));
            }           
        }
        if(!eventLst.isEmpty()){
            update eventLst;
        }
    }
    
    public static void landroverSurveyHandlerForInsert(List<Landrover_Survey__c> lndroverSurveyNewLst){
        Map<string,string> landroverEventLst = new Map<String,String>();
        for(Landrover_Survey__c lndrvSurv: lndroverSurveyNewLst){
            if(lndrvSurv.Event_Id__c!=null && lndrvSurv.Event_Id__c!=''){
                landroverEventLst.put(lndrvSurv.Event_Id__c,lndrvSurv.id);
            }
        }
        List<Event> eventLst = [SELECT Id, Subject, What.Type,Survey_Email_Id__c, whatId FROM Event where id=:landroverEventLst.keyset()];
        for(Event evnt:eventLst){
            if(evnt.Survey_Email_Id__c!=null && evnt.Survey_Email_Id__c!=''){
                evnt.Survey_Email_Id__c = evnt.Survey_Email_Id__c+','+String.valueOf(landroverEventLst.get(evnt.id));
            }else{
                evnt.Survey_Email_Id__c = String.valueOf(landroverEventLst.get(evnt.id));
            }                
        }
        if(!eventLst.isEmpty()){
            update eventLst;
        }
    }
    
    public static void EmailCaptureForUpdate(Map<id,Email_Capture__c> EmlCapNewLst,Map<id,Email_Capture__c> EmlCapoldLst){
        
        Map<string,string> EmlCapEventLst = new Map<String,String>();
        for(Email_Capture__c EmlCap : EmlCapNewLst.values()){
            if(EmlCap.Event_Id__c != EmlCapoldLst.get(EmlCap.id).Event_Id__c && EmlCap.Event_Id__c!=null && EmlCap.Event_Id__c!=''){
                EmlCapEventLst.put(EmlCap.Event_Id__c,EmlCap.id);
            }
        }
        
        List<Event> eventLst = [SELECT Id, Subject, What.Type,Survey_Email_Id__c, whatId FROM Event where id=:EmlCapEventLst.keyset()];
        for(Event evnt:eventLst){
            if(evnt.Survey_Email_Id__c!=null && evnt.Survey_Email_Id__c!=''){
                evnt.Survey_Email_Id__c = evnt.Survey_Email_Id__c+','+String.valueOf(EmlCapEventLst.get(evnt.id));
            }else{
                evnt.Survey_Email_Id__c = String.valueOf(EmlCapEventLst.get(evnt.id));
            }           
        }
        if(!eventLst.isEmpty()){
            update eventLst;
        }
    }
    
    public static void EmailCaptureForInsert(List<Email_Capture__c> EmailCaptureNewLst){
        Map<string,string> EmlCapEventLst = new Map<String,String>();
        for(Email_Capture__c EmlCap: EmailCaptureNewLst){
            if(EmlCap.Event_Id__c!=null && EmlCap.Event_Id__c!=''){
                EmlCapEventLst.put(EmlCap.Event_Id__c,EmlCap.id);
            }
        }
        List<Event> eventLst = [SELECT Id, Subject, What.Type,Survey_Email_Id__c, whatId FROM Event where id=:EmlCapEventLst.keyset()];
        for(Event evnt:eventLst){
            if(evnt.Survey_Email_Id__c!=null && evnt.Survey_Email_Id__c!=''){
                evnt.Survey_Email_Id__c = evnt.Survey_Email_Id__c+','+String.valueOf(EmlCapEventLst.get(evnt.id));
            }else{
                evnt.Survey_Email_Id__c = String.valueOf(EmlCapEventLst.get(evnt.id));
            }                
        }
        if(!eventLst.isEmpty()){
            update eventLst;
        }
    }
    
    
    public static void updateVINBrandFromAsset(Map<id,Event> newMap,Map<id,Event> oldMap){
        
            set<String> filteredEventids = new set<String>();
            for(Event evn:newMap.values()){
                if(evn.Service_Status__c == 'Completed' && (evn.VIN_number__c!=oldMap.get(evn.id).VIN_number__c || evn.Service_Status__c!=oldMap.get(evn.id).Service_Status__c) && evn.VIN_number__c!=null){
                    filteredEventids.add(evn.id);
                }
            }
            
            List<Event> eventLst = [Select id,VIN_Brand__c,VIN_number__c,VIN_number__r.Brand__r.Name from event where id=:filteredEventids];
            for(Event evn:eventLst){
                if(evn.VIN_Brand__c==null || evn.VIN_Brand__c==''){
                    evn.VIN_Brand__c = evn.VIN_number__r.Brand__r.Name;
                }
            }
            
            if(!eventLst.isEmpty()){
                update eventLst;
            }
        
    }
    
}