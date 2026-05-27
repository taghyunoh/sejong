package egovframework.sejong.base.model;
public class CommonDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	private String errMsg;

	public String getErrMsg() { return errMsg; }
	public void setErrMsg(String errMsg) { this.errMsg = errMsg; }
}
