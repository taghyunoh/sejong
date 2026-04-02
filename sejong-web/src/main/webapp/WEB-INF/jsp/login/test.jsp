<%@ page   language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%> 
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WinCheck 컨설팅</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
        }

        /* 상단 헤더 스타일 */
        header {
            background-color: #f8f9fa;
            padding: 15px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #ddd;
        }

        header h1 {
            font-size: 24px;
            font-weight: bold;
            color: #0066cc;
        }

        .header-menu {
            display: flex;
            gap: 20px;
        }

        .header-menu a {
            text-decoration: none;
            color: #333;
            font-size: 16px;
        }

        .header-menu a:hover {
            color: #0066cc;
        }

        /* 메인 메뉴 스타일 */
        .main-menu {
            background-color: #fff;
            padding: 15px 20px;
            display: flex;
            justify-content: center;
            gap: 30px;
            border-bottom: 1px solid #ddd;
        }

        .main-menu a {
            text-decoration: none;
            color: #333;
            font-size: 16px;
            font-weight: bold;
        }

        .main-menu a:hover {
            color: #0066cc;
        }

        /* 이미지 섹션 */
        .image-section {
            background-image: url('your-image-path.jpg'); /* 이미지 경로 삽입 */
            background-size: cover;
            background-position: center;
            height: 400px;
            position: relative;
        }

        .image-section::after {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5); /* 어두운 오버레이 */
        }

        .image-section .content {
            position: relative;
            z-index: 1;
            text-align: center;
            color: white;
            padding-top: 200px;
        }

        .image-section .content h2 {
            font-size: 36px;
            margin-bottom: 10px;
        }

        .image-section .content p {
            font-size: 18px;
        }

        /* 푸터 스타일 */
        footer {
            background-color: #f1f1f1;
            padding: 15px 20px;
            text-align: center;
            font-size: 14px;
            color: #666;
            margin-top: 10px;
        }

        footer a {
            text-decoration: none;
            color: #333;
        }

        footer a:hover {
            color: #0066cc;
        }
		footer {
		    /* footer는 구분선이 없이 아래쪽에 위치하도록 설정 */
		    border: none; /* 구분선 제거 */
		    margin-top: 20px; /* footer와 위 섹션 사이의 간격 */
		}        
		.notice-section-container {
		    display: flex;
		    justify-content: space-between;
		    gap: 20px;
		    height: 30vh; /* 컨테이너 전체 높이 설정 */
		}
		
		.notice-section, .updates-section {
		    flex: 1;
		    height: calc(50vh - 20px); /* 각 섹션 높이 설정, 50%에 섹션 간 간격 포함 */
		}
		
		.notice-section h3, .updates-section h3 {
		    margin-bottom: 10px;
		}
    </style>
</head>
<body>
    <!-- 상단 헤더 -->
    <header>
        <h1>WinCheck</h1>
        <nav class="header-menu">
            <a href="#">적정성평가</a>
            <a href="#">경영분석</a>
            <a href="#">로그인</a>
            <a href="#">회원가입</a>
        </nav>
    </header>

    <!-- 메인 메뉴 -->
    <nav class="main-menu">
        <a href="#">의료기관 컨설팅</a>
        <a href="#">교육 컨설팅</a>
        <a href="#">ONE-STOP(회원병원)</a>
        <a href="#">전문 프로그램</a>
        <a href="#">고객센터</a>
    </nav>

    <!-- 이미지 섹션 -->
    <section class="image-section">
        <div class="content">
            <h2>핵심가치를 발굴하다,</h2>
            <p>위너넷 컨설팅</p>
        </div>
    </section>
	<!-- 공지사항 섹션 -->
	<section class="notice-section-container">
	    <div class="notice-section">
	        <h3>We Are Winnernet</h3>
	        <p>공지사항 내용이 여기에 들어갑니다. 최신 공지사항을 확인하세요!</p>
	    </div>
	        <h3>New Updates</h3>
	        <p>여기서는 새로운 업데이트나 다른 중요한 내용을 넣을 수 있습니다!</p>
	    </div>
	</section>
    <!-- 푸터 -->
    <footer>
        고객센터: 02-2653-7971 | 이용시간: 평일 09:00 ~ 18:00 (점심시간: 12:00 ~ 13:00) <br>
        <a href="#">이용약관</a> | <a href="#">개인정보처리방침</a>
    </footer>
</body>
</html>
