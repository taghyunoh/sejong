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
]

app_meta = [
    ('프로그램의 명칭', '세종 당뇨·혈당관리 모바일 앱 (Sejong_APP)'),
    ('저작물의 종류', '컴퓨터프로그램저작물'),
    ('주요 기능', '연속혈당측정(CGM) 기기 연동 및 혈당 자료 수집 · 혈당 지표(TIR/TAR/TBR/CV/GMI) 산출과 도표 표시 · '
                 '식사·운동 기록과 혈당 연관 분석 · 회원 인증 및 개인 의료정보 관리 · PWA 설치형 모바일 화면'),
    ('개발 언어 및 환경', 'Java 17 (Spring Framework / 전자정부표준프레임워크) · JSP · JavaScript · '
                     'MyBatis SQL(MySQL) · HTML5/CSS3 · Apache Tomcat 9'),
    ('전체 소스 분량', '약 33,800줄 (서드파티 라이브러리 및 KISA 제공 암호모듈 제외)'),
    ('본 문서의 범위', '전체 소스 중 주요 기능 6개 부분 <b>발췌</b>. '
                  '<b>AI 혈당상담 챗봇 모듈은 별도 저작물로 등록하므로 이 문서에서 제외</b>하였다.'),
]

app_note = ('※ 본 문서는 전체 소스코드 중 주요 부분을 발췌한 것이며, 각 코드 왼쪽의 번호는 해당 파일 내 실제 줄번호이다. '
            '가독성을 위해 발췌 구간의 공통 들여쓰기만 제거하였고 코드 내용은 원본과 동일하다. '
            '보안상 접속정보·인증키 등 설정값이 담긴 파일은 발췌 대상에서 제외하였다.')

# ─────────────────────────────── 문서 ② AI 챗봇
BC = J + 'blood/web/BloodController.java'
CS = W + 'Blood_Consult.jsp'

bot_blocks = [
    ('① 챗봇 질의 접수·AI 프롬프트 구성 및 응답 처리 (서버)|' + BC,
     read_ranges(BC, [(988, 1004), (1013, 1029), (1036, 1050)])),
    ('② 이용자 연령·당뇨 유형별 관리목표를 프롬프트에 반영|' + BC,
     read_ranges(BC, [(1073, 1085)])),
    ('③ 연령·당뇨 유형별 혈당관리 목표 기준|' + J + 'util/CgmTarget.java',
     read_ranges(J + 'util/CgmTarget.java', [(37, 48)])),
    ('④ 생성형 AI(Gemini) 호출 — 요청 구성·전송 및 응답 파싱|' + BC,
     read_ranges(BC, [(1112, 1135), (1157, 1171)])),
    ('⑤ 질의 처리 흐름 — 규칙 기반 즉답 후 AI 폴백 (화면)|' + CS,
     read_ranges(CS, [(1427, 1447)])),
    ('⑥ AI 참고자료 생성 및 혈당 유형 4분류 자동 판정|' + CS,
     read_ranges(CS, [(1783, 1806)])),
    ('⑦ 혈당 지식베이스 키워드 매칭 (가중치 점수제)|' + CS,
     read_ranges(CS, [(1729, 1747)])),
    ('⑧ 혈당 Q&A 지식베이스 자료 구조|src/main/webapp/asset/js/blood_qa.js',
     read_ranges('src/main/webapp/asset/js/blood_qa.js', [(1, 14)])),
]

bot_meta = [
    ('프로그램의 명칭', 'AI 혈당상담 챗봇 (Sejong AI Glucose Chatbot)'),
    ('저작물의 종류', '컴퓨터프로그램저작물'),
    ('주요 기능', '이용자의 혈당 관련 질의를 규칙 기반 지식베이스로 우선 응답하고, 해당 답변이 없을 때 생성형 AI를 호출하여 '
                 '상담 문장을 생성 · 혈당 지표(TIR/TAR/TBR/CV)로 혈당 유형 4종을 자체 판정해 AI 참고자료로 제공 · '
                 '연령·당뇨 유형별 관리목표 자동 적용 · 동일 질의 캐시 및 응답 진행 표시'),
    ('개발 언어 및 환경', 'Java 17 (Spring Framework) · JavaScript · JSP · '
                     '생성형 AI API(Google Gemini generateContent) 연동'),
    ('설계상의 특징', '수치 계산과 상태 판정은 프로그램이 직접 수행하고 생성형 AI에는 <b>수치를 전달하지 않으며</b> '
                  '정성적 표현만 전달해 문장 생성에만 사용한다. AI 미설정·호출 실패 시 자체 지표 요약으로 대체 응답한다.'),
    ('본 문서의 범위', '챗봇 모듈 소스 중 주요 기능 8개 부분 <b>발췌</b> (서버 질의 처리·AI 호출부, 화면 대화 처리부, 지식베이스)'),
]

bot_note = ('※ 본 문서는 챗봇 모듈 소스코드 중 주요 부분을 발췌한 것이며, 각 코드 왼쪽의 번호는 해당 파일 내 실제 줄번호이다. '
            '가독성을 위해 발췌 구간의 공통 들여쓰기만 제거하였고 코드 내용은 원본과 동일하다. '
            '인증키 등 비밀값은 소스에 포함되지 않고 실행 환경의 환경변수로 주입된다.')

DATE = '2026. 09. 23.'
jobs = [
    ('세종 당뇨·혈당관리 모바일 앱 소스코드', '소스코드 (발췌) — 세종 당뇨·혈당관리 모바일 앱',
     app_meta, app_blocks, app_note, '01_app_source'),
    ('AI 혈당상담 챗봇 소스코드', '소스코드 (발췌) — AI 혈당상담 챗봇',
     bot_meta, bot_blocks, bot_note, '02_chatbot_source'),
]

if __name__ == '__main__':
    for title, sub, meta, blocks, note, name in jobs:
        render(title, sub, meta, blocks, note, name)
    print('done')
