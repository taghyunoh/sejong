package egovframework.sejong.food.model;

import java.util.List;

public class FoodDTO {
	private String foodSeq;
	private String userUuid;
	private String eatDate;
	private String eatStime;
	private String eatEtime;
	private String foodName;
	private String foodDanwi;
	private String foodCnt;
	private String foodAcnt;
	private String foodMseq ;
	private String regDttm;
	private String modDttm;
	private String kCal;
	
	public String getkCal() {
		return kCal;
	}
	public void setkCal(String kCal) {
		this.kCal = kCal;
	}
	public String getFoodMseq() {
		return foodMseq;
	}
	public void setFoodMseq(String foodMseq) {
		this.foodMseq = foodMseq;
	}
	public String getFoodSeq() {
		return foodSeq;
	}
	public void setFoodSeq(String foodSeq) {
		this.foodSeq = foodSeq;
	}
	public String getFoodCnt() {
		return foodCnt;
	}
	public void setFoodCnt(String foodCnt) {
		this.foodCnt = foodCnt;
	}
	public String getFoodAcnt() {
		return foodAcnt;
	}
	public void setFoodAcnt(String foodAcnt) {
		this.foodAcnt = foodAcnt;
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
	public String getEatStime() {
		return eatStime;
	}
	public void setEatStime(String eatStime) {
		this.eatStime = eatStime;
	}
	public String getEatEtime() {
		return eatEtime;
	}
	public void setEatEtime(String eatEtime) {
		this.eatEtime = eatEtime;
	}
	public String getFoodName() {
		return foodName;
	}
	public void setFoodName(String foodName) {
		this.foodName = foodName;
	}
	public String getFoodDanwi() {
		return foodDanwi;
	}
	public void setFoodDanwi(String foodDanwi) {
		this.foodDanwi = foodDanwi;
	}
	public String getRegDttm() {
		return regDttm;
	}
	public void setRegDttm(String regDttm) {
		this.regDttm = regDttm;
	}
	public String getModDttm() {
		return modDttm;
	}
	public void setModDttm(String modDttm) {
		this.modDttm = modDttm;
	}
	
}
