package egovframework.sejong.food.mapper;

import java.util.HashMap;
import java.util.List;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

import egovframework.sejong.food.model.FoodDTO;


@Mapper("FoodMapper")
public interface FoodMapper {
	int updateFood(FoodDTO dto);
	List<FoodDTO> getFoodDTO(HashMap<String,Object> map);
	List<HashMap<String,Object>> getFoodInfo(HashMap<String,Object> map);
	int deleteFoodData(HashMap<String,Object> map);
}
