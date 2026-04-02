package egovframework.sejong.options.service;

import java.util.List;
import java.util.Map;

import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.options.model.AsqDTO;
import egovframework.sejong.options.model.FaqDTO;
import egovframework.sejong.options.model.NotiDTO;

public interface OptionsService {
	List<NotiDTO> getNotiList();
	NotiDTO getNotiDetail(int notiSeq);
	int updateUserInfo(UserDTO dto);
	int updateAsq(AsqDTO dto);
	List<AsqDTO> getAsqList(Map<String,Object> map);
	List<FaqDTO> getFaqList(Map<String,Object> map);
	int deleteAsq(AsqDTO dto);		
}