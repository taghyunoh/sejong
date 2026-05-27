package egovframework.sejong.exer.mapper;

import java.util.HashMap;
import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.exer.model.ExerDTO;


@Mapper("ExerMapper")
public interface ExerMapper {
	int updateExer(ExerDTO dto);
	List<ExerDTO> getExerDTO(HashMap<String,Object> map);
	List<HashMap<String,Object>> getExerInfo(HashMap<String,Object> map);
	int deleteExerData(HashMap<String,Object> map);
}
