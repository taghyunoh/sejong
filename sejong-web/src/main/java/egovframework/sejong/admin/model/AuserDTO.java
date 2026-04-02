package egovframework.sejong.admin.model;
public class AuserDTO{  
	private String user_id;
	private String enc_user_id;	    //암호화 사용자id
	private String dec_user_id;	    //복호화 사용자id
	private String user_nm;
	private String user_pw;
	private String user_gb;
	private String dept_nm;
	private String start_date;
	private String end_date;
	private String pwd_chg_ymd;
	private String login_fail_cnt;
	private String lock_yn;
	private String useyn;
	private String bigo;
	private String reg_id;
	private String reg_dtm;	
	private String mod_id;
	private String mod_dtm;
	private String iud;
	private int size;
	private String enc_auser_pwd;	   //사용자 비밀번호
	private String bf_auser_pwd;		   //이전 비밀번호
	private String af_auser_pwd;	       //변경 비밀번호
	private String pwdreset;		   //초기화여부
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

	public String getDec_user_id() {
		return dec_user_id;
	}
	public void setDec_user_id(String dec_user_id) {
		this.dec_user_id = dec_user_id;
	}
	
	public String getEnc_auser_pwd() {
		return enc_auser_pwd;
	}
	public void setEnc_auser_pwd(String enc_auser_pwd) {
		this.enc_auser_pwd = enc_auser_pwd;
	}
	public String getBf_auser_pwd() {
		return bf_auser_pwd;
	}
	public void setBf_auser_pwd(String bf_auser_pwd) {
		this.bf_auser_pwd = bf_auser_pwd;
	}
	public String getAf_auser_pwd() {
		return af_auser_pwd;
	}
	public void setAf_auser_pwd(String af_auser_pwd) {
		this.af_auser_pwd = af_auser_pwd;
	}
	public String getPwdreset() {
		return pwdreset;
	}
	public void setPwdreset(String pwdreset) {
		this.pwdreset = pwdreset;
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
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public int getSize() {
		return size;
	}
	public void setSize(int size) {
		this.size = size;
	}

}
