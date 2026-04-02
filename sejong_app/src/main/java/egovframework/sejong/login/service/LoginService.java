package egovframework.sejong.login.service;

import java.util.List;
import java.util.Map;

import egovframework.sejong.login.model.SjgnDTO;
import egovframework.sejong.login.model.UserDTO;

public interface LoginService {
	int connectionTest();
	int loginCheck(String phone)            throws Exception;
	int registerUser(UserDTO dto)           throws Exception;
	int updateUser(UserDTO dto)             throws Exception;
	UserDTO getUser(String phone)           throws Exception; 
	UserDTO getUserEmail(String email)      throws Exception;

	int delAllUser(UserDTO dto)             throws Exception;
	int delAllFood(UserDTO dto)             throws Exception;
	int delAllExer(UserDTO dto)             throws Exception;
	int delAllBldcon(UserDTO dto)           throws Exception;
	int delAllBldinf(UserDTO dto)           throws Exception;
	int delAllPersign(UserDTO dto)          throws Exception;	

	List<SjgnDTO>  getSignList(Map<String, Object> map) throws Exception;
}