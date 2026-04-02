package egovframework.sejong.food.mapper;

import java.util.HashMap;
import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.food.model.FoodPositionDTO;


@Mapper("FoodMapper")
public interface FoodMapper {
	int insertFoodHisData(HashMap<String,Object> map);
	int insertFoodData(HashMap<String,Object> map);
	List<FoodPositionDTO> getFoodDTO(HashMap<String,Object>map);
	FoodDTO getFoodHisDTO(HashMap<String,Object>map);
	List<HashMap<String,Object>> getFoodInfo(HashMap<String,Object>map);
	int deleteFoodHisData(HashMap<String,Object> map);
	int deleteFoodData(HashMap<String,Object> map);
}
