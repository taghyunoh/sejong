package egovframework.sejong.login.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.sejong.login.mapper.LoginMapper;
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

}