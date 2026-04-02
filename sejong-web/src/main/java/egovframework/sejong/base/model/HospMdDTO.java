package egovframework.sejong.base.model;
public class HospMdDTO {
	private static final long serialVersionUID = 1L;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
	private String iud   = "";    
	private String iud2   = "";   // 
	private String year   = "";    
	private String month   = "";   //
    private String hosp_cd; // 요양기관번호
    private String hosp_cd2;
    private String start_ym;     // 적용년월
    private String wardcnt;     // 입원병상수
    private String icucnt;      // 중환자실 병상수
    private String ercnt;       // 응급실 병상수
    private String doccnt;      // 전문의 수
    private String hosp_nm; // 병원명
    private String hosp_addr; // 병원주소
    private String hosp_ceo; // 병원대표자
    private String busi_num; // 사업자등록번호
    private String inaccd; // 산재기관번호
    private String start_dt; // 적용시작일자
    private String end_dt; // 적용종료일자
    private String use_yn; // 사용여부
    private String sthpnm; // 통계용 병원명
    private String reg_dttm; // 등록일시
    private String reg_user; // 등록자
    private String reg_ip; // 등록 IP
    private String upd_dttm; // 최종변경일시
    private String upd_user; // 최종변경자
    private String upd_ip; // 최종변경 IP
    private String join_dt ;
    private String accept_dt ;
    private String close_dt ;
    private String zip_cd ;
    private String hosp_tel ;
    private String hosp_fax ;
	private String hosp_extradr ; 
	private String hosp_uuid ;
	private String winner_yn ;

    private String name1 ;
    private String name2 ;
    private String start_dt2 ;
	private String end_dt2 ; 
	private String join_dt2 ;
	private String accept_dt2 ; 	
	private String close_dt2 ; 	
	
	
	public String getName1() {
		return name1;
	}

	public void setName1(String name1) {
		this.name1 = name1;
	}

	public String getName2() {
		return name2;
	}

	public void setName2(String name2) {
		this.name2 = name2;
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

	public String getJoin_dt2() {
		return join_dt2;
	}

	public void setJoin_dt2(String join_dt2) {
		this.join_dt2 = join_dt2;
	}

	public String getAccept_dt2() {
		return accept_dt2;
	}

	public void setAccept_dt2(String accept_dt2) {
		this.accept_dt2 = accept_dt2;
	}

	public String getClose_dt2() {
		return close_dt2;
	}

	public void setClose_dt2(String close_dt2) {
		this.close_dt2 = close_dt2;
	}

	public String getWinner_yn() {
		return winner_yn;
	}

	public void setWinner_yn(String winner_yn) {
		this.winner_yn = winner_yn;
	}
	
    public String getHosp_uuid() {
		return hosp_uuid;
	}

	public void setHosp_uuid(String hosp_uuid) {
		this.hosp_uuid = hosp_uuid;
	}

	public String getHosp_extradr() {
		return hosp_extradr;
	}

	public void setHosp_extradr(String hosp_extradr) {
		this.hosp_extradr = hosp_extradr;
	}
    
    public String getHosp_tel() {
		return hosp_tel;
	}

	public void setHosp_tel(String hosp_tel) {
		this.hosp_tel = hosp_tel;
	}

	public String getHosp_fax() {
		return hosp_fax;
	}

	public void setHosp_fax(String hosp_fax) {
		this.hosp_fax = hosp_fax;
	}

	public String getJoin_dt() {
		return join_dt;
	}

	public void setJoin_dt(String join_dt) {
		this.join_dt = join_dt;
	}

	public String getAccept_dt() {
		return accept_dt;
	}

	public void setAccept_dt(String accept_dt) {
		this.accept_dt = accept_dt;
	}

	public String getClose_dt() {
		return close_dt;
	}

	public void setClose_dt(String close_dt) {
		this.close_dt = close_dt;
	}

	public String getZip_cd() {
		return zip_cd;
	}

	public void setZip_cd(String zip_cd) {
		this.zip_cd = zip_cd;
	}

	public String getHosp_cd2() {
		return hosp_cd2;
	}

	public void setHosp_cd2(String hosp_cd2) {
		this.hosp_cd2 = hosp_cd2;
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}

	public String getMonth() {
		return month;
	}

	public void setMonth(String month) {
		this.month = month;
	}

	public String getIud2() {
		return iud2;
	}

	public void setIud2(String iud2) {
		this.iud2 = iud2;
	}

	public String getStart_ym() {
		return start_ym;
	}

	public void setStart_ym(String start_ym) {
		this.start_ym = start_ym;
	}

	public String getIud() {
		return iud;
	}

	public void setIud(String iud) {
		this.iud = iud;
	}

	// Getters and Setters
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

    public String getHosp_addr() {
        return hosp_addr;
    }

    public void setHosp_addr(String hosp_addr) {
        this.hosp_addr = hosp_addr;
    }

    public String getHosp_ceo() {
        return hosp_ceo;
    }

    public void setHosp_ceo(String hosp_ceo) {
        this.hosp_ceo = hosp_ceo;
    }

    public String getBusi_num() {
        return busi_num;
    }

    public void setBusi_num(String busi_num) {
        this.busi_num = busi_num;
    }

    public String getInaccd() {
        return inaccd;
    }

    public void setInaccd(String inaccd) {
        this.inaccd = inaccd;
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

    public String getWardcnt() {
        return wardcnt;
    }

    public void setWardcnt(String wardcnt) {
        this.wardcnt = wardcnt;
    }

    public String getIcucnt() {
        return icucnt;
    }

    public void setIcucnt(String icucnt) {
        this.icucnt = icucnt;
    }

    public String getErcnt() {
        return ercnt;
    }

    public void setErcnt(String ercnt) {
        this.ercnt = ercnt;
    }

    public String getDoccnt() {
        return doccnt;
    }

    public void setDoccnt(String doccnt) {
        this.doccnt = doccnt;
    }

    public String getSthpnm() {
        return sthpnm;
    }

    public void setSthpnm(String sthpnm) {
        this.sthpnm = sthpnm;
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
