@IsTest
private class MatchingAccountAttributeDtoTest {

    @IsTest
    static void testAccounSorting() {
        MatchingAccountAttributeDto first = new MatchingAccountAttributeDto();
        first.Id = '1';
        first.AccountName = 'First';
        first.MatchScore = 1;

        MatchingAccountAttributeDto second = new MatchingAccountAttributeDto();
        second.Id = '2';
        second.AccountName = 'Second';
        second.MatchScore = 2;

        List<MatchingAccountAttributeDto> accounts = new List<MatchingAccountAttributeDto> { first, second };
        accounts.sort();

        System.assertEquals(first.Id, accounts.get(0).Id);
    }

    @IsTest
    static void testContactsSorting() {
        MatchingContactAttributeDto firstContact = new MatchingContactAttributeDto();
        firstContact.Id = '1';
        firstContact.MatchScore = 1;

        MatchingContactAttributeDto secondContact = new MatchingContactAttributeDto();
        secondContact.Id = '2';
        secondContact.MatchScore = 2;

        MatchingAccountAttributeDto account = new MatchingAccountAttributeDto();
        account.Id = '1';
        account.AccountName = 'First';
        account.MatchScore = 1;
        account.Contacts = new List<MatchingContactAttributeDto> { firstContact, secondContact };

        account.OrderContactsByMatchScore();

        System.assertEquals(firstContact.Id, account.Contacts.get(0).Id);
        System.assertEquals(firstContact.MatchScore, account.GetContactsBestMatchScore());
    }
}