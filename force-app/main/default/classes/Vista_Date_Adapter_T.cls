@isTest
public class Vista_Date_Adapter_T {
	static testmethod void Parse_ReturnsEmptyDate_GivenEmptyString()
	{
		Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();

		String input = '';

		Date result = dateAdapter.Parse(input);

		System.assertEquals(Date.newInstance(0, 0, 0), result);
	}

	static testmethod void Parse_Returns15May2018_Given18Dash05Dash15()
	{
		Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();

		String input = '2018-05-15';

		Date result = dateAdapter.Parse(input);

		System.assertEquals(Date.newInstance(2018, 5, 15), result);
	}

	static testmethod void Parse_Returns15May2018_Given18Dash05Dash15T14abcdefg()
	{
		Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();

		String input = '2018-05-15T14abcdefg';

		Date result = dateAdapter.Parse(input);

		System.assertEquals(Date.newInstance(2018, 5, 15), result);
	}
}