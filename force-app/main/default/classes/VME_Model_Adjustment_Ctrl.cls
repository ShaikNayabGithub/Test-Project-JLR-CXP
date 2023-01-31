/*****************************************************
||      Name : Model_Adjustment_Controller
||      Company   : ETMarlabs
||      Purpose     :   Class used to get the requested QMSP record by the filtered values provided in 
||                                      the model adjustment under tactical actions.
||      Created By   : Tejashree J
||      Created Date: 15/04/2019
******************************************************/
public with sharing class VME_Model_Adjustment_Ctrl {
        @AuraEnabled public static Campaign get_QMSP_Record(String searchRegion, String searchMarket, String searchYear, String searchBrand, String searchQuarter, String searchModel) {
                try {
                    String QMSPOriginalQuery='Select Id, Name,VME_Retail_P_U__c,convertCurrency(VME_Retail_P_U__c) VME_Retail_P_U, Owner.Name, CurrencyIsoCode, RecordType.Name, VME_QMSP_Code__c, VME_Under_Over_Run__c, VME_Brand__r.Name, QMSP_Quarter__c,VME_Planned_Volume__c, VME_L1_Adjustment_Reason__c, QMSP_Model__r.Model_Alternative__c, VME_Fiscal_Year__c, Market__c,VME_Retail_Volume__c, VME_Planned_Budget__c,convertCurrency(VME_Planned_Budget__c) VME_Planned_Budget,VME_Planned_P_U_Amount__c,convertCurrency(VME_Planned_P_U_Amount__c) VME_Planned_P_U_Amount,VME_Actual_Spent__c,convertCurrency(VME_Actual_Spent__c) VME_Actual_Spent,VME_Adjust_volume__c, convertCurrency(VME_Under_Over_Run__c) VME_Under_Over_Run,VME_Adjust_Budget__c,convertCurrency(VME_Adjust_Budget__c) VME_Adjust_Budget,VME_Approved_Budget__c,VME_Approved_P_U_Amount__c,convertCurrency(VME_Approved_P_U_Amount__c) VME_Approved_P_U_Amount,VME_Approved_Volume__c,convertCurrency(VME_Approved_Budget__c) VME_Approved_Budget,VME_Adjust_P_U_Amount__c,convertCurrency(VME_Adjust_P_U_Amount__c) VME_Adjust_P_U_Amount from Campaign where Market__c = : searchRegion  and VME_Fiscal_Year__c = : searchYear and VME_Brand__r.Name = : searchBrand and QMSP_Quarter__c = : searchQuarter ';

                    System.debug('Model ::: ' + searchModel);//X152 (W9)
                                        if(searchModel.contains('(')) {
                                                String finalModel = searchModel.split(' \\(')[0]; //X152 Model Name
                                                System.debug('Final Model'+finalModel);
                                                String finalProductCode = searchModel.split(' \\(')[1].split('\\)')[0]; //W9 Model Product Code
                                                System.debug('Final finalProductCode'+finalProductCode);
                                                QMSPOriginalQuery+=' AND QMSP_Model__r.Name =\''+finalModel+'\' AND QMSP_Model__r.ProductCode = \''+finalProductCode+'\'LIMIT 1';
                                        } else {
                                                String finalModel = searchModel.split(' \\(')[0];
                                                if(searchModel !='All_Model') QMSPOriginalQuery+=' AND QMSP_Model__r.Name =\''+finalModel+'\'LIMIT 1';
                                        }
                                        System.debug('Model Query ::: ' + QMSPOriginalQuery);



                        System.debug(searchRegion +searchMarket+ searchYear+ searchBrand+ searchQuarter+ searchModel);
                        Campaign reqRec = Database.Query(QMSPOriginalQuery);
                        return reqRec;
                } catch (Exception e) {
                        System.debug('Exception Occured ' + e.getCause());
                        System.debug('Exception Occured ' + e.getLineNumber());
                        System.debug('Exception Occured ' + e.getMessage());
                        return null;
                }
        }
        @AuraEnabled public static TransactionStatus updt_QMSP_Record(Id recId, Decimal adjPUAmt,Decimal  adjVol,Campaign campaignrec, Decimal retailVolm) {
                try {
                        Decimal conCurrency;
                        
                        //getting logged in User Default Currency for convertion
                        User userCurrencyFormat = [SELECT Id,DefaultCurrencyIsoCode FROM User where Id = : UserInfo.getUserId() ];
                        conCurrency = VME_Utility_Class.convertCurrencyGBP_to_Other(adjPUAmt, userCurrencyFormat.DefaultCurrencyIsoCode, campaignrec.CurrencyIsoCode);
                        
                        //getting updating Campaign from Id
                        Campaign recChange = [Select Id,VME_L1_Adjustment_Reason__c,VME_Retail_Volume__c,VME_Adjust_volume__c, VME_Adjust_P_U_Amount__c from Campaign where Id = : recId];
                        recChange.VME_Adjust_P_U_Amount__c = conCurrency;
                        recChange.VME_Adjust_volume__c = adjVol;
                    	/*Commneted by Sumit Kumar on 16/08/2019
        				Reason : Component failure due to Reason field commented*/
                    	//recChange.VME_L1_Adjustment_Reason__c = QMSPreason;
                    	recChange.VME_Retail_Volume__c = retailVolm;
                        //Updating Campaign
                        Update recChange;

                        System.debug('adjPUAmt' + adjPUAmt + 'conCurrency' + conCurrency + 'recChange after update');
                        //generating Transaction Status Wrapper
                        TransactionStatus trxtnWrap = new TransactionStatus();
                                trxtnWrap.Status = 'SUCCESS';
                                trxtnWrap.ErrorMessage = 'No Error!!';
                                trxtnWrap.savedDate = recChange;
                        return trxtnWrap;
                        
                } catch(Exception e) {
                        System.debug(e.getMessage());

                        //generating Transaction Status Wrapper
                        TransactionStatus trxtnWrap = new TransactionStatus();
                        trxtnWrap.Status = 'ERROR';
                        trxtnWrap.ErrorMessage = e.getMessage();
                        trxtnWrap.savedDate = new Campaign();
                        return trxtnWrap;
                }
                
        }
        @AuraEnabled public static String get_User_Currency() {
                // query current user information  
                //User loggedUser = VME_Utility_Class.fetchUser();
                User loggedUser = [SELECT Id,Name,Username,Market__c,DefaultCurrencyIsoCode,FirstName,LastName,User_Status__c, Sales_Region__c, Country_ISO_Code__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
                return loggedUser.DefaultCurrencyIsoCode;
        }

        public class TransactionStatus{
                @AuraEnabled public String Status{get;set;}
                @AuraEnabled public String ErrorMessage {get;set;}
                @AuraEnabled public Campaign savedDate {get;set;}
        }
}