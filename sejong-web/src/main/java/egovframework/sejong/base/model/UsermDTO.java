package egovframework.sejong.base.model;
public class UsermDTO  extends CommonDTO {
	private String iud   = ""; 
	private String hosp_cd; // 요양기관번호
    private String user_id; // 사용자 ID
    private String user_nm; // 사용자명
    private String start_dt; // 적용시작일자
    private String end_dt; // 적용종료일자
    private String main_gu; // 관리자구분
    private String pass_wd; // 비밀번호
    private String pass_cdt; // 패스워드 변경일자
    private String bigo; // 비고
    private String reg_dttm; // 등록일시
    private String reg_user; // 등록자
    private String reg_ip; // 등록 IP
    private String upd_dttm; // 최종변경일시
    private String upd_user; // 최종변경자
    private String upd_ip; // 최종변경 IP
    private String af_pass_wd ;
    private String bf_pass_wd ;
    private String enc_pass_wd ;
    private String use_yn ;
    private String hosp_uuid ;
	private String winner_yn ;
	private String email ;
	private String user_tel ;
	
	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getUser_tel() {
		return user_tel;
	}

	public void setUser_tel(String user_tel) {
		this.user_tel = user_tel;
	}

	public String getWinner_yn() {
		return winner_yn;
	}

	public void setWinner_yn(String winner_yn) {
		this.winner_yn = winner_yn;
	}
	
	public String getHosp_uuid() {
		return hosp_uuid;
	}
	public void setHosp_uuid(String hosp_uuid) {
		this.hosp_uuid = hosp_uuid;
	}
	public String getUse_yn() {
		return use_yn;
	}
	public void setUse_yn(String use_yn) {
		this.use_yn = use_yn;
	}
	public String getEnc_pass_wd() {
		return enc_pass_wd;
	}
	public void setEnc_pass_wd(String enc_pass_wd) {
		this.enc_pass_wd = enc_pass_wd;
	}
	public String getBf_pass_wd() {
		return bf_pass_wd;
	}
	public void setBf_pass_wd(String bf_pass_wd) {
		this.bf_pass_wd = bf_pass_wd;
	}
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}    
	public String getAf_pass_wd() {
		return af_pass_wd;
	}
	public void setAf_pass_wd(String af_pass_wd) {
		this.af_pass_wd = af_pass_wd;
	}
	public String getHosp_cd() {
		return hosp_cd;
	}
	public void setHosp_cd(String hosp_cd) {
		this.hosp_cd = hosp_cd;
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
	public String getStart_dt() {
		return start_dt;
	}
	public void setStart_dt(String start_dt) {
		this.start_dt = start_dt;
	}
	public String getEnd_dt() {
		return end_dt;
	}
	public void setEnd_dt(String end_dt) {
		this.end_dt = end_dt;
	}
	public String getMain_gu() {
		return main_gu;
	}
	public void setMain_gu(String main_gu) {
		this.main_gu = main_gu;
	}
	public String getPass_wd() {
		return pass_wd;
	}
	public void setPass_wd(String pass_wd) {
		this.pass_wd = pass_wd;
	}
	public String getPass_cdt() {
		return pass_cdt;
	}
	public void setPass_cdt(String pass_cdt) {
		this.pass_cdt = pass_cdt;
	}
	public String getBigo() {
		return bigo;
	}
	public void setBigo(String bigo) {
		this.bigo = bigo;
	}
	public String getReg_dttm() {
		return reg_dttm;
	}
	public void setReg_dttm(String reg_dttm) {
		this.reg_dttm = reg_dttm;
	}
	public String getReg_user() {
		return reg_user;
	}
	public void setReg_user(String reg_user) {
		this.reg_user = reg_user;
	}
	public String getReg_ip() {
		return reg_ip;
	}
	public void setReg_ip(String reg_ip) {
		this.reg_ip = reg_ip;
	}
	public String getUpd_dttm() {
		return upd_dttm;
	}
	public void setUpd_dttm(String upd_dttm) {
		this.upd_dttm = upd_dttm;
	}
	public String getUpd_user() {
		return upd_user;
	}
	public void setUpd_user(String upd_user) {
		this.upd_user = upd_user;
	}
	public String getUpd_ip() {
		return upd_ip;
	}
	public void setUpd_ip(String upd_ip) {
		this.upd_ip = upd_ip;
	}
}