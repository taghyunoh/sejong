package egovframework.sejong.exer.model;

public class ExerDTO {
	private int exerSeq;
	private String userUuid;
	private String exerDate;
	private String exerStime;
	private String exerEtime;
	private String exerName;
	private String exerInt;
	private Integer exerCnt;
	private String regDttm;
	private String modDttm;

	public int getExerSeq() { return exerSeq; }
	public void setExerSeq(int exerSeq) { this.exerSeq = exerSeq; }

	public String getUserUuid() { return userUuid; }
	public void setUserUuid(String userUuid) { this.userUuid = userUuid; }

	public String getExerDate() { return exerDate; }
	public void setExerDate(String exerDate) { this.exerDate = exerDate; }

	public String getExerStime() { return exerStime; }
	public void setExerStime(String exerStime) { this.exerStime = exerStime; }

	public String getExerEtime() { return exerEtime; }
	public void setExerEtime(String exerEtime) { this.exerEtime = exerEtime; }

	public String getExerName() { return exerName; }
	public void setExerName(String exerName) { this.exerName = exerName; }

	public String getExerInt() { return exerInt; }
	public void setExerInt(String exerInt) { this.exerInt = exerInt; }

	public Integer getExerCnt() { return exerCnt; }
	public void setExerCnt(Integer exerCnt) { this.exerCnt = exerCnt; }

	public String getRegDttm() { return regDttm; }
	public void setRegDttm(String regDttm) { this.regDttm = regDttm; }

	public String getModDttm() { return modDttm; }
	public void setModDttm(String modDttm) { this.modDttm = modDttm; }
}
