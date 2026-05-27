package egovframework.sejong.base.mapper;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.base.model.UsermDTO;

/**
 * 비밀번호 관련 매퍼. 2026-05-27 미사용 메서드 제거.
 */
@Mapper("BaseMapper")
public interface BaseMapper {

	UsermDTO UserPasswdInfo(UsermDTO dto) throws Exception;

	boolean UserPasswdChange(UsermDTO dto) throws Exception;

	UsermDTO UsernmInfo(UsermDTO dto) throws Exception;
}
