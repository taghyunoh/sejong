package egovframework.sejong.food.model;

import java.util.List;

public class FoodMDTO {
	private String findData; 
	private String foodSeq;
	private String foodName;
	private String foodKcal;
	private String regDtm;
	private String modDttm;


	public String getFindData() {
		return findData;
	}
	public void setFindData(String findData) {
		this.findData = findData;
	}
	public String getFoodSeq() {
		return foodSeq;
	}
	public void setFoodSeq(String foodSeq) {
		this.foodSeq = foodSeq;
	}
	public String getFoodName() {
		return foodName;
	}
	public void setFoodName(String foodName) {
		this.foodName = foodName;
	}
	public String getFoodKcal() {
		return foodKcal;
	}
	public void setFoodKcal(String foodKcal) {
		this.foodKcal = foodKcal;
	}
	public String getRegDtm() {
		return regDtm;
	}
	public void setRegDtm(String regDtm) {
		this.regDtm = regDtm;
	}
	public String getModDttm() {
		return modDttm;
	}
	public void setModDttm(String modDttm) {
		this.modDttm = modDttm;
	}
	
}
