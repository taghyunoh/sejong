package egovframework.sejong.blood.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.sejong.blood.mapper.BloodMapper;
import egovframework.sejong.blood.model.BloodDTO;
import egovframework.sejong.blood.service.BloodService;
import egovframework.sejong.doctor.model.DoctorDTO;


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
	public String getAvgFastingBlood(Map<String, Object> map) {
		return bloodMapper.getAvgFastingBlood(map);
	}

	@Override
	public List<Map<String, Object>> getBloodChartData(Map<String, Object> map) {
		return bloodMapper.getBloodChartData(map);
	}

	@Override
	public List<Map<String, Object>> drawOneMealChart(Map<String, Object> map) {
		return bloodMapper.drawOneMealChart(map);
	}

	@Override
	public Map<String, Object> drawBloodBarChart(Map<String, Object> map) {
		return bloodMapper.drawBloodBarChart(map);
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
	public List<Map<String, Object>> getWeeklyBloodData(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getWeeklyBloodData(map);
	}

	@Override
	public List<Map<String, Object>> getPostBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getPostBlood(map);
	}
	@Override
	public List<Map<String, Object>> getFastingBlood(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getFastingBlood(map);
	}
	@Override
	public List<Map<String, Object>> drawDailyChart(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.drawDailyChart(map);
	}
	@Override
	public List<Map<String, Object>> getWeekHoliAvg(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getWeekHoliAvg(map);
	}
	@Override
	public List<Map<String, Object>> drawRangeChart(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.drawRangeChart(map);
	}

	@Override
	public Map<String, Object> foodAvg(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.foodAvg(map);
	}

	@Override
	public List<Map<String, Object>> getDaylyBloodData(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getDaylyBloodData(map);
	}

	@Override
	public List<Map<String, Object>> getBloodChartDataMulti(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getBloodChartDataMulti(map);
	}

	@Override
	public List<Map<String, Object>> getActionBloodChart(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return bloodMapper.getActionBloodChart(map);
	}
}