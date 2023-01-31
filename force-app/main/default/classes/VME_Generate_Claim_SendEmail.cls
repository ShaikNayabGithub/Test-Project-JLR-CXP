/*--
||      Name : VME_Generate_Claim_SendEmail.apxc
||      Created By: Tamanna Shukla @Marlabs Private Limited
||      Purpose : To send the claim generation/re-generation mail to loggedin user (who initiated the process)
||      Created Date : 19/8/2020
||      Modified By:<Your Name>
||      Modified Date :<Date>
||      Reason :<Reason>
--*/

public  class VME_Generate_Claim_SendEmail {
    public VME_Generate_Claim_SendEmail() {
    } 
    public static void sendMailtoRetailer(Map < Id, Asset > newAssetMap,Map < Id,Map<String,List<VME_Claims__c>>> claimsDetails,String usrEmail) {
        List<Messaging.SingleEmailMessage> semailList = new List<Messaging.SingleEmailMessage>();
        for(Id asstId :newAssetMap.keySet()){
            if(claimsDetails !=null && claimsDetails.size()>0 && claimsDetails.containsKey(asstId) && ( (claimsDetails.get(asstId).containsKey('INSERT') && (claimsDetails.get(asstId).get('INSERT')).size()>0) || (claimsDetails.get(asstId).containsKey('DELETE')  && (claimsDetails.get(asstId).get('DELETE')).size()>0))){
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{usrEmail}; 
                semail.setToAddresses(sendingTo); 
                semail.setSubject('Review the claims for the VIN # '+newAssetMap.get(asstId).VIN__c+', claims may have been re-generated'); 
                //String inserted =   claimsDetails.get(asstId).containsKey('INSERT')  ? String.valueOf((claimsDetails.get(asstId)).get('INSERT').size()): '0';
                //String total =claimsDetails.get(asstId).containsKey('TOTAL')  ? String.valueOf((claimsDetails.get(asstId)).get('TOTAL').size()): '0';
                //String deleted =claimsDetails.get(asstId).containsKey('DELETE')  ? String.valueOf((claimsDetails.get(asstId)).get('DELETE').size()): '0';
                semail.setHtmlBody('Dear '+UserInfo.getName()+',<br/><br/>'+
                'Claims for the VIN # '+ newAssetMap.get(asstId).VIN__c+' may have been re-generated. Please review and re-submit the claims for approval. '+
                '<br/><br/>'+'Thanks & Regards, '+
                '<br/>'+'Team JLR '
                );
                semailList.add(semail);
            }
        }
        if(semailList !=null && semailList.size()>0)
        Messaging.sendEmail(semailList); 
    }
}