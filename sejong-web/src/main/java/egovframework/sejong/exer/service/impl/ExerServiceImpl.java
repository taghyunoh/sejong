package egovframework.sejong.exer.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.sejong.exer.mapper.ExerMapper;
import egovframework.sejong.exer.model.ExerDTO;
import egovframework.sejong.exer.service.ExerService;


@Service("ExerService")
public class ExerServiceImpl implements ExerService {
	@Resource(name = "ExerMapper")
	private ExerMapper exerMapper;

	@Transactional(rollbackFor = {Exception.class})
	@Override
	public int updateExer(ExerDTO dto) {
		return exerMapper.updateExer(dto);
	}

	@Override
	public List<ExerDTO> getExerData(HashMap<String, Object> map) {
		return exerMapper.getExerDTO(map);
	}

	@Override
	public List<HashMap<String, Object>> getExerInfo(HashMap<String, Object> map) {
		return exerMapper.getExerInfo(map);
	}

	@Override
	public int deleteExerData(HashMap<String,Object> map) {
		return exerMapper.deleteExerData(map);
	}
}
