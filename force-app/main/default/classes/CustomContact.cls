public class CustomContact extends CustomSObject {
    public static final Schema.DescribeFieldResult FirstNameDescription = Contact.FirstName.getDescribe();
    public static final Schema.DescribeFieldResult PhoneDescription = Contact.Phone.getDescribe();
    public static final Schema.DescribeFieldResult EmailDescription = Contact.Email.getDescribe();
    public static final Schema.DescribeFieldResult MobilePhoneDescription = Contact.MobilePhone.getDescribe();
    public static final Schema.DescribeFieldResult AccountIdDescription = Contact.AccountId.getDescribe();
    
    
    public final CustomSObjectField FirstName { get; private set; }
    public final CustomSObjectField Phone { get; private set; }
    public final CustomSObjectField Email { get; private set; }
    public final CustomSObjectField MobilePhone { get; private set; }
    public final CustomSObjectField AccountId { get; private set; }
    
    
    public CustomContact()
    {
    	this.FirstName = this.AddField(FirstNameDescription);
    	this.Phone = this.AddField(PhoneDescription);
    	this.Email = this.AddField(EmailDescription);
    	this.MobilePhone = this.AddField(MobilePhoneDescription);
    	this.AccountId = this.AddField(AccountIdDescription);
    }
}