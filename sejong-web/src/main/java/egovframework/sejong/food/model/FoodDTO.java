package egovframework.sejong.food.model;

import java.util.List;

public class FoodDTO {
	private int foodhisSeq;
	private String userUuid;
	private String eatDate;
	private int eatType;
	private String mealType;
	private String predictedImagePath;
	private String version;
	private List<FoodPositionDTO> foodPositionList;
	public int getFoodhisSeq() {
		return foodhisSeq;
	}
	public void setFoodhisSeq(int foodhisSeq) {
		this.foodhisSeq = foodhisSeq;
	}
	public String getUserUuid() {
		return userUuid;
	}
	public void setUserUuid(String userUuid) {
		this.userUuid = userUuid;
	}
	public String getEatDate() {
		return eatDate;
	}
	public void setEatDate(String eatDate) {
		this.eatDate = eatDate;
	}
	public int getEatType() {
		return eatType;
	}
	public void setEatType(int eatType) {
		this.eatType = eatType;
	}
	public String getMealType() {
		return mealType;
	}
	public void setMealType(String mealType) {
		this.mealType = mealType;
	}
	public String getPredictedImagePath() {
		return predictedImagePath;
	}
	public void setPredictedImagePath(String predictedImagePath) {
		this.predictedImagePath = predictedImagePath;
	}
	public String getVersion() {
		return version;
	}
	public void setVersion(String version) {
		this.version = version;
	}
	public List<FoodPositionDTO> getFoodPositionList() {
		return foodPositionList;
	}
	public void setFoodPositionList(List<FoodPositionDTO> foodPositionList) {
		this.foodPositionList = foodPositionList;
	}
	
	
	
	
}
