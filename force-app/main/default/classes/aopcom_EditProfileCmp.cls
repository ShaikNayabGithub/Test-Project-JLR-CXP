public without sharing class aopcom_EditProfileCmp {
    
    @auraEnabled
    public static String getPortraitURL(){
        //String portraitURL;
        String firstName ='';
        String lastName='';
        String country='';
        String email='';
        String phone='';
        String mobilePhone='';
        String street='';
        String city='';
        String state='';
        String postalCode='';
        String portraitData='';
        Id relatedContact;
        Id idAttachment;
     	//It takes an identifier contact that is related to an user
       	List<User> userList =[SELECT ContactId FROM User WHERE Id=: UserInfo.getUserId() limit 1]; 
        //If userList is not null and its size is greater than 0, we are going in
        if(userList !=null && userList.size()>0){   
            System.debug('+++++++++++++ CONTACT ID FOR USER '+ userList.get(0).ContactId);
            User user=userList.get(0);  
            relatedContact=user.ContactId;
            //It creates a contact that is related to the previous user
            List<Contact> contactList=[Select Email,FirstName,HomePhone,LastName,MailingCity,MailingPostalCode,MailingState,MailingStreet,MobilePhone,aopcom_contactPortrait__c From Contact Where Id=:relatedContact];
            //If contactList is not null and its size is greater than 0, we are going in
            if(contactList !=null && contactList.size()>0){	
                Contact contact=contactList.get(0);
    
            	//If FirstName of Contact is not null, we are going in
                if (Contact.FirstName!=null){
                    System.debug('+++++++++++++ CONTACT FIRSTNAME '+ Contact.FirstName);
                    firstName=contact.FirstName;
                    }
                    
                //If LastName of Contact is not null, we are going in
                if (Contact.LastName!=null){
                    System.debug('+++++++++++++ CONTACT LASTNAME '+ Contact.LastName);
                    lastName=contact.LastName;
                    }
                    
        		//If Email of Contact is not null, we are going in
                if (Contact.Email!=null){
                    System.debug('+++++++++++++ CONTACT EMAIL '+ Contact.Email);
                    email=contact.Email;
                    }
                    
                //If HomePhone of Contact is not null, we are going in
                if (Contact.HomePhone!=null){
                    System.debug('+++++++++++++ CONTACT HOMEPHONE '+ Contact.HomePhone);
                    phone=contact.HomePhone;
                    }
                    
                //If MobilePhone of Contact is not null, we are going in
                if (Contact.MobilePhone!=null){
                   System.debug('+++++++++++++ CONTACT MOBILE PHONE '+ Contact.MobilePhone);
                    mobilephone=contact.MobilePhone;
                    }
                    
                //If MailingStreet of Contact is not null, we are going in
                if (Contact.MailingStreet!=null){
					System.debug('+++++++++++++ CONTACT MAILING STREET '+ Contact.MailingStreet);
                    street=contact.MailingStreet;
                    }
                    
        		//If MailingCity of Contact is not null, we are going in
                if (Contact.MailingCity!=null){
					System.debug('+++++++++++++ CONTACT MAILING CITY '+ Contact.MailingCity);
                    city=contact.MailingCity;
                    }
                    
                //If MailingState of Contact is not null, we are going in
                if (Contact.MailingState!=null){
                    System.debug('+++++++++++++ CONTACT MAILING STATE '+ Contact.MailingState);
                    state=contact.MailingState;
                    }
                    
              	//If MailingPostalCode of Contact is not null, we are going in       
                if (Contact.MailingPostalCode!=null){
                    System.debug('+++++++++++++ CONTACT MAILING POSTAL CODE '+ Contact.MailingPostalCode);
                    postalCode=contact.MailingPostalCode;
                 }
               /* List<Attachment> att=[SELECT parentId, body, name, contentType FROM Attachment WHERE parentId=:contact.Id];
                if(att!=null && att.size()>0){
                    System.debug('+++++++++++++ ID ATTACHMENT '+ att.get(0).Id);
                    idAttachment=att.get(0).Id;
                }*/
                if(contact.aopcom_contactPortrait__c!=null){
                    System.debug('+++++++++++++ CONTACT PORTRAIT DATA: '+contact.aopcom_contactPortrait__c);
                    portraitData=contact.aopcom_contactPortrait__c;
                }
              }
           }
        	
            //return portraitURL+'#'
        return firstName+'#'+lastName+'#'+email+'#'+phone+'#'+mobilePhone+'#'+street+'#'+city+'#'+state+'#'+postalCode+'#'+relatedContact+'#'+idAttachment+'#'+Site.getPathPrefix()+'#'+portraitData;
    }
  		
    @auraEnabled
    public static void sendData(String firstnameIn, String lastnameIn, String countryIn, String emailaddressIn, 
                                String landlineIn, String mobilenumberIn, String streetIn, String townIn, String stateIn, 
                                String postcodeIn, String portraitURL)
    {
        
        
        try {
            // Query for the contact, which has been associated with an account.
            List<User> userList2 =[SELECT ContactId
                                   FROM User 
                                   WHERE Id=: UserInfo.getUserId()
                                   limit 1];
            
            Id relatedContact=userList2.get(0).ContactId;  
            
            
            
            Contact queriedContact = [Select Email,FirstName,HomePhone,LastName,MailingCity,MailingPostalCode,MailingState,MailingStreet,MobilePhone,aopcom_contactPortrait__c 
                                      From Contact 
                                      Where Id=:relatedContact
                                      limit 1];
            
            
            queriedContact.FirstName = firstnameIn;               
            queriedContact.LastName=lastnameIn;
            queriedContact.MailingCity = townIn;
            queriedContact.Email= emailaddressIn;                 
            queriedContact.MobilePhone = mobilenumberIn;
            queriedContact.HomePhone = landlineIn;
            queriedContact.MailingPostalCode= postcodeIn;
            queriedContact.MailingState = stateIn;
            queriedContact.MailingStreet= streetIn;
            queriedContact.aopcom_contactPortrait__c=portraitURL;
            
            //This is the call
            update queriedContact;
            

        }
        //It launches the error message
        catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
        
    }
    
    
    @AuraEnabled
    public static Attachment getProfilePicture(Id parentId) {

        // Attachment permissions are set in parent object (Contact)
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
            return null;
        }
 
        return [SELECT Id, Name, LastModifiedDate, ContentType FROM Attachment 
            WHERE parentid=:ParentId AND ContentType IN ('image/png', 'image/jpeg', 'image/gif') 
            ORDER BY LastModifiedDate DESC LIMIT 1];
    }
    
    @AuraEnabled
    public static void saveAttachment(String parentId, String fileName, String base64Data, String contentType) { 
        
        
        
        /*System.debug('++++++++++ fileName: '+fileName);
        System.debug('++++++++++ contentType: '+contentType);
        System.debug('++++++++++ base64Data: '+base64Data);
        System.debug('++++++++++ fileName: '+fileName);
        ConnectApi.BinaryInput binput=new ConnectApi.BinaryInput(Blob.valueOf(base64Data),contentType,fileName); 
        System.debug('++++++++++ Binary Input Blob: '+String.valueOf(binput));
        System.debug('++++++++++ NetworkId: '+Network.getNetworkId());
        System.debug('++++++++++ User Id: '+UserInfo.getUserId());
        ConnectApi.Photo photo= ConnectApi.UserProfiles.setPhoto(Network.getNetworkId(),UserInfo.getUserId(),binput);
        System.debug('+++++++++++++Photo URL: '+photo.largePhotoUrl);
        */
        
        /*Attachment attachment;
        try{
        System.debug('**********Inicio saveAttachment***********');
        // Edit permission on parent object (Contact) is required to add attachments
        if (!Schema.sObjectType.Contact.isUpdateable()) {
            System.debug('**********Contacto no es updateable***********');
            throw new System.NoAccessException();
            return null;
        }
		
		//Consultar y ver si ya existe, en caso contrario inserto. Si updateo actualizo body y contentType
		List<Attachment> att=[SELECT parentId, body, name, contentType FROM Attachment WHERE parentId=:parentId];
        if(att!=null && att.size()>0){
            System.debug('**********Hay attachments***********');
        	    attachment=att.get(0);
            	delete attachment;
            System.debug('**********Attachments borrados***********');
            	attachment = new Attachment();
                attachment.parentId = Id.valueOf(parentId);
                attachment.body = EncodingUtil.base64Decode(base64Data);
                attachment.name = fileName;
                attachment.contentType = contentType;
            	
            	insert attachment;
            System.debug('**********Attachments insertados***********');
        }else{
            	System.debug('**********No hay attachments***********');
                attachment = new Attachment();
                attachment.parentId = Id.valueOf(parentId);
                attachment.body = EncodingUtil.base64Decode(base64Data);
                attachment.name = fileName;
                attachment.contentType = contentType;
                insert attachment;    
        }
        
        }catch(Exception e) {
    			System.debug('An unexpected error has occurred: ' + e.getMessage());
		}
        return attachment.Id;*/
    }



    	
    	/*@auraEnabled
		public static void sendPhoto(String ImageIn)
        {
            User queriedUser =[SELECT FullPhotoUrl FROM User WHERE Id=: UserInfo.getUserId() limit 1];
                 
            	queriedUser.email = ImageIn;
         	
    			
                 system.debug('Mi imagen'+ImageIn);
				 
                 update queriedUser;
        }*/
    
}