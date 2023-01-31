@isTest
public class SearchFirstSearchParameters_Test {
    static testmethod void Clear_SetsFirstNameToEmpty_WhenCalled()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	searchFirstSearchParameters.FirstName = 'test';
    	
    	searchFirstSearchParameters.Clear();
    	
    	System.assert(String.isEmpty(searchFirstSearchParameters.FirstName));
    }
    
    static testmethod void Clear_SetsLastNameToEmpty_WhenCalled()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	searchFirstSearchParameters.LastName = 'test';
    	
    	searchFirstSearchParameters.Clear();
    	
    	System.assert(String.isEmpty(searchFirstSearchParameters.LastName));
    }
    
    static testmethod void Clear_SetsCompanyNameToEmpty_WhenCalled()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	searchFirstSearchParameters.CompanyName = 'test';
    	
    	searchFirstSearchParameters.Clear();
    	
    	System.assert(String.isEmpty(searchFirstSearchParameters.CompanyName));
    }
    
    static testmethod void Clear_SetsPhoneToEmpty_WhenCalled()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	searchFirstSearchParameters.Phone = 'test';
    	
    	searchFirstSearchParameters.Clear();
    	
    	System.assert(String.isEmpty(searchFirstSearchParameters.Phone));
    }
    
    static testmethod void Clear_SetsEmailToEmpty_WhenCalled()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	searchFirstSearchParameters.Email = 'test';
    	
    	searchFirstSearchParameters.Clear();
    	
    	System.assert(String.isEmpty(searchFirstSearchParameters.Email));
    }
    
    static testmethod void Clear_SetsAssetIdentifierToEmpty_WhenCalled()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	searchFirstSearchParameters.AssetIdentifier = 'test';
    	
    	searchFirstSearchParameters.Clear();
    	
    	System.assert(String.isEmpty(searchFirstSearchParameters.AssetIdentifier));
    }
    
    static testmethod void IsEmpty_ReturnsTrue_WhenEmpty()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	System.assert(searchFirstSearchParameters.IsEmpty);
    }
    
    static testmethod void IsEmpty_ReturnsTrue_WhenOnlyRecordIdIsPopulated()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	searchFirstSearchParameters.RecordTypeId = 'test';
    	
    	System.assert(searchFirstSearchParameters.IsEmpty);
    }
    
    static testmethod void IsEmpty_ReturnsFalse_WhenOnlyFirstNameIsPopulated()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	searchFirstSearchParameters.FirstName = 'test';
    	
    	System.assert(!searchFirstSearchParameters.IsEmpty);
    }
    
    static testmethod void IsEmpty_ReturnsFalse_WhenOnlyLastNameIsPopulated()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	searchFirstSearchParameters.LastName = 'test';
    	
    	System.assert(!searchFirstSearchParameters.IsEmpty);
    }
    
    static testmethod void IsEmpty_ReturnsFalse_WhenOnlyCompanyNameIsPopulated()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	searchFirstSearchParameters.CompanyName = 'test';
    	
    	System.assert(!searchFirstSearchParameters.IsEmpty);
    }
    
    static testmethod void IsEmpty_ReturnsFalse_WhenOnlyPhoneIsPopulated()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	searchFirstSearchParameters.Phone = 'test';
    	
    	System.assert(!searchFirstSearchParameters.IsEmpty);
    }
    
    static testmethod void IsEmpty_ReturnsFalse_WhenOnlyEmailIsPopulated()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	searchFirstSearchParameters.Email = 'test';
    	
    	System.assert(!searchFirstSearchParameters.IsEmpty);
    }
    
    static testmethod void IsEmpty_ReturnsFalse_WhenOnlyAssetIdentifierIsPopulated()
    {
    	SearchFirstSearchParameters searchFirstSearchParameters = new SearchFirstSearchParameters();
    	
    	searchFirstSearchParameters.AssetIdentifier = 'test';
    	
    	System.assert(!searchFirstSearchParameters.IsEmpty);
    }
}