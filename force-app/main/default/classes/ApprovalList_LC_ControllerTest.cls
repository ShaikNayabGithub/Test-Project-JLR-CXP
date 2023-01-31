@isTest
public class ApprovalList_LC_ControllerTest {
    
    static testmethod void getApprovalListTest() {        
        ApprovalList_LC_Controller.getApprovalList('Opportunity_Retailer_Lost_MENA');
        ApprovalList_LC_Controller.MyApproval app = new ApprovalList_LC_Controller.MyApproval(system.today(), null, '', null, '', '', null);
    }   
    
    static testmethod void submitApprovalProcessTest() {
        try{
            ApprovalList_LC_Controller.submitApprovalProcess(null,'','');
        }catch(exception exp){
            
        }
    }
    
}