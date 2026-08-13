# sejong_app 프로젝트 메모

## ★배포/반영 방식 (가장 중요한 함정)
- **화면은 `target/Sejong_APP-1.0.0/`(exploded)을 서빙**한다 — `src/` JSP·CSS를 고쳐도 **target 사본에 복사해야 반영**된다.
  ```
  cp src/main/webapp/...파일 target/Sejong_APP-1.0.0/...같은경로
  ```
  2026-07-31 "색이 안 바뀐다" 원인이 전부 이것. 수정 후 반드시 동기화할 것. CSS는 브라우저 캐시 → Ctrl+F5.
- git 저장소는 **상위 폴더(C:\Users\user\git\sejong) 하나**로 sejong_app + sejong-web을 함께 관리.
- 백업: `C:\Users\user\git\sejong\backup_20260731\` (소스 2종 + .git 이력 zip).

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

## 대기/미완
- [대기] AI 챗봇 서버 LLM(/blood/chatAsk.do)·blood_qa.js 지식 확장, 식사/운동 미등록 시 안내문(기획 주석) 여부.
- [대기] `application.properties` 평문 시크릿을 Gemini 키와 같은 `${ENV:}` 방식으로 이관 — Google OAuth client-secret / i-Sens `blood.client.secret` / kakao js key. **이미 git 이력에 올라간 값이라 이관과 함께 재발급(폐기)이 필요**하다. 2026-07-11 에 OpenAI 키를 같은 이유로 제거한 선례 있음.
- [완료 2026-08-13] 새 Gemini 키 **paid tier 확인됨**. 무료/유료는 호출 성공 여부로는 구분되지 않고 **RPM 한도로 판별**한다 — 무료 tier 는 flash 계열 약 10 RPM 이라 동시 요청을 몰면 429 가 뜨고 에러 본문의 quota 이름에 `FreeTier` 문자열이 그대로 박혀 나온다. 50건 동시 요청 전원 200(429 0건) → 유료. `chatAsk.do` 로 25건 동시 요청해도 전원 성공하므로 **앱 JVM 이 쥔 키도 유료 키**임이 함께 확인된다(환경변수가 제대로 상속됐다는 뜻).
