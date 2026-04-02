package egovframework.sejong.exercise.model;

public class ExerciseDTO {
	private String exerSeq;
	private String userUuid;
	private String exerDate;
	private String exerStime;
	private String exerEtime;
	private String exerName;
	private String exerCnt;
	private String exerInt;
	private String regDttm;
	private String modDttm;
	private String startDt;
	private String endDt;
	private String exerMinutes;
	
	public String getExerMinutes() {
		return exerMinutes;
	}
	public void setExerMinutes(String exerMinutes) {
		this.exerMinutes = exerMinutes;
	}
	public String getExerSeq() {
		return exerSeq;
	}
	public void setExerSeq(String exerSeq) {
		this.exerSeq = exerSeq;
	}

	public String getStartDt() {
		return startDt;
	}
	public void setStartDt(String startDt) {
		this.startDt = startDt;
	}
	public String getEndDt() {
		return endDt;
	}
	public void setEndDt(String endDt) {
		this.endDt = endDt;
	}
	public String getExerInt() {
		return exerInt;
	}
	public void setExerInt(String exerInt) {
		this.exerInt = exerInt;
	}
	public String getUserUuid() {
		return userUuid;
	}
	public void setUserUuid(String userUuid) {
		this.userUuid = userUuid;
	}
	public String getExerDate() {
		return exerDate;
	}
	public void setExerDate(String exerDate) {
		this.exerDate = exerDate;
	}
	public String getExerStime() {
		return exerStime;
	}
	public void setExerStime(String exerStime) {
		this.exerStime = exerStime;
	}
	public String getExerEtime() {
		return exerEtime;
	}
	public void setExerEtime(String exerEtime) {
		this.exerEtime = exerEtime;
	}
	public String getExerName() {
		return exerName;
	}
	public void setExerName(String exerName) {
		this.exerName = exerName;
	}
	public String getExerCnt() {
		return exerCnt;
	}
	public void setExerCnt(String exerCnt) {
		this.exerCnt = exerCnt;
	}
	public String getRegDttm() {
		return regDttm;
	}
	public void setRegDttm(String regDttm) {
		this.regDttm = regDttm;
	}
	public String getModDttm() {
		return modDttm;
	}
	public void setModDttm(String modDttm) {
		this.modDttm = modDttm;
	}

}
