package egovframework.sejong.base.mapper;
import java.io.File;
import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.base.model.AsqDTO;
import egovframework.sejong.base.model.CodeMdDTO;
import egovframework.sejong.base.model.DietDTO;
import egovframework.sejong.base.model.SugaDTO;
import egovframework.sejong.base.model.UsermDTO;
import egovframework.sejong.base.model.HospMdDTO;
import egovframework.sejong.base.model.MberDTO;
import egovframework.sejong.base.model.SamverDTO;
import egovframework.sejong.base.model.DiseDTO;
import egovframework.sejong.base.model.HospConDTO;
import egovframework.sejong.base.model.HospEmpDTO;
import egovframework.sejong.base.model.WvalDTO;
import egovframework.sejong.base.model.NotiDTO;
import egovframework.sejong.base.model.LicworkDTO;
import egovframework.sejong.base.model.UrlpathDTO;
@Mapper("BaseMapper")
public interface BaseMapper {
	List<?>    SugaMstList(SugaDTO dto)   throws Exception;
	SugaDTO    SugaMstInfo(SugaDTO dto)   throws Exception;
	int        getSugaMstCount(SugaDTO dto)   throws Exception;
	boolean    insertSugaMst(SugaDTO dto) throws Exception; 
	boolean    updateSugaMst(SugaDTO dto) throws Exception; 
	boolean    deleteSugaMst(SugaDTO dto) throws Exception; 

	
	List<?>   selCommMstList(CodeMdDTO dto) throws Exception; 
	String    selCommMstDupChk(CodeMdDTO dto) throws Exception; 
	boolean   insertCommMst(CodeMdDTO dto) throws Exception; 
	boolean   updateCommMst(CodeMdDTO dto) throws Exception; 
	boolean   deleteCommMst(CodeMdDTO dto) throws Exception; 
	
	List<?>   selectCodeDetailList(CodeMdDTO dto) throws Exception; 
	List<?>   selCommDetailList(CodeMdDTO dto) throws Exception; 
	String    selCommDetailDupChk(CodeMdDTO dto) throws Exception; 
	boolean   insertCommDetail(CodeMdDTO dto) throws Exception; 
	boolean   updateCommDetail(CodeMdDTO dto) throws Exception; 
	boolean   deleteCommDetail(CodeMdDTO dto) throws Exception; 
	
	List<?>   selCommDtlInfo(CodeMdDTO dto) throws Exception; 
	
	List<?>   selUserList(UsermDTO dto) throws Exception; 
	UsermDTO  UserInfo(UsermDTO dto)    throws Exception;
	boolean   insertUser(UsermDTO dto) throws Exception; 
	boolean   updateUser(UsermDTO dto) throws Exception; 
	boolean   deleteUser(UsermDTO dto) throws Exception; 
	UsermDTO  UserPasswdInfo(UsermDTO dto)    throws Exception;
	boolean   UserPasswdChange(UsermDTO dto)    throws Exception;
	String    getUserInfo(UsermDTO dto)    throws Exception;
	UsermDTO  UsernmInfo(UsermDTO dto)    throws Exception;
	
	List<?>   selHospDtlList(HospMdDTO dto) throws Exception; 
	HospMdDTO   HospDtlInfo(HospMdDTO dto)    throws Exception;
	boolean   insertHospDtl(HospMdDTO dto)  throws Exception; 
	boolean   updateHospDtl(HospMdDTO dto)  throws Exception; 
	boolean   deleteHospDtl(HospMdDTO dto)  throws Exception;
	String    HospChk(HospMdDTO dto)        throws Exception; 

	List<?>   selHospList(HospMdDTO dto) throws Exception; 
	List<?>   selHospsumList(HospMdDTO dto) throws Exception; 
	HospMdDTO   HospInfo(HospMdDTO dto)    throws Exception;
	boolean   insertHosp(HospMdDTO dto) throws Exception; 
	boolean   updateHosp(HospMdDTO dto) throws Exception; 
	boolean   deleteHosp(HospMdDTO dto) throws Exception; 	
	boolean   insertHospDtlMonlyList(HospMdDTO dto)  throws Exception; 
	HospMdDTO getHospmst(HospMdDTO dto)    throws Exception;
	
	List<?>   selDiseList(DiseDTO dto)  throws Exception;	
	int       getDiseCount(DiseDTO dto) throws Exception;
	DiseDTO   DiseInfo(DiseDTO dto)     throws Exception;
	boolean   insertDise(DiseDTO dto)   throws Exception; 
	boolean   updateDise(DiseDTO dto)   throws Exception; 
	boolean   deleteDise(DiseDTO dto)   throws Exception; 	
	
	List<?>   selectSamVerList(SamverDTO dto)     throws Exception;	
	String    selectCodeDetailDupChk(CodeMdDTO dto) throws Exception; 
	String    selectSamVerDupchk(SamverDTO dto)   throws Exception;
	SamverDTO selectSamVerMgtView(SamverDTO dto)  throws Exception;	
	boolean   insertSamVerMgtInfo(SamverDTO dto)  throws Exception;	
	boolean   updateSamVerMgtInfo(SamverDTO dto)  throws Exception;	
	String    selectSamVerMaxSeq(SamverDTO dto)   throws Exception;	
	
	List<?>   selectWvalueList(WvalDTO dto)       throws Exception;
	WvalDTO   selectWvalueInfo(WvalDTO dto)       throws Exception;
	boolean   insertWvalue(WvalDTO dto)           throws Exception; 
	boolean   updateWvalue(WvalDTO dto)           throws Exception; 
	boolean   deleteWvalue(WvalDTO dto)           throws Exception; 
	int       selectWvalueMaxSeq(WvalDTO dto)     throws Exception; 
	
	boolean   insertMember(MberDTO dto)      throws Exception; 
	String    selMberDupChk(MberDTO dto)     throws Exception; 
	List<?>   selectMbrList(MberDTO dto)     throws Exception; 
	MberDTO   selectMbrInfo(MberDTO dto)     throws Exception; 
	boolean   updateMember(MberDTO dto)      throws Exception;
	List<?>   getMbrList(MberDTO dto)      throws Exception;
	
	List<?>     selectNotiMstList(NotiDTO dto)  throws Exception; 
	NotiDTO     selectNotiMstinfo(NotiDTO dto)  throws Exception; 
	boolean     insertNotiMst(NotiDTO dto)  throws Exception;
	boolean     updateNotiMst(NotiDTO dto)  throws Exception;
	boolean     deleteNotiMst(NotiDTO dto)  throws Exception;
	
	List<?>     selectHospConList(HospConDTO dto)  throws Exception; 
	boolean     insertHospCon(HospConDTO dto)  throws Exception;
	boolean     updateHospCon(HospConDTO dto)  throws Exception;
	HospConDTO  selectHospConInfo(HospConDTO dto)  throws Exception;
	String      getHospConInfo(HospConDTO dto)  throws Exception;
	
	List<?>     selectqstnlist(AsqDTO dto)  throws Exception; 
	boolean     insertqstnMst(AsqDTO dto)  throws Exception;
	boolean     updateqstnMst(AsqDTO dto)  throws Exception;
	AsqDTO      selectqstnInfo(AsqDTO dto)  throws Exception;
	boolean     updateAnsrMst(AsqDTO dto)  throws Exception;
	
	List<?>     selectDietlist(DietDTO dto) throws Exception;
	boolean     insertDiet(DietDTO dto)  throws Exception;
	boolean     updateDiet(DietDTO dto)  throws Exception;
	DietDTO     selectDietInfo(DietDTO dto)  throws Exception; 

	List<?>        selectHospEmpList(HospEmpDTO dto) throws Exception;
	boolean        insertHospEmp(HospEmpDTO dto)  throws Exception;
	boolean        updateHospEmp(HospEmpDTO dto)  throws Exception;
	HospEmpDTO     selectHospEmpInfo(HospEmpDTO dto)  throws Exception; 
	
	List<?>        selectlicworkList(LicworkDTO dto) throws Exception;
	boolean        insertlicwork(LicworkDTO dto)  throws Exception;
	boolean        updatelicwork(LicworkDTO dto)  throws Exception;
	LicworkDTO     selectlicworkInfo(LicworkDTO dto)  throws Exception; 
	
	List<?>        selectUrlpathList(UrlpathDTO dto) throws Exception;
	boolean        insertUrlPathMst(UrlpathDTO dto)  throws Exception;
	boolean        updateUrlPathMst(UrlpathDTO dto)  throws Exception;
	UrlpathDTO     selectUrlpathInfo(UrlpathDTO dto)  throws Exception; 	
}