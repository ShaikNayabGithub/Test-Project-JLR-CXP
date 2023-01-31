public class DealerDb_AccountMandatoryFieldsRule implements DealerDb_AccountValidationRule_I{
	public void Validate(DealerDBService.RetailerAccount retailerAccount)
	{
		string offendingField = '';
		if(string.isEmpty(retailerAccount.Dealer_CI_Code)){
			offendingField += 'Dealer_CI_Code, ';
		}
		if(string.isEmpty(retailerAccount.Brand)){
			offendingField += 'Brand, ';
		}
		if(string.isEmpty(retailerAccount.ISOCode)){
			offendingField += 'ISOCode, ';
		}
		if(string.isEmpty(retailerAccount.Distribution_Code)){
			offendingField += 'Distribution_Code, ';
		}
		if(string.isEmpty(retailerAccount.Name)){
			offendingField += 'Name, ';
		}
		if(string.isEmpty(retailerAccount.Retailer_Type)){
			offendingField += 'Retailer_Type, ';
		}
		if(string.isEmpty(retailerAccount.Trading_Name)){
			offendingField += 'Trading_Name, ';
		}
		if(string.isEmpty(retailerAccount.Trading_Partner_Type)){
			offendingField += 'Trading_Partner_Type, ';
		}

		if(string.isNotEmpty(offendingField)){
			string exceptionMessage = String.format(System.Label.DealerDBException_MissingField, new List<String> {offendingField});
			throw new DealerDB_InvalidDataException(exceptionMessage);
		}
	}
}