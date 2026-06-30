package com.dca.sejong.common.utils;

import android.content.Context;
import android.os.Environment;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;

public class Files {
    /**
     * 디렉토리 생성
     *
     * @param path 폴더위치
     * @return boolean 폴더생성 성공실패
     */
    public static synchronized void makeDir(String path) {

        File file = new File(path);

        if(!file.exists()){
            if (! file.mkdir()) {
                Logs.e("failed to create directory");
            }
        }
    }

    /**
     *  파일 생성
     *
     * @param filePath 파일위치
     * @param fileName 파일이름
     * @return boolean 파일생성 성공실패
     */
    public static synchronized boolean createFile(String filePath, String fileName) {

        File file = new File(filePath + File.separator + fileName);

        try {
            if(!file.exists())
                return file.createNewFile();
        } catch (IOException e) {
            Logs.printException(e);
        }

        return false;
    }

    /**
     * 폴더 삭제
     *
     * @param dir
     * @return boolean 삭제성공실패
     */
    public static synchronized boolean deleteDir(File dir){
        if(dir != null && dir.isDirectory()){
            String[] items = dir.list();
            for(String f : items){
                File file = new File(dir,f);
                file.delete();
            }
        }

        return dir.delete();
    }

    /**
     * 파일 삭제
     * @param path 파일위치
     * @return
     */
    public static synchronized boolean deleteFile(String path){
        File file = new File(path);
        if(file.exists()){
            return file.delete();
        }

        return false;
    }

    /**
     * 앱에서 사용할 앱 폴더 위치. 폴더가 없으면 생성한다.
     *
     * @param context
     * @param dirName 앱에서 사용할 폴더 이름
     * @return File 미디어위치
     */
    public static File getOutputMediaPath(Context context, String dirName) {
        File mediaStorageDir;

        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            mediaStorageDir = new File(Environment.getExternalStorageDirectory(), dirName);
        } else {
            mediaStorageDir = context.getCacheDir();
        }

        // 없는 경로라면 따로 생성한다.
        if (!mediaStorageDir.exists()) {
            if (!mediaStorageDir.mkdirs()) {
                return null;
            }
        }

        return mediaStorageDir;
    }

    /**
     * 특정 확장자를 가진 파일들을 삭제한다.
     *
     * @param path
     * @param ext
     */
    public static void deleteExtFile(String path, String ext){
        File dir = new File(path);
        if(dir != null) {

            File[] files = dir.listFiles();
            if(files==null)
                return;
            for(File f:files) {
                String filename = f.getName();
                if(filename.contains(ext))
                    f.delete();
            }
        }
    }


    public static void write(File file, byte[] data) throws IOException {
        FileOutputStream stream = new FileOutputStream(file);
        stream.write(data);
        stream.close();
    }

    public static  void write(File file,String content) {
        try {

            if (!file.exists()) {
                file.createNewFile();
            }
            FileWriter writer = new FileWriter(file);

            writer.append(content);
            writer.flush();
            writer.close();
        } catch (IOException e) {
        }
    }
}
