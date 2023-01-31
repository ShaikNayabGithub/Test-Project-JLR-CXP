public class Transitional_Data_Cleanser {
    public static List<Dispensable_Value__mdt> spamValues =  [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Category__c, Is_Full_Text__c FROM Dispensable_Value__mdt];
    
    public List<Transitional_Record__c> cleanEmailAddressSettingSpam( List<Transitional_Record__c> transRecs){
        
        
        List<Dispensable_Value__mdt> fullEmailStrip = new List<Dispensable_Value__mdt>();
        List<Dispensable_Value__mdt> partialEmailStrip = New List<Dispensable_Value__mdt>();
        Boolean areThereSpamEmailMetadataSetting = false;
        
        if(spamValues != null && spamValues.size() >0 ){
            
            
            for(Dispensable_Value__mdt disp : spamValues){
                if(disp.Category__c != null &&  disp.Category__c  == 'Email' && disp.Is_Full_Text__c == true){
                    fullEmailStrip.add(disp);
                    areThereSpamEmailMetadataSetting = true;
                }
                if(disp.Category__c != null &&  disp.Category__c  == 'Email' && disp.Is_Full_Text__c == false){
                    partialEmailStrip.add(disp);
                    areThereSpamEmailMetadataSetting = true;
                }
                
            }
            if(areThereSpamEmailMetadataSetting){
                for(Transitional_Record__c tran : transRecs){
                    
                    tran.Dummy_email__c = isEmailSpam(tran.Email_Address_1__c, partialEmailStrip,fullEmailStrip );
                }
                
            }
            
            
        }
        
        
        return transRecs;
    }
    
    
    public List<Transitional_Record__c> cleanNameKeepingOriginal( List<Transitional_Record__c> transRecs){
        List<Dispensable_Value__mdt> nameStrip = new List<Dispensable_Value__mdt>();
        
        Boolean areThereNameMetadataSetting = false;
        if(spamValues != null && spamValues.size() >0 ){
            
            nameStrip = orderByLengthSingleCategory('Name', spamValues);
            system.debug('spamValues '+spamValues);
            if(nameStrip.size() > 0 ){
                areThereNameMetadataSetting = true;
            }
            
            system.debug(json.serializePretty(nameStrip));
            if(areThereNameMetadataSetting){
                for(Transitional_Record__c tran : transRecs){
                    boolean isSpam = false;
                    //System.debug('Company name');
                    if(tran.Company_Name__c != null && tran.Company_Name__c != '' ){
                        string strippedCompanyName =  stripSpacesAndSpam(tran.Company_Name__c,nameStrip );
                        
                        tran.Stripped_Company_Name__c = strippedCompanyName;
                    }
                    //System.debug('First name');
                    if(tran.First_Name__c != null && tran.First_Name__c != '' ){
                        string strippedFirstName =  stripSpacesAndSpam(tran.First_Name__c,nameStrip );
                        
                        
                        tran.Stripped_Individual_Name__c = strippedFirstName;
                    }
                    
                    //System.debug('Last name');
                    if(tran.Surname_Field_1__c != null && tran.Surname_Field_1__c != '' ){
                        string strippedLastName =  stripSpacesAndSpam(tran.Surname_Field_1__c,nameStrip );
                        
                        if( tran.Stripped_Individual_Name__c != null){
                            tran.Stripped_Individual_Name__c =   tran.Stripped_Individual_Name__c+strippedLastName;
                        }else{
                            tran.Stripped_Individual_Name__c =   strippedLastName;
                        }
                        
                    }
                    
                }
                
            }
            
            
        }
        
        
        return transRecs;
    }
    
    public List<Dispensable_Value__mdt> orderByLengthSingleCategory(String category, List<Dispensable_Value__mdt> spamValues){
        List<Dispensable_Value__mdt> nameStrip = new List<Dispensable_Value__mdt>();
        List<LengthSorter> wrappers = new List<LengthSorter>();
        for (Dispensable_Value__mdt disp : spamValues){
            wrappers.add(new LengthSorter(disp));
        }         
        wrappers.sort();         
        
        for(LengthSorter disp : wrappers){
            
            if(disp.record.Category__c != null &&  disp.record.Category__c  == category){
                nameStrip.add(disp.record);
                
                
            }
            
            
        }
        return nameStrip;
    }
    
    Public string stripSpacesAndSpam(string Name, List<Dispensable_Value__mdt> nameStrip){
        if(Name != null && Name != ''){
            Name =  Name.replaceAll( '\\s+', '');
            if(nameStrip != null && nameStrip.size() > 0){
                integer order = 0;
                for(Dispensable_Value__mdt spam : nameStrip){
                    order++;
                    system.debug('stripping order '+order+spam.Label);
                    if(spam.label != null && Name.contains(spam.label.replaceAll( '\\s+', ''))){
                        system.debug('the name '+Name+' found '+spam.Label);
                        Name = Name.replaceAll(spam.label.replaceAll( '\\s+', ''), '');
                        
                    }
                }
            }
        }      
        
        
        return Name;
    }
    public boolean isEmailSpam(String emailAddress, List<Dispensable_Value__mdt> partialEmailStrip,  List<Dispensable_Value__mdt> fullEmailStrip){
        boolean isSpam = false;
        if(emailAddress != null && emailAddress != '' ){
            if(partialEmailStrip != null && partialEmailStrip.size() > 0){
                for(Dispensable_Value__mdt spam : partialEmailStrip){
                    if(emailAddress.contains(spam.label)){
                        isSpam = true;
                        break;
                    }
                }
            }
            if(!isSpam && fullEmailStrip != null && fullEmailStrip.size() > 0){
                for(Dispensable_Value__mdt spam : fullEmailStrip){
                    if(emailAddress.contains(spam.label)){
                        isSpam = true;
                        break;
                    }
                }
            }
            
        }
        
        return isSpam;
        
    }
}