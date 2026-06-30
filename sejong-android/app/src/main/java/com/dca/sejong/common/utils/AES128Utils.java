package com.dca.sejong.common.utils;

import android.text.TextUtils;
import android.util.Base64;

import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.NoSuchAlgorithmException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.SecretKeySpec;

public class AES128Utils {

    private static final byte[] keyValue = new byte[] { 'L', 'H', 'H', 'e', 'a', 'l', 't', 'h', 'C', 'a', 'r', 'e', '1', '2','!','@'};


    private Key keySpec;

    public AES128Utils() throws UnsupportedEncodingException {
        SecretKeySpec keySpec = new SecretKeySpec(keyValue, "AES");
        this.keySpec = keySpec;
    }


    // 암호화
    public String aesEncode(String str) throws UnsupportedEncodingException, NoSuchAlgorithmException,
            NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException,
            IllegalBlockSizeException, BadPaddingException {


        Cipher c = Cipher.getInstance("AES");
        c.init(Cipher.ENCRYPT_MODE, keySpec);

        byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
        String enStr = Base64.encodeToString(encrypted, Base64.DEFAULT);

/*
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(keyValue));

        byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
        String enStr = Base64.encodeToString(encrypted, Base64.DEFAULT);
*/

        return enStr;
    }

    //복호화
    public String aesDecode(String str) throws UnsupportedEncodingException, NoSuchAlgorithmException,
            NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException,
            IllegalBlockSizeException, BadPaddingException {

        byte[] byteStr = Base64.decode(str.getBytes("UTF-8"), Base64.DEFAULT);

        Cipher c = Cipher.getInstance("AES");
        c.init(Cipher.DECRYPT_MODE, keySpec);
/*
        byte[] byteStr = Base64.decode(str.getBytes("UTF-8"), Base64.DEFAULT);

        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(keyValue));
*/
        return new String(c.doFinal(byteStr),"UTF-8");
    }

    public static String decodeAES(String str){
        String decodeStr = "";

        if(!TextUtils.isEmpty(str)){
            try {
                decodeStr = new AES128Utils().aesDecode(str);
            } catch (UnsupportedEncodingException e) {
                Logs.printException(e);
            } catch (NoSuchAlgorithmException e) {
                Logs.printException(e);
            } catch (NoSuchPaddingException e) {
                Logs.printException(e);
            } catch (InvalidKeyException e) {
                Logs.printException(e);
            } catch (InvalidAlgorithmParameterException e) {
                Logs.printException(e);
            } catch (IllegalBlockSizeException e) {
                Logs.printException(e);
            } catch (BadPaddingException e) {
                Logs.printException(e);
            }
        }

        return decodeStr;
    }

    public static String encodeAES(String str){
        String endcodeStr = "";
        if(!TextUtils.isEmpty(str)){
            try {
                endcodeStr = new AES128Utils().aesEncode(str);
            } catch (UnsupportedEncodingException e) {
                Logs.printException(e);
            } catch (NoSuchAlgorithmException e) {
                Logs.printException(e);
            } catch (NoSuchPaddingException e) {
                Logs.printException(e);
            } catch (InvalidKeyException e) {
                Logs.printException(e);
            } catch (InvalidAlgorithmParameterException e) {
                Logs.printException(e);
            } catch (IllegalBlockSizeException e) {
                Logs.printException(e);
            } catch (BadPaddingException e) {
                Logs.printException(e);
            }
        }

        return endcodeStr;
    }
}

