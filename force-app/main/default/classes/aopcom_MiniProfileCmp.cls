public with sharing class aopcom_MiniProfileCmp {

    @auraEnabled
    public static String getPortraitURL(){
        
        String portraitURL;
        String name='';
        String lname='';
        String country;
        Id idAttachment;
        //It takes an identifier contact that is related to an user
        List<User> userList =[SELECT ContactId  FROM User WHERE Id=: UserInfo.getUserId() limit 1]; 
        //It creates a contact that is related to the previous user
        List<Contact> contactList =[SELECT aop_Country__c,FirstName,aopcom_contactPortrait__c,LastName  FROM Contact WHERE Id=: userList.get(0).ContactId limit 1];
        Contact contact=contactList.get(0);
        
        /*List<Attachment> att=[SELECT parentId, body, name, contentType FROM Attachment WHERE parentId=:contact.Id];
        if(att!=null && att.size()>0){
            idAttachment=att.get(0).Id;
        }
        
        if(contact.PhotoUrl!=null){
        	portraitURL=contact.PhotoUrl;
        }else{
            portraitURL=' ';
        }*/
        List<Network> coms=[SELECT Id FROM Network WHERE Name='TAoP'];
        
        /*ConnectApi.Photo photo=ConnectApi.UserProfiles.getPhoto(coms.get(0).Id, UserInfo.getUserId());
        System.debug('++++++++ Photo fullEmailPhotoUrl: '+photo.fullEmailPhotoUrl);
        System.debug('++++++++ Photo largePhotoUrl: '+photo.largePhotoUrl);
        System.debug('++++++++ Photo photoVersionId: '+photo.photoVersionId);
        System.debug('++++++++ Photo smallPhotoUrl'+photo.smallPhotoUrl);
        System.debug('++++++++ Photo standardEmailPhotoUrl'+photo.standardEmailPhotoUrl);
        System.debug('++++++++ Photo url'+photo.url);*/

        portraitURL=contact.aopcom_contactPortrait__c;
        
        if(portraitURL==null){
            portraitURL='';
        }
        //If the FirstName of the contact is not null, we are going in
        if(contact.FirstName !=null){
        	name=contact.FirstName; //+' '+contact.LastName;
        }
        //If the LastName of the contact is not null, we are going in
        if(contact.LastName !=null){
            lname=contact.LastName;
        }
        //if the aop_Country of the contact is not null, we are going in
        if (contact.aop_Country__c!=null){
        	country=contact.aop_Country__c;
        	}
        	else country=' ';
        System.debug('++++++++ Photo url'+portraitURL);
        return portraitURL+'#'+name+'#'+lname+'#'+country+'#'+Site.getPathPrefix();
    }
}