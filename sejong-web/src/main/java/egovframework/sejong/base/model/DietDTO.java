package egovframework.sejong.base.model;

public class DietDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	private String iud   = "";    // 
	private String hosp_uuid; // 요양기관 UUID
    private String diet_gb; // 식대구분(직영/영양사/조리사/치료사)
    private String start_dt; // 적용일자
    private String end_dt; // 종료일자
    private String hosp_cd; // 요양기관번호
    private String bigo; // 비고
    private String reg_dttm; // 등록일시
    private String reg_user; // 등록자
    private String reg_ip; // 등록 IP
    private String upd_dttm; // 최종변경일시
    private String upd_user; // 최종변경자
    private String upd_ip; // 최종변경 IP
    private String hosp_nm ; // 병원명
    private String user_nm ; // 사용자명 
    private String sub_code_nm; // 서브명   
    private String use_yn ; 

	public String getUse_yn() {
		return use_yn;
	}
	public void setUse_yn(String use_yn) {
		this.use_yn = use_yn;
	}
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getHosp_uuid() {
		return hosp_uuid;
	}
	public void setHosp_uuid(String hosp_uuid) {
		this.hosp_uuid = hosp_uuid;
	}
	public String getDiet_gb() {
		return diet_gb;
	}
	public void setDiet_gb(String diet_gb) {
		this.diet_gb = diet_gb;
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
	public String getHosp_cd() {
		return hosp_cd;
	}
	public void setHosp_cd(String hosp_cd) {
		this.hosp_cd = hosp_cd;
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
	public String getHosp_nm() {
		return hosp_nm;
	}
	public void setHosp_nm(String hosp_nm) {
		this.hosp_nm = hosp_nm;
	}
	public String getUser_nm() {
		return user_nm;
	}
	public void setUser_nm(String user_nm) {
		this.user_nm = user_nm;
	}
	public String getSub_code_nm() {
		return sub_code_nm;
	}
	public void setSub_code_nm(String sub_code_nm) {
		this.sub_code_nm = sub_code_nm;
	}
    

}
