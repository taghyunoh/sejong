package egovframework.sejong.exer.service;

import java.util.HashMap;
import java.util.List;

import egovframework.sejong.exer.model.ExerDTO;

public interface ExerService {
	int updateExer(ExerDTO dto);
	List<ExerDTO> getExerData(HashMap<String,Object> map);
	List<HashMap<String,Object>> getExerInfo(HashMap<String,Object> map);
	int deleteExerData(HashMap<String,Object> map);
}
