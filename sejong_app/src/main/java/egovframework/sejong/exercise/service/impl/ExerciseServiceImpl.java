package egovframework.sejong.exercise.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.stereotype.Service;

import egovframework.sejong.exercise.mapper.ExerciseMapper;
import egovframework.sejong.exercise.model.ExerciseDTO;
import egovframework.sejong.exercise.service.ExerciseService;
import egovframework.sejong.login.model.UserDTO;


@Service("ExerciseService")
public class ExerciseServiceImpl implements ExerciseService {
	@Resource(name = "ExerciseMapper")
	private ExerciseMapper exerciseMapper;

	@Override
	public int updateStep(JSONArray json) {
			int count = 0;
			for(int i =0; i<json.size();i++) {
				JSONObject obj = (JSONObject) json.get(i);
				obj.put("userUuid", "test");
				System.out.println(obj);
				exerciseMapper.updateStep(obj);
				count++;
			}
		return count;
	}
	@Override
	public int updateHealth(ExerciseDTO dto) {
		return exerciseMapper.updateHealth(dto);
	}
	@Override
	public List<ExerciseDTO> getExercise(Map<String, Object> map) {
		return exerciseMapper.getExercise(map);
	}
	@Override
	public UserDTO getTodayExecs(UserDTO dto) {
		return exerciseMapper.getTodayExecs(dto);
	}
	@Override
	public int deleteHealth(ExerciseDTO dto) {
		// TODO Auto-generated method stub
		return exerciseMapper.deleteHealth(dto);
	}
	@Override
	public List<Map<String, Object>> getTodaysumExecs(Map<String, Object> map) {
		// TODO Auto-generated method stub
		return exerciseMapper.getTodaysumExecs(map) ;
	}
	
	
}