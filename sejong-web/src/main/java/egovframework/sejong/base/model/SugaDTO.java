package egovframework.sejong.base.model;
public class SugaDTO {
	
	private String fee_code;        // 수가코드
    private String fee_type;        // 수가구분(일반/약가/재료)
    private String start_dt;        // 적용시작일자
    private String end_dt;          // 적용종료일자
    private String class_no;        // 
    private String kor_nm;          // 한글명
    private String eng_nm;          // 영문명
    private String div_type;        // 1-2구분
    private String surg_yn;         // 수술여부
    private String cln_price;   // 의원단가
    private String hos_price;   // 병원급이상단가
    private String dnt_price;   // 치과병의원단가
    private String pbl_price;   // 보건기관단가
    private String mid_price;   // 조산원단가
    private String orh_price;   // 한방병원단가
    private String rlt_value;   // 상대가치점수
    private String copay_50;        // 본인부담률50/100
    private String copay_80;        // 본인부담률80/100
    private String copay_90;        // 본인부담률90/100
    private String dup_yn;          // 중복인정여부
    private String calc_nm;         // 산정명칭
    private String sec_maj;         // 장구분
    private String sec_min;         // 절구분
    private String sub_cat;         // 세분류
    private String reg_dttm; // 등록일시
    private String reg_user;        // 등록자
    private String reg_ip;          // 등록 IP
    private String upd_dttm; // 최종변경일시
    private String upd_user;        // 최종변경자
    private String upd_ip;          // 최종변경 IP
    private String iud;
    private String excelfile;
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
	
    public String getExcelfile() {
		return excelfile;
	}
	public void setExcelfile(String excelfile) {
		this.excelfile = excelfile;
	}
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public  String getFee_code() {
		return fee_code;
	}
	public void setFee_code(String fee_code) {
		this.fee_code = fee_code;
	}
	public String getFee_type() {
		return fee_type;
	}
	public void setFee_type(String fee_type) {
		this.fee_type = fee_type;
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
	public String getClass_no() {
		return class_no;
	}
	public void setClass_no(String class_no) {
		this.class_no = class_no;
	}
	public String getKor_nm() {
		return kor_nm;
	}
	public void setKor_nm(String kor_nm) {
		this.kor_nm = kor_nm;
	}
	public String getEng_nm() {
		return eng_nm;
	}
	public void setEng_nm(String eng_nm) {
		this.eng_nm = eng_nm;
	}
	public String getDiv_type() {
		return div_type;
	}
	public void setDiv_type(String div_type) {
		this.div_type = div_type;
	}
	public String getSurg_yn() {
		return surg_yn;
	}
	public void setSurg_yn(String surg_yn) {
		this.surg_yn = surg_yn;
	}
	public String getCln_price() {
		return cln_price;
	}
	public void setCln_price(String cln_price) {
		this.cln_price = cln_price;
	}
	public String getHos_price() {
		return hos_price;
	}
	public void setHos_price(String hos_price) {
		this.hos_price = hos_price;
	}
	public String getDnt_price() {
		return dnt_price;
	}
	public void setDnt_price(String dnt_price) {
		this.dnt_price = dnt_price;
	}
	public String getPbl_price() {
		return pbl_price;
	}
	public void setPbl_price(String pbl_price) {
		this.pbl_price = pbl_price;
	}
	public String getMid_price() {
		return mid_price;
	}
	public void setMid_price(String mid_price) {
		this.mid_price = mid_price;
	}
	public String getOrh_price() {
		return orh_price;
	}
	public void setOrh_price(String orh_price) {
		this.orh_price = orh_price;
	}
	public String getRlt_value() {
		return rlt_value;
	}
	public void setRlt_value(String rlt_value) {
		this.rlt_value = rlt_value;
	}
	public String getCopay_50() {
		return copay_50;
	}
	public void setCopay_50(String copay_50) {
		this.copay_50 = copay_50;
	}
	public String getCopay_80() {
		return copay_80;
	}
	public void setCopay_80(String copay_80) {
		this.copay_80 = copay_80;
	}
	public String getCopay_90() {
		return copay_90;
	}
	public void setCopay_90(String copay_90) {
		this.copay_90 = copay_90;
	}
	public String getDup_yn() {
		return dup_yn;
	}
	public void setDup_yn(String dup_yn) {
		this.dup_yn = dup_yn;
	}
	public String getCalc_nm() {
		return calc_nm;
	}
	public void setCalc_nm(String calc_nm) {
		this.calc_nm = calc_nm;
	}
	public String getSec_maj() {
		return sec_maj;
	}
	public void setSec_maj(String sec_maj) {
		this.sec_maj = sec_maj;
	}
	public String getSec_min() {
		return sec_min;
	}
	public void setSec_min(String sec_min) {
		this.sec_min = sec_min;
	}
	public String getSub_cat() {
		return sub_cat;
	}
	public void setSub_cat(String sub_cat) {
		this.sub_cat = sub_cat;
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