package egovframework.sejong.base.model;
public class HospConDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud   = "";   
	private String iud2   = "";
	private String hosp_uuid;
	private String hosp_uuid2;
	private String hosp_cd2;
	private String start_dt2;
	private String end_dt2;

	private String sub_code_nm ;
    private String start_dt;
    private String end_dt;
    private String conact_gb;
    private String hosp_cd;
    private String con_content;
    private String con_user_id;
    private String con_user_tel;
    private String con_email;
    private String ocs_company;
    private String ocs_user_id;
    private String ocs_user_pw;
    private String join_dt;
    private String accept_dt;
    private String close_dt;
    private String join_dt2;
    private String accept_dt2;
    private String close_dt2;
    private String use_yn;
    private String reg_dttm;
    private String reg_user;
    private String reg_ip;
    private String upd_dttm;
    private String upd_user;
    private String upd_ip;

    // Getters and Setters

    public String getAccept_dt() {
		return accept_dt;
	}

	public void setAccept_dt(String accept_dt) {
		this.accept_dt = accept_dt;
	}

	public String getAccept_dt2() {
		return accept_dt2;
	}

	public void setAccept_dt2(String accept_dt2) {
		this.accept_dt2 = accept_dt2;
	}

	public String getIud2() {
		return iud2;
	}

	public String getSub_code_nm() {
		return sub_code_nm;
	}

	public void setSub_code_nm(String sub_code_nm) {
		this.sub_code_nm = sub_code_nm;
	}

	public void setIud2(String iud2) {
		this.iud2 = iud2;
	}

	public String getIud() {
		return iud;
	}

	public String getJoin_dt2() {
		return join_dt2;
	}

	public void setJoin_dt2(String join_dt2) {
		this.join_dt2 = join_dt2;
	}

	public String getClose_dt2() {
		return close_dt2;
	}

	public void setClose_dt2(String close_dt2) {
		this.close_dt2 = close_dt2;
	}

	public String getHosp_uuid2() {
		return hosp_uuid2;
	}

	public void setHosp_uuid2(String hosp_uuid2) {
		this.hosp_uuid2 = hosp_uuid2;
	}

	public String getHosp_cd2() {
		return hosp_cd2;
	}

	public void setHosp_cd2(String hosp_cd2) {
		this.hosp_cd2 = hosp_cd2;
	}

	public String getStart_dt2() {
		return start_dt2;
	}

	public void setStart_dt2(String start_dt2) {
		this.start_dt2 = start_dt2;
	}

	public String getEnd_dt2() {
		return end_dt2;
	}

	public void setEnd_dt2(String end_dt2) {
		this.end_dt2 = end_dt2;
	}

	public void setIud(String iud) {
		this.iud = iud;
	}

	public void setReg_dttm(String reg_dttm) {
		this.reg_dttm = reg_dttm;
	}

	public void setUpd_dttm(String upd_dttm) {
		this.upd_dttm = upd_dttm;
	}

	public String getHosp_uuid() {
        return hosp_uuid;
    }

    public String getReg_dttm() {
		return reg_dttm;
	}

	public String getUpd_dttm() {
		return upd_dttm;
	}

	public void setHosp_uuid(String hosp_uuid) {
        this.hosp_uuid = hosp_uuid;
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

    public String getConact_gb() {
        return conact_gb;
    }

    public void setConact_gb(String conact_gb) {
        this.conact_gb = conact_gb;
    }

    public String getHosp_cd() {
        return hosp_cd;
    }

    public void setHosp_cd(String hosp_cd) {
        this.hosp_cd = hosp_cd;
    }

    public String getCon_content() {
        return con_content;
    }

    public void setCon_content(String con_content) {
        this.con_content = con_content;
    }

    public String getCon_user_id() {
        return con_user_id;
    }

    public void setCon_user_id(String con_user_id) {
        this.con_user_id = con_user_id;
    }

    public String getCon_user_tel() {
        return con_user_tel;
    }

    public void setCon_user_tel(String con_user_tel) {
        this.con_user_tel = con_user_tel;
    }

    public String getCon_email() {
        return con_email;
    }

    public void setCon_email(String con_email) {
        this.con_email = con_email;
    }

    public String getOcs_company() {
        return ocs_company;
    }

    public void setOcs_company(String ocs_company) {
        this.ocs_company = ocs_company;
    }

    public String getOcs_user_id() {
        return ocs_user_id;
    }

    public void setOcs_user_id(String ocs_user_id) {
        this.ocs_user_id = ocs_user_id;
    }

    public String getOcs_user_pw() {
        return ocs_user_pw;
    }

    public void setOcs_user_pw(String ocs_user_pw) {
        this.ocs_user_pw = ocs_user_pw;
    }

    public String getJoin_dt() {
        return join_dt;
    }

    public void setJoin_dt(String join_dt) {
        this.join_dt = join_dt;
    }

    public String getClose_dt() {
        return close_dt;
    }

    public void setClose_dt(String close_dt) {
        this.close_dt = close_dt;
    }

    public String getUse_yn() {
        return use_yn;
    }

    public void setUse_yn(String use_yn) {
        this.use_yn = use_yn;
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
