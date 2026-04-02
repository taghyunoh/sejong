package egovframework.sejong.exercise.mapper;

import java.util.List;
import java.util.Map;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;
import org.json.simple.JSONObject;

import egovframework.sejong.exercise.model.ExerciseDTO;
import egovframework.sejong.login.model.UserDTO;
@Mapper("ExerciseMapper")
public interface ExerciseMapper {
	int updateStep(JSONObject json);
	int updateHealth(ExerciseDTO dto);
	List<ExerciseDTO> getExercise(Map<String,Object> map);
	UserDTO getTodayExecs(UserDTO dto);
	int deleteHealth(ExerciseDTO dto);
	List<Map<String, Object>> getTodaysumExecs(Map<String, Object> map);
}
