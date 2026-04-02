package egovframework.sejong.options.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.options.model.AsqDTO;
import egovframework.sejong.options.model.FaqDTO;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.options.model.NotiDTO;

@Mapper("OptionsMapper")
public interface OptionsMapper {
	List<NotiDTO> getNotiList();
	NotiDTO getNotiDetail(int notiSeq);
	int updateUserInfo(UserDTO dto);
	
	int updateAsq(AsqDTO dto);
	List<AsqDTO> getAsqList(Map<String,Object> map);
	int deleteAsq(AsqDTO dto);	
	List<FaqDTO> getFaqList(Map<String,Object> map);
}
