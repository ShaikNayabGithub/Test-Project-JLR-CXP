public class CampaignVINRecallAppletController { 

    public Campaign camp {get;set;}  
    public boolean alsoRemoveContacts {get;set;}
    public boolean includeContacts {get;set;}
    public boolean includeAuditData {get;set;}
    public string refreshPage {get;set;}
    
    private final string ERR_01 = Label.recallERR_01;
    private final string ERR_02 = Label.recallERR_02;
    private final string ERR_03 = Label.recallERR_03;
    private final string ERR_04 = Label.recallERR_04;
    private final string ERR_05 = Label.recallERR_05;
    private final string ERR_06 = Label.recallERR_06;
    private final string ERR_07 = Label.recallERR_07;
    private final string ERR_08 = Label.recallERR_08;    
    private final string INFO_01 = Label.recallINFO_01;
    private final string INFO_02 = Label.recallINFO_02;
    private final string INFO_03 = Label.recallINFO_03;
    private final string INFO_04 = Label.recallINFO_04;
    
    public String assetStatus {
        get {
            if (camp==null) {
                return String.Format(INFO_04,new String[]{'0'});
            } else { 
                List<Asset> assets = [select id from asset where recall_campaign__c = : camp.id];
                if (assets.isEmpty()) {
                    return String.Format(INFO_04,new String[]{'0'});
                } else {
                    return String.Format(INFO_04,new String[]{String.ValueOf(assets.size())});
                }
            }
        }
    }
    public CampaignVINRecallAppletController(ApexPages.StandardController controller) {
        this.camp = (Campaign) controller.getRecord();
        includeContacts = false;
        includeAuditData = false;
        refreshPage = 'false';
    }

    public void addCustomError(String errMessage) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errMessage));
    }
    
    public void addCustomInfo(String errMessage) {
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,errMessage));
    }
    
    public boolean showRemoveBtn {
        get{
            if (camp==null) {
                return false;
            } else { 
                List<Asset> assets = [select id from asset where recall_campaign__c = : camp.id];
                if (assets.isEmpty()) {
                    return false;
                } else {
                    return true;
                }
            }
        }
    }
    
    public void removeAuditData() {
        
        if (camp!=null) {
            List< Custom_Audit__c > auditData = [select id from Custom_Audit__c where Campaign__c = : camp.id];
            try {
                delete auditData;
            } catch (DMLException e) {
                addCustomError(e.getMessage());
            }
        }
            
    }
    
    public PageReference clearVINs() {
        
        refreshPage='false';
        
        List<Id> AccountIds = new List<Id>(); 
        Set<Id> contactIds = new Set<Id>();
    
        List<Asset> assets = [select accountid, recall_campaign__c from asset where recall_campaign__c = : camp.id];
        for (Asset a : assets) {
            AccountIds.add(a.accountid);
            a.recall_campaign__c = null;
        }
        
        if (!assets.isEmpty()) {
            try {
                update assets;
                addCustomInfo(INFO_01);
            }  catch (DMLException e) {
                addCustomError(e.getMessage());
                return null;        
            } 
        } else {
            addCustomError(ERR_01);
            return null; 
        }
        
        if (!includeContacts) return null;
                
        if (!AccountIds.isEmpty()) {
            for (Contact cont : [select id, accountid from contact where accountid in : AccountIds]) contactIds.add(cont.id);       
            if (!contactIds.isEmpty()) {
                List<CampaignMember> cms = [select id, contactid, campaignid from campaignMember where campaignid = : camp.id and contactid in : contactIds ]; 
                if (!cms.isEmpty()) {
                    try {
                        delete cms;
                        if (includeAuditData) removeAuditData();
                        addCustomInfo(INFO_02);
                        includeAuditData=false;
                    } catch (DMLException e) {
                        addCustomError(e.getMessage());
                        return null;
                    }
                } else {
                    addCustomError(ERR_02);
                    return null;
                }               
            } else {
                addCustomError(ERR_03);
                return null;
            }
        } else {
            addCustomError(ERR_04);
            return null;
        }
    
        refreshPage='true';
        return null;
    }
    
    public PageReference addVINs() {
        
        refreshPage='false';
        
        Campaign c;

        if (camp == null) {
            addCustomError(ERR_05);
            return null;
        } else if (camp.vins_for_recall__c == null) {
            addCustomError(ERR_06);
            return null;  
        } else {
            c = [select vins_for_recall__c from campaign where id = : camp.id];
            if (c==null) {
               addCustomError(ERR_07);
               return null; 
            }  else if (c.vins_for_recall__c != camp.vins_for_recall__c) {
                //addCustomInfo('vins_for_recall__c has changed from:' + c.vins_for_recall__c + ' to: ' + camp.vins_for_recall__c);
                c.vins_for_recall__c = camp.vins_for_recall__c;
                try {
                    update c;
                } catch (DMLException e) {
                    addCustomError(ERR_08 + e.getMessage());
                    return null;
                }      
            }            
        }

        List<String> vins = new List<String>();

        if (c.vins_for_recall__c != null) {
            if (c.vins_for_recall__c.contains(';')) {
                
                vins = c.vins_for_recall__c.replaceAll('\\s+', '').split(';');
            } else {
                vins.add(c.vins_for_recall__c.replaceAll('\\s+', '')); 
            }            
        } else {
            addCustomError(ERR_06);
            return null;
        }

        //List<Asset> assets = [select accountid, recall_campaign__c from asset where account.recordtype.developername in ('Corporate','Individual','Retailer') and (name in : vins or vin__c in : vins)];
        //List<Asset> assets = [select accountid, recall_campaign__c from asset where (name in : vins or vin__c in : vins)];
		List<Asset> assets = [select accountid, recall_campaign__c from asset where (name in : vins or vin__c in : vins) and recall_campaign__c !=:camp.id];
        Set<Id> accountIDs = new Set<Id>();

        Integer aCount = 0;

        for (Asset a : assets) {
            accountIds.add(a.accountid);
            a.recall_campaign__c = camp.id;
            aCount++;
        }

        Integer cCount = 0;
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        List<Contact> contacts = new List<Contact>();
        if (includeContacts && aCount>0) { 
             for (Contact cont : [select id, (Select ContactId, CampaignId from  CampaignMembers  ) from contact where accountid in : accountIds and account.recordtype.developername in ('Corporate', 'Individual','Corporate_Golden_Record','Individual_Golden_Record')]) {
                cCount++;
                List<CampaignMember> cms = cont.CampaignMembers;
                 if(cms == null || (cms!= null && cms.size()==0)){
                      campaignMembers.add(new CampaignMember(CampaignId = camp.id, ContactId = cont.id, Status = 'Sent'));  
                 }else{
                          Boolean addTocampaign = true;
                     for(CampaignMember cm :cms){                    
                         if(cm.CampaignId != null && cm.CampaignId == camp.Id){
                             addTocampaign = false;
                         }
                         
                     }
                     if(addTocampaign){
                            campaignMembers.add(new CampaignMember(CampaignId = camp.id, ContactId = cont.id, Status = 'Sent')); 
                     }
                 }

                
             
            }
        }

        try {
            if (includeContacts && !campaignMembers.isEmpty()) insert campaignMembers;
            update assets;
            addCustomInfo(String.Format(INFO_03,new String[]{String.ValueOf(cCount),String.ValueOf(aCount)}));
        } catch (DMLException e) {
            addCustomError(e.getMessage());
            return null;
        }         
        
        refreshPage='true';
        
        return null;
        
    }

}