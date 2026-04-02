package egovframework.sejong.blood.model;

import com.google.gson.annotations.SerializedName;

public class BloodDTO {

		private String userId;
		
	 	@SerializedName("serial_number")
	    private String serialNumber;

	    @SerializedName("seq_number")
	    private Integer seqNumber;

	    @SerializedName("event_at")
	    private String eventAt;

	    @SerializedName("initial_value")
	    private Integer initialValue;

	    @SerializedName("value")
	    private Integer value;

	    @SerializedName("trend_rate")
	    private Integer trendRate;

	    @SerializedName("trend")
	    private Integer trend;

	    @SerializedName("error_code")
	    private Integer errorCode;

		public String getUserId() {
			return userId;
		}

		public void setUserId(String userId) {
			this.userId = userId;
		}

		public String getSerialNumber() {
			return serialNumber;
		}

		public void setSerialNumber(String serialNumber) {
			this.serialNumber = serialNumber;
		}

		public Integer getSeqNumber() {
			return seqNumber;
		}

		public void setSeqNumber(Integer seqNumber) {
			this.seqNumber = seqNumber;
		}

		public String getEventAt() {
			return eventAt;
		}

		public void setEventAt(String eventAt) {
			this.eventAt = eventAt;
		}

		public Integer getInitialValue() {
			return initialValue;
		}

		public void setInitialValue(Integer initialValue) {
			this.initialValue = initialValue;
		}

		public Integer getValue() {
			return value;
		}

		public void setValue(Integer value) {
			this.value = value;
		}

		public Integer getTrendRate() {
			return trendRate;
		}

		public void setTrendRate(Integer trendRate) {
			this.trendRate = trendRate;
		}

		public Integer getTrend() {
			return trend;
		}

		public void setTrend(Integer trend) {
			this.trend = trend;
		}

		public Integer getErrorCode() {
			return errorCode;
		}

		public void setErrorCode(Integer errorCode) {
			this.errorCode = errorCode;
		}
    
	    private String start_date;
	    private String end_date;
	    private String user_uuid;
	    private String userUuid;
	    private String cgm_dtm;
	    private String start;
	    private String end;
	    private String serial;
	    private String cgm_seq;
	    private String init_value;
	    private String upt_value;
		private String date;
	    private String dates;
	    private String breakfast;
	    private String lunch;
	    private String dinner;
	    private String postAvg;
	    private String fastingAvg;
	    private String weekNm;
	    private String veryLow;
	    private String low;
	    private String slightLow;
	    private String stable;
	    private String veryHigh;
	    private String high;
	    private String lowAvg;
	    private String norAvg;
	    private String warnAvg;
	    private String dangAvg;
	    private String slightHigh;
	    private String dtm;
	    private String foodSeq;
	    private String foodNm;

		public String getStart_date() {
			return start_date;
		}

		public void setStart_date(String start_date) {
			this.start_date = start_date;
		}

		public String getEnd_date() {
			return end_date;
		}

		public void setEnd_date(String end_date) {
			this.end_date = end_date;
		}

		public String getUser_uuid() {
			return user_uuid;
		}

		public void setUser_uuid(String user_uuid) {
			this.user_uuid = user_uuid;
		}

		public String getCgm_dtm() {
			return cgm_dtm;
		}

		public void setCgm_dtm(String cgm_dtm) {
			this.cgm_dtm = cgm_dtm;
		}

		public String getUserUuid() {
			return userUuid;
		}

		public void setUserUuid(String userUuid) {
			this.userUuid = userUuid;
		}

		public String getStart() {
			return start;
		}

		public void setStart(String start) {
			this.start = start;
		}

		public String getEnd() {
			return end;
		}

		public void setEnd(String end) {
			this.end = end;
		}

		public String getSerial() {
			return serial;
		}

		public void setSerial(String serial) {
			this.serial = serial;
		}

		public String getCgm_seq() {
			return cgm_seq;
		}

		public void setCgm_seq(String cgm_seq) {
			this.cgm_seq = cgm_seq;
		}

		public String getInit_value() {
			return init_value;
		}

		public void setInit_value(String init_value) {
			this.init_value = init_value;
		}

		public String getUpt_value() {
			return upt_value;
		}

		public void setUpt_value(String upt_value) {
			this.upt_value = upt_value;
		}

		public String getDate() {
			return date;
		}

		public void setDate(String date) {
			this.date = date;
		}

		public String getDates() {
			return dates;
		}

		public void setDates(String dates) {
			this.dates = dates;
		}

		public String getBreakfast() {
			return breakfast;
		}

		public void setBreakfast(String breakfast) {
			this.breakfast = breakfast;
		}

		public String getLunch() {
			return lunch;
		}

		public void setLunch(String lunch) {
			this.lunch = lunch;
		}

		public String getDinner() {
			return dinner;
		}

		public void setDinner(String dinner) {
			this.dinner = dinner;
		}

		public String getPostAvg() {
			return postAvg;
		}

		public void setPostAvg(String postAvg) {
			this.postAvg = postAvg;
		}

		public String getFastingAvg() {
			return fastingAvg;
		}

		public void setFastingAvg(String fastingAvg) {
			this.fastingAvg = fastingAvg;
		}

		public String getWeekNm() {
			return weekNm;
		}

		public void setWeekNm(String weekNm) {
			this.weekNm = weekNm;
		}

		public String getVeryLow() {
			return veryLow;
		}

		public void setVeryLow(String veryLow) {
			this.veryLow = veryLow;
		}

		public String getLow() {
			return low;
		}

		public void setLow(String low) {
			this.low = low;
		}

		public String getSlightLow() {
			return slightLow;
		}

		public void setSlightLow(String slightLow) {
			this.slightLow = slightLow;
		}

		public String getStable() {
			return stable;
		}

		public void setStable(String stable) {
			this.stable = stable;
		}

		public String getVeryHigh() {
			return veryHigh;
		}

		public void setVeryHigh(String veryHigh) {
			this.veryHigh = veryHigh;
		}

		public String getHigh() {
			return high;
		}

		public void setHigh(String high) {
			this.high = high;
		}

		public String getSlightHigh() {
			return slightHigh;
		}

		public void setSlightHigh(String slightHigh) {
			this.slightHigh = slightHigh;
		}

		public String getLowAvg() {
			return lowAvg;
		}

		public void setLowAvg(String lowAvg) {
			this.lowAvg = lowAvg;
		}

		public String getNorAvg() {
			return norAvg;
		}

		public void setNorAvg(String norAvg) {
			this.norAvg = norAvg;
		}

		public String getWarnAvg() {
			return warnAvg;
		}

		public void setWarnAvg(String warnAvg) {
			this.warnAvg = warnAvg;
		}

		public String getDangAvg() {
			return dangAvg;
		}

		public void setDangAvg(String dangAvg) {
			this.dangAvg = dangAvg;
		}

		public String getDtm() {
			return dtm;
		}

		public void setDtm(String dtm) {
			this.dtm = dtm;
		}

		public String getFoodSeq() {
			return foodSeq;
		}

		public void setFoodSeq(String foodSeq) {
			this.foodSeq = foodSeq;
		}

		public String getFoodNm() {
			return foodNm;
		}

		public void setFoodNm(String foodNm) {
			this.foodNm = foodNm;
		}
}