package egovframework.sejong.food.service.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.sejong.food.mapper.FoodMapper;
import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.food.model.FoodPositionDTO;
import egovframework.sejong.food.service.FoodService;


@Service("FoodService")
public class FoodServiceImpl implements FoodService {
	@Resource(name = "FoodMapper")
	private FoodMapper foodMapper;

	@Transactional(rollbackFor = {Exception.class})
	@Override
	public int insertFoodData(JSONObject json) {
		int count = 0;
		try {
			HashMap<String,Object> foodHisMap = new HashMap<String,Object>();
			foodHisMap.put("eatType",json.get("eatType"));
			foodHisMap.put("eatDate",json.get("eatDate"));
			foodHisMap.put("mealType",json.get("mealType"));
			foodHisMap.put("predictedImagePath",json.get("predictedImagePath"));
			foodHisMap.put("userUuid",json.get("userUuid"));
			foodMapper.insertFoodHisData(foodHisMap);
			//insert 이력 
			JSONArray foodPositionList = (JSONArray) json.get("foodPositionList");
			for(Object obj : foodPositionList) {
				HashMap<String,Object> foodMap = new HashMap<String,Object>();
				JSONObject foodItem = (JSONObject) obj;
			    JSONObject userSelectedFood = (JSONObject) foodItem.get("userSelectedFood");
			    JSONObject nutrition = (JSONObject) userSelectedFood.get("nutrition");
				System.out.println(userSelectedFood);
				foodMap.put("eatAmount",foodItem.get("eatAmount"));
				foodMap.put("foodImagepath",foodItem.get("foodImagepath"));
				foodMap.put("foodId",userSelectedFood.get("foodId"));
				foodMap.put("foodName",userSelectedFood.get("foodName"));
				foodMap.put("keyName",userSelectedFood.get("keyName"));
				foodMap.put("calcium",nutrition.get("calcium"));
				foodMap.put("calories",nutrition.get("calories"));
				foodMap.put("carbonhydrate",nutrition.get("carbonhydrate"));
				foodMap.put("cholesterol",nutrition.get("cholesterol"));
				foodMap.put("customFoodInfo",nutrition.get("customFoodInfo"));
				foodMap.put("dietrayfiber",nutrition.get("dietrayfiber"));
				foodMap.put("fat",nutrition.get("fat"));
				foodMap.put("foodType",nutrition.get("foodType"));
				foodMap.put("protein",nutrition.get("protein"));
				foodMap.put("rawCalories",nutrition.get("rawCalories"));
				foodMap.put("rawTotalGram",nutrition.get("rawTotalGram"));
				foodMap.put("saturatedfat",nutrition.get("saturatedfat"));
				foodMap.put("sodium",nutrition.get("sodium"));
				foodMap.put("sugar",nutrition.get("sugar"));
				foodMap.put("totalGram",nutrition.get("totalGram"));
				foodMap.put("transfat",nutrition.get("transfat"));
				foodMap.put("unit",nutrition.get("unit"));
				foodMap.put("vitamina",nutrition.get("vitamina"));
				foodMap.put("vitaminb",nutrition.get("vitaminb"));
				foodMap.put("vitaminc",nutrition.get("vitaminc"));
				foodMap.put("vitamind",nutrition.get("vitamind"));
				foodMap.put("vitamine",nutrition.get("vitamine"));
				foodMap.put("userUuid",json.get("userUuid"));
				foodMap.put("foodhisSeq",foodHisMap.get("foodhisSeq")); // 가져와야함 위에서 
				foodMapper.insertFoodData(foodMap);
				count++;
			}
		}catch(Exception e) {
			e.printStackTrace();
		}

		return count;
	}

	@Override
	public HashMap<String,Object> getFoodData(HashMap<String, Object> map) {
		HashMap<String,Object> result = new HashMap<String,Object>();
		try {
			FoodDTO foodDto = foodMapper.getFoodHisDTO(map);
			int foodhisSeq = foodDto.getFoodhisSeq();
			List<FoodPositionDTO> foodList = foodMapper.getFoodDTO(map);
			foodDto.setFoodPositionList(foodList);
			ObjectMapper mapper = new ObjectMapper();
			result.put("foodhisSeq", foodhisSeq);
			result.put("data", mapper.writeValueAsString(foodDto));
			System.out.println(result);
		}catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	@Override
	public List<HashMap<String, Object>> getFoodInfo(HashMap<String, Object> map) {
		return foodMapper.getFoodInfo(map);
	}

	@Override
	public int deleteFoodData(HashMap<String,Object> map) {
		foodMapper.deleteFoodData(map);
		return foodMapper.deleteFoodHisData(map);
	}


}