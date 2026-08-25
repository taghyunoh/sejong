package egovframework.sejong.util;

import egovframework.sejong.login.model.UserDTO;

/**
 * ★[2026-08-25 요청 — 의사 협의] CGM 관리지표의 **권장 목표는 나이·당뇨 유형에 따라 다르다.**
 *   종전에는 누구에게나 TIR 70 / TAR 25 / TBR 4 를 대고 문장만 덧붙였는데, 그건 의사 지적대로 맞지 않다.
 *
 *   국제 CGM 합의(ADA 포함)의 대상군별 목표
 *     · 일반(1형·2형·전단계)   TIR ≥70% · TAR &lt;25% · TBR &lt;4%
 *     · 고령·고위험(65세 이상) TIR ≥50% · TAR &lt;50% · TBR &lt;1%   ← 저혈당은 더 엄격히, 고혈당은 느슨하게
 *     · 임신 중                TIR ≥70% · TAR &lt;25% · TBR &lt;4%   (단, 목표 범위가 63~140 으로 더 좁다)
 *
 *   ⚠임신 중 목표 범위(63~140)는 이 앱의 TIR 계산 범위(70~180)와 달라 그대로 견줄 수 없다 —
 *     숫자를 임의로 바꿔 오해를 만들지 않고 {@link #note} 안내를 함께 띄운다.
 *
 *   ★이 클래스가 **기준의 유일한 출처**다. 홈(main.jsp)과 AI 종합분석(Blood_Consult.jsp)이
 *     각자 계산하면 같은 사람에게 다른 판정이 나온다 — 두 화면 모두 여기서 받은 값을 쓴다.
 */
public class CgmTarget {

	/** 기준 이름 — 화면에 「일반 기준 적용」처럼 밝혀 준다. */
	public final String name;
	/** TIR(목표혈당 유지시간) 하한 % — 이 값 **이상**이면 충족. */
	public final int tir;
	/** TAR(고혈당 시간) 상한 % — 이 값 **미만**이면 충족. */
	public final int tar;
	/** TBR(저혈당 시간) 상한 % — 이 값 **미만**이면 충족. */
	public final int tbr;
	/** 덧붙일 주의 안내(없으면 빈 문자열). */
	public final String note;

	private CgmTarget(String name, int tir, int tar, int tbr, String note) {
		this.name = name; this.tir = tir; this.tar = tar; this.tbr = tbr; this.note = note;
	}

	/** 나이·당뇨 유형에 맞는 기준. 값이 없으면(null) 일반 기준. */
	public static CgmTarget of(Integer age, String typeName) {
		if (typeName != null && typeName.startsWith("임신성")) {
			return new CgmTarget("임신 중 기준", 70, 25, 4,
				"임신 중에는 목표 범위가 63~140 mg/dL 로 더 좁습니다. 이 화면의 수치는 70~180 기준이라 담당 의사와 함께 확인해 주세요.");
		}
		if (age != null && age >= 65) {
			return new CgmTarget("고령 기준", 50, 50, 1,
				"나이를 고려해 저혈당을 더 엄격히, 고혈당은 조금 느슨하게 봅니다.");
		}
		return new CgmTarget("일반 기준", 70, 25, 4, "");
	}

	/** 세션 사용자로 바로 — 미로그인/값 없음이면 일반 기준. */
	public static CgmTarget of(UserDTO user) {
		if (user == null) return of(null, null);
		return of(ageFromBirth(user.getBirth()), typeName(user.getBlodGb()));
	}

	/** 생년월일 8자리(yyyyMMdd) → 만 나이. 형식이 아니거나 값이 이상하면 null. */
	public static Integer ageFromBirth(String birth) {
		if (birth == null) return null;
		String b = birth.trim().replaceAll("[^0-9]", "");
		if (b.length() != 8) return null;
		try {
			int y = Integer.parseInt(b.substring(0, 4));
			int m = Integer.parseInt(b.substring(4, 6));
			int d = Integer.parseInt(b.substring(6, 8));
			if (m < 1 || m > 12 || d < 1 || d > 31) return null;
			java.time.LocalDate born = java.time.LocalDate.of(y, m, d);
			int age = java.time.Period.between(born, java.time.LocalDate.now()).getYears();
			return (age >= 0 && age < 130) ? Integer.valueOf(age) : null;
		} catch (Exception e) { return null; }
	}

	/** 당뇨 유형 코드(T_USER_TRAN.BLOD_GB) → 이름. 의료정보변경 팝업의 라디오 값과 같은 코드. */
	public static String typeName(String code) {
		if (code == null) return "";
		switch (code.trim()) {
			case "1": return "1형 당뇨병";
			case "2": return "2형 당뇨병";
			case "3": return "당뇨병 전단계";
			case "4": return "임신성 당뇨병";
			case "9": return "기타";
			default:  return "";
		}
	}

	/** 화면(JSP)이 쓰기 좋은 모델 값들을 한 번에 담아 준다 — 두 화면이 같은 이름을 쓴다. */
	public static void addToModel(org.springframework.ui.Model model, UserDTO user) {
		Integer age  = (user == null) ? null : ageFromBirth(user.getBirth());
		String  type = (user == null) ? ""   : typeName(user.getBlodGb());
		CgmTarget t  = of(age, type);
		model.addAttribute("userAge",    age == null ? "" : String.valueOf(age));
		model.addAttribute("userDmType", type);
		model.addAttribute("stdName", t.name);
		model.addAttribute("stdTir",  String.valueOf(t.tir));
		model.addAttribute("stdTar",  String.valueOf(t.tar));
		model.addAttribute("stdTbr",  String.valueOf(t.tbr));
		model.addAttribute("stdNote", t.note);
	}
}
