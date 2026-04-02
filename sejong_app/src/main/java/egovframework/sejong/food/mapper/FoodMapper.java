package egovframework.sejong.food.mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;
import org.json.simple.JSONObject;

import egovframework.sejong.exercise.model.ExerciseDTO;
import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.food.model.FoodPositionDTO;
import egovframework.sejong.login.model.UserDTO;


@Mapper("FoodMapper")
public interface FoodMapper {
	int insertFoodHisData(HashMap<String,Object> map);
	int insertFoodData(HashMap<String,Object> map);
	FoodDTO getFoodHisDTO(HashMap<String,Object>map);
	List<HashMap<String,Object>> getFoodInfo(HashMap<String,Object>map);
	int deleteFoodHisData(HashMap<String,Object> map);
	int deleteFoodData(HashMap<String,Object> map);
	List<Map<String, Object>> getChartFood(Map<String, Object> map);
	int updateFoodHisData(HashMap<String,Object> map);
	int updateFoodData(HashMap<String,Object> map);

	List<FoodDTO> getFoodList(Map<String,Object> map);	
	UserDTO getTodayFood(UserDTO dto);
	int updateFood(FoodDTO dto);
	int deleteFood(FoodDTO dto);
	
	List<FoodDTO> getFoodMstList(Map<String,Object> map);	
	
	List<Map<String, Object>> getTodaysumFood(Map<String, Object> map);
}
