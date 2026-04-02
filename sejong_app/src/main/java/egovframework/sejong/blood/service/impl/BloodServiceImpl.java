package egovframework.sejong.blood.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.sejong.blood.mapper.BloodMapper;
import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.blood.service.BloodService;


@Service("BloodService")
public class BloodServiceImpl implements BloodService {
	@Resource(name = "BloodMapper")
	private BloodMapper bloodMapper;

	@Override
	public int insertToken(Map<String, Object> map) {
		return bloodMapper.insertToken(map);
	}

	@Override
	public int insertBloodData(List<BloodDTO> bloodDataList) {
		System.out.println("blood IMPL");
		System.out.println(bloodDataList.toString());
		return bloodMapper.insertBloodData(bloodDataList);
	}

	@Override
	public List<Map<String, Object>> getBloodUserData(String userId) {
		return bloodMapper.getBloodUserData(userId);
	}

	@Override
	public List<Map<String, Object>> showBloodData(Map<String, Object> map) {
		return bloodMapper.showBloodData(map);
	}

	@Override
	public Map<String, Object> getAvgFastingBlood(Map<String, Object> map) {
		return bloodMapper.getAvgFastingBlood(map);
	}

	@Override
	public List<Map<String, Object>> getBloodChartData(Map<String, Object> map) {
		return bloodMapper.getBloodChartData(map);
	}

	@Override
	public Map<String, Object> drawBloodBarChart(Map<String, Object> map) {
		return bloodMapper.drawBloodBarChart(map);
	}

	@Override
	public Map<String, Object> BloodLowHigh(Map<String, Object> map) {
		return bloodMapper.BloodLowHigh(map);
	}
	
	@Override
	public Map<String, Object> calcBlood(Map<String, Object> map) {
		return bloodMapper.calcBlood(map);
	}

	@Override
	public Map<String, Object> mealAvg(Map<String, Object> map) {
		return bloodMapper.mealAvg(map);
	}

	@Override
	public int tokenYn(String userUuid) {
		return bloodMapper.tokenYn(userUuid);
	}

	@Override
	public String refreshToken(String userUuid) {
		return bloodMapper.refreshToken(userUuid);
	}

	@Override
	public List<Map<String, Object>> getTodayBlood(String userUuid) {
		return bloodMapper.getTodayBlood(userUuid);
	}

	@Override
	public Map<String, Object> getTodayFastingBlood(String userUuid) {
		return bloodMapper.getTodayFastingBlood(userUuid);
	}

	@Override
	public Map<String, Object> getTodayMealBlood(String userUuid) {
		return bloodMapper.getTodayMealBlood(userUuid);
	}

	@Override
	public Map<String, Object> getBMI(String userUuid) {
		return bloodMapper.getBMI(userUuid);
	}

	@Override
	public int deleteToken(String userUuid) {
		return bloodMapper.deleteToken(userUuid);
	}

	@Override
	public Map<String, Object> analysisBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.analysisBlood(map);
	}

	@Override
	public Map<String, Object> analfastingBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.analfastingBlood(map);
	}

	@Override
	public Map<String, Object> analpostBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.analpostBlood(map);
	}

	@Override
	public List<Map<String, Object>> analexerBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.analexerBlood(map);
	}

	@Override
	public List<Map<String, Object>> analfoodBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.analfoodBlood(map);
	}

	@Override
	public List<Map<String, Object>> today_foodBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.today_foodBlood(map);
	}

	@Override
	public List<Map<String, Object>> today_foodBlood_max(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.today_foodBlood_max(map);
	}

	@Override
	public List<Map<String, Object>> today_exerBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.today_exerBlood(map);
	}

	@Override
	public List<Map<String, Object>> today_exerBlood_max(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.today_exerBlood_max(map);
	}

	@Override
	public Map<String, Object> avgBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.avgBlood(map);
	}

	@Override
	public List<Map<String, Object>>  avgBloodlowhight(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.avgBloodlowhight(map);
	}

	@Override
	public Map<String, Object> getAvgFasting(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getAvgFasting(map);
	}

	@Override
	public List<Map<String, Object>> foodBlood_max(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.foodBlood_max(map);
	}

	@Override
	public List<Map<String, Object>> exerBlood_max(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.exerBlood_max(map);
	}

	@Override
	public Map<String, Object> showBloodAvgData(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return  bloodMapper.showBloodAvgData(map);
	}

	@Override
	public Map<String, Object> showBloodHighLow(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return  bloodMapper.showBloodHighLow(map);
	}


	
}