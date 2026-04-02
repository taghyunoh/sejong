<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>  
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form"   uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui"     uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>  
<%@ page import = "java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>진료비 분석 대시보드</title>
    <link rel="stylesheet" href="dashboard.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="dashboard-container">
        <header class="header">
            <h1>진료비 분석 대시보드</h1>
        </header>
        <div class="stats-container">
            <div class="card">
                <h2>총 진료비</h2>
                <p class="value">₩ 1,234,567</p>
            </div>
            <div class="card">
                <h2>월별 증가율</h2>
                <p class="value">12%</p>
            </div>
            <div class="card">
                <h2>환자 수</h2>
                <p class="value">1,230 명</p>
            </div>
            <div class="card">
                <h2>진료 항목 수</h2>
                <p class="value">25 항목</p>
            </div>
        </div>
        <div class="charts-container">
            <div class="chart" id="chart1">
                <h2>월별 진료비 통계</h2>
                <canvas id="expenseChart"></canvas>
            </div>
            <div class="chart" id="chart2">
                <h2>환자 수 통계</h2>
                <canvas id="patientChart"></canvas>
            </div>
        </div>
    </div>
    <script src="dashboard.js"></script>
</body>
</html>