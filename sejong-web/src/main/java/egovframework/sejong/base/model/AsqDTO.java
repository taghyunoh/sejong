package egovframework.sejong.base.model;

public class AsqDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	private String iud   = "";    // 
	private String hosp_cd;           // 요양기관
    private String asq_seq;              // SEQ
    private String file_gb;           // 파일 구분
    private String qstn_title;        // 질문 제목
    private String qstn_conts;        // 질문 내용
    private String asq_share;         // 전체 공유
    private String ansr_conts;        // 답변 내용
    private String update_sw;         // 등록 구분
    private String reg_dttm;   // 등록 일시
    private String reg_user;          // 등록자
    private String reg_ip;            // 등록 IP
    private String upd_dttm;   // 최종 변경 일시
    private String upd_user;          // 최종 변경자
    private String upd_ip;            // 최종 변경 IP
    private String ansr_dttm;  // 답변 일자
    private String ansr_user;         // 답변자
    private String ansr_ip;           // 답변 IP
    private String ansr_upd_dttm; // 답변 변경 일자
    private String ansr_upd_user;      // 답변 변경자
    private String ansr_upd_ip;        // 답변 변경 IP
	private String hosp_uuid ;
	private String user_nm ;
	private String hosp_nm ;
	private String qstn_wan ;
	private String ansr_wan ;
	private String qstn_stat ;
	private String ansr_stat ; 
	
	public String getQstn_stat() {
		return qstn_stat;
	}
	public void setQstn_stat(String qstn_stat) {
		this.qstn_stat = qstn_stat;
	}
	public String getAnsr_stat() {
		return ansr_stat;
	}
	public void setAnsr_stat(String ansr_stat) {
		this.ansr_stat = ansr_stat;
	}
	public String getQstn_wan() {
		return qstn_wan;
	}
	public void setQstn_wan(String qstn_wan) {
		this.qstn_wan = qstn_wan;
	}
	public String getAnsr_wan() {
		return ansr_wan;
	}
	public void setAnsr_wan(String ansr_wan) {
		this.ansr_wan = ansr_wan;
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
	public String getHosp_uuid() {
		return hosp_uuid;
	}
	public void setHosp_uuid(String hosp_uuid) {
		this.hosp_uuid = hosp_uuid;
	}

    
    public String getRead_cnt() {
		return read_cnt;
	}
	public void setRead_cnt(String read_cnt) {
		this.read_cnt = read_cnt;
	}

	private String read_cnt ;

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
	public String getAsq_seq() {
		return asq_seq;
	}
	public void setAsq_seq(String asq_seq) {
		this.asq_seq = asq_seq;
	}
	public String getFile_gb() {
		return file_gb;
	}
	public void setFile_gb(String file_gb) {
		this.file_gb = file_gb;
	}
	public String getQstn_title() {
		return qstn_title;
	}
	public void setQstn_title(String qstn_title) {
		this.qstn_title = qstn_title;
	}
	public String getQstn_conts() {
		return qstn_conts;
	}
	public void setQstn_conts(String qstn_conts) {
		this.qstn_conts = qstn_conts;
	}
	public String getAsq_share() {
		return asq_share;
	}
	public void setAsq_share(String asq_share) {
		this.asq_share = asq_share;
	}
	public String getAnsr_conts() {
		return ansr_conts;
	}
	public void setAnsr_conts(String ansr_conts) {
		this.ansr_conts = ansr_conts;
	}
	public String getUpdate_sw() {
		return update_sw;
	}
	public void setUpdate_sw(String update_sw) {
		this.update_sw = update_sw;
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
	public String getAnsr_dttm() {
		return ansr_dttm;
	}
	public void setAnsr_dttm(String ansr_dttm) {
		this.ansr_dttm = ansr_dttm;
	}
	public String getAnsr_user() {
		return ansr_user;
	}
	public void setAnsr_user(String ansr_user) {
		this.ansr_user = ansr_user;
	}
	public String getAnsr_ip() {
		return ansr_ip;
	}
	public void setAnsr_ip(String ansr_ip) {
		this.ansr_ip = ansr_ip;
	}
	public String getAnsr_upd_dttm() {
		return ansr_upd_dttm;
	}
	public void setAnsr_upd_dttm(String ansr_upd_dttm) {
		this.ansr_upd_dttm = ansr_upd_dttm;
	}
	public String getAnsr_upd_user() {
		return ansr_upd_user;
	}
	public void setAnsr_upd_user(String ansr_upd_user) {
		this.ansr_upd_user = ansr_upd_user;
	}
	public String getAnsr_upd_ip() {
		return ansr_upd_ip;
	}
	public void setAnsr_upd_ip(String ansr_upd_ip) {
		this.ansr_upd_ip = ansr_upd_ip;
	}

}
