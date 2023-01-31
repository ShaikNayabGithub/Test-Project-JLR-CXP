@isTest
public class DMS_PrefixHandler_Test {
	static testmethod void RemovePrefix_ReturnsBody_GivenStringBodyAndPrefixTest()
	{
		DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('test');
		string input = 'body';

		string result = prefixHandler.RemovePrefix(input);

		System.assertEquals(input, result);
	}

	static testmethod void RemovePrefix_ReturnsBody_GivenStringTestBodyAndPrefixTest()
	{
		string prefix = 'test';
		DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler(prefix);
		string inputBody = 'body';

		string result = prefixHandler.RemovePrefix(prefix + inputBody);

		System.assertEquals(inputBody, result);
	}

	static testmethod void AddPrefix_ReturnsTestBody_GivenStringBodyAndPrefixTest()
	{
		string prefix = 'test';
		DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler(prefix);
		string inputBody = 'body';

		string result = prefixHandler.AddPrefix(inputBody);

		System.assertEquals(prefix + inputBody, result);
	}
}