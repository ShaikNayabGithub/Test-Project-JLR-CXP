public class CustomLead extends CustomSObject {
    //public static final Schema.DescribeFieldResult PersonHomePhoneDescription = Lead.HomePhone.getDescribe();
    public static final Schema.DescribeFieldResult FirstNameDescription = Contact.FirstName.getDescribe();
    public static final Schema.DescribeFieldResult PhoneDescription = Lead.Phone.getDescribe();
    public static final Schema.DescribeFieldResult MobilePhoneDescription = Lead.MobilePhone.getDescribe();
    public static final Schema.DescribeFieldResult EmailDescription = Lead.Email.getDescribe();
    
    
    //public final CustomSObjectField PersonHomePhone { get; private set; }
    public final CustomSObjectField FirstName { get; private set; }
    public final CustomSObjectField Phone { get; private set; }
    public final CustomSObjectField MobilePhone { get; private set; }
    public final CustomSObjectField Email { get; private set; }
    
    
    public CustomLead()
    {
      //this.HomePhone = this.AddField(PersonHomePhoneDescription);
      this.FirstName = this.AddField(FirstNameDescription);
      this.Phone = this.AddField(PhoneDescription);
      this.MobilePhone = this.AddField(MobilePhoneDescription);
      this.Email = this.AddField(EmailDescription);
    }
}