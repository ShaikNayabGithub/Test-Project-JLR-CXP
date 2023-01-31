public class ReviewDuplicateAccountHandler {
    public static void sendEmail(List < Review_Duplicate_Account_Email__c > reviewAccountList) {
        if(reviewAccountList != null && !reviewAccountList.isEmpty()) {
            String subject = 'Review Potential Duplicate Accounts';
            for(Review_Duplicate_Account_Email__c reviewAccount: reviewAccountList) {
                List < String > toAddress = (List < String >) JSON.deserialize(reviewAccount.Recepient_Email_Address__c, List < String >.class);
                System.debug('### reviewAccount.Email_Body__c ### ' + reviewAccount.Email_Body__c);
                List < Account > accountList = (List < Account >) JSON.deserializeStrict(reviewAccount.Email_Body__c.unescapeHtml4(), List < Account >.class);                
                EmailUtility.SendEmail(toAddress, 'Test User', subject, getTableEmailBody(accountList));
            }
        }
    }
    
    public static string getTableEmailBody(List < Account > accountList) {
        String htmlBody = '';
        
        htmlBody += 'Dear Team,';
        htmlBody += '<br /><br />';
        htmlBody += 'Below are the potential duplicate accounts, ';
        htmlBody += '<br /><br />';
        
        // Start Table Tag
        String htmlTable = '<table border="1" style="border-collapse: collapse">';
        htmlTable += '<tr>';
        htmlTable += '<th> Name </th>';
        htmlTable += '<th> Person Email </th>';
        htmlTable += '<th> Phone </th>';
        htmlTable += '<th> Mobile </th>';
        htmlTable += '<th> Is Primary </th>';
        htmlTable += '</tr>';
        
        // Start of URL preparation
        String baseURL = String.valueOf(URL.getOrgDomainUrl().toExternalForm()).toLowerCase();
        String mergeURL = baseURL + '/merge/accmergewizard.jsp?goNext=+Next+&';
        
        // iterate over list and output columns/data into table rows...
        for(Integer i = 0; i < accountList.size(); i++) {
            htmlTable += '<tr>';
            htmlTable += '<td><a href="' + baseURL + '\\' + accountList[i].Id + '">' + accountList[i].Name + '</a></td>';
            htmlTable += '<td>' + (String.isBlank(accountList[i].PersonEmail) ? '' : accountList[i].PersonEmail) + '</td>';
            htmlTable += '<td>' + (String.isBlank(accountList[i].Phone) ? '' : accountList[i].Phone) + '</td>';
            htmlTable += '<td>' + (String.isBlank(accountList[i].PersonMobilePhone) ? '' : accountList[i].PersonMobilePhone) + '</td>';
            htmlTable += '<td>' + (i == 0 ? 'YES' : 'NO') + '</td>';
            htmlTable += '</tr>';
            if(i == 0) {
                mergeURL += 'p2=' + accountList[i].Id.to15() + '&';
            }
            mergeURL += 'cid=' + accountList[i].Id + '&';
        }
        // Remove extra & from end of the URL
        mergeURL = mergeURL.removeEnd('&');
        
        // End Table...
        htmlTable += '</table>';
        
        htmlBody += htmlTable + '<br />';
        // Prepare Hyperlink
        htmlBody += 'Please <a href="' + mergeURL + '">click here</a> to merge duplicate accounts.';
        htmlBody += '<br /><br />';
        
        /***
        htmlBody += '<a href="' + mergeURL + '">' + mergeURL + '</a>';
        htmlBody += '<br /><br />';
        ***/
        htmlBody += 'Thank You !!';
        return htmlBody;
    }
}