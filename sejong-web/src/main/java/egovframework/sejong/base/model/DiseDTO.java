package egovframework.sejong.base.model;
public class DiseDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud   = "";    
    private String diag_code; // 상병코드(KCD)
    private String start_dt; // 적용시작일자
    private String kor_diag_name; // 한글상병명
    private String eng_diag_name; // 영문상병명
    private String gender_type; // 성별구분
    private String infect_type; // 법정감염병구분
    private String diag_type; // 상병구분
    private String icd10_code; // ICD10코드
    private String end_dt; // 적용종료일자
    private Integer max_age; // 상한연령
    private Integer min_age; // 하한연령
    private String vcode; // V코드 정보
    private String desc_info; // 설명
    private String reg_dttm; // 등록일시
    private String reg_user; // 등록자
    private String reg_ip; // 등록 IP
    private String upd_dttm; // 최종변경일시
    private String upd_user; // 최종변경자
    private String upd_ip; // 최종변경 IP
	
    private int pageIndex; // 시작 인덱스
	private int pageSize;  // 한 페이지 당 데이터 개수
	
    public int getPageIndex() {
		return pageIndex;
	}
	public void setPageIndex(int pageIndex) {
		this.pageIndex = pageIndex;
	}
	public int getPageSize() {
		return pageSize;
	}
	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}
   
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getDiag_code() {
		return diag_code;
	}
	public void setDiag_code(String diag_code) {
		this.diag_code = diag_code;
	}
	public String getStart_dt() {
		return start_dt;
	}
	public void setStart_dt(String start_dt) {
		this.start_dt = start_dt;
	}
	public String getKor_diag_name() {
		return kor_diag_name;
	}
	public void setKor_diag_name(String kor_diag_name) {
		this.kor_diag_name = kor_diag_name;
	}
	public String getEng_diag_name() {
		return eng_diag_name;
	}
	public void setEng_diag_name(String eng_diag_name) {
		this.eng_diag_name = eng_diag_name;
	}
	public String getGender_type() {
		return gender_type;
	}
	public void setGender_type(String gender_type) {
		this.gender_type = gender_type;
	}
	public String getInfect_type() {
		return infect_type;
	}
	public void setInfect_type(String infect_type) {
		this.infect_type = infect_type;
	}
	public String getDiag_type() {
		return diag_type;
	}
	public void setDiag_type(String diag_type) {
		this.diag_type = diag_type;
	}
	public String getIcd10_code() {
		return icd10_code;
	}
	public void setIcd10_code(String icd10_code) {
		this.icd10_code = icd10_code;
	}
	public String getEnd_dt() {
		return end_dt;
	}
	public void setEnd_dt(String end_dt) {
		this.end_dt = end_dt;
	}
	public Integer getMax_age() {
		return max_age;
	}
	public void setMax_age(Integer max_age) {
		this.max_age = max_age;
	}
	public Integer getMin_age() {
		return min_age;
	}
	public void setMin_age(Integer min_age) {
		this.min_age = min_age;
	}
	public String getVcode() {
		return vcode;
	}
	public void setVcode(String vcode) {
		this.vcode = vcode;
	}
	public String getDesc_info() {
		return desc_info;
	}
	public void setDesc_info(String desc_info) {
		this.desc_info = desc_info;
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
