@isTest
public class QueueNameCreator_T {
    static testMethod void BuildQueueName_ReturnsJLRJapan_GivenAccountJaguarLandRoverJapan() 
    {
    	QueueNameCreator queueNameCreator = new QueueNameCreator();
    	
    	Account input = new Account(Name='Jaguar Land Rover Japan Kabushiki Kaisha',
    		BillingCity='Tokyo',
			Dealer_CI_Code__c='322111',
			Dealer_CI_Code_2__c='456789');
    	
    	String result = queueNameCreator.BuildQueueName(input);
    	
    	//horrible method of escaping characters required due to Apex's horrible/broken way of comaring strings containing backslashes
    	Blob resultEscaped = EncodingUtil.base64Decode(result);
    	Blob expectedEscaped = EncodingUtil.base64Decode('JLR Japan Kabushiki Tokyo 322111/456789');
    	
    	System.AssertEquals(expectedEscaped, resultEscaped);
    }
    
    static testMethod void BuildQueueName_ReturnsATDubai_GivenAccountATDubai() 
    {
    	QueueNameCreator queueNameCreator = new QueueNameCreator();
    	
    	Account input = new Account(Name='Al Tayer Motors',
    		BillingCity='Dubai',
			Dealer_CI_Code__c='222111',
			Dealer_CI_Code_2__c='654222');
    	
    	String result = queueNameCreator.BuildQueueName(input);
    	
    	//horrible method of escaping characters required due to Apex's horrible/broken way of comaring strings containing backslashes
    	Blob resultEscaped = EncodingUtil.base64Decode(result);
    	Blob expectedEscaped = EncodingUtil.base64Decode('Al Tayer Motors Dubai 222111/654222');
    	
    	System.AssertEquals(expectedEscaped, resultEscaped);
    }
    
    static testMethod void BuildQueueName_ReturnsEuroMotors_GivenAccountEuroMotors() 
    {
    	QueueNameCreator queueNameCreator = new QueueNameCreator();
    	
    	Account input = new Account(Name='Euro Motors Sao Jose do Rio Preto',
    		BillingCity='Sao Jose do Rio Preto',
			Dealer_CI_Code__c='023445');
    	
    	String result = queueNameCreator.BuildQueueName(input);
    	
    	//horrible method of escaping characters required due to Apex's horrible/broken way of comaring strings containing backslashes
    	Blob resultEscaped = EncodingUtil.base64Decode(result);
    	Blob expectedEscaped = EncodingUtil.base64Decode('Euro Motors Sao Jose d Sao Jose d 023445');
    	
    	System.AssertEquals(expectedEscaped, resultEscaped);
    }
    
    static testMethod void BuildQueueName_ReturnsCDA_GivenAccountCDA() 
    {
    	QueueNameCreator queueNameCreator = new QueueNameCreator();
    	
    	Account input = new Account(Name='Comercializadora Ditec Automotives S.A.',
    		BillingCity='Santiago',
			Dealer_CI_Code__c='355542',
			Dealer_CI_Code_2__c='355542');
    	
    	String result = queueNameCreator.BuildQueueName(input);
    	
    	//horrible method of escaping characters required due to Apex's horrible/broken way of comaring strings containing backslashes
    	Blob resultEscaped = EncodingUtil.base64Decode(result);
    	Blob expectedEscaped = EncodingUtil.base64Decode('Comercializadora Ditec A Santiago 355542');
    	
    	System.AssertEquals(expectedEscaped, resultEscaped);
    }
    
    static testMethod void BuildQueueName_ReturnsShipstone_GivenAccountShipstone() 
    {
    	QueueNameCreator queueNameCreator = new QueueNameCreator();
    	
    	Account input = new Account(Name='Shipstone',
			Dealer_CI_Code__c='355542',
			Dealer_CI_Code_2__c='355542');
    	
    	String result = queueNameCreator.BuildQueueName(input);
    	
    	//horrible method of escaping characters required due to Apex's horrible/broken way of comaring strings containing backslashes
    	Blob resultEscaped = EncodingUtil.base64Decode(result);
    	Blob expectedEscaped = EncodingUtil.base64Decode('Shipstone 355542');
    	
    	System.AssertEquals(expectedEscaped, resultEscaped);
    }
}