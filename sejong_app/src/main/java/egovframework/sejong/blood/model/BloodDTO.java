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
    
	    
   


}
