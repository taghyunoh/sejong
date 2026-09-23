# -*- coding: utf-8 -*-
import os, sys, subprocess
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from gen_src_doc import read_ranges, render, OUT

J = 'src/main/java/egovframework/sejong/'
W = 'src/main/webapp/WEB-INF/jsp/main/'

# ─────────────────────────────── 문서 ① 앱 (챗봇 제외)
app_blocks = [
    ('① 로그인 세션 검사·만료 처리|' + J + 'util/SessionCheckInterceptor.java',
     read_ranges(J + 'util/SessionCheckInterceptor.java', [(38, 55), (68, 91)])),
    ('② 연속혈당(CGM) 자료 수집 — 외부 기기 연동 및 토큰 자동 갱신|' + J + 'blood/web/BloodController.java',
     read_ranges(J + 'blood/web/BloodController.java', [(339, 342), (367, 392)])),
    ('③ 혈당 통계 산출 — 고·저혈당 발생 시간대 상위 3구간|src/main/resources/egovframework/sqlmap/mapper/Blood_SQL.xml',
     read_ranges('src/main/resources/egovframework/sqlmap/mapper/Blood_SQL.xml', [(98, 127)])),
    ('④ 혈당 변화 화살표 — 직전 측정값 대비 연속 각도 표시|' + W + 'FAHR_00.jsp',
     read_ranges(W + 'FAHR_00.jsp', [(886, 906)])),
    ('⑤ 무활동 1시간 자동 로그아웃|src/main/webapp/WEB-INF/tiles/main/header.jsp',
     read_ranges('src/main/webapp/WEB-INF/tiles/main/header.jsp', [(48, 78)])),
    ('⑥ 식사등록 음식 검색 — 터치 기기 대응 목록 닫기|' + W + 'food/foodMain.jsp',
     read_ranges(W + 'food/foodMain.jsp', [(686, 705)])),
    ('⑦ RAG 기반 AI 상담 챗봇 — 질의 접수·검색결과 증강 및 생성형 AI 호출|' + J + 'blood/web/BloodController.java',
     read_ranges(J + 'blood/web/BloodController.java', [(988, 1004), (1019, 1029), (1116, 1132)])),
]

app_meta = [
    ('프로그램의 명칭', '개인 맞춤형 혈당관리 플랫폼 소프트웨어 (Sejong_APP)'),
    ('저작물의 종류', '컴퓨터프로그램저작물'),
    ('주요 기능', '연속혈당측정(CGM) 기기 연동 및 혈당 자료 수집 · 혈당 지표(TIR/TAR/TBR/CV/GMI) 산출과 도표 표시 · '
                 '식사·운동 기록과 혈당 연관 분석 · RAG 기반 AI 상담 챗봇 · 회원 인증 및 개인 의료정보 관리 · PWA 설치형 모바일 화면'),
    ('개발 언어 및 환경', 'Java 17 (Spring Framework / 전자정부표준프레임워크) · JSP · JavaScript · '
                     'MyBatis SQL(MySQL) · HTML5/CSS3 · Apache Tomcat 9'),
    ('전체 소스 분량', '약 33,800줄 (서드파티 라이브러리 및 KISA 제공 암호모듈 제외)'),
    ('본 문서의 범위', '플랫폼 <b>전체 소스</b>(AI 상담 챗봇 모듈 포함) 중 주요 기능 7개 부분 <b>발췌</b>.'),
]

app_note = ('※ 본 문서는 전체 소스코드 중 주요 부분을 발췌한 것이며, 각 코드 왼쪽의 번호는 해당 파일 내 실제 줄번호이다. '
            '가독성을 위해 발췌 구간의 공통 들여쓰기만 제거하였고 코드 내용은 원본과 동일하다. '
            '보안상 접속정보·인증키 등 설정값이 담긴 파일은 발췌 대상에서 제외하였다.')

# ─────────────────────────────── 문서 ② AI 챗봇
BC = J + 'blood/web/BloodController.java'
CS = W + 'Blood_Consult.jsp'

bot_blocks = [
    ('① 질의 접수 및 검색결과 증강 프롬프트 구성 — Augmentation (서버)|' + BC,
     read_ranges(BC, [(988, 1004), (1013, 1029), (1036, 1050)])),
    ('② 이용자 연령·당뇨 유형별 관리목표 결합|' + BC,
     read_ranges(BC, [(1073, 1085)])),
    ('③ 연령·당뇨 유형별 혈당관리 목표 기준|' + J + 'util/CgmTarget.java',
     read_ranges(J + 'util/CgmTarget.java', [(37, 48)])),
    ('④ 생성형 AI(Gemini) 호출 — Generation 요청·응답 파싱|' + BC,
     read_ranges(BC, [(1112, 1135), (1157, 1171)])),
    ('⑤ 질의 처리 흐름 — 검색 적중 시 즉답, 미적중 시 생성형 AI (화면)|' + CS,
     read_ranges(CS, [(1427, 1447)])),
    ('⑥ AI 참고자료 생성 및 혈당 유형 4분류 자동 판정|' + CS,
     read_ranges(CS, [(1783, 1806)])),
    ('⑦ 지식베이스 검색 — Retrieval (키워드 가중치 점수제)|' + CS,
     read_ranges(CS, [(1729, 1747)])),
    ('⑧ 혈당 지식베이스(Knowledge Base) 자료 구조|src/main/webapp/asset/js/blood_qa.js',
     read_ranges('src/main/webapp/asset/js/blood_qa.js', [(1, 14)])),
]

bot_meta = [
    ('프로그램의 명칭', '개인 혈당데이터 분석용 RAG 기반 AI 상담 챗봇 (Sejong AI Glucose Chatbot)'),
    ('저작물의 종류', '컴퓨터프로그램저작물'),
    ('주요 기능', '<b>RAG(검색증강생성) 구조</b>의 혈당 상담 챗봇 — ①이용자 질의로 혈당 지식베이스를 검색(Retrieval)하여 '
                 '일치 근거가 있으면 그 내용으로 응답하고 ②근거가 없으면 이용자의 혈당 분석 결과(TIR/TAR/TBR/CV 기반 유형 판정, '
                 '연령·당뇨 유형별 관리목표, 주의 음식·추천 운동)를 프롬프트에 결합(Augmentation)하여 ③생성형 AI가 상담 문장을 '
                 '생성(Generation)한다 · 동일 질의 캐시 및 응답 진행 표시'),
    ('개발 언어 및 환경', 'Java 17 (Spring Framework) · JavaScript · JSP · '
                     '생성형 AI API(Google Gemini generateContent) 연동'),
    ('설계상의 특징', '검색 단계는 혈당 지식베이스(자체 구축)에 대한 <b>키워드 가중치 매칭</b>으로 구현하여 외부 벡터 DB 없이 '
                  '동작한다. 수치 계산과 상태 판정은 프로그램이 직접 수행하고 생성형 AI에는 <b>수치를 전달하지 않으며</b> '
                  '정성적 표현만 결합해 문장 생성에만 사용한다. AI 미설정·호출 실패 시 자체 지표 요약으로 대체 응답한다.'),
    ('본 문서의 범위', '챗봇 모듈 소스 중 주요 기능 8개 부분 <b>발췌</b> (질의 처리·검색·증강·생성 각 단계와 지식베이스)'),
]

bot_note = ('※ 본 문서는 챗봇 모듈 소스코드 중 주요 부분을 발췌한 것이며, 각 코드 왼쪽의 번호는 해당 파일 내 실제 줄번호이다. '
            '가독성을 위해 발췌 구간의 공통 들여쓰기만 제거하였고 코드 내용은 원본과 동일하다. '
            '인증키 등 비밀값은 소스에 포함되지 않고 실행 환경의 환경변수로 주입된다.')

# ═══════════════════════════════════════════ 합본 (한 문서에 1부·2부)
#   1부 = 플랫폼 고유 기능 6개 (챗봇 블록은 2부가 자세히 다루므로 여기서 뺀다 — 같은 코드가 두 번 나오지 않게)
merged_blocks = ([('■ 제1부  개인 맞춤형 혈당관리 플랫폼 소프트웨어', [])]
                 + app_blocks[:6]
                 + [('■ 제2부  개인 혈당데이터 분석용 RAG 기반 AI 상담 챗봇', [])]
                 + bot_blocks)

merged_meta = [
    ('등록 대상', '<b>2건</b> — ① 개인 맞춤형 혈당관리 플랫폼 소프트웨어(B2B용) '
               '② 개인 혈당데이터 분석용 RAG 기반 AI 상담 챗봇'),
    ('① 플랫폼 S/W', '연속혈당측정(CGM) 기기 연동 및 혈당 자료 수집 · 혈당 지표(TIR/TAR/TBR/CV/GMI) 산출과 도표 표시 · '
                  '식사·운동 기록과 혈당 연관 분석 · 회원 인증 및 개인 의료정보 관리 · PWA 설치형 모바일 화면'),
    ('② RAG 챗봇', '<b>RAG(검색증강생성) 구조</b> — ①질의로 혈당 지식베이스를 검색(Retrieval)해 근거가 있으면 그 내용으로 응답 '
                '②없으면 이용자의 혈당 분석 결과(유형 판정·연령별 관리목표·주의 음식·추천 운동)를 프롬프트에 결합(Augmentation) '
                '③생성형 AI가 상담 문장을 생성(Generation). 검색은 자체 구축 지식베이스의 키워드 가중치 매칭으로 '
                '구현해 외부 벡터 DB 없이 동작한다.'),
    ('개발 언어 및 환경', 'Java 17 (Spring Framework / 전자정부표준프레임워크) · JSP · JavaScript · MyBatis SQL(MySQL) · '
                     'HTML5/CSS3 · Apache Tomcat 9 · 생성형 AI API(Google Gemini generateContent)'),
    ('전체 소스 분량', '약 33,800줄 (서드파티 라이브러리 및 KISA 제공 암호모듈 제외)'),
    ('본 문서의 범위', '제1부 = 플랫폼 주요 기능 6개 부분, 제2부 = 챗봇 주요 기능 8개 부분 <b>발췌</b>. '
                  'AI 챗봇은 플랫폼에 포함되어 동작하며, 제2부에서 모듈 단위로 따로 보인다.'),
]

merged_note = ('※ 각 코드 왼쪽 번호는 해당 파일 내 실제 줄번호이며, 가독성을 위해 발췌 구간의 공통 들여쓰기만 제거하였다. '
               '접속정보·인증키가 포함된 설정 파일은 발췌 대상에서 제외하였고, 인증키는 소스가 아닌 실행 환경의 '
               '환경변수로 주입된다.')

jobs_merged = [('개인 맞춤형 혈당관리 플랫폼 소프트웨어 및 RAG 기반 AI 상담 챗봇 소스코드',
                '소스코드 (발췌) — 혈당관리 플랫폼 S/W · RAG 기반 AI 상담 챗봇',
                merged_meta, merged_blocks, merged_note, '00_merged_source')]

DATE = '2026. 09. 23.'
jobs = [
    ('개인 맞춤형 혈당관리 플랫폼 소프트웨어 소스코드', '소스코드 (발췌) — 개인 맞춤형 혈당관리 플랫폼 S/W',
     app_meta, app_blocks, app_note, '01_platform_source'),
    ('개인 혈당데이터 분석용 RAG 기반 AI 상담 챗봇 소스코드', '소스코드 (발췌) — RAG 기반 AI 상담 챗봇',
     bot_meta, bot_blocks, bot_note, '02_chatbot_source'),
]

if __name__ == '__main__':
    for title, sub, meta, blocks, note, name in jobs + jobs_merged:
        render(title, sub, meta, blocks, note, name)
    print('done')
