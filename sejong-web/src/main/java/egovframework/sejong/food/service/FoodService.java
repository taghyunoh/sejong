package egovframework.sejong.food.service;

import java.util.HashMap;
import java.util.List;

import egovframework.sejong.food.model.FoodDTO;

public interface FoodService {
	int updateFood(FoodDTO dto);
	List<FoodDTO> getFoodData(HashMap<String,Object> map);
	List<HashMap<String,Object>> getFoodInfo(HashMap<String,Object> map);
	int deleteFoodData(HashMap<String,Object> map);
}
