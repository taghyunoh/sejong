package egovframework.sejong.user.model;

public class UserDTO{

	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String user_id;            // 사용자 ID
	private String user_nm;            // 사용자 명
	private String user_pw;            // 사용자비밀번호
	private String user_gb;            // 관리자 여부
	private String dept_nm;       	   // 진료과명
	private String start_date;         // 적용시작일자
	private String end_date;           // 적용종료일자
	private String pwd_chg_ymd;		   // 비밀번호 변경 일(8자리)
	private String login_fail_cnt;	   // 로그인 실패 횟수
	private String lock_yn;			   // 로그인 잠김 여부
	private String use_yn;             // 사용여부
	private String useyn;              // 사용여부
	private String bigo;			   // 비고사항  
	private String reg_id;			   // 등록한 아이디
 	private String reg_dtm;			   // 등록일
	private String mod_id;			   // 수정한 아이
	private String mod_dtm;			   // 수정일
	
	private String enc_user_id;	       // 아이디  
	private String enc_user_pwd;	   //사용자 비밀번호
	private String bf_user_pwd;		   //이전 비밀번호
	private String af_user_pwd;	       //변경 비밀번호
	private String pwdreset;		   //초기화여부
	
	private String user_uuid;
	private String userUuid;
	
	
    private String user_id_nm;
	
	public String getUser_id_nm() {
		return user_id_nm;
	}
	public void setUser_id_nm(String user_id_nm) {
		this.user_id_nm = user_id_nm;
	}
	
	public String getEnc_user_id() {
		return enc_user_id;
	}
	public void setEnc_user_id(String enc_user_id) {
		this.enc_user_id = enc_user_id;
	}
	public String getUser_id() {
		return user_id;
	}
	public void setUser_id(String user_id) {
		this.user_id = user_id;
	}
	public String getUser_nm() {
		return user_nm;
	}
	public void setUser_nm(String user_nm) {
		this.user_nm = user_nm;
	}
	public String getUser_pw() {
		return user_pw;
	}
	public void setUser_pw(String user_pw) {
		this.user_pw = user_pw;
	}
	public String getUser_gb() {
		return user_gb;
	}
	public void setUser_gb(String user_gb) {
		this.user_gb = user_gb;
	}
	public String getDept_nm() {
		return dept_nm;
	}
	public void setDept_nm(String dept_nm) {
		this.dept_nm = dept_nm;
	}
	public String getStart_date() {
		return start_date;
	}
	public void setStart_date(String start_date) {
		this.start_date = start_date;
	}
	public String getEnd_date() {
		return end_date;
	}
	public void setEnd_date(String end_date) {
		this.end_date = end_date;
	}
	public String getPwd_chg_ymd() {
		return pwd_chg_ymd;
	}
	public void setPwd_chg_ymd(String pwd_chg_ymd) {
		this.pwd_chg_ymd = pwd_chg_ymd;
	}
	public String getLogin_fail_cnt() {
		return login_fail_cnt;
	}
	public void setLogin_fail_cnt(String login_fail_cnt) {
		this.login_fail_cnt = login_fail_cnt;
	}
	public String getLock_yn() {
		return lock_yn;
	}
	public void setLock_yn(String lock_yn) {
		this.lock_yn = lock_yn;
	}
	public String getUse_yn() {
		return use_yn;
	}
	public void setUse_yn(String use_yn) {
		this.use_yn = use_yn;
	}
	public String getUseyn() {
		return useyn;
	}
	public void setUseyn(String useyn) {
		this.useyn = useyn;
	}
	public String getBigo() {
		return bigo;
	}
	public void setBigo(String bigo) {
		this.bigo = bigo;
	}
	public String getReg_id() {
		return reg_id;
	}
	public void setReg_id(String reg_id) {
		this.reg_id = reg_id;
	}
	public String getReg_dtm() {
		return reg_dtm;
	}
	public void setReg_dtm(String reg_dtm) {
		this.reg_dtm = reg_dtm;
	}
	public String getMod_id() {
		return mod_id;
	}
	public void setMod_id(String mod_id) {
		this.mod_id = mod_id;
	}
	public String getMod_dtm() {
		return mod_dtm;
	}
	public void setMod_dtm(String mod_dtm) {
		this.mod_dtm = mod_dtm;
	}
	public String getEnc_user_pwd() {
		return enc_user_pwd;
	}
	public void setEnc_user_pwd(String enc_user_pwd) {
		this.enc_user_pwd = enc_user_pwd;
	}
	public String getBf_user_pwd() {
		return bf_user_pwd;
	}
	public void setBf_user_pwd(String bf_user_pwd) {
		this.bf_user_pwd = bf_user_pwd;
	}
	
	public String getAf_user_pwd() {
		return af_user_pwd;
	}
	public void setAf_user_pwd(String af_user_pwd) {
		this.af_user_pwd = af_user_pwd;
	}
	public String getPwdreset() {
		return pwdreset;
	}
	public void setPwdreset(String pwdreset) {
		this.pwdreset = pwdreset;
	}
	public String getUser_uuid() {
		return user_uuid;
	}
	public void setUser_uuid(String user_uuid) {
		this.user_uuid = user_uuid;
	}
	public String getUserUuid() {
		return userUuid;
	}
	public void setUserUuid(String userUuid) {
		this.userUuid = userUuid;
	}
	
	
}
