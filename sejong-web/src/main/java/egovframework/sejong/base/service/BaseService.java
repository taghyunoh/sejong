package egovframework.sejong.base.service;

import egovframework.sejong.base.model.UsermDTO;

/**
 * 비밀번호 관련 서비스. 2026-05-27 미사용 메서드 제거.
 */
public interface BaseService {

	/** 사용자 비밀번호 조회 (HOSP_UUID + USER_ID). 비밀번호 변경 시 현재값 검증용 */
	UsermDTO UserPasswdInfo(UsermDTO dto) throws Exception;

	/** 사용자 비밀번호 변경 (PASS_WD 갱신) */
	boolean UserPasswdChange(UsermDTO dto) throws Exception;

	/** 이름+이메일로 사용자 ID/비번 해시 조회 (찾기 기능) */
	UsermDTO UsernmInfo(UsermDTO dto) throws Exception;
}
