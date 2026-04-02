package egovframework.sejong.food.model;


public class FoodPositionDTO {
	private int foodhisSeq;
	private int foodSeq;
	private float eatAmount;
	private String foodImagepath;
	private FoodSelectedDTO userSelectedFood;
	
	public int getFoodhisSeq() {
		return foodhisSeq;
	}
	public void setFoodhisSeq(int foodhisSeq) {
		this.foodhisSeq = foodhisSeq;
	}
	public int getFoodSeq() {
		return foodSeq;
	}
	public void setFoodSeq(int foodSeq) {
		this.foodSeq = foodSeq;
	}
	public float getEatAmount() {
		return eatAmount;
	}
	public void setEatAmount(float eatAmount) {
		this.eatAmount = eatAmount;
	}
	public String getFoodImagepath() {
		return foodImagepath;
	}
	public void setFoodImagepath(String foodImagepath) {
		this.foodImagepath = foodImagepath;
	}
	public FoodSelectedDTO getUserSelectedFood() {
		return userSelectedFood;
	}
	public void setUserSelectedFood(FoodSelectedDTO userSelectedFood) {
		this.userSelectedFood = userSelectedFood;
	}
	

	
		
}
