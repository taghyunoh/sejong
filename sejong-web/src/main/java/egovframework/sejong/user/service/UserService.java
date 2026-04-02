package egovframework.sejong.user.service;

import java.util.List;

import egovframework.sejong.user.model.UserDTO;

public interface UserService {
	UserDTO userLoginCheck(UserDTO dto) throws Exception;

	UserDTO userInfo(UserDTO dto) throws Exception;

	boolean userPwdReset(UserDTO dto) throws Exception;

	boolean userPwdChange(UserDTO dto) throws Exception;

}