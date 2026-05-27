package egovframework.sejong.base.model;
public class UsermDTO extends CommonDTO {
	private String iud  = "";
	private String hospCd;       // 요양기관번호
	private String userId;       // 사용자 ID
	private String userNm;       // 사용자명
	private String startDt;      // 적용시작일자
	private String endDt;        // 적용종료일자
	private String mainGu;       // 관리자구분
	private String passWd;       // 비밀번호
	private String passCdt;      // 패스워드 변경일자
	private String bigo;         // 비고
	private String regDttm;      // 등록일시
	private String regUser;      // 등록자
	private String regIp;        // 등록 IP
	private String updDttm;      // 최종변경일시
	private String updUser;      // 최종변경자
	private String updIp;        // 최종변경 IP
	private String afPassWd;
	private String bfPassWd;
	private String encPassWd;
	private String useYn;
	private String hospUuid;
	private String winnerYn;
	private String email;
	private String userTel;

	public String getEmail() { return email; }
	public void setEmail(String email) { this.email = email; }

	public String getUserTel() { return userTel; }
	public void setUserTel(String userTel) { this.userTel = userTel; }

	public String getWinnerYn() { return winnerYn; }
	public void setWinnerYn(String winnerYn) { this.winnerYn = winnerYn; }

	public String getHospUuid() { return hospUuid; }
	public void setHospUuid(String hospUuid) { this.hospUuid = hospUuid; }

	public String getUseYn() { return useYn; }
	public void setUseYn(String useYn) { this.useYn = useYn; }

	public String getEncPassWd() { return encPassWd; }
	public void setEncPassWd(String encPassWd) { this.encPassWd = encPassWd; }

	public String getBfPassWd() { return bfPassWd; }
	public void setBfPassWd(String bfPassWd) { this.bfPassWd = bfPassWd; }

	public String getIud() { return iud; }
	public void setIud(String iud) { this.iud = iud; }

	public String getAfPassWd() { return afPassWd; }
	public void setAfPassWd(String afPassWd) { this.afPassWd = afPassWd; }

	public String getHospCd() { return hospCd; }
	public void setHospCd(String hospCd) { this.hospCd = hospCd; }

	public String getUserId() { return userId; }
	public void setUserId(String userId) { this.userId = userId; }

	public String getUserNm() { return userNm; }
	public void setUserNm(String userNm) { this.userNm = userNm; }

	public String getStartDt() { return startDt; }
	public void setStartDt(String startDt) { this.startDt = startDt; }

	public String getEndDt() { return endDt; }
	public void setEndDt(String endDt) { this.endDt = endDt; }

	public String getMainGu() { return mainGu; }
	public void setMainGu(String mainGu) { this.mainGu = mainGu; }

	public String getPassWd() { return passWd; }
	public void setPassWd(String passWd) { this.passWd = passWd; }

	public String getPassCdt() { return passCdt; }
	public void setPassCdt(String passCdt) { this.passCdt = passCdt; }

	public String getBigo() { return bigo; }
	public void setBigo(String bigo) { this.bigo = bigo; }

	public String getRegDttm() { return regDttm; }
	public void setRegDttm(String regDttm) { this.regDttm = regDttm; }

	public String getRegUser() { return regUser; }
	public void setRegUser(String regUser) { this.regUser = regUser; }

	public String getRegIp() { return regIp; }
	public void setRegIp(String regIp) { this.regIp = regIp; }

	public String getUpdDttm() { return updDttm; }
	public void setUpdDttm(String updDttm) { this.updDttm = updDttm; }

	public String getUpdUser() { return updUser; }
	public void setUpdUser(String updUser) { this.updUser = updUser; }

	public String getUpdIp() { return updIp; }
	public void setUpdIp(String updIp) { this.updIp = updIp; }
}
