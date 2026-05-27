package egovframework.sejong.blood.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.doctor.model.NoticeDTO;


@Mapper("BloodMapper")
public interface BloodMapper {
	int insertToken(Map<String, Object> map);

	int insertBloodData(List<BloodDTO> bloodDataList);

	List<Map<String, Object>> getBloodUserData(String userId);

	/** 환자별 i-Sens 토큰 + 마지막 CGM_DTM 조회 (동기화 시 사용) */
	Map<String, Object> getSyncContext(String userUuid);

	/** 환자별 마지막 CGM_DTM 조회 (없으면 NULL) */
	String getLastCgmDtm(String userUuid);

	/** refresh_token 만 갱신 (insertToken 의 ON DUPLICATE KEY UPDATE 와 동일 효과) */
	int updateToken(Map<String, Object> map);

	/** 환자별 i-Sens 토큰 존재 여부 */
	int tokenYn(String userUuid);

	/** 오늘 최근 혈당 2건 */
	List<Map<String, Object>> getTodayBlood(String userUuid);

	/** 오늘 식후 평균 혈당 */
	Map<String, Object> getTodayMealBlood(String userId);

	List<Map<String, Object>> showBloodData(Map<String, Object> map);

	String getAvgFastingBlood(Map<String, Object> map);

	List<Map<String, Object>> getBloodChartData(Map<String, Object> map);
	List<Map<String, Object>> drawOneMealChart(Map<String, Object> map);

	Map<String, Object> drawBloodBarChart(Map<String, Object> map);

	Map<String, Object> calcBlood(Map<String, Object> map);

	Map<String, Object> mealAvg(Map<String, Object> map);
	
	Map<String, Object> foodAvg(Map<String, Object> map);
	
	List<Map<String, Object>> getBloodChartDataMulti(Map<String, Object> map);
	List<Map<String, Object>> getActionBloodChart(Map<String, Object> map);
	List<Map<String, Object>> getWeeklyBloodData(Map<String, Object> map);
	List<Map<String, Object>> getDaylyBloodData(Map<String, Object> map);
	List<Map<String, Object>> getPostBlood(Map<String, Object> map);
	List<Map<String, Object>> getFastingBlood(Map<String, Object> map);
	List<Map<String, Object>> drawDailyChart(Map<String, Object> map);
	List<Map<String, Object>> getWeekHoliAvg(Map<String, Object> map);
	List<Map<String, Object>> drawRangeChart(Map<String, Object> map);
}