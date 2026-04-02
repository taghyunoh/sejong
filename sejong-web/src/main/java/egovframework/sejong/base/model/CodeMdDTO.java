package egovframework.sejong.base.model;

public class CodeMdDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	
	private String iud   = "";    // 
    private String code_cd; // 코드(DTL같이 씀)
    private String code_nm; // 코드명
    private String start_dt; // 적용시작일자
    private String end_dt; // 적용종료일자
    private String use_yn; // 사용여부
    private String reg_dttm; // 등록일시
    private String reg_user; // 등록자
    private String reg_ip; // 등록 IP
    private String upd_dttm; // 최종변경일시
    private String upd_user; // 최종변경자
    private String upd_ip; // 최종변경 IP

    // TBL_CODE_DTL 추가 필드
    private String code_gb; // 코드구분
    private String sub_code; // 상세코드
    private String sub_code_nm; // 상세코드명
    private String dtl_code; // 상세코드
    private String dtl_code_nm; // 상세코드명   
    private Integer sort; // 정렬순서

    private String prop_1; // 
    private String prop_2; // 
    private String prop_3; // 
    private String prop_4; // 
    private String prop_5; // 
    

	public String getProp_1() {
		return prop_1;
	}

	public void setProp_1(String prop_1) {
		this.prop_1 = prop_1;
	}

	public String getProp_2() {
		return prop_2;
	}

	public void setProp_2(String prop_2) {
		this.prop_2 = prop_2;
	}

	public String getProp_3() {
		return prop_3;
	}

	public void setProp_3(String prop_3) {
		this.prop_3 = prop_3;
	}

	public String getProp_4() {
		return prop_4;
	}

	public void setProp_4(String prop_4) {
		this.prop_4 = prop_4;
	}

	public String getProp_5() {
		return prop_5;
	}

	public void setProp_5(String prop_5) {
		this.prop_5 = prop_5;
	}

	public String getCode_cd() {
        return code_cd;
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

	public String getIud() {
		return iud;
	}

	public void setIud(String iud) {
		this.iud = iud;
	}

	public void setCode_cd(String code_cd) {
        this.code_cd = code_cd;
    }

    public String getCode_nm() {
        return code_nm;
    }

    public void setCode_nm(String code_nm) {
        this.code_nm = code_nm;
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

    public String getUse_yn() {
        return use_yn;
    }

    public void setUse_yn(String use_yn) {
        this.use_yn = use_yn;
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

    public String getCode_gb() {
        return code_gb;
    }

    public void setCode_gb(String code_gb) {
        this.code_gb = code_gb;
    }

    public String getSub_code() {
        return sub_code;
    }

    public void setSub_code(String sub_code) {
        this.sub_code = sub_code;
    }

    public String getSub_code_nm() {
        return sub_code_nm;
    }

    public void setSub_code_nm(String sub_code_nm) {
        this.sub_code_nm = sub_code_nm;
    }

    public Integer getSort() {
        return sort;
    }

    public void setSort(Integer sort) {
        this.sort = sort;
    }
}
