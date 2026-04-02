package egovframework.sejong.doctor.mapper;

import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.doctor.model.DoctorDTO;
import egovframework.sejong.doctor.model.NoticeDTO;


@Mapper("DoctorMapper")
public interface DoctorMapper {

	//환자
	List<?> selectPatientList(DoctorDTO dto) throws Exception;
	DoctorDTO patientInfo(DoctorDTO dto) throws Exception;
	DoctorDTO getMostRecentDate(DoctorDTO dto) throws Exception;
	boolean insertPatient(DoctorDTO dto) throws Exception; 
	boolean updatePatient(DoctorDTO dto) throws Exception; 
	boolean deletePatient(DoctorDTO dto) throws Exception; 
	List<DoctorDTO> selectPatientListExcelDown(DoctorDTO dto) throws Exception;

	//공지
	List<?> noticeList(NoticeDTO dto) throws Exception;
	NoticeDTO noticeInfo(NoticeDTO dto) throws Exception;
	
	//faq
	List<?> faqList(DoctorDTO dto) throws Exception;
	DoctorDTO faqInfo(DoctorDTO dto) throws Exception;
	
}
