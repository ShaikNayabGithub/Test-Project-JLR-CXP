public without sharing class SiteCrypto {

	private static final String JDAAN_ENCRYPTION_KEY_NAME = 'Judaan Site';
	private static final Blob JDAAN_INITIALIZATIONVECTOR = Blob.valueOf('udaan vector key');

	private static Blob CryptoKey{
		get{
			if(CryptoKey != null) return CryptoKey;

			//attempt to load key from database
			List<DMS_Connection__c> cryptoRecord = [SELECT Password__c FROM DMS_Connection__c WHERE Name =: JDAAN_ENCRYPTION_KEY_NAME];

			if(cryptoRecord.size() > 0){
				CryptoKey = EncodingUtil.base64Decode(cryptoRecord[0].Password__c);
			}
			else{
				//Create new key is none exists
				CryptoKey = CreateEncryptionKey();
			}
			 
			 return CryptoKey;
		}	
		set;
	}

	private static Blob CreateEncryptionKey(){
		DMS_Connection__c newKey = new DMS_Connection__c();
		Blob key = Crypto.generateAesKey(128);		
		newKey.Password__c = EncodingUtil.base64Encode(key);
		newKey.Name = JDAAN_ENCRYPTION_KEY_NAME;
		insert newKey;
		return key;
	}

	public static String EncryptIdHex(ID value){
		if(value == null) return null;

		Blob encrypted = Crypto.encrypt('AES128', CryptoKey, JDAAN_INITIALIZATIONVECTOR, Blob.valueOf(value));
		return EncodingUtil.convertToHex(encrypted);
	}

	public static ID DecryptIdHex(String value){
		try{
			Blob encryptedValue = EncodingUtil.convertFromHex(value);
			Blob decrypted = Crypto.decrypt('AES128', CryptoKey, JDAAN_INITIALIZATIONVECTOR, encryptedValue);
			return ID.valueOf(decrypted.toString());
		}
		catch (Exception ex){
			return null;
		}
	}

}