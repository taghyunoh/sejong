package egovframework.sejong.admin.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.sejong.admin.mapper.AdminMapper;
import egovframework.sejong.admin.service.AdminService;

import egovframework.sejong.admin.model.PatientDTO;
import egovframework.sejong.admin.model.AsqDTO;
import egovframework.sejong.admin.model.AuserDTO;
import egovframework.sejong.admin.model.FaqDTO;
import egovframework.sejong.doctor.model.NoticeDTO;


@Service("AdminService")
public class AdminServiceImpl implements AdminService {
	private static final Logger LOGGER = LoggerFactory.getLogger(AdminServiceImpl.class);	
	@Autowired
	private AdminMapper mapper;

	@Override
	public List<?> noticeList(NoticeDTO dto) throws Exception {
		return  mapper.noticeList(dto);
	}
	@Override
	public NoticeDTO noticeInfo(NoticeDTO dto) throws Exception {
		return mapper.noticeInfo(dto);
	}

	@Override
	public boolean insertNotice(NoticeDTO dto) throws Exception {
		return mapper.insertNotice(dto);
	}
	@Override
	public boolean updateNotice(NoticeDTO dto) throws Exception {
		return mapper.updateNotice(dto);
	}
	@Override
	public boolean deleteNotice(NoticeDTO dto) throws Exception {
		return mapper.deleteNotice(dto);
	}
	
	// 환자정보 
	@Override
	public List<?> selectPatientList(PatientDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectPatientList(dto);
	}
	@Override
	public PatientDTO patientInfo(PatientDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.patientInfo(dto);
	}
	@Override
	public boolean insertPatient(PatientDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertPatient(dto);
	}
	@Override
	public boolean updatePatient(PatientDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updatePatient(dto);
	}
	@Override
	public boolean deletePatient(PatientDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deletePatient(dto);
	}
	//사용자(의사)
	@Override
	public List<?> selectAuserList(AuserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectAuserList(dto);
	}
	@Override
	public AuserDTO auserInfo(AuserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.auserInfo(dto);
	}
	@Override
	public boolean insertAuser(AuserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertAuser(dto);
	}
	@Override
	public boolean updateAuser(AuserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateAuser(dto);
	}
	@Override
	public boolean deleteAuser(AuserDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteAuser(dto);
	}
	@Override
	public List<?> selectfaqList(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectfaqList(dto);
	}
	@Override
	public FaqDTO faqInfo(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.faqInfo(dto);
	}
	@Override
	public boolean insertfaq(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertfaq(dto);
	}
	@Override
	public boolean updatefaq(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updatefaq(dto);
	}
	@Override
	public boolean deletefaq(FaqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deletefaq(dto);
	}
	@Override
	public List<?> selectasqList(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectasqList(dto);
	}
	@Override
	public AsqDTO asqInfo(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.asqInfo(dto);
	}
	@Override
	public boolean insertasq(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertasq(dto);
	}
	@Override
	public boolean updateasq(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updateasq(dto);
	}
	@Override
	public boolean deleteasq(AsqDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deleteasq(dto);
	}
}