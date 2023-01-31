/*
* @description  Handler class for Case.trigger
* @author       JLR
* @V1.0         JLR
* @V2.0         Uvais Komath@ChangiConsulting - Inherited existing code, Added Change Log - 28-Mar-2019
*/

public class CaseTriggerHandler {
    public static Boolean IgnoreCaseLinker;

    public void PreCreate(List<Case> cases)
    {       
          ClosedCaseLogic ccl = new ClosedCaseLogic();
        ccl.setClosedCaseStatusCreate(cases);
        for(Case c : cases){
            if(c.Status == 'Closed' && c.Solved_Date__c != null){
                c.ClosedDate = c.Solved_Date__c;
               
                
            }
        }
        caseEntitlementHandler entitlementHandler = new caseEntitlementHandler();
        CaseUpdateBusinessHours updateBusinessHours = new CaseUpdateBusinessHours();
        Case_Brand2Setter brand2Setter = new Case_Brand2Setter();
        entitlementHandler.SetEntitlementOnCase(cases);
        updateBusinessHours.updateBusinessHoursFromOwner(cases);
        brand2Setter.SetBrand(cases);
        
        AssetSetter assetSetter= new AssetSetter();
        assetSetter.SetAssetWithLicencePlateNumber(cases,new Map<Id,Case>());

        CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
        CaseToContactLinker linker = caseToContactLinkerFactory.Create();
        linker.LinkCasesToContactsByTrigger(cases,true,false);
        //V2.0 START
        CaseTriggerHelper.setEscalationDates(cases);
        //V2.0 END
    }    
    
    public void PreUpdate(List<Case> cases, Map<Id, Case> oldCaseMap)
    {
        Case_Brand2Setter brand2Setter = new Case_Brand2Setter();
        brand2Setter.SetBrand(cases, oldCaseMap);
        
        if(IgnoreCaseLinker == null || !IgnoreCaseLinker){
            CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
            CaseToContactLinker linker = caseToContactLinkerFactory.Create();
            linker.LinkCasesToContactsByTrigger(cases,true,true); 
        }    
        
         AssetSetter assetSetter= new AssetSetter();
        assetSetter.SetAssetWithLicencePlateNumber(cases,oldCaseMap);
        
                for(Case newCase: cases){
            if(newCase.OwnerId != oldCaseMap.get(newCase.Id).OwnerId && String.ValueOf(newCase.OwnerId).startsWith('005') &&  String.ValueOf(oldCaseMap.get(newCase.Id).OwnerId).startsWith('005')) {
                   newCase.Is_Reassigned__c = true;
                   newCase.Old_Owner__c = oldCaseMap.get(newCase.Id).OwnerId;
               }else if(newCase.OwnerId != oldCaseMap.get(newCase.Id).OwnerId && ! String.ValueOf(oldCaseMap.get(newCase.Id).OwnerId).startsWith('005') ){                   
                   newCase.Old_Owner__c = null;
               }else if(newCase.Is_Reassigned__c == true &&newCase.OwnerId != oldCaseMap.get(newCase.Id).OwnerId && String.ValueOf(oldCaseMap.get(newCase.Id).OwnerId).startsWith('005')){                   
                            newCase.Old_Owner__c = oldCaseMap.get(newCase.Id).OwnerId;
                        }
        
                
                
                
                }
        
        ClosedCaseLogic ccl = new ClosedCaseLogic();
        ccl.setClosedCaseStatusChange(cases, oldCaseMap);
        
        //V2.0 START
        CaseTriggerHelper.setEscalationDates(cases);
        //V2.0 END
    }
    
    public void PostUpdate(List<Case> caseList, Map<id,case> oldCases)
    {
        //changed as per CXPD-2617 Goodwill Case Approval Modifications
        //specifically for Korea market, goodwill process should not trigger automatically
        //User will explictly click on approval button to trigger approval process
        User u = [SELECT Id, Name, Country_ISO_Code__c FROM User where Id=:UserInfo.getUserId()];
        if (u.Country_ISO_Code__c != 'KR'){        
        CaseGoodwillApprovalHandler approvalHandler = new  CaseGoodwillApprovalHandler();
        approvalHandler.HandleGoodwillApproval(caseList, oldCases);
        }
        //CustomerJourneySetterStatusAccount CJSSA = new CustomerJourneySetterStatusAccount();
        //CJSSA.getAccountsForCRCCaseClosed(caseList, oldCases);
        AccountCustomerJourneyStatusHandler.getAccountsForCRCCaseClosed(caseList, oldCases);
     

        //if(IgnoreCaseLinker == null || !IgnoreCaseLinker){
            //Set<String> caseIds = SObjectUtilities.GetFieldValues(caseList,Case.id.getDescribe().getName());
            //CaseToContactLinker.LinkCasesToContactsFuture(caseIds);
            //CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
            //CaseToContactLinker linker = caseToContactLinkerFactory.Create();
            //linker.LinkCasesToContactsByTrigger(caseList);
        //}
        RecordSharer sharer = new RecordSharer(); 
        try{            
            sharer.Share_Cases(caseList);          //LB don't want the trigger to error if the sharing fails 
        }catch (Exception  e){}
    }
    
    public void PostCreate(List<Case> caseList, Map<Id,Case> oldCases)
    {
                //changed as per CXPD-2617 Goodwill Case Approval Modifications
        //specifically for Korea market, goodwill process should not trigger automatically
        //User will explictly click on approval button to trigger approval process
        User u = [SELECT Id, Name, Country_ISO_Code__c FROM User where Id=:UserInfo.getUserId()];
        if (u.Country_ISO_Code__c != 'KR'){        
       
        CaseGoodwillApprovalHandler approvalHandler = new  CaseGoodwillApprovalHandler();
        approvalHandler.HandleGoodwillApproval(caseList, oldCases);        
         
        }
        Set<String> caseIds = SObjectUtilities.GetFieldValues(caseList,Case.id.getDescribe().getName());        
        CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
        CaseToContactLinker linker = caseToContactLinkerFactory.Create();
        linker.LinkCasesToContactsByTrigger(caseList,false,true);   
        IgnoreCaseLinker = true; 
        //CustomerJourneySetterStatusAccount CJSSA = new CustomerJourneySetterStatusAccount();
        //CJSSA.getAccountsForCRCCaseOpened(caseList);
        AccountCustomerJourneyStatusHandler.getAccountsForCRCCaseClosed(caseList, null);
        RecordSharer sharer = new RecordSharer(); 
        try{            
            sharer.Share_Cases(caseList);          //LB don't want the trigger to error if the sharing fails 
        }catch (Exception  e){}  
        CRCCaseAccountTypeHandler cath = new CRCCaseAccountTypeHandler();
        
        cath.validateAccountType(caseList);
    }
    
    public void CreateAssetRoles(List<Case> caseList, Map<Id, Case> oldCaseMap){
     //   CaseAssetRoleSetter assetRoleSetter = new CaseAssetRoleSetter();
     //   assetRoleSetter.SetAssetRoles(caseList, oldCaseMap);
    }
}