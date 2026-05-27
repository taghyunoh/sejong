package egovframework.sejong.food.service.impl;

import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import egovframework.sejong.food.mapper.FoodMapper;
import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.food.service.FoodService;


@Service("FoodService")
public class FoodServiceImpl implements FoodService {
	@Resource(name = "FoodMapper")
	private FoodMapper foodMapper;

	@Transactional(rollbackFor = {Exception.class})
	@Override
	public int updateFood(FoodDTO dto) {
		return foodMapper.updateFood(dto);
	}

	@Override
	public List<FoodDTO> getFoodData(HashMap<String, Object> map) {
		return foodMapper.getFoodDTO(map);
	}

	@Override
	public List<HashMap<String, Object>> getFoodInfo(HashMap<String, Object> map) {
		return foodMapper.getFoodInfo(map);
	}

	@Override
	public int deleteFoodData(HashMap<String,Object> map) {
		return foodMapper.deleteFoodData(map);
	}
}
