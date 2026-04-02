package egovframework.sejong.base.service.impl;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;

import javax.annotation.Resource;

import org.apache.ibatis.annotations.Mapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.stream.JsonReader;

import egovframework.sejong.base.mapper.BaseMapper;
import egovframework.sejong.base.service.BaseService;
import egovframework.sejong.base.model.AsqDTO;
import egovframework.sejong.base.model.CodeMdDTO;
import egovframework.sejong.base.model.DietDTO;
import egovframework.sejong.base.model.DiseDTO;
import egovframework.sejong.base.model.HospConDTO;
import egovframework.sejong.base.model.HospEmpDTO;
import egovframework.sejong.base.model.HospMdDTO;
import egovframework.sejong.base.model.LicworkDTO;
import egovframework.sejong.base.model.MberDTO;
import egovframework.sejong.base.model.NotiDTO;
import egovframework.sejong.base.model.SamverDTO;
import egovframework.sejong.base.model.SugaDTO;
import egovframework.sejong.base.model.UrlpathDTO;
import egovframework.sejong.base.model.UsermDTO;
import egovframework.sejong.base.model.WvalDTO;

@Service("BaseService")
public class BaseServiceImpl   implements BaseService {
	private static final Logger LOGGER = LoggerFactory.getLogger(BaseServiceImpl.class);	

	@Resource(name = "BaseService")
	private BaseService svc;
	
	@Autowired
	private BaseMapper mapper;
	
	@Override
	public List<?> SugaMstList(SugaDTO dto) throws Exception {
		return mapper.SugaMstList(dto);
	}
	
	@Override
	public SugaDTO SugaMstInfo(SugaDTO dto) throws Exception {
		return mapper.SugaMstInfo(dto);
	}

	@Override
	public boolean insertSugaMst(SugaDTO dto) throws Exception {
		return mapper.insertSugaMst(dto);
	}

	@Override
	public boolean updateSugaMst(SugaDTO dto) throws Exception {
		return mapper.updateSugaMst(dto);
	}

	@Override
	public boolean deleteSugaMst(SugaDTO dto) throws Exception {
		return false;
	}
	@Override
	public int getSugaMstCount(SugaDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.getSugaMstCount(dto);
	}

	@Override
	public List<?> selCommMstList(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selCommMstList(dto);
	}

	@Override
	public String selCommMstDupChk(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selCommMstDupChk(dto);
	}

	@Override
	public boolean insertCommMst(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertCommMst(dto);
	}

	@Override
	public boolean updateCommMst(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateCommMst(dto);
	}

	@Override
	public boolean deleteCommMst(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteCommMst(dto);
	}

	@Override
	public List<?> selectCodeDetailList(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectCodeDetailList(dto);
	}	
	
	@Override
	public List<?> selCommDetailList(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selCommDetailList(dto);
	}

	@Override
	public String selCommDetailDupChk(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selCommDetailDupChk(dto);
	}

	@Override
	public boolean insertCommDetail(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertCommDetail(dto);
	}

	@Override
	public boolean updateCommDetail(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateCommDetail(dto) ;
	}

	@Override
	public boolean deleteCommDetail(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteCommDetail(dto);
	}


	@Override
	public List<?> selUserList(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selUserList(dto) ;
	}

	@Override
	public boolean insertUser(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertUser(dto) ;
	}

	@Override
	public boolean updateUser(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateUser(dto) ;
	}

	@Override
	public boolean deleteUser(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteUser(dto) ;
	}

	@Override
	public UsermDTO UserInfo(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		 return mapper.UserInfo(dto);
	}
	@Override
	public List<?> selHospList(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selHospList(dto);
	}

	@Override
	public HospMdDTO HospInfo(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.HospInfo(dto);
	}

	@Override
	public boolean insertHosp(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertHosp(dto);
	}

	@Override
	public boolean updateHosp(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateHosp(dto);
	}

	@Override
	public boolean deleteHosp(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteHosp(dto);
	}

	@Override
	public List<?> selHospDtlList(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selHospDtlList(dto);
	}

	@Override
	public HospMdDTO HospDtlInfo(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.HospDtlInfo(dto);
	}

	@Override
	public boolean insertHospDtl(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertHospDtl(dto);
	}

	@Override
	public boolean updateHospDtl(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateHospDtl(dto);
	}

	@Override
	public boolean deleteHospDtl(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteHospDtl(dto);
	}

	@Override
	public String HospChk(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.HospChk(dto);
	}

	@Override
	public boolean insertHospDtlMonlyList(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertHospDtlMonlyList(dto);
	}

	@Override
	public List<?> selDiseList(DiseDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selDiseList(dto);
	}

	@Override
	public int getDiseCount(DiseDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.getDiseCount(dto);
	}

	@Override
	public DiseDTO DiseInfo(DiseDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.DiseInfo(dto);
	}

	@Override
	public boolean insertDise(DiseDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertDise(dto);
	}

	@Override
	public boolean updateDise(DiseDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateDise(dto);
	}

	@Override
	public boolean deleteDise(DiseDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteDise(dto);
	}

	@Override
	public List<?> selectSamVerList(SamverDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectSamVerList(dto);
	}

	@Override
	public String selectCodeDetailDupChk(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectCodeDetailDupChk(dto) ;
	}

	@Override
	public String selectSamVerDupchk(SamverDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectSamVerDupchk(dto);
	}

	@Override
	public SamverDTO selectSamVerMgtView(SamverDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectSamVerMgtView(dto);
	}

	@Override
	public boolean insertSamVerMgtInfo(SamverDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertSamVerMgtInfo(dto) ;
	}

	@Override
	public boolean updateSamVerMgtInfo(SamverDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertSamVerMgtInfo(dto);
	}

	@Override
	public String selectSamVerMaxSeq(SamverDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectSamVerMaxSeq(dto) ;
	}
    //가중치 관리 
	@Override
	public List<?> selectWvalueList(WvalDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectWvalueList(dto);
	}

	@Override
	public WvalDTO selectWvalueInfo(WvalDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectWvalueInfo(dto);
	}

	@Override
	public boolean insertWvalue(WvalDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertWvalue(dto);
	}

	@Override
	public boolean updateWvalue(WvalDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateWvalue(dto);
	}

	@Override
	public boolean deleteWvalue(WvalDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteWvalue(dto);
	}

	@Override
	public int selectWvalueMaxSeq(WvalDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectWvalueMaxSeq(dto);
	}

	@Override
	public List<?> selCommDtlInfo(CodeMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selCommDtlInfo(dto);
	}

	@Override
	public boolean insertMember(MberDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertMember(dto);
	}

	@Override
	public String selMberDupChk(MberDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selMberDupChk(dto);
	}

	@Override
	public List<?> selectNotiMstList(NotiDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectNotiMstList(dto);
	}

	@Override
	public NotiDTO selectNotiMstinfo(NotiDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectNotiMstinfo(dto);
	}

	@Override
	public boolean insertNotiMst(NotiDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertNotiMst(dto);
	}

	@Override
	public boolean updateNotiMst(NotiDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateNotiMst(dto);
	}

	@Override
	public boolean deleteNotiMst(NotiDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteNotiMst(dto);
	}

	@Override
	public UsermDTO UserPasswdInfo(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.UserPasswdInfo(dto);
	}

	@Override
	public boolean UserPasswdChange(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.UserPasswdChange(dto);
	}

	@Override
	public List<?> selectMbrList(MberDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectMbrList(dto);
	}

	@Override
	public MberDTO selectMbrInfo(MberDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectMbrInfo(dto);
	}

	@Override
	public boolean updateMember(MberDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateMember(dto);
	}

	@Override
	public List<?> selectHospConList(HospConDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectHospConList(dto);
	}

	@Override
	public boolean insertHospCon(HospConDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertHospCon(dto);
	}

	@Override
	public boolean updateHospCon(HospConDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateHospCon(dto);
	}

	@Override
	public HospConDTO selectHospConInfo(HospConDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectHospConInfo(dto);
	}

	@Override
	public HospMdDTO getHospmst(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.getHospmst(dto);
	}

	@Override
	public List<?> selectqstnlist(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectqstnlist(dto);
	}

	@Override
	public boolean insertqstnMst(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertqstnMst(dto);
	}

	@Override
	public AsqDTO selectqstnInfo(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectqstnInfo(dto);
	}

	@Override
	public boolean updateqstnMst(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateqstnMst(dto);
	}

	@Override
	public List<?> selectDietlist(DietDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectDietlist(dto);
	}

	@Override
	public boolean insertDiet(DietDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertDiet(dto);
	}

	@Override
	public boolean updateDiet(DietDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateDiet(dto);
	}

	@Override
	public DietDTO selectDietInfo(DietDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectDietInfo(dto);
	}

	@Override
	public List<?> selectHospEmpList(HospEmpDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectHospEmpList(dto);
	}

	@Override
	public boolean insertHospEmp(HospEmpDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertHospEmp(dto);
	}

	@Override
	public boolean updateHospEmp(HospEmpDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateHospEmp(dto);
	}

	@Override
	public HospEmpDTO selectHospEmpInfo(HospEmpDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectHospEmpInfo(dto);
	}

	@Override
	public List<?> selectlicworkList(LicworkDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectlicworkList(dto);
	}

	@Override
	public boolean insertlicwork(LicworkDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertlicwork(dto);
	}

	@Override
	public boolean updatelicwork(LicworkDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updatelicwork(dto);
	}

	@Override
	public LicworkDTO selectlicworkInfo(LicworkDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectlicworkInfo(dto);
	}

	@Override
	public String getUserInfo(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.getUserInfo(dto);
	}

	@Override
	public List<?> getMbrList(MberDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return  mapper.getMbrList(dto) ;
	}

	@Override
	public String getHospConInfo(HospConDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.getHospConInfo(dto) ;
	}

	@Override
	public List<?> selectUrlpathList(UrlpathDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectUrlpathList(dto) ;
	}

	@Override
	public boolean insertUrlPathMst(UrlpathDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertUrlPathMst(dto) ;
	}

	@Override
	public boolean updateUrlPathMst(UrlpathDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateUrlPathMst(dto) ;
	}

	@Override
	public UrlpathDTO selectUrlpathInfo(UrlpathDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectUrlpathInfo(dto) ;
	}

	@Override
	public boolean updateAnsrMst(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateAnsrMst(dto) ;
	}

	@Override
	public UsermDTO UsernmInfo(UsermDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.UsernmInfo(dto) ;
	}

	@Override
	public List<?> selHospsumList(HospMdDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selHospsumList(dto) ;
	}
}
