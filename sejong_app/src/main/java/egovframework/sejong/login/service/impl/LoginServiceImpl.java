package egovframework.sejong.login.service.impl;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.sejong.login.mapper.LoginMapper;
import egovframework.sejong.login.model.SjgnDTO;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.login.service.LoginService;


@Service("LoginService")
public class LoginServiceImpl implements LoginService {
	@Resource(name = "LoginMapper")
	private LoginMapper loginMapper;
	
	@Override
	public int connectionTest() {
		System.out.println("IMPL");
		return loginMapper.connectionTest();
	}

	@Override
	public int loginCheck(String phone) throws Exception {
		return loginMapper.loginCheck(phone);
	}

	@Override
	public int registerUser(UserDTO dto) throws Exception  {
		// TODO Auto-generated method stub
		dto.setUserUuid(UUID.randomUUID().toString());
		dto.setUserGb("1");
		dto.setMgmtGb("1");
		dto.setLoginFailCnt(0);
		dto.setLockYn("N");
		return loginMapper.registerUser(dto);
	}

	@Override
	public UserDTO getUser(String phone) throws Exception {
		return loginMapper.getUser(phone);
	}

	@Override
	public UserDTO getUserEmail(String email) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.getUserEmail(email);
	}

	@Override
	public int delAllUser(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.delAllUser(dto);
	}

	@Override
	public int delAllFood(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.delAllFood(dto);
	}

	@Override
	public int delAllExer(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.delAllExer(dto);
	}

	@Override
	public int delAllBldcon(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.delAllBldcon(dto);
	}

	@Override
	public int delAllBldinf(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.delAllBldinf(dto);
	}

	@Override
	public int delAllPersign(UserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.delAllPersign(dto);
	}

	@Override
	public List<SjgnDTO> getSignList(Map<String, Object> map) throws Exception {
		// TODO Auto-generated method stub
		return loginMapper.getSignList(map);
	}

	@Override
	public int updateUser(UserDTO dto) throws Exception {
		dto.setUserGb("1");
		dto.setMgmtGb("1");
		return loginMapper.updateUser(dto);
	}
}