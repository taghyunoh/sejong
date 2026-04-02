package egovframework.sejong.doctor.model;

public class DoctorDTO {
	private String user_uuid;
	private String userUuid;
	private String user_id;
	private String user_nm;
	private String user_pw;
	private String user_gb;
	private String mgmt_gb;
	private String birth;
	private String gender;
	private String phone;
	private String email;
	private String join_ymd;
	private String joinYmd;
	private String pwd_chg_ymd;
	private String login_fail_cnt;
	private String lock_yn;
	private String reg_dtm;
	private String mod_dtm;
	private String token;
	private String push_yn;
	private String del_dtm;
	private String searchText;
	private String iud;
	private String year;
	private String month;
	private String day;
	private int size;
	private String cgm_dtm;
	private String upt_value;
	private String gap_value;
	private String height;
	private String weight;
	private String dtl_code_nm ;
	private String dept_nm ;
	private String title ;
		
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getDept_nm() {
		return dept_nm;
	}
	public void setDept_nm(String dept_nm) {
		this.dept_nm = dept_nm;
	}
	public String getDtl_code_nm() {
		return dtl_code_nm;
	}
	public void setDtl_code_nm(String dtl_code_nm) {
		this.dtl_code_nm = dtl_code_nm;
	}
	public String getHeight() {
		return height;
	}
	public void setHeight(String height) {
		this.height = height;
	}
	public String getWeight() {
		return weight;
	}
	public void setWeight(String weight) {
		this.weight = weight;
	}
	public String getCgm_dtm() {
		return cgm_dtm;
	}
	public void setCgm_dtm(String cgm_dtm) {
		this.cgm_dtm = cgm_dtm;
	}
	public String getUpt_value() {
		return upt_value;
	}
	public void setUpt_value(String upt_value) {
		this.upt_value = upt_value;
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
	public String getMgmt_gb() {
		return mgmt_gb;
	}
	public void setMgmt_gb(String mgmt_gb) {
		this.mgmt_gb = mgmt_gb;
	}
	public String getBirth() {
		return birth;
	}
	public void setBirth(String birth) {
		this.birth = birth;
	}
	public String getGender() {
		return gender;
	}
	public void setGender(String gender) {
		this.gender = gender;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getJoin_ymd() {
		return join_ymd;
	}
	public void setJoin_ymd(String join_ymd) {
		this.join_ymd = join_ymd;
	}
	public String getJoinYmd() {
		return joinYmd;
	}
	public void setJoinYmd(String joinYmd) {
		this.joinYmd = joinYmd;
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
	public String getReg_dtm() {
		return reg_dtm;
	}
	public void setReg_dtm(String reg_dtm) {
		this.reg_dtm = reg_dtm;
	}
	public String getMod_dtm() {
		return mod_dtm;
	}
	public void setMod_dtm(String mod_dtm) {
		this.mod_dtm = mod_dtm;
	}
	public String getToken() {
		return token;
	}
	public void setToken(String token) {
		this.token = token;
	}
	public String getPush_yn() {
		return push_yn;
	}
	public void setPush_yn(String push_yn) {
		this.push_yn = push_yn;
	}
	public String getDel_dtm() {
		return del_dtm;
	}
	public void setDel_dtm(String del_dtm) {
		this.del_dtm = del_dtm;
	}
	public String getSearchText() {
		return searchText;
	}
	public void setSearchText(String searchText) {
		this.searchText = searchText;
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
	public String getYear() {
		return year;
	}
	public void setYear(String year) {
		this.year = year;
	}
	public String getMonth() {
		return month;
	}
	public void setMonth(String month) {
		this.month = month;
	}
	public String getDay() {
		return day;
	}
	public void setDay(String day) {
		this.day = day;
	}
	
	private String faq_seq;
	private String faq_gb;
	private String qstn_conts;
	private String ansr_conts;
	private String reg_id;
	private String mod_id;

	public String getFaq_seq() {
		return faq_seq;
	}
	public void setFaq_seq(String faq_seq) {
		this.faq_seq = faq_seq;
	}
	public String getFaq_gb() {
		return faq_gb;
	}
	public void setFaq_gb(String faq_gb) {
		this.faq_gb = faq_gb;
	}
	public String getQstn_conts() {
		return qstn_conts;
	}
	public void setQstn_conts(String qstn_conts) {
		this.qstn_conts = qstn_conts;
	}
	public String getAnsr_conts() {
		return ansr_conts;
	}
	public void setAnsr_conts(String ansr_conts) {
		this.ansr_conts = ansr_conts;
	}
	public String getReg_id() {
		return reg_id;
	}
	public void setReg_id(String reg_id) {
		this.reg_id = reg_id;
	}
	public String getMod_id() {
		return mod_id;
	}
	public void setMod_id(String mod_id) {
		this.mod_id = mod_id;
	}
	public String getGap_value() {
		return gap_value;
	}
	public void setGap_value(String gap_value) {
		this.gap_value = gap_value;
	}	
}
