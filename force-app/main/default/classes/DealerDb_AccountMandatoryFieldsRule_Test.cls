@isTest
public class DealerDb_AccountMandatoryFieldsRule_Test {
	static testMethod void Validate_DoesNotThrowException_GivenValidAccount() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, false);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyDealer_CI_Code() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.Dealer_CI_Code = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyBrand() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.Brand = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyISOCode() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.ISOCode = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyDistribution_Code() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.Distribution_Code = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyName() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.Name = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyRetailer_Type() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.Retailer_Type = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyTrading_Name() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.Trading_Name = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}

	static testMethod void Validate_ThrowsException_GivenEmptyTrading_Partner_Type() {
		DealerDb_AccountMandatoryFieldsRule validationRule = new DealerDb_AccountMandatoryFieldsRule();
		DealerDBService.RetailerAccount account = BuildValidAccount();
		account.Trading_Partner_Type = '';

		TestClass_DealerDbAccountValidatorTest.RunValidationTest(validationRule, account, true);
	}
	

	private static DealerDBService.RetailerAccount BuildValidAccount()
	{
		DealerDBService.RetailerAccount account = new DealerDBService.RetailerAccount();

		account.Dealer_CI_Code = 'test';
		account.Brand = 'test';
		account.ISOCode = 'test';
		account.Distribution_Code = 'test';
		account.Name = 'test';
		account.Retailer_Type = 'test';
		account.Trading_Name = 'test';
		account.Trading_Partner_Type = 'test';

		return account;
	}
}