package egovframework.sejong.base.model;
public class MberDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud   = "";  
	private String email;           // 이메일
    private String hosp_cd;         // 병원코드
    private String hosp_nm;         // 병원명
    private String pass_wd;         // 패스워드
    private String af_pass_wd ;
    private String mbr_nm;        // 담당자명
    private String job_nm;        // 담당자명
    private String mbr_tel;         // 담당자 전화번호
    private String per_use_cd;      // 이용약관코드
    private String per_use_red;      // 이용약관코드
    private String per_use_yn;      // 이용약관 동의
    private String per_info_cd;     // 개인정보 수집 및 이용 동의코드
    private String per_info_red ;
    private String per_info_yn;     // 개인정보 수집 및 이용 동의
    private String per_pro_cd;      // 개인정보 처리위탁코드
    private String per_pro_red ;
    private String per_pro_yn;      // 개인정보 처리위탁
    private String join_dt;         // 가입일자
    private String reg_dttm;          // 등록일시
    private String reg_user;        // 등록 사용자
    private String reg_ip;          // 등록 IP
    private String upd_dttm;          // 수정일시
    private String upd_user;        // 수정 사용자
    private String upd_ip;          // 수정 IP
    private String peruseyn;
    private String perinfoyn;
    private String perproyn;
    private String use_yn;
    private String user_id;
    private String per_use_nm;      // 이용약관코드
    private String per_info_nm;      // 이용약관코드
    private String per_pro_nm;      // 이용약관코드
    private String hosp_uuid ;
    
    private String sub_nm;      // 이용약관코드
    private String start_dt;      // 이용약관코드
    private String end_dt ;
    
    private String sub_nm1;      // 이용약관코드
    private String start_dt1;      // 이용약관코드
    private String end_dt1 ;
    
	public String getSub_nm() {
		return sub_nm;
	}


	public void setSub_code_nm(String sub_nm) {
		this.sub_nm = sub_nm;
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


	public String getSub_nm1() {
		return sub_nm1;
	}


	public void setSub_code_nm1(String sub_nm1) {
		this.sub_nm1 = sub_nm1;
	}


	public String getStart_dt1() {
		return start_dt1;
	}


	public void setStart_dt1(String start_dt1) {
		this.start_dt1 = start_dt1;
	}


	public String getEnd_dt1() {
		return end_dt1;
	}


	public void setEnd_dt1(String end_dt1) {
		this.end_dt1 = end_dt1;
	}


	public String getHosp_uuid() {
		return hosp_uuid;
	}


	public void setHosp_uuid(String hosp_uuid) {
		this.hosp_uuid = hosp_uuid;
	}


	public String getUse_yn() {
		return use_yn;
	}


	public void setUse_yn(String use_yn) {
		this.use_yn = use_yn;
	}


	public String getUser_id() {
		return user_id;
	}


	public void setUser_id(String user_id) {
		this.user_id = user_id;
	}


	public String getPer_use_nm() {
		return per_use_nm;
	}


	public void setPer_use_nm(String per_use_nm) {
		this.per_use_nm = per_use_nm;
	}


	public String getPer_info_nm() {
		return per_info_nm;
	}


	public void setPer_info_nm(String per_info_nm) {
		this.per_info_nm = per_info_nm;
	}


	public String getPer_pro_nm() {
		return per_pro_nm;
	}


	public void setPer_pro_nm(String per_pro_nm) {
		this.per_pro_nm = per_pro_nm;
	}


	// Getters and Setters
	public String getIud() {
		return iud;
	}


	public String getJob_nm() {
		return job_nm;
	}


	public void setJob_nm(String job_nm) {
		this.job_nm = job_nm;
	}


	public String getPeruseyn() {
		return peruseyn;
	}


	public void setPeruseyn(String peruseyn) {
		this.peruseyn = peruseyn;
	}


	public String getPerinfoyn() {
		return perinfoyn;
	}


	public void setPerinfoyn(String perinfoyn) {
		this.perinfoyn = perinfoyn;
	}


	public String getPerproyn() {
		return perproyn;
	}


	public void setPerproyn(String perproyn) {
		this.perproyn = perproyn;
	}


	public void setMbr_nm(String mbr_nm) {
		this.mbr_nm = mbr_nm;
	}


	public String getPer_use_cd() {
		return per_use_cd;
	}


	public void setPer_use_cd(String per_use_cd) {
		this.per_use_cd = per_use_cd;
	}


	public String getPer_use_red() {
		return per_use_red;
	}


	public void setPer_use_red(String per_use_red) {
		this.per_use_red = per_use_red;
	}


	public String getPer_use_yn() {
		return per_use_yn;
	}


	public void setPer_use_yn(String per_use_yn) {
		this.per_use_yn = per_use_yn;
	}


	public String getPer_info_red() {
		return per_info_red;
	}

	public void setPer_info_red(String per_info_red) {
		this.per_info_red = per_info_red;
	}

	public String getPer_pro_red() {
		return per_pro_red;
	}

	public void setPer_pro_red(String per_pro_red) {
		this.per_pro_red = per_pro_red;
	}

	public void setIud(String iud) {
		this.iud = iud;
	}

	public String getAf_pass_wd() {
		return af_pass_wd;
	}

	public void setAf_pass_wd(String af_pass_wd) {
		this.af_pass_wd = af_pass_wd;
	}
	
	public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getHosp_cd() {
        return hosp_cd;
    }

    public void setHosp_cd(String hosp_cd) {
        this.hosp_cd = hosp_cd;
    }

    public String getHosp_nm() {
        return hosp_nm;
    }

    public void setHosp_nm(String hosp_nm) {
        this.hosp_nm = hosp_nm;
    }

    public String getPass_wd() {
        return pass_wd;
    }

    public void setPass_wd(String pass_wd) {
        this.pass_wd = pass_wd;
    }

    public String getMbr_nm() {
        return mbr_nm;
    }


    public String getMbr_tel() {
        return mbr_tel;
    }

    public void setMbr_tel(String mbr_tel) {
        this.mbr_tel = mbr_tel;
    }

    public String getPer_info_cd() {
        return per_info_cd;
    }

    public void setPer_info_cd(String per_info_cd) {
        this.per_info_cd = per_info_cd;
    }

    public String getPer_info_yn() {
        return per_info_yn;
    }

    public void setPer_info_yn(String per_info_yn) {
        this.per_info_yn = per_info_yn;
    }

    public String getPer_pro_cd() {
        return per_pro_cd;
    }

    public void setPer_pro_cd(String per_pro_cd) {
        this.per_pro_cd = per_pro_cd;
    }

    public String getPer_pro_yn() {
        return per_pro_yn;
    }

    public void setPer_pro_yn(String per_pro_yn) {
        this.per_pro_yn = per_pro_yn;
    }

    public String getJoin_dt() {
        return join_dt;
    }

    public void setJoin_dt(String join_dt) {
        this.join_dt = join_dt;
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