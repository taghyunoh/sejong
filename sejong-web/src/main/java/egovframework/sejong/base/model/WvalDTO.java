package egovframework.sejong.base.model;
public class WvalDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud   = "";    
    private String cate_code; // 분류코드
    private int order_seq; // 분류순서
    private String start_dt; // 시작일자
    private String cal_gubun; // 점수구분(1.접수/2.율)
    private String wevalue_nm; // 명칭
    private String start_indi; // 시작지표
    private String end_indi; // 지표종료
    private String std_score; // 표준화점수
    private String we_value; // 가중치
    private String reg_dttm; // 입력일시
    private String reg_user; // 입력자
    private String reg_ip; // 입력IP
    private String upd_dttm; // 수정일시
    private String upd_user; // 수정자
    private String upd_ip; // 수정IP  
    private  int maxcnt ;
    
	public int getMaxcnt() {
		return maxcnt;
	}
	public void setMaxcnt(int maxcnt) {
		this.maxcnt = maxcnt;
	}
	public  String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getCate_code() {
		return cate_code;
	}
	public void setCate_code(String cate_code) {
		this.cate_code = cate_code;
	}
	public int getOrder_seq() {
		return order_seq;
	}
	public void setOrder_seq(int order_seq) {
		this.order_seq = order_seq;
	}
	public String getStart_dt() {
		return start_dt;
	}
	public void setStart_dt(String start_dt) {
		this.start_dt = start_dt;
	}
	public String getCal_gubun() {
		return cal_gubun;
	}
	public void setCal_gubun(String cal_gubun) {
		this.cal_gubun = cal_gubun;
	}
	public String getWevalue_nm() {
		return wevalue_nm;
	}
	public void setWevalue_nm(String wevalue_nm) {
		this.wevalue_nm = wevalue_nm;
	}
	public String getStart_indi() {
		return start_indi;
	}
	public void setStart_indi(String start_indi) {
		this.start_indi = start_indi;
	}
	public String getEnd_indi() {
		return end_indi;
	}
	public void setEnd_indi(String end_indi) {
		this.end_indi = end_indi;
	}
	public String getStd_score() {
		return std_score;
	}
	public void setStd_score(String std_score) {
		this.std_score = std_score;
	}
	public String getWe_value() {
		return we_value;
	}
	public void setWe_value(String we_value) {
		this.we_value = we_value;
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
