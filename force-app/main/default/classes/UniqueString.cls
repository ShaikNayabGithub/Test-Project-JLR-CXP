public class UniqueString {
    public static string CreateNew()
    {
    	Blob aes = Crypto.generateAesKey(128);
        return EncodingUtil.convertToHex(aes);
    }
}