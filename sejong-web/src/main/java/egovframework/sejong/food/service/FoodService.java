package egovframework.sejong.food.service;

import java.util.HashMap;
import java.util.List;

import org.json.simple.JSONObject;

public interface FoodService {
	int insertFoodData(JSONObject json);
	HashMap<String,Object> getFoodData(HashMap<String,Object> map);
	List<HashMap<String,Object>> getFoodInfo(HashMap<String,Object>map);
	int deleteFoodData(HashMap<String,Object> map);
}