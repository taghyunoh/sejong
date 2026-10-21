package egovframework.sejong.user.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.user.model.PersignDTO;
import egovframework.sejong.user.model.SjgnDTO;
import egovframework.sejong.user.model.UserDTO;


@Mapper("UserMapper")
public interface UserMapper {

	UserDTO userLoginCheck(UserDTO dto) throws Exception;

	UserDTO userInfo(UserDTO dto) throws Exception;

	boolean userPwdReset(UserDTO dto) throws Exception;

	boolean userPwdChange(UserDTO dto) throws Exception;

	/** 약관 본문 조회 (T_SIGN_MST) — termsGb 별 */
	List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception;

	/** termsGb 의 가장 최신(MAX TERMS_SEQ) USE_YN='Y' 약관 SEQ — 동의이력 INSERT 시 어느 버전에 동의했는지 기록용 */
	String selectLatestTermsSeq(String termsGb) throws Exception;

	/** 동의이력 INSERT (T_PERSIGN_TRAN) — 회원가입 시 termsGb 1/2/3 각 1건씩 호출 */
	int insertPersign(PersignDTO dto) throws Exception;
	// 환자 본인 약관 동의 내역
	java.util.List<PersignDTO> myAgreeList(String userUuid) throws Exception;
	// 환자 공지사항 (앱 getNotiList 와 동일 조건)
	java.util.List<?> patientNoticeList() throws Exception;
	// 저혈당/고혈당 발생구간 (앱 avgBloodlowhight 포팅)
	java.util.List<?> avgBloodLowHigh(java.util.Map<String, Object> map) throws Exception;
	// 앱 Blood_SQL 그대로: 고혈당/저혈당 구간(시간대 텍스트) · 주의할음식 TOP3 · 추천운동 TOP3
	java.util.Map<String, Object> showBloodHighLow(java.util.Map<String, Object> map) throws Exception;
	java.util.List<?> foodBlood_max(java.util.Map<String, Object> map) throws Exception;
	java.util.List<?> exerBlood_max(java.util.Map<String, Object> map) throws Exception;
}
