public class AccountCustomerJourneyUpdateProcessor {
    static String takeTheKeysVal = 'Take the Keys';
    static String commitVal = 'Commit';
    static String selectVal = 'Select';
    static String enjoyVal = 'Enjoy';
    static String renewVal = 'Renew';
    static String maintainVal = 'Maintain';

    static set<String> caseStageSet = new set<String>{'Solved', 'Closed','Closed2', 'Cancelled'};
        static set<String> enjoyOppStageSet = new set<String>{'Handover','Won', 'Handover & RDA'};
            static set<String> commitOppStageSet = new set<String>{'Order','Order Taken'};
                static set<String> selectOppStageSet = new set<String>{'Qualify', 'Qualified', 'Test Drive Demo','Select Vehicle', 'Appraise','Negotiate','Negotiation','Contacted', 'Test Drive','Re-Opened','Appraisal','Negotiation & Approval','Vehicle Selection','Test Drive Taken/Booked'};
                    
                    
                    public static void checkCaseAvailableDetails(Account accIns){
                        boolean isOpen = false;
                        for(Case caseIns  : [select id,isclosed,status from case where accountid =:accIns.Id]){
                            if(!caseStageSet.contains(caseIns.status)){
                                isOpen = true;
                            }
                        }
                        
                        if(isOpen==true){
                            accIns.Customer_Journey_Stage__c = 'Resolve';
                        }else{
                            accIns.Customer_Journey_Stage__c = 'Enjoy';
                        }
                        System.debug('Customer Journey Stage: '+accIns.Customer_Journey_Stage__c);
                    }
    
    public static void checkOpportunityAvailableDetails(Account accIns){
        List<Opportunity> oppList = [select id,stagename,iswon,isclosed,Handover_Date__c,Handed_Over_Date__c,CloseDate from opportunity 
                                     where accountid =: accIns.Id 
                                     order by CreatedDate desc limit 1];

        if(oppList != null && !oppList.isEmpty() && accIns.Customer_Journey_Stage__c != 'Resolve' && accIns.Customer_Journey_Stage__c != 'Maintain'){
            Opportunity oppIns = oppList.get(0);
            System.debug(oppIns);
            Date startDate = oppIns.CloseDate;
            Date endDate = System.today();
            Integer noOfDays = startDate.daysBetween(endDate);
            System.debug(noOfDays);
            if(commitOppStageSet.contains(oppIns.stageName)){
                accIns.Customer_Journey_Stage__c = commitVal;
                System.debug('Commit Stage');
            }else if(enjoyOppStageSet.contains(oppIns.StageName) && oppIns.CloseDate!=null && noOfDays > 913){
                accIns.Customer_Journey_Stage__c = renewVal;
                System.debug('Renew Stage');
                System.debug('Close Date: '+oppIns.CloseDate);
                System.debug('NoofDaysBetween: '+noOfDays);
            }else if( enjoyOppStageSet.contains(oppIns.StageName) && ((accIns.Country_ISO_Code__c !='AU' && oppIns.Handover_Date__c != null && oppIns.Handover_Date__c < System.today()) || (accIns.Country_ISO_Code__c=='AU' && oppIns.Handed_Over_Date__c !=null && oppIns.Handed_Over_Date__c < System.today()))){
                accIns.Customer_Journey_Stage__c = enjoyVal;
                System.debug('Enjoy Stage:');
                System.debug('Handover Date: '+oppIns.Handover_Date__c);
                System.debug('Handed Over Date: '+oppIns.Handed_Over_Date__c);
            } else if(enjoyOppStageSet.contains(oppIns.StageName)){
                accIns.Customer_Journey_Stage__c = takeTheKeysVal;
                System.debug('Take the Keys Stage');
            }else if(selectOppStageSet.contains(oppIns.StageName)){
                accIns.Customer_Journey_Stage__c = selectVal;
                System.debug('Select Stage');
            }
            System.debug('Customer Journey Stage: '+accIns.Customer_Journey_Stage__c);
        }
    }
    
    public static void checkAssetRoleDetails(Account accIns){
        List<Service_Data__c> servList = new List<Service_Data__c>();
        try{
            servList = [SELECT Id, Account__c, Asset__c FROM Service_Data__c WHERE Account__r.Id =: accIns.Id AND Service_Status__c!='Completed'];
        }catch(System.Exception e){
            System.debug(e.getStackTraceString());
        }
        Set<Id> assetId = new Set<Id>();
        if(servList!=null){
            for(Service_Data__c serv: servList){
            	assetId.add(serv.Asset__c);
            }
        }else{
            accIns.Customer_Journey_Stage__c='Enjoy';
        }

        for(Role__c roleIns : [select id,Account__c,Role__c,Vehicle__c from Role__c 
                               where Account__c != null 
                               AND Account__c =: accIns.Id 
                               and Role__c = 'Current Owner'
                               and Vehicle__c =: assetId
                               and Account__r.Record_Type_Name__c IN ('Individual','Corporate')]){
                                   accIns.Customer_Journey_Stage__c = maintainVal;
                               }
        System.debug('Customer Journey Stage: '+accIns.Customer_Journey_Stage__c);
    }
}