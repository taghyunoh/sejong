package egovframework.sejong.food.web;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import egovframework.sejong.food.model.FoodDTO;
import egovframework.sejong.food.model.FoodMDTO;
import egovframework.sejong.util.GeminiUtil;
import egovframework.sejong.food.service.FoodService;
import egovframework.sejong.login.model.UserDTO;
import egovframework.sejong.util.ResponseObject;


@Controller
public class FoodController {
	@Resource(name = "FoodService") // 서비스 선언
	FoodService foodService;

	private static final Logger log = LoggerFactory.getLogger(FoodController.class);

	// 음식 사진 인식 LLM(Gemini) — 혈당 챗봇(BloodController)과 같은 설정 키를 쓴다. 미설정이면 안내만.
	@Value("${api.gemini.key:}")
	private String geminiKey;

	@Value("${api.gemini.url:}")
	private String geminiUrl;
	
	// 메인 페이지 이동
	@RequestMapping("/foodMain.do")
	public String index(HttpSession session,Model model) {
		session.setAttribute("menuName", "식사등록");
		model.addAttribute("menuName","식사등록");
		UserDTO user = (UserDTO) session.getAttribute("user");
		model.addAttribute("gender",user.getGender());
		return ".main/food/foodMain";
	}
	// 메인 페이지 이동
	@RequestMapping("/foodConsult.do")
	public String foodConsult(HttpSession session,Model model) {
		session.setAttribute("menuName", "식사연관 혈당분석");
		model.addAttribute("menuName","식사연관 혈당분석");
		UserDTO user = (UserDTO) session.getAttribute("user");
		model.addAttribute("gender",user.getGender());
		return ".main/Food_Consult";
	}
	
	// food data insert
	@RequestMapping(value = "/insertFoodData.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject insertFoodData(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody String data) throws Exception {
		JSONParser parser = new JSONParser();
        JSONObject jsonObject = (JSONObject) parser.parse(data);
        UserDTO user = (UserDTO) session.getAttribute("user");
        jsonObject.put("userUuid", user.getUserUuid());
		foodService.insertFoodData(jsonObject);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
	

	// getFoodInfo
	// 화면에보여지는 음식 정보 
	@RequestMapping(value = "/getFoodInfo.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFoodInfo(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		UserDTO user = (UserDTO) session.getAttribute("user");
		reqMap.put("userUuid", user.getUserUuid());
		List<HashMap<String,Object>> list = foodService.getFoodInfo(reqMap);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		return result;
	}
	// food data edit
	// 푸드렌즈에서 반환받은 데이터로 수
	@RequestMapping(value = "/editFoodData.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject editFoodData(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model, @RequestBody HashMap<String,Object> reqMap) throws Exception {
		System.out.println(reqMap);
		String data = reqMap.get("data").toString();
		JSONParser parser = new JSONParser();
        JSONObject jsonObject = (JSONObject) parser.parse(data);
        foodService.deleteFoodData(reqMap);
        UserDTO user = (UserDTO) session.getAttribute("user");
        jsonObject.put("userUuid", user.getUserUuid());
        jsonObject.put("foodhisSeq", reqMap.get("foodhisSeq"));
		foodService.updateFoodData(jsonObject);
		ResponseObject result = new ResponseObject();
		result.Data = "Data";
		result.IsSucceed = true;
		return result;
	}
	
	//getChartFood
	@RequestMapping(value = "/getChartFood.do", method = RequestMethod.POST)	
	public @ResponseBody ResponseObject getChartFood(HttpSession session, @RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		UserDTO user = (UserDTO) session.getAttribute("user");
		map.put("start", params.get("start"));
		map.put("end", params.get("end"));
		map.put("userUuid", user.getUserUuid());
		
		List<Map<String, Object>> list = foodService.getChartFood(map);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		System.out.println(result);
			   
		return result;
	}
	// 개별운동 기간별조회   
	//updateStep
	@RequestMapping(value = "/updateFood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> updateFood(@RequestBody List<FoodDTO> data) {
  
		System.out.println("Insert 시작했음");
		String returnValue = "OK";

	    try {
	        for (FoodDTO dto : data) {
	             foodService.updateFood(dto);
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}
	//delete
	@RequestMapping(value = "/deleteFood.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseEntity<String> deleteFood(@RequestBody List<FoodDTO> data) {
  
		System.out.println("delete 시작했음");
		String returnValue = "OK";

	    try {
	        for (FoodDTO dto : data) {
	             foodService.deleteFood(dto) ;
	        }

	        return ResponseEntity.ok(returnValue); 
	    } catch (Exception e) {
	    	return ResponseEntity.status(500).body(e.getMessage());
	    }
	}	
	@RequestMapping(value = "/getFoodList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFood(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<FoodDTO> list = foodService.getFoodList(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}
	@RequestMapping(value = "/getFoodMstList.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject getFoodMstList(HttpSession session, HttpServletRequest request,
			HttpServletResponse response, Model model,@RequestBody Map<String,Object> map) throws Exception {
		ResponseObject obj = new ResponseObject();
		List<FoodDTO> list = foodService.getFoodMstList(map);
		obj.IsSucceed = true;
		obj.Data = list;
		return obj;
	}	
	//당일 칼로리합산 
	@RequestMapping(value = "/getTodaysumFood.do", method = RequestMethod.POST)	
	public @ResponseBody ResponseObject getTodaysumFood(HttpSession session, @RequestBody HashMap<String, Object> params) {
		
		Map<String, Object> map = new HashMap<>();
		UserDTO user = (UserDTO) session.getAttribute("user");
		map.put("start", params.get("start"));
		map.put("userUuid", user.getUserUuid());
		
		List<Map<String, Object>> list = foodService.getTodaysumFood(map);
		ResponseObject result = new ResponseObject();
		result.Data = list;
		result.IsSucceed = true;
		System.out.println(result);
			   
		return result;
	}		

	// =====================================================================
	// 음식 사진 인식 (2026-10-30) — 식사 등록 화면 [📷 사진으로 등록]
	//   · 화면이 보낸 사진(base64, 긴 변 1024px 로 줄인 JPEG)을 Gemini 에 넣어
	//     「음식명·섭취량·단위·열량」 JSON 목록을 받는다(이 앱의 식사기록 포맷 = updateFood.do 의 FoodDTO).
	//   · 음식마다 T_FOOD_MST 를 이름으로 찾아 foodMseq·열량을 붙인다 — 마스터에 있으면 저장 뒤 열량 집계가
	//     마스터 기준으로 되고(종전 자동완성 선택과 같은 길), 없으면 foodMseq '1'(직접입력)로 저장된다.
	//   · 여기서는 저장하지 않는다 — 사람이 결과를 보고 고친 뒤 [등록]을 누르면 종전 updateFood.do 로 저장.
	//   · 키 미설정·오류 = IsSucceed=false + Message (화면은 안내만 띄운다). 사진은 서버에 남기지 않는다.
	// =====================================================================
	@RequestMapping(value = "/analyzeFoodImage.do", method = RequestMethod.POST)
	@ResponseBody
	public ResponseObject analyzeFoodImage(HttpSession session, @RequestBody HashMap<String, Object> params) {
		ResponseObject json = new ResponseObject();
		if (session.getAttribute("user") == null) {
			json.IsSucceed = false; json.Message = "로그인이 필요합니다."; return json;
		}
		if (!GeminiUtil.configured(geminiKey, geminiUrl)) {
			json.IsSucceed = false; json.Message = "LLM 미설정"; return json;
		}
		String img = params.get("image") == null ? "" : params.get("image").toString().trim();
		String mime = params.get("mime") == null ? "image/jpeg" : params.get("mime").toString();
		// data:image/jpeg;base64,xxxx 꼴이면 접두사를 떼고 mime 도 거기서 읽는다
		if (img.startsWith("data:")) {
			int comma = img.indexOf(',');
			if (comma > 0) {
				String head = img.substring(5, comma);          // image/jpeg;base64
				int semi = head.indexOf(';');
				mime = semi > 0 ? head.substring(0, semi) : head;
				img = img.substring(comma + 1);
			}
		}
		if (img.isEmpty()) { json.IsSucceed = false; json.Message = "사진이 비어 있습니다."; return json; }
		if (img.length() > 6 * 1024 * 1024) { json.IsSucceed = false; json.Message = "사진이 너무 큽니다(4MB 이하)."; return json; }
		if (!mime.startsWith("image/")) mime = "image/jpeg";

		// 조리된 음식(식판·그릇)과 인스턴트·포장 식품(컵라면·도시락·과자·음료·간편식) 둘 다 — 포장이면 제품명·영양성분표를 읽는다 (2026-10-30 「인스턴트 사진도 적용」)
		String sys = "너는 한국 식단 기록 도우미다. 사진에 보이는 음식을 식별해 JSON 배열만 출력한다.\n"
				+ "대상: ①조리된 음식(식판·그릇·접시) ②인스턴트·포장 식품(컵라면·즉석밥·도시락·삼각김밥·빵·과자·음료·간편식·배달 용기).\n"
				+ "포장 식품은 포장에 적힌 제품명을 foodName 으로(예: 신라면 컵, 햇반, 비비고 왕교자), 영양성분표가 보이면 그 열량(1회 제공량 또는 총 내용량 기준)을 kcal 로 쓴다. "
				+ "제품명이 안 보이면 종류로(예: 컵라면, 즉석 도시락, 탄산음료).\n"
				+ "각 항목: {\"foodName\": 한국어 음식명·제품명(짧게), "
				+ "\"foodAcnt\": 섭취량 숫자(1인분·1개 기준, 예: 1, 0.5, 2), "
				+ "\"foodDanwi\": 단위(인분·그릇·개·봉지·컵·조각·캔·g·ml 중 하나 — 포장 식품은 개·봉지·컵·캔), "
				+ "\"kcal\": 그 섭취량의 열량(정수 — 영양성분표가 있으면 그 값, 없으면 추정), \"carb\": 그 섭취량의 탄수화물 g(정수 — 영양성분표가 있으면 그 값, 없으면 추정)}.\n"
				+ "규칙: 음식·식품이 아니면 빈 배열 []. 같은 음식은 하나로 합친다. 최대 8개. 설명문·마크다운 없이 JSON 배열만.";
		String user = "이 사진의 음식(또는 포장 식품)을 목록으로 적어 줘. 음식마다 열량(kcal)과 탄수화물(g)을 꼭 적고, 포장 식품이면 제품명과 영양성분표를 읽어 줘.";
		String out = GeminiUtil.generate(geminiKey, geminiUrl, sys, user, mime, img, true, 2048);
		if (out == null) { json.IsSucceed = false; json.Message = "사진 인식에 실패했습니다. 잠시 뒤 다시 시도해 주세요."; return json; }

		List<Map<String, Object>> list = new java.util.ArrayList<Map<String, Object>>();
		try {
			JsonElement root = new Gson().fromJson(GeminiUtil.stripFence(out), JsonElement.class);
			JsonArray arr = root.isJsonArray() ? root.getAsJsonArray()
					: (root.isJsonObject() && root.getAsJsonObject().has("foods") ? root.getAsJsonObject().getAsJsonArray("foods") : new JsonArray());
			for (int i = 0; i < arr.size() && i < 8; i++) {
				if (!arr.get(i).isJsonObject()) continue;
				JsonObject o = arr.get(i).getAsJsonObject();
				String name = str(o, "foodName");
				if (name.isEmpty()) continue;
				Map<String, Object> row = new HashMap<String, Object>();
				row.put("foodName", name);
				row.put("foodAcnt", normAcnt(str(o, "foodAcnt")));
				row.put("foodDanwi", str(o, "foodDanwi").isEmpty() ? "인분" : str(o, "foodDanwi"));
				row.put("kcal", str(o, "kcal").replaceAll("[^0-9]", ""));
				row.put("carb", str(o, "carb").replaceAll("[^0-9.]", ""));   // 2026-11-04 탄수화물(g) — 기록의 FOOD_CARB 로 저장
				// T_FOOD_MST 매칭 — 이름 그대로 → 띄어쓰기 뗀 포함 일치 → 첫 후보
				row.put("foodMseq", "");
				row.put("mstName", "");
				row.put("mstKcal", "");
				try {
					Map<String, Object> q = new HashMap<String, Object>();
					q.put("findData", name);
					List<?> mst = foodService.getFoodMstList(q);
					if (mst == null || mst.isEmpty()) {
						String core = name.replaceAll("\\s+", "");
						if (core.length() >= 2 && !core.equals(name)) { q.put("findData", core); mst = foodService.getFoodMstList(q); }
					}
					// ⚠ LIKE 첫 후보를 그냥 쓰면 「물」이 「가물치」로 붙는다(모바일 실측) —
					//   ①띄어쓰기 뗀 같은 이름 ②3자 이상일 때 그 이름으로 시작하는 가장 짧은 것 · 그 밖은 마스터 없음(직접입력)
					Object pick = null;
					if (mst != null) {
						String key = name.replaceAll("\\s+", "").toLowerCase();
						for (Object m : mst) {
							if (!(m instanceof FoodMDTO) || ((FoodMDTO) m).getFoodName() == null) continue;
							if (key.equals(((FoodMDTO) m).getFoodName().replaceAll("\\s+", "").toLowerCase())) { pick = m; break; }
						}
						if (pick == null && key.length() >= 3) {
							String best = null;
							for (Object m : mst) {
								if (!(m instanceof FoodMDTO) || ((FoodMDTO) m).getFoodName() == null) continue;
								String mn = ((FoodMDTO) m).getFoodName().replaceAll("\\s+", "").toLowerCase();
								if (mn.startsWith(key) && (best == null || mn.length() < best.length())) { best = mn; pick = m; }
							}
						}
					}
					if (pick instanceof FoodMDTO && ((FoodMDTO) pick).getFoodKcal() != null && !((FoodMDTO) pick).getFoodKcal().trim().isEmpty()) {   // 마스터 열량이 비면(현미밥·사과 등 null 행이 많다) 안 붙인다 — 붙이면 「✔ 열량 자동 집계」로 보이는데 저장 뒤 집계가 빈다
						FoodMDTO m = (FoodMDTO) pick;
						row.put("foodMseq", m.getFoodSeq() == null ? "" : m.getFoodSeq());
						row.put("mstName", m.getFoodName() == null ? "" : m.getFoodName());
						row.put("mstKcal", m.getFoodKcal() == null ? "" : m.getFoodKcal());
					}
				} catch (Exception e) {
					log.warn("food master match skipped: " + e.getMessage());
				}
				list.add(row);
			}
		} catch (Exception e) {
			log.error("analyzeFoodImage parse error: " + e.getMessage() + " / raw=" + out, e);
			json.IsSucceed = false; json.Message = "인식 결과를 읽지 못했습니다. 다시 시도해 주세요."; return json;
		}
		json.IsSucceed = true;
		json.Data = list;
		json.Message = list.isEmpty() ? "사진에서 음식을 찾지 못했습니다." : null;
		return json;
	}

	private static String str(JsonObject o, String k) {
		JsonElement e = o.get(k);
		if (e == null || e.isJsonNull()) return "";
		try { return e.isJsonPrimitive() ? e.getAsString().trim() : e.toString(); } catch (Exception ex) { return ""; }
	}

	/** 섭취량을 화면 선택지와 같은 꼴로 — 0.5→1/2, 0.33→1/3, 그 밖은 숫자 그대로(없으면 1) */
	private static String normAcnt(String v) {
		if (v == null || v.trim().isEmpty()) return "1";
		String t = v.trim();
		if (t.contains("/")) return t;
		try {
			double d = Double.parseDouble(t.replaceAll("[^0-9.]", ""));
			if (d <= 0) return "1";
			if (Math.abs(d - 0.5) < 0.05) return "1/2";
			if (Math.abs(d - 0.33) < 0.05) return "1/3";
			if (Math.abs(d - Math.rint(d)) < 0.05) return String.valueOf((int) Math.rint(d));
			return String.valueOf(d);
		} catch (Exception e) { return "1"; }
	}
}
