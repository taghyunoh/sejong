package egovframework.sejong.base.model;

public class LicworkDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud   = "";    // 
	private String hosp_uuid;
	private String hosp_cd ;
	private String user_nm ;
	private String hosp_nm ;
    private String seq;
    private String sub_code_nm;
    private String sub_dep_nm ;
    private String lic_num;
    private String lic_detail ;
    private String vac_gb;
    private String vac_start_dt;
    private String vac_end_dt;
    private String sub_name;
    private String sub_start_dt;
    private String sub_end_dt;
    private String ward_nm;
    private String ward_dan;
    private String ward_start_dt;
    private String ward_end_dt;
    private String ecch_yn;
    private String upd_dttm;
    private String upd_user;
    private String upd_ip;
    private String ip_dt ;
    private String te_dt ;

	public String getLic_detail() {
		return lic_detail;
	}
	public void setLic_detail(String lic_detail) {
		this.lic_detail = lic_detail;
	}
	public String getSub_dep_nm() {
		return sub_dep_nm;
	}
	public void setSub_dep_nm(String sub_dep_nm) {
		this.sub_dep_nm = sub_dep_nm;
	}
	public String getHosp_cd() {
		return hosp_cd;
	}
	public void setHosp_cd(String hosp_cd) {
		this.hosp_cd = hosp_cd;
	}
	public String getIp_dt() {
		return ip_dt;
	}
	public void setIp_dt(String ip_dt) {
		this.ip_dt = ip_dt;
	}
	public String getTe_dt() {
		return te_dt;
	}
	public void setTe_dt(String te_dt) {
		this.te_dt = te_dt;
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
	public String getSeq() {
		return seq;
	}
	public void setSeq(String seq) {
		this.seq = seq;
	}
	public String getSub_code_nm() {
		return sub_code_nm;
	}
	public void setSub_code_nm(String sub_code_nm) {
		this.sub_code_nm = sub_code_nm;
	}
	public String getLic_num() {
		return lic_num;
	}
	public void setLic_num(String lic_num) {
		this.lic_num = lic_num;
	}
	public String getVac_gb() {
		return vac_gb;
	}
	public void setVac_gb(String vac_gb) {
		this.vac_gb = vac_gb;
	}
	public String getVac_start_dt() {
		return vac_start_dt;
	}
	public void setVac_start_dt(String vac_start_dt) {
		this.vac_start_dt = vac_start_dt;
	}
	public String getVac_end_dt() {
		return vac_end_dt;
	}
	public void setVac_end_dt(String vac_end_dt) {
		this.vac_end_dt = vac_end_dt;
	}
	public String getSub_name() {
		return sub_name;
	}
	public void setSub_name(String sub_name) {
		this.sub_name = sub_name;
	}
	public String getSub_start_dt() {
		return sub_start_dt;
	}
	public void setSub_start_dt(String sub_start_dt) {
		this.sub_start_dt = sub_start_dt;
	}
	public String getSub_end_dt() {
		return sub_end_dt;
	}
	public void setSub_end_dt(String sub_end_dt) {
		this.sub_end_dt = sub_end_dt;
	}
	public String getWard_nm() {
		return ward_nm;
	}
	public void setWard_nm(String ward_nm) {
		this.ward_nm = ward_nm;
	}
	public String getWard_dan() {
		return ward_dan;
	}
	public void setWard_dan(String ward_dan) {
		this.ward_dan = ward_dan;
	}
	public String getWard_start_dt() {
		return ward_start_dt;
	}
	public void setWard_start_dt(String ward_start_dt) {
		this.ward_start_dt = ward_start_dt;
	}
	public String getWard_end_dt() {
		return ward_end_dt;
	}
	public void setWard_end_dt(String ward_end_dt) {
		this.ward_end_dt = ward_end_dt;
	}
	public String getEcch_yn() {
		return ecch_yn;
	}
	public void setEcch_yn(String ecch_yn) {
		this.ecch_yn = ecch_yn;
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
