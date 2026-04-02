package egovframework.sejong.options.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.options.mapper.OptionsMapper;
import egovframework.sejong.options.model.AsqDTO;
import egovframework.sejong.options.model.FaqDTO;
import egovframework.sejong.options.model.NotiDTO;
import egovframework.sejong.options.service.OptionsService;


@Service("OptionsService")
public class OptionsServiceImpl implements OptionsService {
	@Resource(name = "OptionsMapper")
	private OptionsMapper optionsMapper;

	@Override
	public List<NotiDTO> getNotiList() {
		return optionsMapper.getNotiList();
	}

	@Override
	public NotiDTO getNotiDetail(int notiSeq) {
		return optionsMapper.getNotiDetail(notiSeq);
	}

	@Override
	public int updateUserInfo(UserDTO dto) {
		return optionsMapper.updateUserInfo(dto);
	}

	@Override
	public int updateAsq(AsqDTO dto) {
		// TODO Auto-generated method stub
		return optionsMapper.updateAsq(dto);
	}

	@Override
	public List<AsqDTO> getAsqList(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return optionsMapper.getAsqList(map);
	}

	@Override
	public int deleteAsq(AsqDTO dto) {
		// TODO Auto-generated method stub
		return optionsMapper.deleteAsq(dto);
	}

	@Override
	public List<FaqDTO> getFaqList(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return optionsMapper.getFaqList(map);
	}
	
	
}