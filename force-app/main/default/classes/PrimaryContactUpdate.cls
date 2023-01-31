public class PrimaryContactUpdate {
    
    
    public void PostCreatePrimaryContact(List<Contact> contacts,  Set<Id> primaryContactsId){
        Map<Id, Contact> primaryContact = new Map<Id,Contact>([SELECT Id, Email,Email2__c,Email3__c, MobilePhone, OtherPhone, Phone FROM Contact WHERE Id in :primaryContactsId]); 
        List<Contact> conts = new List<Contact>();
        for(Contact con : contacts){
            Contact primCons = primaryContact.get(con.Primary_Contact__c);
            Boolean addUpdatePrimCon = false;
            ///////phone
            if(con.Phone != null){
                if(primCons.Phone == null ){
                    primCons.Phone = con.Phone;
                    addUpdatePrimCon = true;
                }else{
                    if( primCons.Phone != con.Phone){
                        if(primCons.MobilePhone == null ){
                            primCons.MobilePhone = con.Phone;
                            addUpdatePrimCon = true;
                        }else{
                            if(con.Phone != primCons.MobilePhone){
                                if(primCons.OtherPhone == null){
                                    primCons.OtherPhone = con.Phone;
                                    addUpdatePrimCon = true;
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            
            //////////MobilePhone
            
            if(con.MobilePhone != null){
                if(primCons.Phone == null ){
                    primCons.Phone = con.MobilePhone;
                    addUpdatePrimCon = true;
                }else{
                    if( primCons.Phone != con.MobilePhone){
                        if(primCons.MobilePhone == null ){
                            primCons.MobilePhone = con.MobilePhone;
                            addUpdatePrimCon = true;
                        }else{
                            if(con.MobilePhone != primCons.MobilePhone){
                                if(primCons.OtherPhone == null){
                                    primCons.OtherPhone = con.MobilePhone;
                                    addUpdatePrimCon = true;
                                }
                            }
                        }
                    }
                    
                }
                
            }
            ////////OtherPhone
            if(con.OtherPhone != null){
                if(primCons.Phone == null ){
                    primCons.Phone = con.OtherPhone;
                    addUpdatePrimCon = true;
                }else{
                    if( primCons.Phone != con.OtherPhone){
                        if(primCons.MobilePhone == null ){
                            primCons.MobilePhone = con.OtherPhone;
                            addUpdatePrimCon = true;
                        }else{
                            if(con.OtherPhone != primCons.MobilePhone){
                                if(primCons.OtherPhone == null){
                                    primCons.OtherPhone = con.OtherPhone;
                                    addUpdatePrimCon = true;
                                }
                            }
                        }
                    }
                    
                }
                
            }
            ////////
              ///////Email
            if(con.Email != null){
                if(primCons.Email == null ){
                    primCons.Email = con.Email;
                    addUpdatePrimCon = true;
                }else{
                    if( primCons.Email != con.Email){
                        if(primCons.Email2__c == null ){
                            primCons.Email2__c = con.Email;
                            addUpdatePrimCon = true;
                        }else{
                            if(con.Email != primCons.Email2__c){
                                if(primCons.Email3__c == null){
                                    primCons.Email3__c = con.Email;
                                    addUpdatePrimCon = true;
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            
          /////
                    ///////Email2
            if(con.Email2__c != null){
                if(primCons.Email == null ){
                    primCons.Email = con.Email2__c;
                    addUpdatePrimCon = true;
                }else{
                    if( primCons.Email != con.Email2__c){
                        if(primCons.Email2__c == null ){
                            primCons.Email2__c = con.Email2__c;
                            addUpdatePrimCon = true;
                        }else{
                            if(con.Email2__c != primCons.Email2__c){
                                if(primCons.Email3__c == null){
                                    primCons.Email3__c = con.Email2__c;
                                    addUpdatePrimCon = true;
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            
          /////
          //
                  ///////Email3
            if(con.Email3__c != null){
                if(primCons.Email == null ){
                    primCons.Email = con.Email3__c;
                    addUpdatePrimCon = true;
                }else{
                    if( primCons.Email != con.Email3__c){
                        if(primCons.Email2__c == null ){
                            primCons.Email2__c = con.Email3__c;
                            addUpdatePrimCon = true;
                        }else{
                            if(con.Email3__c != primCons.Email2__c){
                                if(primCons.Email3__c == null){
                                    primCons.Email3__c = con.Email3__c;
                                    addUpdatePrimCon = true;
                                }
                            }
                        }
                    }
                    
                }
                
            }
            
            
          /////
            if(addUpdatePrimCon){
                conts.add(primCons);
            }
            
        }
        update conts;
        
        
    }
    
}