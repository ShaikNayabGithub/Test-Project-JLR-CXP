@isTest
public class TestClass_ValidContactBuilder {
    public static Contact Build(Account account)
    {
    	Contact contact = new Contact();
    	
    	if(account != null) {//very horrible, temp. fix for DMSMessager_India_Update_Test and DMSOutbound_ResponseProcessor_Test
    		contact.AccountId = account.Id;
    	}
    	contact.LastName = 'testLastName';
        contact.Email = 'test@email.com';
        contact.MailingState = 'testState';
        contact.MailingPostalCode = 'testCode';
        contact.MailingCountry = 'testCountry';
    	
    	insert contact;
    	return contact;
    }
    
    public static Contact Build()
    {
    	Contact contact = new Contact();
    	
    	contact.LastName = 'testLastName';
        contact.Email = 'test@email.com';
    	
    	insert contact;
    	return contact;
    }

	public static List<Contact> createContactsList()
	{
		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < 10; i++)
		{
			Contact con = new Contact(FirstName = 'Test' + i, LastName = 'Test' + i, Email = 'test' + i + '@test.com');
			contacts.add(con);
		}
		insert contacts;
		return contacts;
	}

}