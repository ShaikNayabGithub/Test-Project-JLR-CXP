public class Asset_ModelYearSetter {
    
    public static void SetModelYear(List<Asset> assets, Map<Id, Asset> oldAssetMap) {
        List<Product_Code_Translations__mdt> prodTranslations = [SELECT MasterLabel, Feature_Word__c, Feature_Description__c FROM Product_Code_Translations__mdt WHERE Group__c = 'Model_Year'];
        String modelYearString;
        String nonNumericValues = '[^0-9]';
        Boolean metadataValueFound = false;
        for(Asset ass : assets){
            if(ass.Model_Year_Code__c != null && (oldAssetMap == null || ass.Model_Year__c == null || ass.Model_Year_Code__c != oldAssetMap.get(ass.Id).Model_Year_Code__c)){
                for(Product_Code_Translations__mdt pct : prodTranslations){
                    if(pct.MasterLabel == ass.Model_Year_Code__c){
                        modelYearString = pct.Feature_Word__c;
                        metadataValueFound = true;
                    }
                }
                if(!metadataValueFound){
                    //email should be sent
                    String message1 = 'Hi Team,<br/><br/>';
                    String message2 = 'Model Year Code \'<b>'+ass.Model_Year_Code__c+'\'</b> is not found in the Translation Table (Product Code Translations - Custom Metadata Type).<br/>';
                    String message3 = 'Kindly do the needful.<br/><br/>Thank you.';
                    String message = message1 + message2 + message3;
                    SendErrorEmail(message);
                }
                
            }else if(ass.Model_Year_Description__c != NULL && (modelYearString == NULL || ass.Model_Year_Description__c != oldAssetMap.get(ass.Id).Model_Year_Description__c)){
                modelYearString = ass.Model_Year_Description__c;
            }
            
            if(modelYearString != NULL){
                String modelYearStr = modelYearString.left(4).replaceAll(nonNumericValues, '');
                if(modelYearStr!=null && modelYearStr.length()>=2 && modelYearStr.length()<4){
                    String modelYear = '20'+modelYearStr.left(2);
                    System.debug('Model Year: '+modelYear);
                    ass.Model_Year__c = modelYear;
                }else if(modelYearStr.length()==4){
                    ass.Model_Year__c = modelYearStr;
                }
            }
            
        }
    }
    
    public static void SendErrorEmail(String message){
        List<String> recipients = new List<String>();
        String html='';
        String exmessage;
        System_Settings__mdt errorRecipients;
        List<System_Settings__mdt> errorRecipientList = [Select Value__c from System_Settings__mdt Where DeveloperName = 'DealerDB_Email_Failure_Alert'];
        if(errorRecipientList != null && !errorRecipientList.isEmpty()){
            errorRecipients = errorRecipientList.get(0);
        }
        
        if(errorRecipients!=null && String.isNotBlank(errorRecipients.Value__c)){
            recipients.addAll((errorRecipients.Value__c).split(','));
        }
        //recipients.add('pereddilakshmi.shivasaraswathi@nttdata.com');
        //recipients.add('shalini.d@nttdata.com');
        if (recipients.size() == 0) return;
                
        //html = '<pre>'+exmessage+'</pre><hr/><pre>'+'</pre><br/><br/>';
        html += '<font size="3">'+message+'</font>';
        
        List<Logger.Log> logs = Logger.getLogs();
        
        if(logs.isEmpty())
            logs=new List<Logger.Log>();
        
        if(logs.size() > 0){
            String logHtml = '<h3>Logs</h3><table>';
            
            for(Logger.Log l : logs){
                logHtml += '<tr><td>'+l.timestamp+'</td><td>' + l.level + '</td><td>' + l.message + '</td></tr>';
            }
            
            logHtml += '</table>';
            html += '<br/><br/>' + logHtml;
        }
        
          if(!test.isRunningTest())
        EmailUtility.SendEmail(recipients, 'DealerDBService Exception', 'Model Year Code not found - ' + system.now() ,html, null, null, false, null, true);
    }
    
}