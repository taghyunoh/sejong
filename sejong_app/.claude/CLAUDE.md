# sejong_app 프로젝트 메모

## ★배포/반영 방식 (가장 중요한 함정)
- **화면은 `target/Sejong_APP-1.0.0/`(exploded)을 서빙**한다 — `src/` JSP·CSS를 고쳐도 **target 사본에 복사해야 반영**된다.
  ```
  cp src/main/webapp/...파일 target/Sejong_APP-1.0.0/...같은경로
  ```
  2026-07-31 "색이 안 바뀐다" 원인이 전부 이것. 수정 후 반드시 동기화할 것. CSS는 브라우저 캐시 → Ctrl+F5.
- **[실측 2026-08-13] Eclipse 톰캣(9060)이 실제로 서빙하는 건 `target/` 이 아니라 Eclipse 배포본**이다 :
  `C:\Users\HYUN\eclipse-workspace\.metadata\.plugins\org.eclipse.wst.server.core\tmp5\wtpwebapps\Sejong_APP\`
  (tmp 번호는 서버 추가 순서라 바뀔 수 있다 — `wtpwebapps\Sejong_APP` 로 찾을 것).
  **CLI 로 `src/` 를 고치면 Eclipse 가 모르므로 F5(Refresh) 해야 배포된다.** 급히 확인만 하려면 위 폴더에
  JSP 를 직접 복사하면 즉시 반영된다(다음 publish 때 Eclipse 가 덮으므로 `src/` 가 언제나 정본).
- git 저장소는 **상위 폴더(C:\Users\user\git\sejong) 하나**로 sejong_app + sejong-web을 함께 관리.
- 백업: `C:\Users\user\git\sejong\backup_20260731\` (소스 2종 + .git 이력 zip).

## ★★[완료 2026-08-13] 운동·식사 등록 저장 실패 — ***URL 을 루트 절대경로로 불러서***

> ***"로컬은 되는데 운영만 안 된다" 면 이 항목부터 볼 것.*** 아래 CDN jQuery 건과 두 겹으로 겹쳐 있었다.

- **★진짜 원인**: **운영은 컨텍스트 `/app` 아래에 있다** — `https://allcare24.kr/app/foodMain.do`.
  (도메인 루트 `allcare24.kr/` 은 **sejong-web(관리자)** 이다. 톰캣 `webapps/{ROOT=sejong-web, app=Sejong_APP, konet}`.
  ※이 문서 아래 "운영 서버" 절의 *Sejong_APP = webapps/ROOT* 는 **틀린 기록** — 실측 `webapps/app`.)
  그런데 JSP 가 `url:"/updateFood.do"` · `fetch('/getFoodList.do')` 처럼 **루트 절대경로**로 불렀다.
  → 운영에서 요청이 **이 앱이 아니라 sejong-web 으로 간다.** 거기서 404/500 이 나면
  **앞단 nginx 가 외부 오류페이지(`errdoc.gabia.net`)로 302** 시키고, XHR 이 **다른 출처로 리다이렉트**되어
  브라우저가 차단 → jQuery 는 **status 0**. 화면엔 "서버에 연결하지 못했습니다".
  **로컬은 컨텍스트가 루트(`/`)라 같은 코드가 멀쩡히 동작한다 — 그래서 재현이 안 됐다.**
- **조치**: 두 JSP 에 `const CTX = "${pageContext.request.contextPath}";` 를 두고 **호출 7곳 전부 접두**
  (`updateHealth`·`deleteHealth`·`getExercise` / `updateFood`·`deleteFood`·`getFoodList`·`getFoodMstList`).
  로컬은 `CTX=""` 로 렌더되어 종전과 동일하게 동작한다(회귀 없음).
- **[함정] status 0 을 통신장애로 오해하기 쉽다** — 실제로는 *요청이 엉뚱한 앱에 갔고, 그 오류를 nginx 가
  외부 도메인 리다이렉트로 바꿔서* 브라우저가 막은 것이다. **앱 로그를 아무리 봐도 안 나온다.**
  판별법: 운영 엔드포인트를 컨텍스트 붙여 직접 때려 본다 — `/app/updateFood.do` 는 **401 JSON** 이
  정상적으로 오는데 `/updateFood.do` 는 **302 → errdoc.gabia.net** 이면 이 건이다.
- **[재발 방지] 새 화면에서도 서버 호출·정적자원은 반드시 contextPath 를 붙일 것**
  (JSP 는 `${pageContext.request.contextPath}` 또는 `<c:url value='…'/>`).
- **[전수 점검 완료 2026-08-13] 앱 전체(JSP·JS)에서 루트 절대경로를 훑은 결과** — 아래가 전부다.
  | 파일 | 내용 | 판정 |
  |---|---|---|
  | `exercise/exerMain.jsp`·`food/foodMain.jsp` | 호출 7곳 | **장애 원인 — 수정함** |
  | `tiles/main/header.jsp`·`tiles/login/header.jsp` | `src='/asset/js/jquery/common.js'` (바로 다음 줄들은 `<c:url>` 쓰는데 이 줄만 빠졌다) | **수정함.** 운영에서 sejong-web 의 동명 파일을 싣고 있었다 — 지금은 두 앱 내용이 같아 무증상이었지만 한쪽만 고치면 조용히 깨진다 |
  | `main/register.jsp` | `getAuth`·`authToken`·`getBloodData`·`getData` 4곳 | **수정함**(현재 화면에서 연결된 링크는 없음 — `goRegisterPage.do` 직접 호출뿐이라 사실상 사장. 살아날 때를 대비) |
  | `login/login.jsp` | `/v1/user/access_token_info`·`/v2/user/me` | **문제 아님** — `Kakao.API.request` 라 kapi.kakao.com 기준 상대경로다. 건드리지 말 것 |
  | `login_back.jsp`·`Blood_Consult_back.jsp` | 각 3·2곳 | **죽은 파일**(컨트롤러가 반환하지 않음) |
  | `tiles/popup/header.jsp` | css/js 4곳 | **죽은 레이아웃**(`.popup/*` 뷰를 쓰는 컨트롤러 없음). 참조 파일 자체가 이 앱에 없다 |
  | `asset/js/jquery/common.js` | `/PHSS/loginOut.do`·`/com/checkBtnYn.do` | **타 프로젝트 잔재**, 호출하는 화면 0곳 |
- **[완료] `index.jsp`(welcome-file) 정리** — 컨텍스트 루트(`/app/`)로 들어오면 **옛 로그인 화면**
  (ID/PW 폼, 없는 css/js 참조)이 떴다. **`index.do` 로 넘기는 리다이렉트만 남겼다** — 세션 있으면
  `mainPage.do`, 없으면 `loginPage.do`. 파일을 지우지 않은 이유는 그 주소를 북마크한 사용자를 살리기 위함.
  (PWA 시작주소는 `manifest.webmanifest` 의 `start_url=loginPage.do` 라 이 파일과 무관.)

## ★[완료 2026-08-13] 의료정보변경 팝업 — 키(height) 수정 불가

- **증상**: 팝업에서 **키 칸만 회색으로 잠겨** 수정이 안 됨(몸무게는 됨).
- **원인이 세 겹이었다** — `disabled` 만 떼면 *입력은 되는데 저장이 안 되는* 더 나쁜 상태가 된다:
  1. `<input id="height" … **disabled**>`
  2. `updateUserInfo()` 가 **키를 payload 에 안 담았다**(`weight`·`blodGb` 만)
  3. `Option_SQL.xml` 의 `updateUserInfo` 가 **`SET WEIGHT, BLOD_GB` 뿐**이라 HEIGHT 를 안 고쳤다
- **조치**: ①②를 **팝업이 복제된 3파일 전부**에 적용(`login/main.jsp` · `options/userSetting.jsp` ·
  `tiles/main/top.jsp` — ***이 팝업은 항상 3곳을 같이 고쳐야 한다***), ③ SQL 에 `HEIGHT = #{height}` 추가.
  `UserDTO.height` 는 이미 있어 자바 변경은 없다.
- ⚠**배포**: **매퍼 XML 이 바뀌었으므로 재기동(컨텍스트 재적재) 전까지는 키가 저장되지 않는다.**
  실측 확인함 — XML 만 갈아 끼우고 그대로 호출하면 `IsSucceed:true` 가 오는데 **값은 안 바뀐다**(옛 SQL).
  운영은 `webapps/app/WEB-INF/classes/…/Option_SQL.xml` 교체 후 **`touch webapps/app/WEB-INF/web.xml`**
  로 컨텍스트만 재적재하면 된다(톰캣 전체·konet 안 건드림). 로컬은 Eclipse 서버 Restart.

## ★[완료 2026-08-13] 운동·식사 등록 "시스템오류입니다 다시 입력하세요!" — CDN jQuery 중복 로드

> 위 URL 문제와 **별개의 두 번째 결함**. 이것 때문에 원인이 가려져 있었다(무슨 오류인지 화면이 안 알려줌).

- **증상**: 운동등록·식사등록에서 [입력] 시 위 알림만 뜨고 저장 안 됨. **두 화면만** 같은 증상.
- **원인은 데이터·SQL 이 아니다**(확인함) — 화면과 똑같은 payload 를 로컬 서버로 보내면 둘 다 **200 OK**.
  로컬은 운영 DB 를 그대로 보므로 컬럼 길이·제약도 같은 조건이다. 빈 `exerInt`, 미전송 `exerCnt`·`foodDanwi`,
  쉼표로 긴 음식명("공기밥, 김치찌개, 삶은닭살") 모두 정상 저장됐다.
- **진짜 원인**: 레이아웃 [header.jsp](../src/main/webapp/WEB-INF/tiles/main/header.jsp) 가 jQuery 3.5.1 →
  `commonUtil.js` 순으로 실어 **전역 `$(document).ajaxError`**(401 → 로그인 화면 이동)를 걸어 두는데,
  본문 JSP 가 `code.jquery.com/jquery-3.6.4` 를 **한 번 더 실어 `window.$` 를 통째로 교체**했다.
  → 저장 `$.ajax` 는 핸들러 없는 새 jQuery 를 타고, **세션 만료(401)가 와도 리다이렉트 없이**
  로컬 `error` 콜백의 "시스템오류" 알림만 떴다. **세션 만료를 시스템 장애로 오인**하게 만든 것.
- ***어느 JSP 든 jQuery 를 다시 싣는 순간 세션 만료 안전망이 죽는다*** — 이게 이 건의 교훈.
  같은 패턴이 남아 있는 파일: **`asqmain/asqMain.jsp`(3.6.4) · `Blood_Consult.jsp`(3.6.4, defer)**
  (이번엔 손대지 않음 — 챗봇 레이아웃이 걸려 있어 별도 확인 필요).
- **조치**: exerMain.jsp·foodMain.jsp 에서 CDN jQuery 줄 제거(주석으로 이유 명시. fullcalendar·flatpickr 는
  jQuery 비의존이라 안전) + **`ajaxFailMsg(xhr, what)`** 신설 — 401 은 "로그인이 만료되었습니다",
  그 외는 **상태코드 + 서버 메시지**를 함께 보여 준다(종전엔 상태코드·본문을 버려서 원인 추적이 어려웠다).
- **검증**: 렌더 결과 jQuery 1회 로드 · 옛 문구 0건 · 인라인 JS `node --check` 통과 ·
  세션 없이 `updateHealth.do` 호출 시 `401 {"sessionExpired":true}` 확인.
- **배포**: JSP 만 — 파일 교체(WAR 재빌드 불필요). 로컬은 Eclipse **F5 후 publish**.

## 구조
- eGov JSP + Tiles(.main/* = top.jsp 래핑, .raw 아님). 뷰: `WEB-INF/jsp/`, 공용 CSS `asset/css/`(common/layout/comm_style/blood_fahr).
- 크기 단위 `calc(N * var(--vwu,1vw))` — 데스크톱은 app-desktop.css가 휴대폰 프레임으로 감쌈.
- 로그인/회원가입 = `jsp/login/login.jsp`(팝업 joinPopup1~4·10 내장) / 홈 = `jsp/login/main.jsp` / 연속혈당 = `jsp/main/FAHR_00.jsp` / 혈당 연관분석 = `jsp/main/Blood_Consult.jsp` / 설정 = `jsp/main/options/setting.jsp`.
- 슬라이드 메뉴가 **main.jsp와 tiles/main/top.jsp 두 곳에 복제** — 바꿀 땐 둘 다.

## 2026-07-31 대규모 화면 개편 (기획 이미지 기준)
### 메인(main.jsp)
- 4카드(연속혈당·혈당분석·식사·운동) → **숨김**(`#oldMainCards`, 원복 대비). 새 구성:
  - **혈당상태 카드**: 오늘 TIR(70~180 비율)≥70% '정상'(초록)/미만 '관리 필요'(황토). 오늘 데이터 없으면 **마지막 측정일**로 판정(getLastBloodDate + getBloodChartData 재사용, 일시·수치 표시). [혈당 지표 확인]=goBloodPage.do.
  - **[AI 종합분석(주간)]**=goBloodPage2.do / **[AI 챗봇]**=goBloodPage2.do?chat=1.
  - **CGM 상태 안내**(`#errormsg`): [AI 챗봇] 바로 밑. 연동됨→"착용하면 표시" / 미연동→"i-Sens 연동 필요". 내용 있을 때만 표시(`_setCgmNotice`), 파랑 배경 위라 반투명 박스(`.cgmNotice`). 2026-07-31 에 겹쳐 보인다고 숨겼다가 2026-08-01 복원.
- 슬라이드 메뉴 하단: 아이콘 그리드 → 텍스트 바로가기 4개(공지/FAQ/개인정보 변경/설정). **1:1문의는 기획으로 제외**.
- 의료정보변경 팝업: 취소=확인과 같은 파랑(#218ecb)+간격 — 스타일은 **common.css**(팝업이 3파일에 복제라 공통 처리).

### 연속혈당(FAHR_00.jsp) — 2페이지 분할
- 1p=수치·차트·평균3종 + [상세 지표 보기(다음)] / 2p=평균3종 복사+**GMI(참고)·TIR·TAR·TBR·CV**(권장 문구+색) + 기존 혈당변화 설명. `bloodPage(n)` 전환, `_fillPage2Stats`(차트 dataPoints로 계산).
- 여백 조정 이력: echarts grid 기본 top 60 → top24/bottom12, 컨테이너 300→268(플롯 크기 유지·위치만 위로). `.blood_list` 간격은 margin이 아니라 **flex gap:20px**(common.css)라 gap/padding으로 줄임. `.lyInner` 아래 padding 5.56vwu도 축소. 하단 고정메뉴에 안 가리게 `.bloodPageNav margin-bottom 14vwu`.

### 혈당 연관분석(Blood_Consult.jsp)
- 헤더 "현재일 기준 이전 일주일". GMI/TIR 패널+TAR/TBR/CV 카드 → **wk-metrics 목록**(앞장과 동일 표현식, id 유지 — 값 채우는 기존 스크립트 무변경).
- **wkAi 스크립트**(MutationObserver): 값 도착 시 색(권장기준)+ *혈당지표 분석*(TIR 베이스 '정상/관리필요'+문제 항목 조언) + *생활습관 코칭* 자동 생성. [개인 맞춤 추천] 리포트는 숨김(대체됨).
- 평균 색: 평균 70~180 / 공복 <100 / 식후 <140 = 초록, 벗어나면 황토.
- **관리지표 기준 = 대한당뇨병학회**: TIR≥70% · TAR<25% · TBR<4% · CV≤36% · GMI 권장 없음(참고).

### ★챗봇 레이아웃 — 여러 번 실패 끝에 확정한 방식 (2026-07-31)
- **fixed 오버레이 금지**: `position:fixed` + `height:100%/100dvh/좌표(top·bottom)` 는 기기·PC 프레임마다 실제 높이가 달라 **하단(입력·칩) 잘림 / 칩 아래 빈 띠**가 번갈아 발생했다(수차례 왕복).
- **확정 = 화면 전환 + 고정 픽셀 + 남은 간격만 실측**
  1. 챗봇을 열면 같은 부모의 **다른 카드만 display:none** (연속혈당 1↔2p 와 같은 방식). 문서 흐름이라 하단 메뉴가 자연히 보인다.
  2. 대화영역 `height:200px` **고정**(작은 폰 기준) + `overflow-y:auto`.
  3. 화면이 크면 `_chatFill()` 이 **'칩 줄 아래끝 ~ 하단메뉴 윗변' 남은 간격만** 재서 그만큼 대화영역을 늘린다(절대 좌표·vh 추정 안 함 → 어떤 기기에서도 안전).
- 칩은 `flex-wrap:wrap` 로 **전부 표시**(가로 한 줄 스크롤은 조작 불편하다는 지적으로 폐기).
- 전체 삭제 버튼은 헤더가 아니라 **입력줄 옆 🗑**(헤더에 두면 모바일에서 잘림).

### AI 챗봇 (기획 7)
- 혈당 Q&A를 연관분석 본문에서 **제외** → `#chatOverlay` 전체화면 오버레이. `?chat=1` 진입 시 자동 오픈, 닫기=history.back.
- 첫 인사 밑에 **TIR·TAR·TBR 분석**(한 줄씩·nowrap). **3종이 다 모인 뒤 게시**(TIR이 늦어 빠졌던 버그), 4초 후엔 부분 게시.
- 지표 칩 7종 추가(TIR/TAR/TBR/CV/GMI/고·저혈당 구간 — 구간은 avgHigh/Low_name 재사용). 오버레이 flex: `.qa-messages{min-height:0}` 필수(없으면 하단이 밀려 안 보임), 제목 말줄임(전체 삭제 버튼 밀림 방지), 하단 padding 14vwu(고정메뉴 대비).

### 로그인/회원가입(login.jsp)
- **`test` 입력 → 회원가입 화면 테스트 진입**(authPhoneInput — 숫자필터 유지, 더미폰 세팅).
- 회원 3단계: 취소·다음·완료 = **파랑(#218ecb) 통일**+gap 10px(사용자 확정 — 처음 회색으로 냈다가 변경), 단계바 좌우 꽉·배경 #218ecb, 3단계에도 취소 추가. 본문 배경 그라데이션은 **원복됨**(재적용 요청 시 이력 확인).
- 회원탈퇴 [확 인]=btnCol07 파랑·w50. **loginOutAct류 아님** — 로그아웃은 없고, 참고로 konet과 무관.

### 설정(setting.jsp)
- 자동 로그인·알림 PUSH 숨김(.hide), 버전 V3.0.

## ★서버 LLM(Gemini) — `BloodController.callGemini()`

> **다른 PC에서 개발을 시작한다면** → [docs/개발PC_Gemini키_설정_2026-08-13.md](../docs/개발PC_Gemini키_설정_2026-08-13.md)
> (키 등록·Eclipse 재시작·유료 검증 2단계·밟았던 함정 3개를 절차로 정리해 두었다)

### 키
- **평문 금지.** `application.properties` 는 `api.gemini.key = ${GEMINI_API_KEY:}` 참조만 하고, 실제 값은 **Windows 사용자 환경변수**(`HKCU\Environment\GEMINI_API_KEY`) 한 곳에만 둔다. sejong_app · sejong-web 이 같은 값을 공유하므로 **레지스트리 하나만 바꾸면 양쪽 반영**(소스·target 복사 불필요 — 위 배포 함정 해당 없음).
  ```
  setx GEMINI_API_KEY "새키"
  ```
- 바꾼 뒤 **Eclipse를 완전히 종료 후 재시작**해야 한다. 서버(Tomcat)만 restart 하면 JVM이 Eclipse 실행 시점의 환경변수를 그대로 물고 있어 **옛 키로 계속 호출**된다.
- 키가 비어 있으면 chatAsk.do 가 `IsSucceed=false, "LLM 미설정"` 을 반환하고 화면은 안내문구로 폴백한다.

### ★모델 별칭이 움직이면 조용히 깨진다 (2026-08-13)
- URL 이 `models/gemini-flash-latest` 라 **Google이 별칭을 옮기면 코드 변경 없이 동작이 바뀐다.** 실제로 별칭이 **`gemini-3.6-flash`(Gemini 3 계열)** 로 이동하면서 챗봇이 통째로 죽어 있었다. 증상은 화면상 `"LLM 응답 없음"` 뿐이라 원인 파악이 어렵다 — **키 문제로 오인하기 쉬움**(당시 유료 키 교체 중이었으나 무관했다).
- 원인 3가지, 모두 Gemini 3 에서 바뀐 규약:
  1. `thinkingConfig.thinkingBudget = 0`(추론 끄기) → **400 INVALID_ARGUMENT**. Gemini 3 는 추론 완전 비활성이 불가하고 **`thinkingLevel`("low"/"high")** 을 쓴다.
  2. **추론 토큰이 `maxOutputTokens` 를 함께 소모**한다. 1024 로 두면 추론이 900+ 를 먹고 답변이 잘린다(`finishReason: MAX_TOKENS`). → **2048** 로 상향.
  3. 응답 `parts` 에 **text 없이 `thoughtSignature` 만 든 추론 조각**이 섞여 온다. `parts[0].text` 만 보면 null 이 될 수 있어 → **text 있는 조각을 전부 이어붙이도록** 수정.
- 확정 설정: `temperature 0.4` / `maxOutputTokens 2048` / `thinkingConfig.thinkingLevel = "low"` → `finishReason: STOP`, `<br>` 포맷·200자 제한 정상.
- **증상이 비슷하면 별칭 이동부터 의심할 것.** 원 API 를 직접 때려 보면 3초 만에 갈린다:
  ```
  curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent" \
    -H "x-goog-api-key: $GEMINI_API_KEY" -H "Content-Type: application/json" \
    -d '{"contents":[{"parts":[{"text":"ping"}]}]}'
  ```
  응답의 `modelVersion` 이 현재 별칭이 가리키는 실제 모델이다. 안정성이 필요하면 URL 을 특정 버전으로 고정할 것.

## 로컬 개발 환경 (실측 2026-08-13)
- Eclipse 워크스페이스는 **`C:\Users\HYUN\eclipse-workspace`** (현재 로그인 계정 SRC 와 폴더명이 다름 — 헷갈리지 말 것). Tomcat 8.5.66 인스턴스 **3개**가 동시에 뜬다:
  | 포트 | catalina.base | 앱 | 컨텍스트 |
  |---|---|---|---|
  | **9060** | tmp2 | **Sejong_APP** | `/` (루트) |
  | 8080 | tmp1 | wnn_medcost | `/` |
  | 9080 | tmp0 | wnn_consult | `/wnn_consult` |
- Context `reloadable="true"` → 배포본 `WEB-INF/classes` 의 .class 를 바꾸면 **컨텍스트가 자동 재적재**된다. Eclipse 밖에서 고친 java 를 급히 확인할 때 유용(단, 나중에 Eclipse F5+빌드로 정식 반영할 것).
- **API 단독 테스트용 세션**: `POST /testUser.do`·`/testUser2.do` 가 하드코딩 계정으로 세션을 만들어 준다(`SessionCheckInterceptor.PUBLIC_URIS` 에 등록됨). `testUser.do`(01036721855)는 현재 DB에 없어 500 → **`testUser2.do` 를 쓸 것**. 이후 쿠키를 물려 보호 엔드포인트 호출 가능.
  ```
  curl -c j.txt -X POST http://localhost:9060/testUser2.do -H "X-Requested-With: XMLHttpRequest"
  curl -b j.txt -X POST http://localhost:9060/blood/chatAsk.do \
    -H "Content-Type: application/json;charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" \
    --data-binary @q.json      # 한글 본문은 -d 대신 UTF-8 파일로 (인라인 -d 는 400)
  ```
- 미로그인 상태로 `*.do` AJAX 호출 시 **401 + `sessionExpired:true`** 가 정상 응답이다(엔드포인트가 죽은 게 아님).

## ★서버(운영) 배포 시 체크리스트 — 키는 서버에 따로 넣어야 한다
- **환경 분리(dev/prod)가 프로젝트에 아예 없다**(2026-08-13 전수 확인). profile 파일도, 환경별 properties 도 없고 **DB 조차 `context-datasource.xml` 에 원격 주소가 하드코딩**(`jdbc:mysql://211.47.75.102:3306/dbhannetit02`)되어 **로컬·서버가 같은 DB 를 본다.** → WAR 하나가 어디서든 동일하게 동작하므로 **서버에서 갈아끼울 설정은 `GEMINI_API_KEY` 하나뿐**이다.
  - ※ 뒤집어 말하면 **로컬 테스트가 운영 데이터에 붙는다.** `testUser2.do` 로 잡히는 것도 실계정이다. 쓰기가 있는 기능을 로컬에서 시험할 땐 주의.
- 프로젝트 "바깥" 설정 2가지: ① **Google·Kakao 콘솔에 서버 도메인/리디렉션 URI 등록**(코드 아님, 배포만으로 안 됨) ② 서버에서 `generativelanguage.googleapis.com:443` **아웃바운드 허용**(막히면 증상이 똑같이 `"LLM 응답 없음"`).
- **`GEMINI_API_KEY` 는 소스에도 WAR 에도 없다.** 로컬 PC 의 OS 환경변수에만 있으므로 **WAR 만 올리면 서버 챗봇은 죽는다.** 증상은 `{"IsSucceed":false,"Message":"LLM 미설정"}` → 화면엔 에러 없이 안내문구만 뜬다. **정상처럼 보여서 놓치기 쉬움.**
- **★로컬처럼 `setx`(사용자 변수/HKCU) 로 넣으면 서버에선 안 먹는다.** Tomcat 이 Windows 서비스로 돌면 SYSTEM/서비스 계정으로 실행되어 HKCU 를 보지 않는다. 구동 방식별로:
  | 서버 구동 방식 | 설정 위치 |
  |---|---|
  | **Windows 서비스** | 관리자 권한 `setx /M GEMINI_API_KEY "키"`(시스템 변수=HKLM) 후 **서비스 재시작**<br>또는 `Tomcat9w.exe` → Java 탭 → Java Options 에 `-DGEMINI_API_KEY=키` |
  | startup.bat 수동 기동 | `bin\setenv.bat` 에 `set GEMINI_API_KEY=키` |
  | Linux Tomcat | `bin/setenv.sh` 에 `export GEMINI_API_KEY=키` |
  - 어느 경우든 **JVM 재기동 필수**(프로세스 생성 시점에 환경변수를 상속). 로컬의 "Eclipse 완전 재시작"과 같은 이유.
  - `-D` 시스템 프로퍼티가 통하는 이유: `@PropertySource("classpath:application.properties")`(LoginController.java) + `<context:property-placeholder>`(dispatcher-servlet.xml) → `PropertySourcesPlaceholderConfigurer` 가 Environment 를 `systemProperties` → `systemEnvironment` 순으로 조회한다. **단 실측 검증된 경로는 환경변수 쪽뿐**(2026-08-13).
  - **`application.properties` 에 키를 직접 적지 말 것** — 커밋되고 WAR 에 그대로 들어간다.
- **★키만 넣으면 안 된다 — 코드도 같이 올려야 한다.** 위 "모델 별칭" 절의 `BloodController` 수정(thinkingLevel 등)이 빠진 채 키만 넣으면 여전히 `"LLM 응답 없음"` 이 뜬다. **키 설정 + 코드 배포는 세트.**
- 반영 확인은 로컬과 동일하게 `testUser2.do` → `chatAsk.do` (위 "로컬 개발 환경" 절의 curl). `IsSucceed:true` + 한글 답변이면 성공, `"LLM 미설정"` 이면 환경변수가 JVM 에 안 들어간 것.
- 참고: **서버에 추가로 넣을 환경변수는 `GEMINI_API_KEY` 하나뿐.** `OPENAI_API_KEY` 는 AiController 가 비활성이라 미사용이고, 나머지 시크릿(Google OAuth client-secret · i-Sens `blood.client.secret` · kakao js key)은 `application.properties` 에 **평문으로 커밋되어 있다** — 그래서 서버 설정은 불필요하지만, 저장소(github.com/taghyunoh/sejong)에 노출된 상태라 Gemini 키처럼 환경변수로 빼는 정리가 필요하다. → 아래 대기 항목.

## ★★운영 서버(139.150.73.139) — 실측 2026-08-13

- **접속** : `guser@139.150.73.139`. **SSHPiper 중계**를 거쳐 윈도우 OpenSSH(`ssh`/`scp`)는 키교환 직후 끊긴다 —
  ***MobaXterm 저장세션(`2.세종_TP(hannetit02)`)으로만 접속·전송이 된다.*** 파일은 **SFTP 패널에 드래그**.
- **톰캣** : `/web/tomcat9`(catalina.base=home), JDK17, `guser` 로 기동. 포트 **8080 / 8443**.
  ⚠**konet 이 같은 톰캣에 함께 떠 있다**(`webapps/{ROOT,app,konet}`) — 재기동하면 konet 도 같이 내려간다.
- ~~**Sejong_APP = `webapps/ROOT`**(루트 컨텍스트, 로컬 9060 과 같은 구조).~~ WAR 원본은 `/web/*.war`.
  ⚠**[정정 2026-08-13 실측] Sejong_APP 은 `webapps/app`(컨텍스트 `/app`)이다** — 접속 주소는
  `https://allcare24.kr/app/`. `webapps/ROOT` 는 **sejong-web(관리자)** 이고 `allcare24.kr/` 이 그쪽이다.
  판별: `curl -s -o /dev/null -w '%{http_code}' https://allcare24.kr/app/sw.js` → **200**(sw.js·manifest 는
  Sejong_APP 에만 있다). ***로컬(루트)과 컨텍스트가 다르다는 점이 URL 하드코딩 장애의 원인이었다*** — 맨 위 절 참조.
- **`reloadable` 설정이 없다** ⇒ 클래스만 바꿔도 자동 반영 안 됨. manager 계정도 전부 기본값(`<must-be-changed>`)이라 못 쓴다.
  ⇒ **컨텍스트만 재적재하는 법** : `touch webapps/ROOT/WEB-INF/web.xml` → 12초 뒤 `catalina.out` 에
  `HostConfig.reload 컨텍스트 []` 가 찍히면 성공(톰캣·konet 안 건드림). **실측으로 통했다.**
- **키(`GEMINI_API_KEY`)는 `/web/tomcat9/bin/setenv.sh`** 에 `export` 로 들어 있다(중복 2줄 — 무해).
  ⚠**서버에는 이미 새 유료 키가 들어가 있었다**(2026-08-13 확인). 로컬 HKCU 값과 동일.
- **검증 절차(서버)** — `testUser2.do` 는 **배포본에 없어 404**다. 세션 없이도 챗봇은 응답하므로 이것으로 충분 :
  ```
  cd /tmp && printf '{"q":"혈당 관리 팁 한 줄만"}' > q.json      # ★파라미터명은 q (question 아님)
  curl -s -X POST http://localhost:8080/blood/chatAsk.do \
    -H "Content-Type: application/json;charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" \
    --data-binary @q.json -m 40
  ```
  ⚠⚠**`chatAsk.do` 의 HTTP 코드로 유료/무료를 판별하면 안 된다** — Gemini 가 429 여도 **앱은 200 을 돌려주고
  본문만 `IsSucceed:false`** 다. 2026-08-13 에 이 방식으로 「25건 전원 200 → 유료」라 오판했다.
  ***반드시 아래 둘 중 하나로 본다*** :
  ```
  # ⓐ API 를 직접 때린다(가장 확실)
  for i in $(seq 1 12); do curl -s -o r$i.txt -w "%{http_code}\n" -X POST \
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent" \
    -H "x-goog-api-key: $GEMINI_API_KEY" -H "Content-Type: application/json" \
    -d '{"contents":[{"parts":[{"text":"ping"}]}]}' & done; wait; grep -l FreeTier r*.txt | wc -l
  # ⓑ 앱으로 몰고 나서 로그를 본다
  grep -c FreeTier /web/tomcat9/logs/catalina.out      # ★시각까지 확인할 것(누적 파일이다)
  ```

### ✅[2026-08-13] 서버 챗봇 복구 — **키가 아니라 코드가 문제였다**

증상 : 서버 챗봇 무응답. 원인 : **오늘 14:03 올린 WAR 가 `thinkingLevel` 수정(ed58f40) 이전 빌드**였다
(배포된 `BloodController.class` 에 `thinkingLevel` 0건, 7/31자 파일). 키는 이미 유료로 바뀌어 있었으므로
***키 교체만 했다면 계속 죽어 있었을 상황*** — 「키 설정 + 코드 배포는 세트」가 실제로 증명됐다.

조치(최소 변경) : 로컬에서 `BloodController.java` 만 컴파일 → SFTP 로 `/web` 업로드 →
`.bak-20260813` 백업 후 배포본 클래스 교체 → `web.xml` touch 로 ROOT 재적재 → 검증.
결과 : `IsSucceed:true` + 한글 답변 → **서버 챗봇 복구 완료.**

### ✅[2026-08-13 저녁] 유료 키 배포 완료 — **서버는 유료 확정**

위 무료 판정 뒤 **새 유료 키(`AQ.Ab8RN6Ie…`)를 서버에 배포**했다 :
`setenv.sh` 를 heredoc 으로 **한 줄로 재작성**(중복 2줄 제거) → **톰캣 재기동**(konet 동시 중단) →
API 직접 12건 동시 **전원 200 · FreeTier 0**(직전 같은 조건에서 5×429 였다) ⇒ **유료 확정.**

**로컬도 같은 날 완료** — HKCU 값 교체 + **Eclipse 완전 재시작**(17:31) → 새 셸 키로 API 12건 동시 **전원 200**,
`testUser2.do` → `chatAsk.do` **`IsSucceed:true`**. ⇒ 로컬·서버 **양쪽 다 새 유료 키**로 동작한다.

### ⚠키를 넣을 때 밟은 함정 3개 (다음에 또 겪는다)

1. **`read -s` 프롬프트엔 「키만」 붙여넣을 것** — 블록을 통째로 붙여넣으면 `read` 가 **다음 명령줄을 키로 먹는다**
   (실제 발생: `GEMINI_API_KEY="cat > /web/…"`). 검증 = `echo "길이=${#K}"` → **53**.
2. **클립보드로 우회하지 말 것** — 「명령을 복사해 붙여넣으라」고 안내하는 순간 **클립보드가 그 명령으로 덮인다.**
   `Get-Clipboard` 로 키를 읽으려다 355자(명령문)를 환경변수에 써 버렸다([[secret-paste-clipboard-clobber]] 그대로).
   ⇒ **사용자 셸에서 `Read-Host -AsSecureString` → 같은 세션에서 `SetEnvironmentVariable`** 이 가장 안전하다.
3. **HKCU 값 ≠ 실행 중 프로세스의 값** — 레지스트리엔 새 키가 있어도 Eclipse/톰캣은 옛 키를 쥔다.
   확인법 : `[Environment]::GetEnvironmentVariable('GEMINI_API_KEY','User') -eq $env:GEMINI_API_KEY` 가 **False** 면
   아직 재시작 안 된 것. (해시 앞 12자만 비교하면 평문 노출 없이 확인된다)

### ⛔[2026-08-13 오후] (경위) 키가 무료 티어였다 — 유료 전환이 안 먹고 있었다

같은 날 확인 : 로컬 HKCU 키와 서버 `setenv.sh` 키가 **해시까지 완전히 동일**하고,
그 키로 **API 를 직접** 12건 동시 호출하면 **7×200 / 5×429**, 본문에
`quotaId: ...-FreeTier`, `quotaValue: 5`, `model: gemini-3.6-flash` 가 그대로 박혀 나온다.

- **서버 `setenv.sh` 는 6/29 자 파일** — 이 `AQ.…` 키는 오늘 만든 것이 아니라 **6월부터 쓰던 키**다.
  ⇒ ***오늘 발급한 유료 키는 로컬·서버 어디에도 안 들어가 있다.***
- 원인 후보 : ⓐ**키가 속한 프로젝트 ≠ 결제를 건 프로젝트**(결제는 프로젝트 단위) ⓑ유료 키를 발급만 하고 미배포.
- 확인 : [AI Studio → API keys](https://aistudio.google.com/apikey) 에서 **그 키의 프로젝트 이름**과 결제 상태.
  프로젝트가 다르면 **유료 프로젝트에서 키를 새로 발급**해야 한다.
- ⚠**그때까지 환자 CGM 혈당이 무료 티어로 나간다 = 구글 학습에 사용**([[sejong-gemini-patient-data-tier]]).
- 새 키를 받으면 : ①서버 `setenv.sh` 의 **두 줄 다** 교체(중복이라 아래 줄이 이긴다) ②**톰캣 재기동**
  (환경변수는 프로세스 생성 때 상속 — 컨텍스트 리로드로는 안 바뀐다. ⚠konet 도 같이 내려간다)
  ③로컬은 `setx GEMINI_API_KEY` + **Eclipse 완전 재시작** ④위 ⓐ 방식으로 재검증.

⚠**정식 정리 필요** : 지금은 클래스 1개만 갈아 끼운 상태다. 다음 배포 때 **소스 최신으로 다시 빌드한 WAR**
(`Sejong_APP-1.0.0.war`)를 올려야 한다 — 안 그러면 다음 WAR 배포에서 **다시 옛 코드로 되돌아간다.**

## 대기/미완
- [대기] AI 챗봇 서버 LLM(/blood/chatAsk.do)·blood_qa.js 지식 확장, 식사/운동 미등록 시 안내문(기획 주석) 여부.
- [대기] 평문 시크릿을 Gemini 키와 같은 `${ENV:}` 방식으로 이관. **이미 git 이력에 올라간 값이라 이관과 함께 재발급(폐기)이 필요**하다. 2026-07-11 에 OpenAI 키를 같은 이유로 제거한 선례 있음. 범위(2026-08-13 전수 확인):
  - `application.properties` — Google OAuth client-secret / i-Sens `blood.client.secret` / kakao js key
  - `egovframework/conf/globals.properties` — NCP `accessKey`·`secretKey` / Gabia `sms.apiKey`
  - `egovframework/spring/context-datasource.xml` — **DB 접속정보 평문**(url·username·password)
- [완료 2026-08-13] 새 Gemini 키 **paid tier 확인됨**. 무료/유료는 호출 성공 여부로는 구분되지 않고 **RPM 한도로 판별**한다 — 무료 tier 는 flash 계열 약 10 RPM 이라 동시 요청을 몰면 429 가 뜨고 에러 본문의 quota 이름에 `FreeTier` 문자열이 그대로 박혀 나온다. 50건 동시 요청 전원 200(429 0건) → 유료. `chatAsk.do` 로 25건 동시 요청해도 전원 성공하므로 **앱 JVM 이 쥔 키도 유료 키**임이 함께 확인된다(환경변수가 제대로 상속됐다는 뜻).

## ✅[2026-08-20] 식사등록 — 음식 검색 목록을 **닫을 방법이 없었다**

- **증상**(사용자): 「골라야만 목록이 없어지고, 아니면 다른 화면으로 가야 한다」.
- **원인**: 바깥 누름을 ***`mousedown` 으로만*** 듣고 있었다. **휴대폰 터치에서는 이 이벤트가 늦게 오거나
  아예 안 와서** 바깥을 눌러도 안 닫혔다(PC 에서는 멀쩡해 눈치채기 어렵다).
- **조치**(foodMain.jsp `initFoodAutosuggest`) :
  · **`pointerdown` + `touchstart` + `mousedown` 을 모두 capture 로** 받아 바깥 누름에 닫는다
    (입력칸·목록 안은 제외 — 고르는 중에 닫히면 안 된다).
  · **화면을 굴리면 닫는다**(목록이 칸에 붙어 있어 굴리면 자리가 어긋난다).
  · 목록 맨 위에 **「✓ 입력내용 적용」 줄**(sticky·왼쪽 정렬) — 바깥을 눌러 닫는 걸 모르는 분이 많고,
    목록이 화면을 덮으면 **바깥을 누를 자리도 마땅치 않다.** 닫는 길을 눈에 보이게 둔다.
    ★처음엔 「✕ 닫기」였는데 **「입력내용 적용」으로 바꿨다**(2026-08-20 요청) —
    목록에 없는 음식을 적었을 때 **내가 친 그대로 쓰는 길**이 진짜 필요한 것이었다.
    ⚠누르면 **`foodMseq`(마스터 연결)를 반드시 비운다** — 안 비우면 앞서 고른 음식의 코드가 남아
    ***엉뚱한 칼로리로 집계된다.*** 저장 쪽은 코드가 없으면 기본값 '1' 을 쓰므로 그대로 저장된다.
  · Esc 는 종전대로.
- ⚠**터치 화면에서 「바깥 누르면 닫힘」을 만들 때는 `mousedown` 만으로는 부족하다** — 이 앱 전체에 해당한다.

### 운동등록도 같은 조작으로 (exerMain.jsp, 2026-08-20)

- 종전 : 운동 종류 칸이 **readonly** 라 ***목록에서 고르는 것만*** 됐다. 목록에 없는 운동은
  「직접입력」 을 먼저 골라야 했고, **목록을 닫을 방법이 없어** 다른 화면으로 나가야 했다.
- 지금 : ①칸에 **바로 칠 수 있고 치는 대로 목록이 걸러진다** ②맨 앞 **「✓ 입력내용 적용」** 으로
  적은 그대로 쓰고 닫는다(Enter 도 같은 동작) ③바깥 누름(pointerdown·touchstart·click)·스크롤·Esc 로 닫힌다.
- ★**운동 목록은 서버에 없다** — 화면에 박힌 **16종**(걷기·달리기…)이라 거르기도 화면에서 한다.
  (사용자 확인 «서버내용없습니다». 나중에 마스터가 생기면 식사처럼 조회로 바꾸면 된다.)
- ⚠「직접입력」 줄은 ②가 대신하므로 **감췄다**(둘이 같이 보이면 무엇을 누를지 헷갈린다). markup 은 남아 있다.
- ★**목록을 세로로 폈다**(2026-08-20 «운동도 식사처럼») — 종전 CSS 가 `flex; nowrap; overflow-x` 라
  **가로로 늘어섰고**, 폭이 모자라면 ***글자가 한 자씩 세로로 쪼개져*** 읽을 수 없었다(걷기 → 걷/기).
  ⇒ `flex-direction:column` + 세로 스크롤(240px), 항목은 `white-space:nowrap`.
  ⚠**칸 아래로 펴게 바꿨다** — 이 화면은 `.dropup`(위로 펴기)이라 위 칸(운동일자·시간)을 가렸다.
  `.custom-select.dropup .custom-select-options` (0,3,0) 로 눌러 둬서 공용 `.dropup` 규칙보다 세다.
- 「✓ 입력내용 적용」은 목록 맨 위에 **sticky** — 굴려도 붙어 있다(식사등록과 같은 모양).

## ✅[2026-08-20] 1시간 무활동 자동 로그아웃 + 하단 네비 모순 2건

- **자동 로그아웃**(요청 «화면 변경이 없으면 1시간 이후 로그아웃») — [tiles/main/header.jsp] 에 무활동 타이머.
  · 서버는 이미 `web.xml <session-timeout>60</session-timeout>` 이지만 그건 **다음 요청 때** 튕기는 것이라
    ***켜 둔 화면은 개인 혈당 자료를 띄운 채 그대로 남아 있었다.*** 이제 화면이 스스로 나간다.
  · 헤더는 **로그인 뒤 화면(tiles 'main')에만** 들어가므로 로그인 화면에는 안 걸린다.
  · 활동 판정 = click·keydown·touchstart·mousedown·mousemove·wheel·scroll·input(capture) + 탭 복귀(visibilitychange).
    **30초 스로틀** — 마우스·스크롤이 초당 수십 번 오므로 매번 타이머를 새로 걸지 않는다.
  · 나갈 때 **자동로그인부터 끈다**(`callAndroid f102`) — 안 끄면 로그인 화면에서 곧바로 재로그인된다.
    logout.do 응답이 없어도 1.5초 뒤 로그인 화면으로 간다.
  · ⚠**`IDLE_MIN`(60) 은 web.xml session-timeout 과 같은 값으로 유지할 것.**
- **네비 모순 ①「AI 화면에서 탭이 하나도 안 켜짐」** — AI 챗봇·AI 종합분석은 goBloodPage2.do(혈당 화면)인데
  2026-08-20 에 제목을 「AI 챗봇」 으로 바꾸며 menuName 에서 '혈당' 이 사라져 어느 가지에도 안 걸렸다.
  ⇒ footer.jsp 혈당 가지에 **`menu.contains("AI")`** 추가.
- **네비 모순 ②「홈인데 직전 화면 탭이 켜져 있음」** — ***운동·식사 컨트롤러는 menuName 을 `session` 에 넣는다***
  (다른 화면까지 따라다닌다). 홈(`mainPage.do`)은 그 값을 갱신하지 않아 **운동등록 → 홈** 이면 '운동등록' 이 켜진 채였다.
  ⇒ `LoginController.mainPage` 에서 **`session.setAttribute("menuName","홈")`**, footer 에 `menu.equals("홈")` 가지.
  ⚠**자바 변경** — Eclipse F5 + 재기동 필요(챗봇 제목 건과 함께 올라간다).
  ⚠menuName 이 세션에 남는 구조라, 새 화면을 만들 때 **menuName 을 반드시 설정**해야 남의 탭이 켜지지 않는다.

## ✅[2026-08-20] 연속혈당 증감 화살표 — 7단계 → **하나를 기울이는 연속 각도**

- **요청**: "증감 화살표를 좀더 세분화 — 지금은 단계적 단순함" + "화살표는 하나로".
- **종전**: 글자 화살표 7개(↑↑ ↑ ↗ → ↘ ↓ ↓↓) 중 하나를 골라 끼웠다 → +2 와 +4 가 똑같은 ↗ 라
  변화 크기가 화살표에 안 담겼다(뚝뚝 끊김). 2026-08-16 에 이미지→글자로 바꾼 그 자리다.
- **지금**: **화살표 한 글자(→)를 변화율만큼 기울인다**(단계 없음).
  · 각도 = `-(rate/_RATE_FULL)*90` — **`_RATE_FULL` mg/dL/분에서 수직**, 0 이면 수평.
    처음 3(국제 CGM 표기 관례)으로 뒀다가 **2 로 낮췄다**(2026-08-20 요청 — 3 은 좀처럼 안 닿아 늘 눕는 편).
    ***기울기 조절은 이 상수 하나만 고치면 된다.*** 지금 = 5분당 ±10 이면 수직.
  · `display:inline-block` 필수(기본 inline 이면 transform 이 무시된다) + `transition .35s` 로 부드럽게.
  · ⚠**숫자(#diff)는 종전 그대로 '직전 5분 차이'** — 좌우에 보이는 두 측정값의 차이와 같아야 해서
    계산 근거를 바꾸지 않았다(30분 회귀 등으로 바꾸면 97→109 인데 +11.8 처럼 어긋나 보인다).
  · 상태 문구(안정적·증가…)는 7단계 표현 유지 + 분당 변화율 병기. **경계값은 종전과 동일**
    (±2/±5/±10 per 5분 = ±0.4/±1/±2 per 분) — -40~40 전수 대조로 판정 불변 확인.
- `BLOOD_IMG`(단계별 그림 경로)는 이제 완전히 미사용 — 되돌릴 때를 위해 주석만 달아 남겨 두었다.
- **JSP 만** — target 사본 복사 완료.

## ✅[2026-08-20] 연속혈당 — 로그인 직후 「마지막 측정시각」이 한참 이르게 나오던 문제

- **증상**(사용자 보고): 한참 만에 로그인하면 큰 숫자 밑 시각이 현재보다 이르다(예 지금 14:00 인데 13:40).
- **원인**: `FAHR_00.jsp` `$(document).ready` 가 **`getBloodData()`(외부 i-Sens 수집, async:true)를 쏘고
  기다리지 않은 채** 바로 `orderby()` → `showBloodData()` 로 **DB 를 읽는다.** 그 순간 DB 엔 아직 옛 자료뿐이라
  수집 전 마지막 측정시각이 그려지고, **수집이 끝나도 다시 그리는 곳이 없었다.**
  ⚠`async:true` 줄의 주석("완료 시 orderby로 차트 갱신")이 **실제 코드엔 빠져 있었다** — 주석만 믿지 말 것.
  (SQL `showBloodData` 는 CGM_DTM DESC LIMIT 2 로 정상, `timeFormatFunc` 표시도 정상 — 자료 도착 시점 문제였다.)
- **조치**: `getBloodData()` success 에서 수집 성공 시 **`orderby()` 재렌더**. 안전장치 둘 —
  ①호출 시점의 날짜(`_viewAtCall`)와 다르면(사용자가 ◀▶ 로 이동) 손대지 않는다
  ②오늘을 보는 중이면 `now`/`halfNow` 를 '지금' 기준으로 다시 잡는다(수집 중 들어온 '페이지 연 시각 이후'
  측정이 `BETWEEN start AND end` 밖으로 빠지지 않게).
- **[이어서 처리] 폴백 복귀**(2026-08-20 요청): 오늘 자료가 0건이라 `adjustToLastDataDate()` 로 **과거일 폴백**된
  상태에서 수집으로 오늘 자료가 들어오면 **오늘로 되돌린다**(`restoreTodayIfArrived`).
  종전엔 '오늘 → 과거' 한 방향뿐이라 화면이 과거일에 머물고 "당일 혈당 측정이 없어…" 안내까지 남았다.
  - 판정 = `lastMeasureDate` 와 같은 날을 보는 중 + 그 날이 오늘이 아님 → 폴백. 아니면 조회 없이 통과(평소 경로).
  - 복귀 시 `lastMeasureDate=null`(안내 사라짐) · `now/halfNow` 재설정 · 시간 버튼 복원.
    ⚠버튼은 `updateButtonState()` 대신 **전날버튼의 '오늘 복귀' 처리와 같은 모양**을 쓴다 —
    updateButtonState 의 오늘 분기는 3·6·12·24 를 **전부 선택색(btnCol06)** 으로 칠한다.
  - 확인이 오는 사이 사용자가 ◀▶ 로 날짜를 옮기면 **아무것도 하지 않는다**(재렌더도 생략).
  - 검증 : 4가지 경우를 Node 로 태워 확인(폴백+오늘도착 / 폴백+미도착 / 평소 / 응답중 날짜이동) — 전부 통과.
- **JSP 만** — target 사본 복사 완료. Eclipse 서빙이면 F5 + Ctrl+F5.

## ✅[2026-08-20] 챗봇 제목 정리 — 상단 헤더가 유일한 제목

- **요청**: ?chat=1 진입 화면의 상단 제목이 「AI 종합분석(주간)」이라 어긋남 + 화면 안 「< 🤖 AI 챗봇」 줄과 중복.
- **조치**: ①`BloodController.goBloodPage2` 가 `@RequestParam chat` 을 받아 **?chat=1 이면 menuName=「AI 챗봇」**,
  아니면 종전 「AI 종합분석(주간)」 ②`Blood_Consult.jsp` 챗 오버레이의 제목줄(`.chat-ovhead` : ‹ 뒤로 + 🤖 AI 챗봇) **제거** —
  나가기는 상단 공통 뒤로가기(top.jsp btnPrev → history.back → 메인)가 맡는다. `closeChat()` 함수와
  `.chat-ovhead` CSS 는 남아 있다(호출부·사용처만 없음 — 복원 시 chatOverlay 위 주석 참고).
- ⚠**자바 변경 포함** — Eclipse 새로고침(F5)+재기동해야 반영. JSP 만 고칠 때(파일 복사)와 다르다.
- **[같은 날 수정] 공복 평균혈당 답변 기준 모순** — 판정은 진단 기준(정상<100/공복혈당장애 100~125/≥126)인데
  권장은 관리 목표(80~130)라 108 이 「공복혈당장애 + 권장 범위 안」으로 동시에 나왔다(진단명 사용이
  "진단이 아닙니다" 각주와도 충돌). → 판정을 **관리 목표 기준으로 통일**(<80 낮음 주의 / 80~130 목표 범위 내 /
  131~160 다소 높음 / >160 높음) — 같은 화면 공복 카드(avgFastingBlood1_name)와 동일 구간.

## ✅[2026-08-13 저녁] 챗봇 — 기획 「AI 응답 Sample」 반영 + 동적 진행바

기획 원본 = `D:\세종TP\화면 기능개선(3차전달자료)_AI.pptx` (4유형 샘플 + 프롬프트 실험 2종).
**컨셉 = 수치·판정은 기존 자료(화면), 문장만 유료 Gemini.** 고친 곳 :

- **`Blood_Consult.jsp` `_chatCtxText()`** — TAR/TBR/CV 를 컨텍스트에 추가하고(종전엔 TIR 뿐이라
  고혈당형/저혈당형을 못 갈랐다), **4유형 판정은 우리가 한다**(`_chatGlucoseType`, 학회 기준
  TIR≥70/TAR<25/TBR<4/CV≤36 — LLM 에 맡기면 같은 수치에 다른 유형이 나온다).
- ★★**숫자를 LLM 에 보내지 않는다** — 「수치를 쓰지 마」라고 지시해도 모델은 받은 숫자를
  되읽는다(4유형 전부 실측). ⇒ 컨텍스트를 **정성 표현**(`목표범위 유지 양호 / 저혈당 반복 / …`)으로
  바꿔 보내니 한 번에 해결. ***되읽을 숫자를 주지 않는 것이 유일하게 확실한 방법.***
- **`BloodController` 프롬프트** — 3단계 구조(상태→이유→행동, 기획 결론 그대로) · 100자 내외 ·
  유형별 행동 방향 4종 명시 · **번호(①②③)·머리기호 금지**(넣으면 그대로 찍힌다 — 실측).
- **「…」 → 동적 진행바**(`.chat-progress`) — Gemini 2~5초 대기가 멈춘 것처럼 보였다(사용자 지적).
  90% 까지 점근(가짜 100% 로 안 기다리게) + 응답 오면 100% 닫고 제거. 실측 1.0s=7% → 6.0s=100%.
- ⚠배포는 **세 곳** — src(정본) · `target/Sejong_APP-1.0.0/`(빌드 산출) · **tmp2 wtpwebapps(실제 서빙)**.
  JSP 는 wtpwebapps 에 안 넣으면 화면에 안 나온다(§배포 함정의 로컬 확장판).
  ⚠클래스를 wtpwebapps 에 넣으면 **컨텍스트 자동 재적재 → 세션 전부 끊김**(testUser2 재로그인).
- 검증 : 규칙 매칭(①②단계)에 안 걸리는 질문이어야 LLM 경로(③)가 탄다 — "혈당 상태 어때"는
  로컬 규칙이 가로챈다. 서버(운영) 반영은 **다음 WAR 빌드에 자동 포함**(src 에 커밋됐으므로).
- **[2026-08-13 추가] 수치+가이드 복합 질문 = 두 답변 이어붙임** — "내 최고혈당 관련 운동, 식사 가이드"처럼
  수치 규칙(최고/최저·평균 등)에 걸리면서 가이드 낱말(가이드·추천·운동·식사·먹…)이 섞인 질문은
  수치 즉답 → 진행바 → **LLM 가이드**가 이어서 나온다(`_chatLLMFollow`, 음식추천·운동추천 구간부터는 끔).
  이때 화면의 주의음식·추천운동 TOP3 **이름만** ctx 에 실어 보낸다(`_chatGuideCtx`) — 실측: "흰쌀밥과 짜장면
  섭취량을 조절하시면서 걷기 운동을…" 처럼 앱 데이터를 문장에 녹여 답한다. 입력줄 🗑(전체삭제)는 사용자
  요청으로 제거(주석에 복원법), 진행바는 「AI 생각중…」 + 부트스트랩식 파란 줄무늬 바로 확정.
