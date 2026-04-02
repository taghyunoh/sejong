package egovframework.sejong.admin.model;

public class CommDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud            = "";    // 
	private String code           = "";    // 공통코드
	private String code_name      = "";    // 공통코드명
	private String start_date     = "";    // 적용시작일
	private String end_date       = "";    // 적용종료일
	private String use_yn         = "";    // 사용여부
	private String dtl_code       = "";    // 상세코드
	private String dtl_code_nm    = "";    // 상세코드명
	private String sort           = "";    // 정렬순서

	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
	}
	public String getCode_name() {
		return code_name;
	}
	public void setCode_name(String code_name) {
		this.code_name = code_name;
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
	public String getUse_yn() {
		return use_yn;
	}
	public void setUse_yn(String use_yn) {
		this.use_yn = use_yn;
	}
	public String getDtl_code() {
		return dtl_code;
	}
	public void setDtl_code(String dtl_code) {
		this.dtl_code = dtl_code;
	}
	public String getDtl_code_nm() {
		return dtl_code_nm;
	}
	public void setDtl_code_nm(String dtl_code_nm) {
		this.dtl_code_nm = dtl_code_nm;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
	
}
