# -*- coding: utf-8 -*-
"""저작권 등록 첨부용 소스코드 발췌 문서 생성기 (HTML → Chrome headless → PDF)

- 실제 소스에서 지정한 줄 범위를 그대로 읽어 온다(원본 줄번호 유지).
- 수동 페이지 분할: 페이지당 줄 예산을 두고 채운다 → 페이지 번호(n/N)가 정확하다.
"""
import os, sys, html, math, unicodedata, subprocess

ROOT = r"C:\Users\HYUN\git\sejong\sejong_app"
OUT  = os.path.dirname(os.path.abspath(__file__))

LINES_PER_PAGE  = 66   # 2쪽 이후 본문 줄 예산
FIRST_PAGE_BUDGET = 48 # 1쪽은 표제/개요가 차지하는 만큼 줄인다
MAXCOLS = 108          # 이 폭을 넘으면 줄바꿈되어 한 줄을 더 먹는 것으로 계산


def dwidth(s):
    w = 0
    for ch in s:
        w += 2 if unicodedata.east_asian_width(ch) in ('W', 'F') else 1
    return w


def read_ranges(relpath, ranges, tabsize=4):
    """[(start,end), ...] → [(lineno, text), ...]  (구간 사이는 None 로 생략표시)"""
    with open(os.path.join(ROOT, relpath), encoding='utf-8', errors='replace') as f:
        src = f.read().split('\n')
    out = []
    for i, (s, e) in enumerate(ranges):
        if i:
            out.append((None, None))
        seg = [(n, src[n - 1].replace('\t', ' ' * tabsize)) for n in range(s, e + 1)]
        while seg and not seg[0][1].strip():     # 구간 앞뒤 빈 줄은 버린다
            seg.pop(0)
        while seg and not seg[-1][1].strip():
            seg.pop()
        # 공통 들여쓰기 제거 (JSP 는 들여쓰기가 매우 깊다)
        body = [t for _, t in seg if t.strip()]
        cut = min((len(t) - len(t.lstrip(' ')) for t in body), default=0)
        out += [(n, t[cut:] if t.strip() else '') for n, t in seg]
    return out


def cont_title(title):
    """'제목|경로' 의 **제목 쪽에** (이어서) 를 붙인다 — 경로 뒤에 붙으면 파일명이 어지러워진다."""
    if '|' in title:
        name, path = title.split('|', 1)
        return name.rstrip() + '  (이어서)|' + path
    return title + '  (이어서)'


def layout(blocks, first_budget, budget):
    """blocks: [(title, [(no,text)...])] → pages: [[('h',title)|('c',no,text)...]]"""
    pages, cur, used = [], [], 0
    cap = first_budget

    def flush():
        nonlocal cur, used, cap
        if cur:
            pages.append(cur)
        cur, used, cap = [], 0, budget

    for title, lines in blocks:
        cost = 3  # 블록 제목줄 + 여백
        if used + cost + 4 > cap:      # 제목만 덜렁 남기지 않는다
            flush()
        cur.append(('h', title))
        used += cost
        for no, text in lines:
            c = 1 if no is None else max(1, math.ceil(max(dwidth(text), 1) / MAXCOLS))
            if used + c > cap:
                flush()
                cur.append(('h', cont_title(title)))
                used += cost
            cur.append(('c', no, text))
            used += c
    flush()
    return pages


CSS = """
@page { size: A4; margin: 17mm 14mm 15mm 14mm; }
* { box-sizing: border-box; }
body { margin:0; font-family: "Malgun Gothic", "맑은 고딕", sans-serif; color:#000; }
.page { page-break-after: always; position: relative; height: 262mm; }
.page:last-child { page-break-after: auto; }
.doctitle { text-align:center; border-bottom:2px solid #000; padding-bottom:6px; margin-bottom:10px; }
.doctitle h1 { font-size:15pt; margin:0 0 3px; letter-spacing:-0.3px; }
.doctitle .sub { font-size:9pt; color:#333; }
table.meta { width:100%; border-collapse:collapse; font-size:8.5pt; margin-bottom:11px; }
table.meta th, table.meta td { border:1px solid #666; padding:3px 6px; vertical-align:top; line-height:1.45; }
table.meta th { background:#eee; width:22%; text-align:left; white-space:nowrap; }
.blk { font-size:9pt; font-weight:bold; margin:9px 0 3px; padding:2px 5px;
       background:#e8e8e8; border-left:3px solid #333; }
.blk .path { font-family:Consolas, monospace; font-weight:normal; font-size:8pt; color:#222; }
pre.code { margin:0; font-family:Consolas, "D2Coding", monospace; font-size:8pt; line-height:1.30;
           white-space:pre-wrap; word-break:break-all; }
pre.code .ln { display:inline-block; width:9mm; color:#888; text-align:right;
               margin-right:2.5mm; -webkit-user-select:none; }
pre.code .om { color:#888; }
.foot { position:absolute; bottom:0; left:0; right:0; font-size:8pt; color:#333;
        border-top:1px solid #999; padding-top:2px; }
.foot .r { float:right; }
.note { font-size:8pt; color:#333; margin-top:8px; line-height:1.5; border:1px dashed #888; padding:5px 7px; }
"""


def render(title, subtitle, meta_rows, blocks, note, outfile):
    pages = layout(blocks, FIRST_PAGE_BUDGET, LINES_PER_PAGE)
    total = len(pages)
    parts = ['<!DOCTYPE html><html lang="ko"><head><meta charset="utf-8">',
             '<title>%s</title><style>%s</style></head><body>' % (html.escape(title), CSS)]
    for pi, page in enumerate(pages, 1):
        parts.append('<div class="page">')
        if pi == 1:
            parts.append('<div class="doctitle"><h1>%s</h1><div class="sub">%s</div></div>'
                         % (html.escape(title), html.escape(subtitle)))
            parts.append('<table class="meta">')
            for k, v in meta_rows:
                parts.append('<tr><th>%s</th><td>%s</td></tr>' % (html.escape(k), v))
            parts.append('</table>')
        buf = []
        for item in page:
            if item[0] == 'h':
                if buf:
                    parts.append('<pre class="code">%s</pre>' % '\n'.join(buf)); buf = []
                t = item[1]
                if '|' in t:
                    name, path = t.split('|', 1)
                    parts.append('<div class="blk">%s <span class="path">[%s]</span></div>'
                                 % (html.escape(name), html.escape(path)))
                else:
                    parts.append('<div class="blk">%s</div>' % html.escape(t))
            else:
                _, no, text = item
                if no is None:
                    buf.append('<span class="ln">&nbsp;</span><span class="om">        (... 중략 ...)</span>')
                else:
                    buf.append('<span class="ln">%d</span>%s' % (no, html.escape(text)))
        if buf:
            parts.append('<pre class="code">%s</pre>' % '\n'.join(buf))
        if pi == total and note:
            parts.append('<div class="note">%s</div>' % note)
        parts.append('<div class="foot">%s<span class="r">- %d / %d -</span></div>'
                     % (html.escape(subtitle), pi, total))
        parts.append('</div>')
    parts.append('</body></html>')
    hp = os.path.join(OUT, outfile + '.html')
    with open(hp, 'w', encoding='utf-8') as f:
        f.write('\n'.join(parts))
    print('HTML:', hp, '| pages:', total)
    return hp, total
