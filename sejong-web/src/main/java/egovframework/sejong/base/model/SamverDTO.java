package egovframework.sejong.base.model;
public class SamverDTO {
	    private String iud   = "";    // 
	    private String samver; // SAM FILE 확장구분
	    private String tblinfo; // 청구서, 명세서 구분정보
	    private String version; // 버전정보
	    private String seq; // 순번
	    private String item_nm; // 청구서 항목구분명
	    private String sort_seq; // 정렬순서
	    private String start_pos; // 시작위치
	    private String end_pos; // 끝위치
	    private String data_type; // 데이터형태
	    private String decimal_pos; // 소수점자리수
	    private String dataproc_yn; // 데이터처리여부
	    private String db_colnm; // DB 컬럼정보
	    private String last_yn; // 마지막 컬럼여부
	    private String col_size; // 컬럼사이즈
	    private String reg_dttm; // 입력일시
	    private String reg_user; // 입력자
	    private String reg_ip; // 입력IP
	    private String upd_dttm; // 수정일시
	    private String upd_user; // 수정자
	    private String upd_ip; // 수정IP
	    private String sub_code ;
	    private String sub_code_nm; // 정렬순서
	    private String prop_1; // 
	    private String prop_2; // 
	    private String prop_3; // 
	    private String prop_4; // 
	    private String prop_5; // 	    

	    public String getSub_code() {
			return sub_code;
		}

		public void setSub_code(String sub_code) {
			this.sub_code = sub_code;
		}

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

		public String getSub_code_nm() {
			return sub_code_nm;
		}

		public void setSub_code_nm(String sub_code_nm) {
			this.sub_code_nm = sub_code_nm;
		}

		public String getIud() {
			return iud;
		}

		public void setIud(String iud) {
			this.iud = iud;
		}

		// Getters and Setters
	    public String getSamver() {
	        return samver;
	    }

	    public void setSamver(String samver) {
	        this.samver = samver;
	    }

	    public String getTblinfo() {
	        return tblinfo;
	    }

	    public void setTblinfo(String tblinfo) {
	        this.tblinfo = tblinfo;
	    }

	    public String getVersion() {
	        return version;
	    }

	    public void setVersion(String version) {
	        this.version = version;
	    }

	    public String getSeq() {
	        return seq;
	    }

	    public void setSeq(String seq) {
	        this.seq = seq;
	    }

	    public String getItem_nm() {
	        return item_nm;
	    }

	    public void setItem_nm(String item_nm) {
	        this.item_nm = item_nm;
	    }

	    public String getSort_seq() {
	        return sort_seq;
	    }

	    public void setSort_seq(String sort_seq) {
	        this.sort_seq = sort_seq;
	    }

	    public String getStart_pos() {
	        return start_pos;
	    }

	    public void setStart_pos(String start_pos) {
	        this.start_pos = start_pos;
	    }

	    public String getEnd_pos() {
	        return end_pos;
	    }

	    public void setEnd_pos(String end_pos) {
	        this.end_pos = end_pos;
	    }

	    public String getData_type() {
	        return data_type;
	    }

	    public void setData_type(String data_type) {
	        this.data_type = data_type;
	    }

	    public String getDecimal_pos() {
	        return decimal_pos;
	    }

	    public void setDecimal_pos(String decimal_pos) {
	        this.decimal_pos = decimal_pos;
	    }

	    public String getDataproc_yn() {
	        return dataproc_yn;
	    }

	    public void setDataproc_yn(String dataproc_yn) {
	        this.dataproc_yn = dataproc_yn;
	    }

	    public String getDb_colnm() {
	        return db_colnm;
	    }

	    public void setDb_colnm(String db_colnm) {
	        this.db_colnm = db_colnm;
	    }

	    public String getLast_yn() {
	        return last_yn;
	    }

	    public void setLast_yn(String last_yn) {
	        this.last_yn = last_yn;
	    }

	    public String getCol_size() {
	        return col_size;
	    }

	    public void setCol_size(String col_size) {
	        this.col_size = col_size;
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
