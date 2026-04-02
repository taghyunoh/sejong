package egovframework.sejong.blood.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.blood.model.BloodDTO;


@Mapper("BloodMapper")
public interface BloodMapper {
	int insertToken(Map<String, Object> map);

	int insertBloodData(List<BloodDTO> bloodDataList);

	List<Map<String, Object>> getBloodUserData(String userId);

	List<Map<String, Object>> showBloodData(Map<String, Object> map);
	Map<String, Object> showBloodHighLow(Map<String, Object> map);
	
	Map<String, Object> showBloodAvgData(Map<String, Object> map);

	Map<String, Object> getAvgFastingBlood(Map<String, Object> map);
	Map<String, Object> getAvgFasting(Map<String, Object> map);

	List<Map<String, Object>> getBloodChartData(Map<String, Object> map);

	Map<String, Object> drawBloodBarChart(Map<String, Object> map);
	Map<String, Object> BloodLowHigh(Map<String, Object> map);

	Map<String, Object> calcBlood(Map<String, Object> map);
	
	Map<String, Object> analysisBlood(Map<String, Object> map);
	Map<String, Object> analfastingBlood(Map<String, Object> map);
	Map<String, Object> analpostBlood(Map<String, Object> map);
	List<Map<String, Object>> analexerBlood(Map<String, Object> map);
	List<Map<String, Object>> analfoodBlood(Map<String, Object> map);
	List<Map<String, Object>> today_foodBlood(Map<String, Object> map);
	List<Map<String, Object>> today_foodBlood_max(Map<String, Object> map);
	List<Map<String, Object>> foodBlood_max(Map<String, Object> map);
	
	List<Map<String, Object>> today_exerBlood(Map<String, Object> map);
	List<Map<String, Object>> today_exerBlood_max(Map<String, Object> map);
	List<Map<String, Object>> exerBlood_max(Map<String, Object> map);	
	
	Map<String, Object> mealAvg(Map<String, Object> map);
	Map<String, Object> avgBlood(Map<String, Object> map);
	
	List<Map<String, Object>>  avgBloodlowhight(Map<String, Object> map);
	
	int tokenYn(String userUuid);
	
	String refreshToken(String userUuid);

	List<Map<String, Object>> getTodayBlood(String userUuid);
	
	Map<String, Object> getTodayFastingBlood(String userUuid);
	
	Map<String, Object> getTodayMealBlood(String userUuid);
	
	Map<String, Object> getBMI(String userUuid);
	
	int deleteToken(String userUuid);
}
