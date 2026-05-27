package egovframework.sejong.base.service.impl;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.sejong.base.mapper.BaseMapper;
import egovframework.sejong.base.model.UsermDTO;
import egovframework.sejong.base.service.BaseService;

/**
 * 비밀번호 관련 서비스 구현체. 2026-05-27 미사용 메서드 제거.
 */
@Service("BaseService")
public class BaseServiceImpl implements BaseService {
	private static final Logger LOGGER = LoggerFactory.getLogger(BaseServiceImpl.class);

	@Resource(name = "BaseService")
	private BaseService svc;

	@Autowired
	private BaseMapper mapper;

	@Override
	public UsermDTO UserPasswdInfo(UsermDTO dto) throws Exception {
		return mapper.UserPasswdInfo(dto);
	}

	@Override
	public boolean UserPasswdChange(UsermDTO dto) throws Exception {
		return mapper.UserPasswdChange(dto);
	}

	@Override
	public UsermDTO UsernmInfo(UsermDTO dto) throws Exception {
		return mapper.UsernmInfo(dto);
	}
}
