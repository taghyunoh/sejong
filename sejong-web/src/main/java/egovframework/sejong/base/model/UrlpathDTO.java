package egovframework.sejong.base.model;

public class UrlpathDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	private String iud   = "";    // 
	private String hosp_cd;           // 요양기관
    private String url_path;
	private String hosp_uuid;
	private String sub_code_nm;
    private String start_dt;
    private String end_dt;
    private String use_yn;
    private String bigo;
    private String reg_dttm;
    private String reg_user;
    private String reg_ip;
    private String upd_dttm;
    private String upd_user;
    private String upd_ip;
    private String user_nm ;
	private String hosp_nm ;

	public String getSub_code_nm() {
		return sub_code_nm;
	}
	public void setSub_code_nm(String sub_code_nm) {
		this.sub_code_nm = sub_code_nm;
	}
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getHosp_cd() {
		return hosp_cd;
	}
	public void setHosp_cd(String hosp_cd) {
		this.hosp_cd = hosp_cd;
	}
	public String getUrl_path() {
		return url_path;
	}
	public void setUrl_path(String url_path) {
		this.url_path = url_path;
	}
	public String getHosp_uuid() {
		return hosp_uuid;
	}
	public void setHosp_uuid(String hosp_uuid) {
		this.hosp_uuid = hosp_uuid;
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
	public String getUse_yn() {
		return use_yn;
	}
	public void setUse_yn(String use_yn) {
		this.use_yn = use_yn;
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
	public String getUser_nm() {
		return user_nm;
	}
	public void setUser_nm(String user_nm) {
		this.user_nm = user_nm;
	}
	public String getHosp_nm() {
		return hosp_nm;
	}
	public void setHosp_nm(String hosp_nm) {
		this.hosp_nm = hosp_nm;
	}

}
