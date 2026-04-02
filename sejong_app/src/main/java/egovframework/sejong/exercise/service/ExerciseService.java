package egovframework.sejong.exercise.service;

import java.util.List;
import java.util.Map;

import org.json.simple.JSONArray;

import egovframework.sejong.exercise.model.ExerciseDTO;
import egovframework.sejong.login.model.UserDTO;

public interface ExerciseService {
	int updateStep(JSONArray json);
	int updateHealth(ExerciseDTO dto);
	List<ExerciseDTO> getExercise(Map<String,Object> map);
	UserDTO getTodayExecs(UserDTO dto);
	int deleteHealth(ExerciseDTO dto);
	List<Map<String, Object>> getTodaysumExecs(Map<String, Object> map);
}