package egovframework.sejong.food.model;


public class FoodSelectedDTO {
	private int foodId;
	private String foodName;
	private String keyName;
	private NutritionDTO nutrition;
	public int getFoodId() {
		return foodId;
	}
	public void setFoodId(int foodId) {
		this.foodId = foodId;
	}
	public String getFoodName() {
		return foodName;
	}
	public void setFoodName(String foodName) {
		this.foodName = foodName;
	}
	public String getKeyName() {
		return keyName;
	}
	public void setKeyName(String keyName) {
		this.keyName = keyName;
	}
	public NutritionDTO getNutrition() {
		return nutrition;
	}
	public void setNutrition(NutritionDTO nutrition) {
		this.nutrition = nutrition;
	}
	
	
	
		
}
