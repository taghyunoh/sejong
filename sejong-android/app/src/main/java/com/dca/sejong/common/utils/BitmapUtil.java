package com.dca.sejong.common.utils;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.File;
import java.io.FileInputStream;

public class BitmapUtil {

    public static Bitmap getBitmapFromFile(String filePath) {
        BitmapFactory.Options options = new BitmapFactory.Options();
        return BitmapFactory.decodeFile(filePath, options);
    }

    public static byte[] readContentIntoByteArray(File file) {
        FileInputStream fileInputStream = null;
        byte[] bFile = new byte[(int) file.length()];
        try {
            // Convert file into array of bytes
            fileInputStream = new FileInputStream(file);
            fileInputStream.read(bFile);
            fileInputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bFile;
    }

    public static Bitmap cropBitmap(Bitmap orgBitmap, int left, int top, int right, int bottom) {
        int width = right - left;
        int height = bottom - top;

        if (orgBitmap != null) {
            try {
                return Bitmap.createBitmap(orgBitmap, left, top, width, height);
            } catch (Exception e) {
                return null;
            }
        }
        return null;
    }
}