package egovframework.sejong.util;

import java.util.Base64;

public class SeedUtil {
	// SEED 암호화 키 (16바이트 = 128비트)
    private static final String SEED_KEY = "allcareseed02024"; // 
    private static final String pbszIV = "42020deeseraclla"; // 
    // 암호화 함수
    public static String encrypt(String data) throws Exception {
        byte[] encryptedMessage = KISA_SEED_CBC.SEED_CBC_Encrypt(SEED_KEY.getBytes(), pbszIV.getBytes(), data.getBytes(), 0, data.getBytes().length);
        return Base64.getEncoder().encodeToString(encryptedMessage);
    }

    // 복호화 함수
    public static String decrypt(String encryptedData) throws Exception {
    	byte[] encryptChar = Base64.getDecoder().decode(encryptedData);
        byte[] decryptedMessage = KISA_SEED_CBC.SEED_CBC_Decrypt(SEED_KEY.getBytes(), pbszIV.getBytes(), encryptChar, 0, encryptChar.length);        
        return new String(decryptedMessage);
    }
}
