package egovframework.sejong.food.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.simple.JSONObject;

import egovframework.sejong.exercise.model.ExerciseDTO;
import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.login.model.UserDTO;

public interface FoodService {
	int insertFoodData(JSONObject json);
	List<HashMap<String,Object>> getFoodInfo(HashMap<String,Object>map);
	int deleteFoodData(HashMap<String,Object> map);
	List<Map<String, Object>> getChartFood(Map<String, Object> map);
	int updateFoodData(JSONObject json);
	
	List<FoodDTO> getFoodList(Map<String,Object> map);	
	UserDTO getTodayFood(UserDTO dto);
	int updateFood(FoodDTO dto);
	int deleteFood(FoodDTO dto);
	
	List<FoodDTO> getFoodMstList(Map<String,Object> map);	
	List<Map<String, Object>> getTodaysumFood(Map<String, Object> map);
}