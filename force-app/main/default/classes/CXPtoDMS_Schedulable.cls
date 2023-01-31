public class CXPtoDMS_Schedulable implements Schedulable{
    
    public List<String> recIds;
    
    public CXPtoDMS_Schedulable(List<String> recIds){
        this.recIds = recIds;
    }
    
    public void execute(SchedulableContext SC) {
        //CXPD-1651 Changes
        //LeadHandler.CXPtoDMS(recIds);
    }
}