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

## 대기/미완
- [대기] AI 챗봇 서버 LLM(/blood/chatAsk.do)·blood_qa.js 지식 확장, 식사/운동 미등록 시 안내문(기획 주석) 여부.
