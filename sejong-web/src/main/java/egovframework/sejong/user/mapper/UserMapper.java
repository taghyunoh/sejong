package egovframework.sejong.user.mapper;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.user.model.UserDTO;


@Mapper("UserMapper")
public interface UserMapper {

	UserDTO userLoginCheck(UserDTO dto) throws Exception;

	UserDTO userInfo(UserDTO dto) throws Exception;

	boolean userPwdReset(UserDTO dto) throws Exception;

	boolean userPwdChange(UserDTO dto) throws Exception;
}
