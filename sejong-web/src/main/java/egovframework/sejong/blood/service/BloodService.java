package egovframework.sejong.blood.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.doctor.model.NoticeDTO;

public interface BloodService {
	int insertToken(Map<String, Object> map);

	int insertBloodData(List<BloodDTO> bloodDataList);

	List<Map<String, Object>> getBloodUserData(String userId);

	List<Map<String, Object>> showBloodData(Map<String, Object> map);

	String getAvgFastingBlood(Map<String, Object> map);

	List<Map<String, Object>> getBloodChartData(Map<String, Object> map);
	List<Map<String, Object>> drawOneMealChart(Map<String, Object> map);

	Map<String, Object> drawBloodBarChart(Map<String, Object> map);

	Map<String, Object> calcBlood(Map<String, Object> map);

	Map<String, Object> mealAvg(Map<String, Object> map);
	
	Map<String, Object> foodAvg(Map<String, Object> map);
	
	List<Map<String, Object>> getBloodChartDataMulti(Map<String, Object> map);
	
	List<Map<String, Object>> getWeeklyBloodData(Map<String, Object> map);
	List<Map<String, Object>> getDaylyBloodData(Map<String, Object> map);
	List<Map<String, Object>> getActionBloodChart(Map<String, Object> map);
	
	List<Map<String, Object>> getPostBlood(Map<String, Object> map);
	List<Map<String, Object>> getFastingBlood(Map<String, Object> map);
	List<Map<String, Object>> drawDailyChart(Map<String, Object> map);
	List<Map<String, Object>> getWeekHoliAvg(Map<String, Object> map);
	List<Map<String, Object>> drawRangeChart(Map<String, Object> map);
}