package egovframework.sejong.doctor.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.doctor.mapper.DoctorMapper;
import egovframework.sejong.doctor.model.DoctorDTO;
import egovframework.sejong.doctor.model.NoticeDTO;
import egovframework.sejong.doctor.service.DoctorService;


@Service("DoctorService")
public class DoctorServiceImpl implements DoctorService {
	@Resource(name = "DoctorMapper")
	DoctorMapper mapper;

	//환자
	@Override
	public List<?> selectPatientList(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectPatientList(dto);
	}

	@Override
	public DoctorDTO patientInfo(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.patientInfo(dto);
	}

	@Override
	public DoctorDTO getMostRecentDate(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.getMostRecentDate(dto);
	}
	
	@Override
	public boolean insertPatient(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.insertPatient(dto);
	}

	@Override
	public boolean updatePatient(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.updatePatient(dto);
	}

	@Override
	public boolean deletePatient(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.deletePatient(dto);
	}

	@Override
	public List<DoctorDTO> selectPatientListExcelDown(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.selectPatientListExcelDown(dto);
	}

	
	//공지
	@Override
	public List<?> noticeList(NoticeDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.noticeList(dto);
	}

	@Override
	public NoticeDTO noticeInfo(NoticeDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.noticeInfo(dto);
	}
	
	//faq
	@Override
	public List<?> faqList(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.faqList(dto);
	}

	@Override
	public DoctorDTO faqInfo(DoctorDTO dto) throws Exception {
		// TODO Auto-generated method stub
		return mapper.faqInfo(dto);
	}
}