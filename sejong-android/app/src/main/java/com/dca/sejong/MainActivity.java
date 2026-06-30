package com.dca.sejong;

import static com.doinglab.foodlens.sdk.NutritionRetrieveMode.TOP1_NUTRITION_ONLY;
import static com.doinglab.foodlens.sdk.ui.util.BitmapUtil.readContentIntoByteArray;

import android.Manifest;
import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.health.connect.HealthPermissions;

import androidx.health.connect.client.permission.HealthPermission;
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord;
import androidx.health.connect.client.records.DistanceRecord;
import androidx.health.connect.client.records.Record;
import androidx.health.connect.client.records.StepsRecord;
import androidx.health.connect.client.records.metadata.DataOrigin;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Base64;
import android.util.Log;
import android.widget.FrameLayout;
import android.widget.ImageView;

import androidx.activity.OnBackPressedCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.health.connect.client.HealthConnectClient;
import androidx.health.connect.client.PermissionController;

import androidx.health.connect.client.records.metadata.Device;
import androidx.health.connect.client.records.metadata.Metadata;
import androidx.health.connect.client.request.ReadRecordsRequest;
import androidx.health.connect.client.response.ReadRecordsResponse;
import androidx.health.connect.client.time.TimeRangeFilter;

import com.dca.sejong.common.AppPreference;
import com.dca.sejong.common.Define;
import com.dca.sejong.common.utils.Logs;
import com.dca.sejong.common.utils.PermissionUtils;
import com.dca.sejong.web.BaseWebChromeClient;
import com.dca.sejong.web.BaseWebClient;
import com.dca.sejong.web.BaseWebView;
import com.dca.sejong.web.JavaScriptBridge;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.doinglab.foodlens.sdk.FoodLens;
import com.doinglab.foodlens.sdk.FoodLensBundle;
import com.doinglab.foodlens.sdk.NetworkService;
import com.doinglab.foodlens.sdk.NutritionResultHandler;
import com.doinglab.foodlens.sdk.RecognizeResultHandler;
import com.doinglab.foodlens.sdk.UIService;
import com.doinglab.foodlens.sdk.UIServiceMode;
import com.doinglab.foodlens.sdk.UIServiceResultHandler;
import com.doinglab.foodlens.sdk.errors.BaseError;
import com.doinglab.foodlens.sdk.network.model.FoodPosition;
import com.doinglab.foodlens.sdk.network.model.NutritionResult;
import com.doinglab.foodlens.sdk.network.model.RecognitionResult;
import com.doinglab.foodlens.sdk.network.model.UserSelectedResult;
import com.doinglab.foodlens.sdk.theme.BottomWidgetTheme;
import com.doinglab.foodlens.sdk.theme.DefaultWidgetTheme;
import com.doinglab.foodlens.sdk.theme.ToolbarTheme;

import kotlin.coroutines.EmptyCoroutineContext;
import kotlin.jvm.JvmClassMappingKt;
import kotlin.reflect.KClass;
import kotlinx.coroutines.BuildersKt;

public class MainActivity extends BaseActivity {
    private static final String TAG = MainActivity.class.getSimpleName();

    private FrameLayout mWebViewContainer;
    private String mCurrentWebPage;
    private JavaScriptBridge mJsBridge;
    private ImageView ivCapture;
    private MainActivity mActivity;
    private DownloadManager mDownloadManager;
    private Long mDownloadQueueId;
    private Context mContext;
    private BaseWebView webView;
    private BaseWebChromeClient chromeClient;
    private File file =null;
    public final static int FILECHOOSER_NORMAL_REQ_CODE = 2001;
    public final static int FILECHOOSER_LOLLIPOP_REQ_CODE = 2002;
    private String mCurrentPhotoPath;
    private Uri cameraImageUri = null;
    private Handler mHandler;

    private UIService uiService;
    private String foodImagePath = "";
    final int REQ_PICTURE = 0x02;
    private NetworkService ns;
    private RecognitionResult recognitionResult;
    //health data 연동
    private String providerPackageName = "com.google.android.apps.healthdata";
    private HealthConnectClient healthConnectClient;

    private ActivityResultLauncher permissionRequestLauncher;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        PermissionController.createRequestPermissionResultContract();
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Logs.e("[onCreate]");
        mContext = this;
        mActivity = this;
        mHandler = new Handler();
        mWebViewContainer = findViewById(R.id.webview_container);
        webView = (BaseWebView) mWebViewContainer.getChildAt(mWebViewContainer.getChildCount() - 1);
        webView.setTag(1);

        BaseWebClient client = new BaseWebClient(this, mWebViewContainer);
        webView.setWebViewClient(client);

        mJsBridge = new JavaScriptBridge(this, mWebViewContainer);
        webView.addJavascriptInterface(mJsBridge, JavaScriptBridge.CALL_NAME);

        chromeClient = new BaseWebChromeClient(this, mWebViewContainer, mJsBridge);
        webView.setWebChromeClient(chromeClient);
        webView.clearHistory();
        webView.clearCache(true);
        getOnBackPressedDispatcher().addCallback(this, callback);
        showProgressDialog();
        //FoodLens 초기화
        uiService = FoodLens.createUIService(this);
        BottomWidgetTheme bottomWidgetTheme =  new BottomWidgetTheme(this);
        bottomWidgetTheme.setButtonTextColor(Color.parseColor("#ffffff"));
        bottomWidgetTheme.setWidgetColor(Color.parseColor("#0A58CA"));

        DefaultWidgetTheme defaultWidgetTheme = new DefaultWidgetTheme(this);
        defaultWidgetTheme.setWidgetColor(Color.parseColor("#0A58CA"));
        defaultWidgetTheme.setButtonTextColor(Color.parseColor("#0A58CA"));

        ToolbarTheme toolbarTheme = new ToolbarTheme(this);
        toolbarTheme.setBackgroundColor(Color.parseColor("#0A58CA"));
        toolbarTheme.setWidgetColor(Color.parseColor("#0A58CA"));

        uiService.setBottomWidgetTheme(bottomWidgetTheme);
        uiService.setDefaultWidgetTheme(defaultWidgetTheme);
        uiService.setToolbarTheme(toolbarTheme);
        uiService.setUiServiceMode(UIServiceMode.USER_SELECTED_WITH_CANDIDATES);
        uiService.setUseActivityResult(false);
        try {
            FoodLensBundle bundle = new FoodLensBundle();
            bundle.setEnableManualInput(true);
            bundle.setSaveToGallery(true);
            bundle.setUseImageRecordDate(false);
            uiService.setDataBundle(bundle);
        } catch (Exception e) {

        }
        // health
        permissionRequestLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    Logs.e("health lauchecer code =  " + result.getResultCode());
                    if (result.getResultCode() == RESULT_OK) {
                        // 권한 요청 성공 후 작업을 여기에 추가합니다.
                        KClass<? extends Record> dt = dataTypeNameToClass("steps");
                        KClass<? extends Record> dt2 = kotlin.jvm.JvmClassMappingKt.getKotlinClass(ActiveCaloriesBurnedRecord.class);
                        KClass<? extends Record> dt3 = kotlin.jvm.JvmClassMappingKt.getKotlinClass(DistanceRecord.class);
                        readHealthData(dt);
                        readHealthData(dt2);
                        readHealthData(dt3);
                    } else {
                        // 권한 요청이 거부된 경우 처리합니다.
                    }
                }
        );
        loadWebview();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Logs.e("[onNewIntent]");
        //Bundle extras = intent.getExtras();
        Intent extras = getIntent();
        if(extras != null) {
            AppApplication.pushLinkUrl = extras.getStringExtra("link");
            Logs.e("[onNewIntent] pushLinkUrl : " + AppApplication.pushLinkUrl);
            Logs.e("extras : " + extras);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();

        AppApplication.setCurrentActivity(this);

        IntentFilter filter = new IntentFilter();
        filter.addAction(Define.ACTION_JAVASCRIPT_CMD_200);
        filter.addAction(Define.ACTION_JAVASCRIPT_CMD_201);
        filter.addAction(Define.ACTION_JAVASCRIPT_CMD_202);
        filter.addAction(Define.ACTION_JAVASCRIPT_CMD_203);
        filter.addAction(Define.ACTION_JAVASCRIPT_CMD_301);
        filter.addAction(Define.ACTION_JAVASCRIPT_CMD_303);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            mContext.registerReceiver(mBroadcastReceiver, filter,Context.RECEIVER_EXPORTED);
        } else {
            mContext.registerReceiver(mBroadcastReceiver, filter);
        }

        // Download 로직 생성시 추가해야함 나중에
        /*registerReceiver(downloadCompleteReceiver,
                new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));*/
    }

    @Override
    protected void onPause() {
        super.onPause();

        //unregisterReceiver(mBroadcastReceiver);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    OnBackPressedCallback callback = new OnBackPressedCallback(true) {
        @Override
        public void handleOnBackPressed() {
            Logs.e("onBackPressed : " + mCurrentWebPage);
            if (TextUtils.isEmpty(mCurrentWebPage)) {
                finish();
            } else {
                int webViewCnt = mWebViewContainer.getChildCount();
                if (webViewCnt > 1) {
                    mWebViewContainer.removeViewAt(webViewCnt - 1);
                } else {
                    if (webView.canGoBack())
                        webView.goBack();
                    else {
                        webView.clearCache(true);
                        webView.clearHistory();
                        mJsBridge.callJavascriptFunc("appBackButton", null);
                    }
                }
            }
        }
    };
  /*  @Override
    public void onBackPressed() {
        super.onBackPressed();
        Logs.e("onBackPressed : " + mCurrentWebPage);
        if (TextUtils.isEmpty(mCurrentWebPage)) {
            finish();
        } else {
            int webViewCnt = mWebViewContainer.getChildCount();
            if (webViewCnt > 1) {
                mWebViewContainer.removeViewAt(webViewCnt - 1);
            } else {
                if (webView.canGoBack())
                    webView.goBack();
                else {
                    webView.clearCache(true);
                    webView.clearHistory();
                    mJsBridge.callJavascriptFunc("appBackButton", null);
                }
            }
        }
    }*/

    /**
     * POST방식일 경우 주석을 풀어서 확인한다.
     * Intent로 받은 Url을 로드한다.
     */
    public void loadWebview(){
        Intent intent = getIntent();
        String url = intent.getStringExtra("url");
        Logs.e("MainActivity - url : " + url);
        //Test용
        url = url+"loginPage.do";
       // url = url+"index.do";
        String param = "";
        if (intent.hasExtra("param"))
            param = intent.getStringExtra("param");

        showProgressDialog();

        /*if (TextUtils.isEmpty(param)) {
            webView.loadUrl(url);
        }
        else {
            Logs.e("MainActivity - param : " + param);
            webView.postUrl(url, param.getBytes());
        }*/

        /*Map<String, String> headers = new HashMap<>();
        headers.put("Set-Cookie", "Secure;SameSite=None;");
        headers.put("Accept-Language", "ko-KR,ko");

        webView.loadUrl(url, headers);*/
        webView.loadUrl(url);
    }
    /**
     *
     * 현재 페이지 url을 저장한다.
     */
    public void setCurrentPage(String page){
        mCurrentWebPage = page;
    }
    /**
     * 자동로그인, 아이디저장의 정보를 JSON형태로 보내준다.
     */
    public void sendUserLoinInfo() {
        String uli = AppPreference.getUserLoginInfo();
        if(uli != null && !uli.equals(""))
            mJsBridge.callJavascriptFuncWithString("getUserLoginInfo", uli);
    }
    public void startFoodLensCamera(){
        uiService.startFoodLensCamera(MainActivity.this, new UIServiceResultHandler() {
            @Override
            public void onSuccess(UserSelectedResult result) {
                setRecognitionResultData(result);
            }
            @Override
            public void onCancel() {
                Log.d("MSG_LOG", "Recognition Cancel");
            }
            @Override
            public void onError(BaseError error) {
                Log.d("MSG_LOG", error.getMessage());
            }
        });
    }
    private void setRecognitionResultData(RecognitionResult recognitionResultData)
    {
        List<FoodPosition> foodPositions = recognitionResultData.getFoodPositions();
        Bitmap recogBitmap = BitmapFactory.decodeFile(recognitionResultData.getRecognizedImage());
        recognitionResultData.setRecognizedImagePath(saveImage2(recogBitmap));
        for(int i=0; i<foodPositions.size(); i++)
        {
            FoodPosition foodPosition = foodPositions.get(i);
            Bitmap bitmap = BitmapFactory.decodeFile(foodPosition.getFoodImagePath());
            saveImage(bitmap,foodPosition);
        }
        mJsBridge.callJavascriptFuncWithString("returnFoodData", recognitionResultData.toJSONString());
    }
    // 이미지를 저장하는 메서드
    private void saveImage(Bitmap bitmap,FoodPosition foodPosition) {
        String ImageName = System.currentTimeMillis() + ".png";  // 이미지 파일명을 현재 시간으로 설정
        File file = new File(getFilesDir(), ImageName);  // 파일 경로 설정
        try {
            file.createNewFile();  // 새 파일 생성
            FileOutputStream out = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);  // 비트맵 이미지를 파일로 압축하여 저장
            foodPosition.setFoodImagePath(file.toString());
            out.close();  // 출력 스트림 닫기
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    // 이미지를 저장하는 메서드
    private String saveImage2(Bitmap bitmap) {
        String ImageName = System.currentTimeMillis() + ".png";  // 이미지 파일명을 현재 시간으로 설정
        File file = new File(getFilesDir(), ImageName);  // 파일 경로 설정
        try {
            file.createNewFile();  // 새 파일 생성
            FileOutputStream out = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out);  // 비트맵 이미지를 파일로 압축하여 저장
            out.close();  // 출력 스트림 닫기
        } catch (Exception e) {
            e.printStackTrace();
        }
        return file.toString();
    }
    public void startFoodLensEdit(String json,String foodhisSeq){
        recognitionResult = RecognitionResult.create(json);
        uiService.startFoodLensDataEdit(MainActivity.this, recognitionResult, new UIServiceResultHandler() {
            @Override
            public void onSuccess(UserSelectedResult result) {
                JSONObject obj = new JSONObject();
                try {
                    obj.put("data",result.toJSONString());
                    obj.put("foodhisSeq",foodhisSeq);
                } catch (JSONException e) {
                    throw new RuntimeException(e);
                }
                mJsBridge.callJavascriptFunc("editFoodData", obj);
            }
            @Override
            public void onCancel() {
                Log.d("MSG_LOG", "Recognition Cancel");
            }

            @Override
            public void onError(BaseError error) {
                Log.d("MSG_LOG", error.getMessage());
            }
        });
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQ_PICTURE && resultCode == RESULT_OK && null != data) {
            Uri selectedImage = data.getData();
            String[] filePathColumn = { MediaStore.Images.Media.DATA };

            Cursor cursor = getContentResolver().query(selectedImage,
                    filePathColumn, null, null, null);
            cursor.moveToFirst();

            int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
            String picturePath = cursor.getString(columnIndex);
            cursor.close();

            final byte[] byteData = readContentIntoByteArray(new File(picturePath));

            ns = FoodLens.createNetworkService(getApplicationContext());
            ns.setNutritionRetrieveMode(TOP1_NUTRITION_ONLY);
            ns.predictMultipleFood(byteData, new RecognizeResultHandler() {
                @Override
                public void onSuccess(RecognitionResult result) {
                    Logs.e("Result from Network Service");
                    Logs.e(result.toJSONString());
                }
                @Override
                public void onError(BaseError errorReason) {
                    Log.e("FOODLENS_LOG", errorReason.getMessage());

                }
            });
            ns.getNutritionInfo(20, new NutritionResultHandler() {
                @Override
                public void onSuccess(NutritionResult result) {

                }

                @Override
                public void onError(BaseError errorReason) {

                }
            });
        }
        uiService.onActivityResult(requestCode, resultCode, data);
    }
    public void getBase64FromFile(String filePath,String index) throws JSONException {
        File file = new File(filePath);
        byte[] fileBytes = new byte[(int) file.length()];
        try {
            FileInputStream fis = new FileInputStream(file);
            fis.read(fileBytes);
            fis.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        JSONObject json = new JSONObject();
        json.put("data",Base64.encodeToString(fileBytes, Base64.DEFAULT));
        json.put("index",index);
        mJsBridge.callJavascriptFunc("foodImageCallBack",json);
    }
    public boolean checkHealthAPi(){

        int availabilityStatus = HealthConnectClient.getSdkStatus(mContext, providerPackageName);
        Logs.e(availabilityStatus+"");
        if (availabilityStatus == HealthConnectClient.SDK_UNAVAILABLE) {
            Logs.shwoToast(mContext, "헬스 커넥트 앱을 다운로드 해주세요.");
            return false; // 더 이상 진행할 수 없음
        }

        if (availabilityStatus == HealthConnectClient.SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED) {
            Logs.shwoToast(mContext, "헬스 커넥트 앱을 업데이트 해주세요.");
            // 패키지 설치 프로그램으로 리디렉션하는 옵션
            String uriString = "market://details?id=" + providerPackageName + "&url=healthconnect%3A%2F%2Fonboarding";
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setPackage("com.android.vending");
            intent.setData(Uri.parse(uriString));
            intent.putExtra("overlay", true);
            intent.putExtra("callerId", mContext.getPackageName());
            mContext.startActivity(intent);

            return false;
        }
        healthConnectClient = HealthConnectClient.getOrCreate(mContext);
        Logs.e("health client create 성공 ");
        return true;
    }
    private void checkAndRequestPermissions() {
        Set<String> readPermissions = Set.of(
                HealthPermissions.READ_STEPS,
                HealthPermissions.READ_DISTANCE,
                HealthPermission.READ_ACTIVE_CALORIES_BURNED,
                HealthPermission.WRITE_DISTANCE,
                HealthPermission.WRITE_STEPS,
                HealthPermission.WRITE_ACTIVE_CALORIES_BURNED
        );
        Intent permissionRequestIntent = PermissionController.createRequestPermissionResultContract().createIntent(mContext,readPermissions);

        try {
            // 부여된 권한 확인\
            Set<String> grantedPermissions = BuildersKt.runBlocking(
                    EmptyCoroutineContext.INSTANCE,
                    (s, c) -> healthConnectClient.getPermissionController().getGrantedPermissions(c)
            );

            if (grantedPermissions.containsAll(readPermissions)) {
                // 모든 권한이 이미 부여된 경우
                KClass<? extends Record> dt = dataTypeNameToClass("steps");
                KClass<? extends Record> dt2 = kotlin.jvm.JvmClassMappingKt.getKotlinClass(ActiveCaloriesBurnedRecord.class);
                KClass<? extends Record> dt3 = kotlin.jvm.JvmClassMappingKt.getKotlinClass(DistanceRecord.class);
                readHealthData(dt);
                readHealthData(dt2);
                readHealthData(dt3);
            } else {
                // 권한 요청이 필요한 경우
                Logs.e("권한 요청 ");
                requestPermissions(readPermissions);
                permissionRequestLauncher.launch(permissionRequestIntent);
            }
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 처리
        }
    }
    private void requestPermissions(Set<String> readPermissions) {
        // 권한 요청을 위한 인텐트 생성
        Intent permissionRequestIntent = PermissionController.createRequestPermissionResultContract().createIntent(mContext,readPermissions);
        // 권한 요청 시작
        // 권한 요청 런처 초기화
        permissionRequestLauncher.launch(permissionRequestIntent);
    }

    private void readHealthData(KClass<? extends Record> dt) {
        Logs.e("데이터 가져오기 ");
        try {
            // Define the time range for which you want to fetch the data
            LocalDate startDate = LocalDate.now().minusDays(3);
            LocalDate endDate = LocalDate.now();
            /*KClass<?> dt = null;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                dt = JvmClassMappingKt.getKotlinClass(StepsRecord.class);
            }*/
            // LocalDate를 Instant로 변환하고, 이를 long 타입으로 변환
            long st = startDate.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli();
            long et = endDate.atStartOfDay(ZoneId.systemDefault()).toInstant().plusMillis(86400000L).toEpochMilli(); // End of the day
            TimeRangeFilter timeRange = TimeRangeFilter.between(Instant.ofEpochMilli(st), Instant.ofEpochMilli(et));
            HashSet<DataOrigin> dor = new HashSet<>();
            ReadRecordsRequest request = new ReadRecordsRequest(dt, timeRange, dor, true, 1000, null);
            // see https://kt.academy/article/cc-other-languages
            ReadRecordsResponse response = BuildersKt.runBlocking(
                    EmptyCoroutineContext.INSTANCE,
                    (s, c) -> healthConnectClient.readRecords(request, c)
            );
            Logs.e(TAG, "Data query successful");
            Logs.e(TAG, response.getRecords().toString());
            Logs.e(TAG, response.getRecords().stream().count()+"");
            JSONArray resultset = new JSONArray();
            // default behaviour is that each record corresponds to one element in the array, but there can be exceptions
            boolean oneElementPerRecord = true;
            String type = "";
            for (Object datapointObj : response.getRecords()) {
                if (datapointObj instanceof androidx.health.connect.client.records.Record) {
                    androidx.health.connect.client.records.Record datapoint = (androidx.health.connect.client.records.Record) datapointObj;
                    JSONObject obj = new JSONObject();

                    populateFromMeta(obj, datapoint.getMetadata());

                    // DATA_TYPES here we need to add support for each different data type
                    if (datapoint instanceof StepsRecord) {
                        populateFromQuery(datapoint, obj);
                        type="step";
                    }
                    if (datapoint instanceof DistanceRecord) {
                        Logs.e("distanc record");
                        type="distance";
                    }
                    if (datapoint instanceof ActiveCaloriesBurnedRecord) {
                        Logs.e("calories record");
                        type="cal";
                    }
                    // add to result array
                    if (oneElementPerRecord){
                        resultset.put(obj);
                    }
                } else {
                    Log.e(TAG, "Unrecognized type for record " + datapointObj.getClass());
                }
            }
            // done:
            if(type == "step"){
                mJsBridge.callJavascriptFuncWithString("returnStepData", resultset.toString());
            } else if (type == "distance") {
                mJsBridge.callJavascriptFuncWithString("returnDistanceData", resultset.toString());
            } else if (type == "cal"){
                mJsBridge.callJavascriptFuncWithString("returnCalData", resultset.toString());
            }

        } catch (InterruptedException | JSONException ex2) {
            Log.e(TAG, "Thread interrupted", ex2);
        }
    }
    protected static void populateFromMeta(JSONObject obj, Metadata meta) throws JSONException {
        String id = meta.getId();
        if (id != null) {
            obj.put("id", id);
        }

        Device dev = meta.getDevice();
        if (dev != null) {
            String device = "";
            String manufacturer = dev.getManufacturer();
            String model = dev.getModel();
            if (manufacturer != null || model != null) {
                obj.put("sourceDevice", manufacturer + " " + model);
            }
        }

        DataOrigin origin = meta.getDataOrigin();
        if (origin != null) {
            obj.put("sourceBundleId", origin.getPackageName());
        }

        int methodInt = meta.getRecordingMethod();
        String method = "unknown";
        switch (methodInt) {
            case 1:
                method = "actively_recorded";
                break;
            case 2:
                method = "automatically_recorded";
                break;
            case 3:
                method = "manual_entry";
                break;
        }
        obj.put("entryMethod", method);
    }
    public static void populateFromQuery(androidx.health.connect.client.records.Record datapoint, JSONObject obj) throws JSONException {
        StepsRecord stepsDP = (StepsRecord) datapoint;
        obj.put("startDate", stepsDP.getStartTime().toEpochMilli());
        obj.put("endDate", stepsDP.getEndTime().toEpochMilli());

        long steps = stepsDP.getCount();
        obj.put("value", steps);
        obj.put("unit", "count");
        Logs.e("value =" + steps);
    }
    private KClass<? extends androidx.health.connect.client.records.Record> dataTypeNameToClass(String name) {
        if (name.equalsIgnoreCase("steps")) {
            return dataTypeToClass();
        }
        return null;
    }
    public static KClass<StepsRecord> dataTypeToClass() {
        return kotlin.jvm.JvmClassMappingKt.getKotlinClass(StepsRecord.class);
    }
    // JS 통신 로직
    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Logs.e("[onReceive] action : " + action);
            switch(action) {
                case Define.ACTION_JAVASCRIPT_CMD_200:
                    if(ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                        PermissionUtils.checkRuntimePermission(MainActivity.this, Define.gPermissionCameraList, Define.REQUEST_CAMERA_PERMISSION);
                    }
                    else {
                        //Camera 실행 로직
                    }
                    break;
                case Define.ACTION_JAVASCRIPT_CMD_201:
                    if(ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
                        Logs.e("201카메라 권한 체크");
                        PermissionUtils.checkRuntimePermission(MainActivity.this, Define.gPermissionCameraList, Define.REQUEST_CAMERA_PERMISSION);
                    }
                    else {
                        //Camera 실행 로직
                        Logs.e("푸드렌즈카메라실행");
                        startFoodLensCamera();
                    }
                    break;
                case Define.ACTION_JAVASCRIPT_CMD_202:
                    Logs.e("푸드렌즈에디터실행");
                    startFoodLensEdit(intent.getStringExtra("data"),intent.getStringExtra("foodhisSeq"));
                    break;
                case Define.ACTION_JAVASCRIPT_CMD_203:
                    Logs.e("푸드렌즈이미지전달");
                    try {
                        getBase64FromFile(intent.getStringExtra("imagePath"),intent.getStringExtra("index"));
                    } catch (JSONException e) {
                        throw new RuntimeException(e);
                    }
                    break;
                case Define.ACTION_JAVASCRIPT_CMD_301:
                    Logs.e("헬스데이터 연동 브로드캐스트 ");
                    if(checkHealthAPi()){
                        checkAndRequestPermissions();
                    };
                    break;
                default:
                    break;
            }
        }
    };

}