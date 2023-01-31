/******************************************************************************************
*  Name        : VME_Submit_Claims
*  
*  Company     : ETMarlabs
*    
*  Purpose     : Class used to get all the existing claims.
* 
*  Developer   : Tejashree J
*
*  Created Date: 26/04/2019
----------------------------------------------------------------------
*/
public class VME_Submit_Claims {
    @AuraEnabled
    public static Submit_Claim_Wrapper get_Assets(String startDate, String endDate, String vin, String customerName, String customerPhone, String cusclaimStatus) {
        /* Check again if the logged in user is a partner community user having certain specific profiles*/
        Submit_Claim_Wrapper submitWrapper = new Submit_Claim_Wrapper();
        submitWrapper.statusOfTransaction = 'NO-FILTER';
        submitWrapper.errorMsgOfTransaction = '';
        try {
            User usr = [Select Id, name, Market__c,Contact.AccountId,VME_Submit_Claims__c from User where Id = : UserInfo.getUserId()];
            usr.CPF__c = VME_Utility_Class.getUserDateTimeFormat();
            String query = 'Select Id, Name, VME_Pending_Claims__c, Short_VIN__c,Model__r.Name,Manufacture_Year__c,Account.Name, VIN__c, SerialNumber, VME_Retail_Date__c from Asset where Retailer_Name__c =\''+ usr.Contact.AccountId+'\' AND VME_Retail_Date__c!=null';
            List < VME_Claims__c > all_Claims; 
            if(startDate != '' && startDate != null){
                Date retailStart = Date.valueOf(startDate);
                query += ' AND VME_Retail_Date__c >=: retailStart';
                submitWrapper.statusOfTransaction = 'SUCCESS';
            }
            if(endDate != '' && endDate != null){
                Date retailEnd = Date.valueOf(endDate);
                query += ' AND VME_Retail_Date__c <=: retailEnd';
                submitWrapper.statusOfTransaction = 'SUCCESS';
            }
            if(vin != '' && vin != null){
                string tempVIN = '%' + vin + '%';
                query += ' AND VIN__c LIKE : tempVIN';
                submitWrapper.statusOfTransaction = 'SUCCESS';
            }
            if(customerName != '' && customerName != null){
                string tempName = '%' + customerName + '%';
                query += ' AND Account.Name LIKE : tempName';
                submitWrapper.statusOfTransaction = 'SUCCESS';
            }
            if(customerPhone != '' && customerPhone != null){
                string tempMobile = '%' + customerPhone + '%';
                query += ' AND Account.PersonMobilePhone LIKE : tempMobile';
                submitWrapper.statusOfTransaction = 'SUCCESS';
            }
            if(cusclaimStatus != '' && cusclaimStatus != null){
				query += ' AND VME_Pending_Claims__c =: cusclaimStatus';
                submitWrapper.statusOfTransaction = 'SUCCESS';                
            }
            query += ' ORDER BY VME_Retail_Date__c ASC LIMIT 100';
            List<Asset> assetList = Database.query(query);
            System.debug('assetList'+assetList);
            Map < String, List < String >> VME_Evidence_Matrix_map = new Map < String, List < String >> ();
            for (VME_CXP_Evidence_Matrix__mdt vcmd: [Select id,Label,Attachments_Required__c,Category__c,Category_Code__c,Combination__c,Country__c,Market__c,Sub_Category__c,Sub_Category_Code__c from VME_CXP_Evidence_Matrix__mdt ORDER BY Label]) {
                if (!VME_Evidence_Matrix_map.containsKey(vcmd.Combination__c)) {
                    VME_Evidence_Matrix_map.put(vcmd.Combination__c, new List < String > {
                        vcmd.Attachments_Required__c
                            });
                } else {
                    List < String > tempVcmd = VME_Evidence_Matrix_map.get(vcmd.Combination__c);
                    tempVcmd.add(' ' + vcmd.Attachments_Required__c);
                    VME_Evidence_Matrix_map.put(vcmd.Combination__c, tempVcmd);
                }
            }
            Map < String, String > getCatSubCatCodeMapping = VME_Utility_Class.getCatSubCatCodeMappingForL2();
            Set < Id > setofAssetIds = new Set < Id > ();
            for (Asset inst: assetList) {
                setofAssetIds.add(inst.Id);
            }
            List<ProcessInstance> processInstList;
            Map<String,List<ProcessInstance>> claimApprovalHistoryMap = new Map<String,List<ProcessInstance>>();
            if(setofAssetIds.size()>0){
                all_Claims = [Select Id, Name, VME_InActive__c, VME_VIN__r.VIN__c, VME_Amount__c, VME_Status__c, VME_Country_ISO_Code__c, VME_Related_Scheme__r.VME_Campaign__r.VME_Category__c,
                              VME_Related_Scheme__r.VME_Campaign__r.VME_Sub_Category__c, VME_Related_Scheme__r.VME_Level_3_Description__c,VME_Related_Scheme__r.VME_PU_Amount__c,
                              VME_Related_Scheme__c, VME_Retailer_Contribution__c,VME_Region_Market__c,VME_Last_Resubmission_Date__c,VME_Last_Date_of_Submissiom__c, 
                              VME_Maximum_Attempts__c,VME_Submitter_Comments__c,VME_Number_Of_Attachments__c,VME_Applied_Scheme__c, (SELECT ContentDocumentId, ContentDocument.Title, 
                                                                                                               ContentDocument.ContentSize FROM ContentDocumentLinks) from VME_Claims__c
                              where VME_InActive__c != true AND VME_VIN__c IN: setofAssetIds ];
                processInstList  = [SELECT Id,TargetObjectId,CreatedDate,Status, (SELECT Id,comments, StepStatus FROM StepsAndWorkitems) FROM ProcessInstance where  TargetObjectId  IN:all_Claims ORDER BY CreatedDate ASC];
                for(ProcessInstance eachProcess: processInstList){
                    if (!claimApprovalHistoryMap.containsKey(eachProcess.TargetObjectId)) {
                        claimApprovalHistoryMap.put(eachProcess.TargetObjectId, new List < ProcessInstance > {eachProcess});
                    } else {
                        List < ProcessInstance > tempInstances = claimApprovalHistoryMap.get(eachProcess.TargetObjectId);
                        tempInstances.add(eachProcess);
                        claimApprovalHistoryMap.put(eachProcess.TargetObjectId, tempInstances);
                    }
                }
            }
            List < get_All_Claims > wrapperList = new List < get_All_Claims > ();
            List<get_All_Asets> assets = new List<get_All_Asets>();
            List < Id > documentsId = new List < Id > ();
            Map<String,String> uploadEvidenceMap = new Map<String,String>();
            List<String> submissionDates = new List<String>();
            Date currentDate = System.today();
            for (Asset ast: assetList) {
                get_All_Asets assetsWrp = new get_All_Asets();
                get_All_Claims wrp = new get_All_Claims();
                assetsWrp.asset = ast;
                assetsWrp.loggedInUser=usr.CPF__c;
                assetsWrp.financeUser=usr.VME_Submit_Claims__c;
                wrapperList = new List < get_All_Claims > ();
                if(all_Claims.size()>0){
                    for (VME_Claims__c cl: all_Claims) {
                        documentsId = new List < Id > ();
                        wrp = new get_All_Claims();
                        uploadEvidenceMap = new Map<String,String>();
                        submissionDates = new List<String>();
                        if (cl.VME_VIN__c == ast.Id) {
                            wrp.claims = cl;
                            if(cl.VME_Last_Date_of_Submissiom__c != null){
                                DateTime lstDate = DateTime.newInstance(cl.VME_Last_Date_of_Submissiom__c.year(), cl.VME_Last_Date_of_Submissiom__c.month(),cl.VME_Last_Date_of_Submissiom__c.day());
                                submissionDates.add('Last Date For Claim Submission :   '+String.valueOf(lstDate.format(VME_Utility_Class.getUserDateTimeFormat()))+'          ');
                            }
                            if(cl.VME_Last_Resubmission_Date__c != null){
                                DateTime lstReDate = DateTime.newInstance(cl.VME_Last_Resubmission_Date__c.year(), cl.VME_Last_Resubmission_Date__c.month(),cl.VME_Last_Resubmission_Date__c.day());
                                submissionDates.add('                                             Last Date For Claim Resubmission : '+String.valueOf(lstReDate.format(VME_Utility_Class.getUserDateTimeFormat())));
                            }
                            wrp.submissionDates=submissionDates;
                            if(currentDate>cl.VME_Last_Date_of_Submissiom__c && cl.VME_Status__c!='Rejected'){
                                wrp.isSubmitable=true;
                            }else if(cl.VME_Status__c=='Rejected'){
                                if(currentDate<cl.VME_Last_Resubmission_Date__c && cl.VME_Maximum_Attempts__c>0){
                                    wrp.isSubmitable=false;
                                }else{
                                    wrp.isSubmitable=true;
                                }
                            }else{
                                wrp.isSubmitable=false;
                            }
                            wrp.isEditable = true;
                            wrp.isUploadable = false;
                            wrp.isDeletable = false;
                            wrp.bottonlabel = 'Edit';
                            wrp.uploadCount = cl.VME_Number_Of_Attachments__c;
                            wrp.bottonvariant = 'brand';
                            wrp.submitterComments = '';
                            wrp.isselected = false;
                            wrp.isApprovedClaim = false;
                            List<ProcessInstance> historyList;
                            if(claimApprovalHistoryMap.containsKey(cl.Id)){
                                historyList = claimApprovalHistoryMap.get(cl.Id);
                            }
                            List<String> rejComment = new List<String>();
                            if(historyList!=null){
                                Integer rejCnt = 5;
                                for(ProcessInstance p:historyList){
                                    Boolean checkRecall = false;
                                    for(ProcessInstanceHistory s:p.StepsAndWorkitems){
                                        if(s.StepStatus == 'Approved' && cl.VME_Status__c !='Resubmitted'){
                                            wrp.isApprovedClaim = true;
                                        }else if(cl.VME_Status__c == 'Submitted' && s.StepStatus == 'Pending' && currentDate>cl.VME_Last_Date_of_Submissiom__c){
                                            wrp.isApprovedClaim = true;
                                        }else if(p.Status == 'Rejected' && s.StepStatus == 'Rejected' && cl.VME_Status__c !='Approved'){
                                            if(s.comments==null){
                                                rejCnt--; 
                                            }else{
                                                rejComment.add('#'+rejCnt+' : '+s.StepStatus+' on '+p.CreatedDate.format('MM/dd/yyyy')+' - '+s.comments+'\n');
                                                rejCnt--;  
                                            }
                                        }
                                        if((p.Status == 'Pending' && cl.VME_Status__c =='Resubmitted' && s.StepStatus == 'Approved' )|| currentDate>cl.VME_Last_Resubmission_Date__c){
                                                wrp.isApprovedClaim = true;
                                                checkRecall = true;
                                        }else if((p.Status == 'Pending' && !checkRecall && cl.VME_Status__c =='Resubmitted' && s.StepStatus == 'Pending' )|| currentDate>cl.VME_Last_Resubmission_Date__c){
                                                wrp.isApprovedClaim = false;
                                        } 
                                    }
                                }
                                wrp.approverComments = rejComment;
                            }
                            String cat = getCatSubCatCodeMapping.get(cl.VME_Related_Scheme__r.VME_Campaign__r.VME_Category__c+'-C');
                            String subCat = getCatSubCatCodeMapping.get(cl.VME_Related_Scheme__r.VME_Campaign__r.VME_Sub_Category__c+'-SC');
                            String country = cl.VME_Country_ISO_Code__c;
                            String regMarket = cl.VME_Region_Market__c;
                            String combin = cat + '_' + subCat + '_' + regMarket + '_' + country;
                            wrp.documents = VME_Evidence_Matrix_map.get(combin);
                            if(wrp.documents!=null){ 
                                if(cl.VME_Status__c!='Approved'|| cl.VME_Status__c!='Settled'){
                                    for(String evidences:wrp.documents){
                                        uploadEvidenceMap.put(evidences.trim(),''); 
                                    }
                                }
                                for(ContentDocumentLink cdl: cl.ContentDocumentLinks){
                                    if(uploadEvidenceMap.containsKey(cdl.ContentDocument.Title)){
                                        uploadEvidenceMap.put(cdl.ContentDocument.Title,cdl.ContentDocumentId);
                                        
                                    }else{
                                        uploadEvidenceMap.put('Others',cdl.ContentDocumentId);
                                    }
                                }
                            }else{
                                List<String> otherDocument = new List<String>();
                                otherDocument.add('Others');
                                wrp.documents=otherDocument;
                                if(cl.ContentDocumentLinks.size()>0){
                                    for (ContentDocumentLink cdl: cl.ContentDocumentLinks) {
                                        uploadEvidenceMap.put(cdl.ContentDocument.Title,cdl.ContentDocumentId);
                                    }
                                }
                            }
                            if(uploadEvidenceMap.size()>0){
                                wrp.uploadEvidence = uploadEvidenceMap;
                            }else{
                                uploadEvidenceMap.put('Others','');
                                wrp.uploadEvidence=uploadEvidenceMap;                                
                            }
                            wrapperList.add(wrp);
                        }
                        assetsWrp.allClaims = wrapperList;
                    }
                }else{
                    assetsWrp.allClaims = new List < get_All_Claims > ();
                }
                assets.add(assetsWrp);
            }
            if(assets != null && assets.size()==0){
                submitWrapper.statusOfTransaction = 'NO-VIN';
            }
            submitWrapper.Asset_Wrapper_List = assets;
            return submitWrapper;
        } catch (Exception e) {
            System.debug('Exception::::'+e.getLineNumber()+'  '+e.getMessage());
            Submit_Claim_Wrapper ExceptionWrapper = new Submit_Claim_Wrapper();
            ExceptionWrapper.Asset_Wrapper_List = new List<get_All_Asets>();
            ExceptionWrapper.statusOfTransaction ='ERROR';
            ExceptionWrapper.errorMsgOfTransaction ='Error is '+e.getMessage()+' occurs in line '+e.getLineNumber();
            
            return ExceptionWrapper;
        }
    }
    public class Submit_Claim_Wrapper {
        @AuraEnabled public List<get_All_Asets> Asset_Wrapper_List {get;set;}
        @AuraEnabled public String statusOfTransaction {get;set;}
        @AuraEnabled public String errorMsgOfTransaction {get;set;}
    }
    public class get_All_Asets {
        @AuraEnabled public Asset asset;
        @AuraEnabled public List < get_All_Claims > allClaims;
        @AuraEnabled public String loggedInUser;
        @AuraEnabled public Boolean financeUser;
    }
    public class get_All_Claims {
        @AuraEnabled public VME_Claims__c claims;
        @AuraEnabled public Boolean editable_claim;
        @AuraEnabled public Boolean isEditable;
        @AuraEnabled public Boolean isUploadable;
        @AuraEnabled public Boolean isDeletable;
        @AuraEnabled public List < String > documents;
        @AuraEnabled public Decimal uploadCount;
        @AuraEnabled public String submitterComments;
        @AuraEnabled public Map<String,Id> uploadEvidence;
        @AuraEnabled public List<String> submissionDates;
        @AuraEnabled public String bottonlabel;
        @AuraEnabled public String bottonvariant;
        @AuraEnabled public Boolean isselected;
        @AuraEnabled public Boolean isSubmitable;
        @AuraEnabled public Boolean isApprovedClaim;
        @AuraEnabled public List<String> approverComments;
    }
    public class Approve_Claim_Wrapper {
        @AuraEnabled public String statusOfTransaction {get;set;}
        @AuraEnabled public String errorMsgOfTransaction {get;set;}
    }
    @AuraEnabled public static void save_Edited_Claim(Id editClaimId, double editClaimAmount, String subComments, double editAmountClaimed, Boolean editedScheme) {
        VME_Claims__c edit_claim = [Select Id, VME_Retailer_Contribution__c,VME_Submitter_Comments__c,VME_Amount__c,VME_Applied_Scheme__c from VME_Claims__c where Id = : editClaimId];
        edit_claim.VME_Retailer_Contribution__c = editClaimAmount;
        edit_claim.VME_Submitter_Comments__c = subComments; 
        edit_claim.VME_Amount__c = editAmountClaimed;
        edit_claim.VME_Applied_Scheme__c = editedScheme;
        update edit_claim;
    }
    @AuraEnabled public static void delete_Claim_Record(Id rec_To_Delete) {
        VME_Claims__c delete_record = [Select id, VME_InActive__c, VME_Status__c from VME_Claims__c where id = : rec_To_Delete];
        delete_record.VME_InActive__c = true;
        update delete_record;
    }
    @AuraEnabled public static Approve_Claim_Wrapper submitForApproval(List<String> claimCom) {
        System.debug(claimCom);
        // Create an approval request for the Claim
        
        List<Approval.ProcessSubmitRequest> reList = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessSubmitRequest> reList2 = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessSubmitRequest> reList3 = new List<Approval.ProcessSubmitRequest>();
        List<VME_Claims__c> claimList = [Select id,VME_Status__c,VME_Submitter_Comments__c,VME_Maximum_Attempts__c from VME_Claims__c where id IN:claimCom];
        for(VME_Claims__c cl : claimList){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest(); 
            Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest(); 
            Approval.ProcessSubmitRequest req3 = new Approval.ProcessSubmitRequest(); 
            if(cl.VME_Maximum_Attempts__c==5 && (cl.VME_Status__c=='Generated' || cl.VME_Status__c=='Recalled') ){
                req1.setProcessDefinitionNameOrId(System.Label.Approval1);
                req1.setObjectId(cl.Id); 
                req1.setComments(cl.VME_Submitter_Comments__c);
                reList.add(req1);
                
            }else if(cl.VME_Maximum_Attempts__c ==1 && (cl.VME_Status__c=='Rejected'|| cl.VME_Status__c=='Recalled')){
                req3.setProcessDefinitionNameOrId(System.Label.Approval3);
                req3.setObjectId(cl.Id); 
                req3.setComments(cl.VME_Submitter_Comments__c);
                reList3.add(req3);
            }else if(cl.VME_Maximum_Attempts__c<5 && (cl.VME_Status__c=='Rejected'|| cl.VME_Status__c=='Recalled')){
                req2.setProcessDefinitionNameOrId(System.Label.Approval2);
                req2.setObjectId(cl.Id); 
                req2.setComments(cl.VME_Submitter_Comments__c);
                reList2.add(req2);
            }else{
                Approve_Claim_Wrapper ExceptionWrapper = new Approve_Claim_Wrapper();
                ExceptionWrapper.statusOfTransaction ='ERROR';
                ExceptionWrapper.errorMsgOfTransaction ='Please contact your admin';
                
                return ExceptionWrapper;
            }
            
        }
        
        // Submit the approval request for the Claim
        if(reList.size()>0){
            Approval.ProcessResult[] result = Approval.process(reList,true);
        }if(reList2.size()>0){
            Approval.ProcessResult[] result = Approval.process(reList2,true);
        }if(reList3.size()>0){
            Approval.ProcessResult[] result = Approval.process(reList3,true);
        }
        Approve_Claim_Wrapper ExceptionWrapper = new Approve_Claim_Wrapper();
        ExceptionWrapper.statusOfTransaction ='SENTFORAPPROVAL';
        ExceptionWrapper.errorMsgOfTransaction ='NO-ERROR';
        
        return ExceptionWrapper;
    }
    @AuraEnabled public static Approve_Claim_Wrapper recallOnSubmit(String recordId){
        //String recordId = 'a351w0000009DotAAE';
        Approve_Claim_Wrapper apr = new Approve_Claim_Wrapper();
        //Get Process Instance Work Items
        ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :recordId
                                                 AND ProcessInstance.Status = 'Pending']; 
        
        if(piWorkItems.size() > 0){
            //Create Process Work Item Request
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItems[0].Id);
            Approval.ProcessResult result = Approval.process(pwiRequest);
            apr.statusOfTransaction='RECALLSUCCESSFUL';
            return apr;
        }
        return apr;
        
    }
    @AuraEnabled public static void delete_Document(Id DocumentIdValue) {
        ContentDocument del = new ContentDocument();
        del.id=DocumentIdValue;
        delete del;
    }
    @AuraEnabled public static void rename_Document(Id DocIdToUpdate, String newDocName) {
        List<ContentDocument> doc = [SELECT Id,title FROM ContentDocument where Id=:DocIdToUpdate];
        for(ContentDocument dc:doc){
            dc.title=newDocName;
        }
        update doc;
    }
}