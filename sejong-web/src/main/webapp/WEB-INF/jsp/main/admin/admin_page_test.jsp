<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>대교출판사 스타일 책 넘기기</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background: #f5f5f5;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }

    .book {
      width: 300px;
      height: 400px;
      position: relative;
      perspective: 1500px;
      border: 1px solid #ddd;
    }

    .page {
      width: 100%;
      height: 100%;
      background: white;
      position: absolute;
      top: 0;
      left: 0;
      transform-origin: left; /* 왼쪽 기준으로 회전 */
      transition: transform 0.8s ease-out, z-index 0.8s step-end;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
    }

    .page-content {
      padding: 20px;
    }

    .page:nth-child(even) {
      background: #ececec;
    }

    .page.flipped {
      transform: rotateY(-180deg); /* 왼쪽으로 넘기기 */
      z-index: 0; /* 넘긴 페이지는 뒤로 */
    }

    .page:not(.flipped) {
      z-index: 1; /* 넘기지 않은 페이지는 앞으로 */
    }

    .page-container {
      position: absolute;
      width: 100%;
      height: 100%;
      transform-style: preserve-3d;
    }

    .navigation {
      position: absolute;
      bottom: 0;
      left: 50%;
      transform: translateX(-50%);
      display: flex;
      gap: 10px;
    }

    .navigation button {
      padding: 10px 20px;
      border: none;
      border-radius: 5px;
      cursor: pointer;
    }

    .navigation button:hover {
      background-color: #ccc;
    }
  </style>
</head>
<body>
  <div class="book">
    <div class="page-container">
      <div class="page">
        <div class="page-content">
          <h2>페이지 1</h2>
          <p>감사합니다!</p>
        </div>
      </div>
      <div class="page">
        <div class="page-content">
          <h2>페이지 2</h2>
          <p>좋은 아침입니다!</p>
        </div>
      </div>
      <div class="page">
        <div class="page-content">
          <h2>페이지 3</h2>
          <p>행복하세요!</p>
        </div>
      </div>
      <div class="page">
        <div class="page-content">
          <h2>페이지 4</h2>
          <p>즐겁습니다!</p>
        </div>
      </div>
      <div class="page">
        <div class="page-content">
          <h2>페이지 5</h2>
          <p>건강하세요!</p>
          <img src="https://via.placeholder.com/150" alt="샘플 이미지">
        </div>
      </div>
    </div>
    <div class="navigation">
      <button id="prev-page">이전 페이지</button>
      <button id="next-page">다음 페이지</button>
      <button id="pause-button">중지</button>
    </div>
  </div>

  <script>
    const pages = document.querySelectorAll('.page');
    let currentPage = 0;
    let isPaused = false; // 애니메이션 멈춤 상태 관리
    let intervalId;

    function resetPages() {
      pages.forEach((page, index) => {
        page.classList.remove('flipped');
        page.style.zIndex = pages.length - index;
      });
      currentPage = 0;
    }

    function flipPage() {
      if (currentPage < pages.length) {
        pages[currentPage].classList.add('flipped');
        currentPage++;
      } else {
        resetPages();
      }
    }

    function startFlip() {
      intervalId = setInterval(flipPage, 3000); // 자연스러운 넘김을 위해 시간을 더 줍니다.
    }

    function stopFlip() {
      clearInterval(intervalId);
    }

    // 초기 상태에서 애니메이션 시작
    resetPages();
    startFlip();

    // 네비게이션 버튼 이벤트 리스너
    document.getElementById('prev-page').addEventListener('click', () => {
      if (currentPage > 0) {
        pages[currentPage - 1].classList.remove('flipped');
        currentPage--;
      } else {
        resetPages();
        currentPage = pages.length - 1;
        pages[currentPage].classList.add('flipped');
      }
    });

    document.getElementById('next-page').addEventListener('click', () => {
      if (currentPage < pages.length) {
        pages[currentPage].classList.add('flipped');
        currentPage++;
      } else {
        resetPages();
      }
    });

    document.getElementById('pause-button').addEventListener('click', () => {
      isPaused = !isPaused;
      if (isPaused) {
        stopFlip();
        document.getElementById('pause-button').textContent = '재개';
      } else {
        startFlip();
        document.getElementById('pause-button').textContent = '중지';
      }
    });

    // 책 영역 클릭 이벤트 리스너
    document.querySelector('.book').addEventListener('click', () => {
      if (!isPaused && currentPage < pages.length) {
        pages[currentPage].classList.add('flipped');
        currentPage++;
      } else if (currentPage >= pages.length) {
        resetPages();
      }
    });

    // 키보드 네비게이션
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowLeft') {
        if (currentPage > 0) {
          pages[currentPage - 1].classList.remove('flipped');
          currentPage--;
        } else {
          resetPages();
          currentPage = pages.length - 1;
          pages[currentPage].classList.add('flipped');
        }
      } else if (e.key === 'ArrowRight') {
        if (currentPage < pages.length) {
          pages[currentPage].classList.add('flipped');
          currentPage++;
        } else {
          resetPages();
        }
      } else if (e.key === ' ') {
        isPaused = !isPaused;
        if (isPaused) {
          stopFlip();
          document.getElementById('pause-button').textContent = '재개';
        } else {
          startFlip();
          document.getElementById('pause-button').textContent = '중지';
        }
      }
    });
  </script>
</body>
</html>
