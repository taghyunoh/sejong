package egovframework.sejong.admin.model;

public class FaqDTO {
	private String faq_gb;
	private String qstn_conts;
	private String ansr_conts;
	private String use_yn;
	private String reg_id;
	private String reg_dtm;
	private String mod_id;
	private String mod_dtm;
	private String iud;
	private String faq_seq ;
	private String searchText;
	private String searchGb;
	
	public String getSearchGb() {
		return searchGb;
	}
	public void setSearchGb(String searchGb) {
		this.searchGb = searchGb;
	}
	public String getSearchText() {
		return searchText;
	}
	public void setSearchText(String searchText) {
		this.searchText = searchText;
	}
	public String getFaq_gb() {
		return faq_gb;
	}
	public void setFaq_gb(String faq_gb) {
		this.faq_gb = faq_gb;
	}
	public String getQstn_conts() {
		return qstn_conts;
	}
	public void setQstn_conts(String qstn_conts) {
		this.qstn_conts = qstn_conts;
	}
	public String getAnsr_conts() {
		return ansr_conts;
	}
	public void setAnsr_conts(String ansr_conts) {
		this.ansr_conts = ansr_conts;
	}
	public String getUse_yn() {
		return use_yn;
	}
	public void setUse_yn(String use_yn) {
		this.use_yn = use_yn;
	}
	public String getReg_id() {
		return reg_id;
	}
	public void setReg_id(String reg_id) {
		this.reg_id = reg_id;
	}
	public String getReg_dtm() {
		return reg_dtm;
	}
	public void setReg_dtm(String reg_dtm) {
		this.reg_dtm = reg_dtm;
	}
	public String getMod_id() {
		return mod_id;
	}
	public void setMod_id(String mod_id) {
		this.mod_id = mod_id;
	}
	public String getMod_dtm() {
		return mod_dtm;
	}
	public void setMod_dtm(String mod_dtm) {
		this.mod_dtm = mod_dtm;
	}
	public String getIud() {
		return iud;
	}
	public void setIud(String iud) {
		this.iud = iud;
	}
	public String getFaq_seq() {
		return faq_seq;
	}
	public void setFaq_seq(String faq_seq) {
		this.faq_seq = faq_seq;
	}
}
