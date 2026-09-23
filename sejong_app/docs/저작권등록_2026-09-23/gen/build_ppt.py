# -*- coding: utf-8 -*-
"""저작권 등록 첨부용 소스코드 발췌 — PowerPoint(.pptx) 생성  (각 2장)

  1장 : 표제 + 개요(상단) + 소스코드 2단(하단)
  2장 : 소스코드 2단 (전면)

PDF 판(build_docs.py)과 같은 파일·같은 기능 구간을 쓰되, 2장에 담기도록 발췌 범위를 줄였다.
단당 줄 예산을 두고 나누므로 상자 밖으로 넘치지 않는다(넘치면 build 가 멈춘다).
"""
import os, sys, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

from gen_src_doc import dwidth, read_ranges
import build_docs as C
from qa_ppt import measure as _measure   # 글꼴 실측(Pillow) — 개요 줄수 계산용

OUT = os.path.dirname(os.path.abspath(__file__))

# ── 조판 상수 ──────────────────────────────────────────────
SLIDE_W, SLIDE_H = 13.333, 7.5
MARGIN, GAP, PAD = 0.55, 0.30, 0.10
COL_W = (SLIDE_W - MARGIN * 2 - GAP) / 2

CODE_PT, CODE_LEAD, MAXCOLS = 7.5, 9.0, 90
HEAD_COST = 3          # 블록 제목 한 덩어리(12pt + 앞뒤 여백)가 잡아먹는 코드 줄 수

META_TOP, META_PT, META_LEAD = 1.45, 10.5, 0.175   # 1장 개요 블록
META_KEY_W, META_VAL_X = 1.85, 1.95
BOTTOM = 0.62                                       # 카드 아래 여백
S2_CARD_TOP, S2_CARD_H = 1.16, 5.76      # 2장 : 전면

NAVY = RGBColor(0x1E, 0x27, 0x61)
INK  = RGBColor(0x1A, 0x1A, 0x1A)
GRAY = RGBColor(0x80, 0x86, 0x90)
CARD = RGBColor(0xF4, 0xF5, 0xF8)
LINE = RGBColor(0xD6, 0xDB, 0xE4)
MONO, SANS = 'Courier New', 'Calibri'


def meta_rows_h(meta_rows):
    """개요 블록이 실제로 차지하는 높이(inch) — 값 글상자의 줄바꿈을 글꼴로 실측해 더한다."""
    vw = (SLIDE_W - MARGIN * 2 - META_VAL_X) * 100        # measure() 는 100px/inch 기준
    h = 0.0
    for _, v in meta_rows:
        v = v.replace('<b>', '').replace('</b>', '')
        n = max(1, math.ceil(_measure(v, 'Calibri', META_PT) / vw - 1e-6))
        h += META_LEAD * n + 0.10
    return h


def lines_for(card_h):
    return int(((card_h - PAD * 2) * 72) // CODE_LEAD)


def cost(text):
    return max(1, math.ceil(max(dwidth(text), 1) / MAXCOLS))


def cont_title(title):
    """'제목|경로' 의 **제목 쪽에** (이어서) 를 붙인다 — 경로 뒤에 붙으면 파일명이 어지러워진다."""
    if '|' in title:
        name, path = title.split('|', 1)
        return name.rstrip() + '  (이어서)|' + path
    return title + '  (이어서)'


class Overflow(Exception):
    """주어진 단 수에 내용이 들어가지 않음."""


def paginate(blocks, budgets):
    """blocks → 단(column) 목록. budgets 개수를 넘으면 예외."""
    cols, cur, used, ci = [], [], 0, 0

    def flush():
        nonlocal cur, used, ci
        cols.append(cur)
        cur, used, ci = [], 0, ci + 1
        if ci >= len(budgets):
            raise Overflow()

    for title, lines in blocks:
        if used + HEAD_COST + 3 > budgets[ci]:
            flush()
        cur.append(('h', title))
        used += HEAD_COST
        for no, text in lines:
            c = 1 if no is None else cost('%4s  %s' % (no, text))
            if used + c > budgets[ci]:
                flush()
                cur.append(('h', cont_title(title)))
                used += HEAD_COST
            cur.append(('c', no, text))
            used += c
    cols.append(cur)                                 # 마지막 단은 예산 검사 없이 닫는다
    while len(cols) < len(budgets):
        cols.append([])
    return cols


def _box(slide, x, y, w, h):
    tb = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = tb.text_frame
    tf.word_wrap = True
    tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
    return tf


def _run(p, text, *, font=SANS, size=12, bold=False, color=INK):
    r = p.add_run()
    r.text = text
    r.font.name = font
    r.font.size = Pt(size)
    r.font.bold = bold
    r.font.color.rgb = color
    return r


def code_columns(slide, cols, top, height):
    for ci, col in enumerate(cols):
        if not col:
            continue
        x = MARGIN + ci * (COL_W + GAP)
        card = slide.shapes.add_shape(1, Inches(x), Inches(top), Inches(COL_W), Inches(height))
        card.fill.solid()
        card.fill.fore_color.rgb = CARD
        card.line.color.rgb = LINE
        card.line.width = Pt(0.75)
        card.shadow.inherit = False

        tf = _box(slide, x + PAD, top + PAD, COL_W - PAD * 2, height - PAD * 2)
        first = True
        for item in col:
            p = tf.paragraphs[0] if first else tf.add_paragraph()
            if item[0] == 'h':
                name, path = item[1].split('|', 1) if '|' in item[1] else (item[1], '')
                p.line_spacing = Pt(12)
                p.space_before = Pt(0 if first else 7)
                p.space_after = Pt(2)
                _run(p, name.strip(), font=SANS, size=10, bold=True, color=NAVY)
                if path:
                    _run(p, '   ' + path.strip(), font=MONO, size=7, color=GRAY)
            else:
                _, no, text = item
                p.line_spacing = Pt(CODE_LEAD)
                p.space_before = p.space_after = Pt(0)
                if no is None:
                    _run(p, '        (... 중략 ...)', font=MONO, size=CODE_PT, color=GRAY)
                else:
                    _run(p, '%4d  ' % no, font=MONO, size=CODE_PT, color=GRAY)
                    _run(p, text, font=MONO, size=CODE_PT, color=INK)
            first = False


def slide1(prs, title, meta_rows, cols, total=2):
    s = prs.slides.add_slide(prs.slide_layouts[6])

    tf = _box(s, MARGIN, 0.42, SLIDE_W - MARGIN * 2, 0.62)
    _run(tf.paragraphs[0], title, font=SANS, size=26, bold=True, color=NAVY)
    tf2 = _box(s, MARGIN, 1.02, SLIDE_W - MARGIN * 2, 0.32)
    _run(tf2.paragraphs[0], '컴퓨터프로그램저작물 등록 첨부자료 — 소스코드 (발췌)',
         font=SANS, size=11.5, color=GRAY)

    y = META_TOP
    vw = (SLIDE_W - MARGIN * 2 - META_VAL_X) * 100
    for k, v in meta_rows:
        v = v.replace('<b>', '').replace('</b>', '')
        n = max(1, math.ceil(_measure(v, 'Calibri', META_PT) / vw - 1e-6))
        kt = _box(s, MARGIN, y, META_KEY_W, META_LEAD)
        _run(kt.paragraphs[0], k, font=SANS, size=META_PT, bold=True, color=NAVY)
        vt = _box(s, MARGIN + META_VAL_X, y, SLIDE_W - MARGIN * 2 - META_VAL_X, META_LEAD * n)
        vp = vt.paragraphs[0]
        vp.line_spacing = Pt(META_PT * 1.2)
        _run(vp, v, font=SANS, size=META_PT, color=INK)
        y += META_LEAD * n + 0.10

    top, height = card_geom(meta_rows)
    code_columns(s, cols, top, height)
    _page_no(s, 1, total)
    return s


def slide_cont(prs, title, cols, note, idx, total, height=S2_CARD_H):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    tf = _box(s, MARGIN, 0.44, SLIDE_W - MARGIN * 2 - 1.5, 0.45)
    _run(tf.paragraphs[0], title + ' — 소스코드 (이어서)', font=SANS, size=17, bold=True, color=NAVY)

    code_columns(s, cols, S2_CARD_TOP, height)

    if idx == total and note:
        ny = min(SLIDE_H - 0.94, S2_CARD_TOP + height + 0.22)
        nt = _box(s, MARGIN, ny, SLIDE_W - MARGIN * 2 - 1.4, 0.5)
        np_ = nt.paragraphs[0]
        np_.line_spacing = 1.25
        _run(np_, note, font=SANS, size=8.5, color=GRAY)
    _page_no(s, idx, total)
    return s


def _page_no(s, i, n):
    t = _box(s, SLIDE_W - MARGIN - 1.2, SLIDE_H - 0.62, 1.2, 0.3)
    p = t.paragraphs[0]
    p.alignment = PP_ALIGN.RIGHT
    _run(p, '%d / %d' % (i, n), font=SANS, size=10, color=GRAY)


def card_geom(meta_rows):
    top = META_TOP + meta_rows_h(meta_rows) + 0.14
    return top, SLIDE_H - BOTTOM - 0.34 - top


def build(title, meta_rows, blocks, note, outfile, max_slides=4):
    b1, b2 = lines_for(card_geom(meta_rows)[1]), lines_for(S2_CARD_H)
    # ① 먼저 가득 채워 필요한 단 수를 구하고 ② 그 단 수(짝수)로 고르게 다시 나눈다
    #    — 마지막 장에 한 단만 덜렁 남는 모양을 피한다.
    cols = paginate(blocks, [b1, b1] + [b2] * ((max_slides - 1) * 2))
    while len(cols) > 2 and not cols[-1]:
        cols.pop()
    k = max(2, len(cols) - 2)
    k += k % 2                                       # 이어지는 장은 항상 2단
    budgets = [b1, b1] + [b2] * k
    for cand in range(14, b2 + 1):                   # 고르게 담기는 가장 작은 예산
        try:
            trial = paginate(blocks, [b1, b1] + [cand] * k)
        except Overflow:
            continue
        cols, budgets = trial, [b1, b1] + [cand] * k
        break
    while len(cols) > 2 and not cols[-1]:
        cols.pop()

    prs = Presentation()
    prs.slide_width, prs.slide_height = Inches(SLIDE_W), Inches(SLIDE_H)
    rest = cols[2:]
    total = 1 + math.ceil(len(rest) / 2)
    slide1(prs, title, meta_rows, cols[:2], total)
    h2 = min(S2_CARD_H, max(budgets[2:]) * CODE_LEAD / 72.0 + PAD * 2 + 0.06)
    for i in range(0, len(rest), 2):
        slide_cont(prs, title, rest[i:i + 2], note, 2 + i // 2, total, h2)

    path = os.path.join(OUT, outfile + '.pptx')
    prs.save(path)
    used = [sum(HEAD_COST if it[0] == 'h' else cost('%4s  %s' % (it[1], it[2])) for it in c) for c in cols]
    print('PPTX:', os.path.basename(path), '| 슬라이드', total,
          '| 단 사용/예산:', list(zip(used, budgets)))
    return path


# ═══════════════════════════════════════════ 내용 (2장 분량으로 축약)
J = 'src/main/java/egovframework/sejong/'
W = 'src/main/webapp/WEB-INF/jsp/main/'
BC = J + 'blood/web/BloodController.java'
CS = W + 'Blood_Consult.jsp'

app_blocks = [
    ('① 로그인 세션 검사·만료 처리|SessionCheckInterceptor.java',
     read_ranges(J + 'util/SessionCheckInterceptor.java', [(68, 91)])),
    ('② 연속혈당(CGM) 자료 수집 — 기기 연동·토큰 자동 갱신|BloodController.java',
     read_ranges(BC, [(339, 342), (367, 384)])),
    ('③ 혈당 통계 산출 — 고·저혈당 발생 시간대 상위 3구간|Blood_SQL.xml',
     read_ranges('src/main/resources/egovframework/sqlmap/mapper/Blood_SQL.xml', [(98, 113)])),
    ('④ 혈당 변화 화살표 — 직전 측정값 대비 연속 각도|FAHR_00.jsp',
     read_ranges(W + 'FAHR_00.jsp', [(893, 903)])),
    ('⑤ 무활동 1시간 자동 로그아웃|tiles/main/header.jsp',
     read_ranges('src/main/webapp/WEB-INF/tiles/main/header.jsp', [(49, 66)])),
    ('⑥ 식사등록 음식 검색 — 터치 기기 대응 목록 닫기|food/foodMain.jsp',
     read_ranges(W + 'food/foodMain.jsp', [(686, 697)])),
]

bot_blocks = [
    ('① 챗봇 질의 접수·AI 프롬프트 구성 (서버)|BloodController.java',
     read_ranges(BC, [(994, 1004), (1019, 1026)])),
    ('② AI 응답 생성 및 예외 처리|BloodController.java',
     read_ranges(BC, [(1036, 1046)])),
    ('③ 연령·당뇨 유형별 관리목표 반영|BloodController.java / CgmTarget.java',
     read_ranges(BC, [(1078, 1085)]) + read_ranges(J + 'util/CgmTarget.java', [(38, 47)])),
    ('④ 생성형 AI(Gemini) 호출 및 응답 파싱|BloodController.java',
     read_ranges(BC, [(1116, 1130), (1160, 1166)])),
    ('⑤ 질의 처리 흐름 — 규칙 기반 즉답 후 AI 폴백 (화면)|Blood_Consult.jsp',
     read_ranges(CS, [(1427, 1437)])),
    ('⑥ 혈당 유형 4분류 자동 판정|Blood_Consult.jsp',
     read_ranges(CS, [(1786, 1795)])),
    ('⑦ 지식베이스 키워드 매칭 (가중치 점수제)|Blood_Consult.jsp',
     read_ranges(CS, [(1731, 1743)])),
    ('⑧ 혈당 Q&A 지식베이스 자료 구조|asset/js/blood_qa.js',
     read_ranges('src/main/webapp/asset/js/blood_qa.js', [(14, 18)])),
]

app_meta = [
    ('프로그램의 명칭', '세종 당뇨·혈당관리 모바일 앱 (Sejong_APP)'),
    ('주요 기능', '연속혈당측정(CGM) 기기 연동 및 혈당 자료 수집 · 혈당 지표(TIR/TAR/TBR/CV/GMI) 산출과 도표 표시 · '
                 '식사·운동 기록과 혈당 연관 분석 · 회원 인증 및 개인 의료정보 관리 · PWA 설치형 모바일 화면'),
    ('개발 언어 및 환경', 'Java 17 (Spring Framework / 전자정부표준프레임워크) · JSP · JavaScript · MyBatis SQL(MySQL) · '
                     'HTML5/CSS3 · Apache Tomcat 9'),
    ('전체 소스 분량', '약 33,800줄 (서드파티 라이브러리 및 KISA 제공 암호모듈 제외)'),
    ('본 문서의 범위', '전체 소스 중 주요 기능 6개 부분 발췌. AI 혈당상담 챗봇 모듈은 별도 저작물로 등록하므로 이 문서에서 제외하였다.'),
]

bot_meta = [
    ('프로그램의 명칭', 'AI 혈당상담 챗봇 (Sejong AI Glucose Chatbot)'),
    ('주요 기능', '혈당 관련 질의를 규칙 기반 지식베이스로 우선 응답하고, 해당 답변이 없을 때 생성형 AI를 호출해 상담 문장을 생성 · '
                 '혈당 지표(TIR/TAR/TBR/CV)로 혈당 유형 4종을 자체 판정해 AI 참고자료로 제공 · 연령·당뇨 유형별 관리목표 자동 적용'),
    ('개발 언어 및 환경', 'Java 17 (Spring Framework) · JavaScript · JSP · 생성형 AI API(Google Gemini generateContent) 연동'),
    ('설계상의 특징', '수치 계산과 상태 판정은 프로그램이 직접 수행하고 생성형 AI에는 수치를 전달하지 않으며 정성적 표현만 전달해 '
                  '문장 생성에만 사용한다. AI 미설정·호출 실패 시 자체 지표 요약으로 대체 응답한다.'),
    ('본 문서의 범위', '챗봇 모듈 소스 중 주요 기능 8개 부분 발췌 (서버 질의 처리·AI 호출부, 화면 대화 처리부, 지식베이스)'),
]

app_note = ('※ 각 코드 왼쪽 번호는 해당 파일 내 실제 줄번호이며, 가독성을 위해 발췌 구간의 공통 들여쓰기만 제거하였다. '
            '접속정보·인증키가 포함된 설정 파일은 발췌 대상에서 제외하였다.')
bot_note = ('※ 각 코드 왼쪽 번호는 해당 파일 내 실제 줄번호이며, 가독성을 위해 발췌 구간의 공통 들여쓰기만 제거하였다. '
            '인증키 등 비밀값은 소스에 포함되지 않고 실행 환경의 환경변수로 주입된다.')

if __name__ == '__main__':
    # 발췌 구간은 PDF 판(build_docs.py)과 동일하게 쓴다 — 두 첨부물의 내용을 어긋나지 않게.
    build('세종 당뇨·혈당관리 모바일 앱', app_meta, C.app_blocks, app_note, '01_app_source')
    build('AI 혈당상담 챗봇', bot_meta, C.bot_blocks, bot_note, '02_chatbot_source')
