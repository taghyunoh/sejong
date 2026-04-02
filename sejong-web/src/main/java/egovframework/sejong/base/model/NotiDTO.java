package egovframework.sejong.base.model;
public class NotiDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud   = "";    
	private String noti_seq;          // 작성순서
    private String file_gb;        // 공지사항('1'), 심사방('2'), 소식지('3')
    private String start_dt;       // 공지 시작일자
    private String end_dt;         // 공지 종료일자
    private String use_yn;         // 사용여부
    private String hosp_cd;        // 요양기관(특정병원에만 올릴경우)
    private String noti_title;     // 공지 제목
    private String noti_content;   // 공지 세부내용
    private String update_sw;      // 등록 구분
    private String noti_redcnt;       // 읽기 카운트
    private String reg_dttm;   // 등록 일시
    private String reg_user;       // 등록자
    private String reg_ip;         // 등록 IP
    private String upd_dttm;   // 최종 변경 일시
    private String upd_user;       // 최종 변경자
    private String upd_ip;         // 최종 변경 IP
    private String searchText;
	private String start_date;
	private String end_date;
	private String user_nm;
	private String sub_code_nm;
	private String noti_nm ;
	private String hosp_uuid ;
	public String getHosp_uuid() {
		return hosp_uuid;
	}
	public void setHosp_uuid(String hosp_uuid) {
		this.hosp_uuid = hosp_uuid;
	}

	public String getNoti_nm() {
		return noti_nm;
	}
	public void setNoti_nm(String noti_nm) {
		this.noti_nm = noti_nm;
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
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getNoti_seq() {
		return noti_seq;
	}
	public void setNoti_seq(String noti_seq) {
		this.noti_seq = noti_seq;
	}
	public String getFile_gb() {
		return file_gb;
	}
	public void setFile_gb(String file_gb) {
		this.file_gb = file_gb;
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
	public String getHosp_cd() {
		return hosp_cd;
	}
	public void setHosp_cd(String hosp_cd) {
		this.hosp_cd = hosp_cd;
	}
	public String getNoti_title() {
		return noti_title;
	}
	public void setNoti_title(String noti_title) {
		this.noti_title = noti_title;
	}
	public String getNoti_content() {
		return noti_content;
	}
	public void setNoti_content(String noti_content) {
		this.noti_content = noti_content;
	}
	public String getUpdate_sw() {
		return update_sw;
	}
	public void setUpdate_sw(String update_sw) {
		this.update_sw = update_sw;
	}
	public String getNoti_redcnt() {
		return noti_redcnt;
	}
	public void setNoti_redcnt(String noti_redcnt) {
		this.noti_redcnt = noti_redcnt;
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
	public String getSearchText() {
		return searchText;
	}
	public void setSearchText(String searchText) {
		this.searchText = searchText;
	}
    
}