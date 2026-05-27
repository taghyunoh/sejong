-- =====================================================================
-- 세종 프로젝트 (sejong-web) T_* 테이블 스키마 DDL
-- 대상 DB: MySQL 5.7+ / 8.0  (DB_DCA — context-datasource.xml 참조)
-- 출처: MyBatis 매퍼 SQL + DTO 모델 클래스 역분석
-- 작성일: 2026-05-19
--
-- 사용 방법:
--   mysql -u DCA -p DB_DCA < 01_schema_T_tables.sql
--   이후 02_seed_T_tables.sql 실행
--
-- 참고:
--  * 컬럼 타입/길이는 매퍼 SQL과 DTO Java 타입에서 추정한 값.
--    실제 운영 데이터에 맞춰 VARCHAR 길이는 조정 필요.
--  * T_USER_TRAN 은 작업 지시 범위 밖이지만 5개 테이블이 USER_UUID 로
--    FK 참조하므로 화면 동작을 위해 포함. (필요 시 분리 가능)
--  * FK 제약은 의도적으로 추가하지 않음 (매퍼 추정 기반이라 부정확
--    위험). 운영 안정화 후 ALTER TABLE ... ADD CONSTRAINT 권장.
-- =====================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. T_ADMIN_MST  — 관리자/의사 마스터 (로그인 계정)
--    PK: USER_ID 단일
--    로그인: UserController.java 가 USER_ID 해시값으로 SELECT 후
--            USER_PW(해시) 비교. NOW() BETWEEN START_DATE AND END_DATE.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_ADMIN_MST;
CREATE TABLE T_ADMIN_MST (
    USER_ID       VARCHAR(100)  NOT NULL                  COMMENT 'EgovFileScrty.encryptPassword(id,id) 해시값',
    USER_NM       VARCHAR(50)   NOT NULL                  COMMENT '사용자명',
    USER_ID_NM    VARCHAR(100)  NULL                      COMMENT '사용자 표시명/별칭(평문 ID)',
    USER_PW       VARCHAR(255)  NULL                      COMMENT 'EgovFileScrty.encryptPassword(pw,"1234") 해시값',
    USER_GB       CHAR(1)       NULL DEFAULT 'D'          COMMENT '사용자구분 A=관리자 D=의사',
    DEPT_NM       VARCHAR(100)  NULL                      COMMENT '진료과/부서명',
    START_DATE    DATETIME      NULL                      COMMENT '적용시작일시 (NOW() BETWEEN 비교)',
    END_DATE      DATETIME      NULL                      COMMENT '적용종료일시',
    LOCK_YN       CHAR(1)       NULL DEFAULT 'N'          COMMENT '잠금여부 Y/N',
    USEYN         CHAR(1)       NULL DEFAULT 'Y'          COMMENT '사용여부 Y/N (삭제 시 N)',
    BIGO          VARCHAR(500)  NULL                      COMMENT '비고',
    REG_ID        VARCHAR(50)   NULL                      COMMENT '등록자',
    REG_DTM       DATETIME      NULL                      COMMENT '등록일시',
    MOD_ID        VARCHAR(50)   NULL                      COMMENT '수정자',
    MOD_DTM       DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (USER_ID),
    KEY IDX_T_ADMIN_MST_PERIOD (START_DATE, END_DATE),
    KEY IDX_T_ADMIN_MST_NM (USER_NM)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='관리자/의사 마스터';

-- ---------------------------------------------------------------------
-- 2. T_USER_TRAN  — 환자/사용자 트랜
--    (작업 범위 외이나 5개 테이블의 USER_UUID FK 부모이므로 함께 생성)
--    PK: USER_UUID (UUID 문자열, 36~50자)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_USER_TRAN;
CREATE TABLE T_USER_TRAN (
    USER_UUID     VARCHAR(50)   NOT NULL                  COMMENT '사용자 UUID (PK)',
    USER_ID       VARCHAR(100)  NULL                      COMMENT '로그인 ID 해시값',
    USER_NM       VARCHAR(50)   NULL                      COMMENT '환자/사용자명',
    USER_PW       VARCHAR(255)  NULL                      COMMENT '비밀번호 해시값',
    USER_GB       CHAR(1)       NULL                      COMMENT '구분 P=환자 D=의사',
    PHONE         VARCHAR(20)   NULL                      COMMENT '전화번호',
    EMAIL         VARCHAR(100)  NULL                      COMMENT '이메일',
    BIRTH         VARCHAR(8)    NULL                      COMMENT '생년월일 YYYYMMDD',
    GENDER        CHAR(1)       NULL                      COMMENT '성별 M/F',
    HEIGHT        INT           NULL                      COMMENT '신장(cm)',
    WEIGHT        INT           NULL                      COMMENT '체중(kg)',
    BLOD_GB       VARCHAR(10)   NULL                      COMMENT '혈액형 (T_COMM_MST_DTL CODE=CD7)',
    JOIN_YMD      DATETIME      NULL                      COMMENT '가입일시',
    LOCK_YN       CHAR(1)       NULL DEFAULT 'N'          COMMENT '잠금여부',
    USEYN         CHAR(1)       NULL DEFAULT 'Y'          COMMENT '사용여부',
    REG_DTM       DATETIME      NULL                      COMMENT '등록일시',
    MOD_DTM       DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (USER_UUID),
    KEY IDX_T_USER_TRAN_ID (USER_ID),
    KEY IDX_T_USER_TRAN_NM (USER_NM)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='환자/사용자 트랜 (참고용 - 작업범위 외)';

-- ---------------------------------------------------------------------
-- 3. T_COMM_MST  — 공통코드 대표
--    PK: CODE
--    START_DATE/END_DATE 는 YYYYMMDD 문자열(8자) — DATE_FORMAT 변환 저장
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_COMM_MST;
CREATE TABLE T_COMM_MST (
    CODE          VARCHAR(20)   NOT NULL                  COMMENT '공통코드 (PK)',
    CODE_NAME     VARCHAR(100)  NULL                      COMMENT '코드명',
    START_DATE    VARCHAR(8)    NULL                      COMMENT '적용시작일 YYYYMMDD',
    END_DATE      VARCHAR(8)    NULL                      COMMENT '적용종료일 YYYYMMDD',
    USE_YN        CHAR(1)       NULL DEFAULT 'Y'          COMMENT '사용여부',
    REG_ID        VARCHAR(50)   NULL                      COMMENT '등록자',
    REG_DTM       DATETIME      NULL                      COMMENT '등록일시',
    MOD_ID        VARCHAR(50)   NULL                      COMMENT '수정자',
    MOD_DTM       DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (CODE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='공통코드 대표';

-- ---------------------------------------------------------------------
-- 4. T_COMM_MST_DTL  — 공통코드 상세
--    PK: (CODE, DTL_CODE)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_COMM_MST_DTL;
CREATE TABLE T_COMM_MST_DTL (
    CODE          VARCHAR(20)   NOT NULL                  COMMENT '공통코드 (T_COMM_MST.CODE)',
    DTL_CODE      VARCHAR(20)   NOT NULL                  COMMENT '상세코드',
    DTL_CODE_NM   VARCHAR(100)  NULL                      COMMENT '상세코드명',
    START_DATE    VARCHAR(8)    NULL                      COMMENT '적용시작일 YYYYMMDD',
    END_DATE      VARCHAR(8)    NULL                      COMMENT '적용종료일 YYYYMMDD',
    USE_YN        CHAR(1)       NULL DEFAULT 'Y'          COMMENT '사용여부',
    SORT          VARCHAR(10)   NULL                      COMMENT '정렬순서',
    REG_ID        VARCHAR(50)   NULL                      COMMENT '등록자',
    REG_DTM       DATETIME      NULL                      COMMENT '등록일시',
    MOD_ID        VARCHAR(50)   NULL                      COMMENT '수정자',
    MOD_DTM       DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (CODE, DTL_CODE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='공통코드 상세';

-- ---------------------------------------------------------------------
-- 5. T_NOTICE_TRAN  — 공지사항
--    PK: NOTI_SEQ (AUTO_INCREMENT)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_NOTICE_TRAN;
CREATE TABLE T_NOTICE_TRAN (
    NOTI_SEQ      INT           NOT NULL AUTO_INCREMENT   COMMENT '공지 SEQ',
    TITLE         VARCHAR(200)  NULL                      COMMENT '제목',
    EXPLN         TEXT          NULL                      COMMENT '본문/설명',
    POST_STR      VARCHAR(8)    NULL                      COMMENT '게시시작일 YYYYMMDD',
    POST_END      VARCHAR(8)    NULL                      COMMENT '게시종료일 YYYYMMDD',
    USE_YN        CHAR(1)       NULL DEFAULT 'Y'          COMMENT '사용여부 (삭제 시 N)',
    REG_ID        VARCHAR(50)   NULL                      COMMENT '등록자 ID',
    REG_DTM       DATETIME      NULL                      COMMENT '등록일시',
    MOD_ID        VARCHAR(50)   NULL                      COMMENT '수정자 ID (T_ADMIN_MST.USER_ID)',
    MOD_DTM       DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (NOTI_SEQ),
    KEY IDX_T_NOTICE_TRAN_POST (POST_STR, POST_END),
    KEY IDX_T_NOTICE_TRAN_USE (USE_YN),
    KEY IDX_T_NOTICE_TRAN_TITLE (TITLE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='공지사항';

-- ---------------------------------------------------------------------
-- 6. T_FAQ_TRAN  — FAQ
--    PK: FAQ_SEQ (AUTO_INCREMENT)
--    FAQ_GB: 'T'=공통, 'A'=앱, 'W'=웹
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_FAQ_TRAN;
CREATE TABLE T_FAQ_TRAN (
    FAQ_SEQ       INT           NOT NULL AUTO_INCREMENT   COMMENT 'FAQ SEQ',
    FAQ_GB        CHAR(1)       NULL                      COMMENT 'FAQ 구분 T=공통 A=앱 W=웹',
    QSTN_CONTS    TEXT          NULL                      COMMENT '질문 내용',
    ANSR_CONTS    TEXT          NULL                      COMMENT '답변 내용',
    USE_YN        CHAR(1)       NULL DEFAULT 'Y'          COMMENT '사용여부',
    REG_ID        VARCHAR(50)   NULL                      COMMENT '등록자',
    REG_DTM       DATETIME      NULL                      COMMENT '등록일시',
    MOD_ID        VARCHAR(50)   NULL                      COMMENT '수정자',
    MOD_DTM       DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (FAQ_SEQ),
    KEY IDX_T_FAQ_TRAN_GB_USE (FAQ_GB, USE_YN)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='FAQ';

-- ---------------------------------------------------------------------
-- 7. T_ASQ_TRAN  — 환자 질의응답
--    PK: ASQ_SEQ (AUTO_INCREMENT)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_ASQ_TRAN;
CREATE TABLE T_ASQ_TRAN (
    ASQ_SEQ       INT           NOT NULL AUTO_INCREMENT   COMMENT '질의 SEQ',
    USER_UUID     VARCHAR(50)   NOT NULL                  COMMENT '환자 UUID (T_USER_TRAN.USER_UUID)',
    QSTN_TITL     VARCHAR(200)  NULL                      COMMENT '질문 제목',
    QSTN_CONTS    TEXT          NULL                      COMMENT '질문 내용',
    QSTN_YMD      DATETIME      NULL                      COMMENT '질문일시',
    ANSR_CONTS    TEXT          NULL                      COMMENT '답변 내용',
    ANSR_YN       CHAR(1)       NULL DEFAULT 'N'          COMMENT '답변여부 Y/N',
    PRIMARY KEY (ASQ_SEQ),
    KEY IDX_T_ASQ_TRAN_USER (USER_UUID),
    KEY IDX_T_ASQ_TRAN_YMD (QSTN_YMD)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='환자 질의응답';

-- ---------------------------------------------------------------------
-- 8. T_BLDCON_MST  — 혈당 장비 토큰 (iSens OAuth)
--    PK: USER_UUID  (ON DUPLICATE KEY UPDATE 사용 → 단독 PK 확실)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_BLDCON_MST;
CREATE TABLE T_BLDCON_MST (
    USER_UUID     VARCHAR(50)   NOT NULL                  COMMENT '환자 UUID (PK)',
    ISENS_ID      VARCHAR(100)  NULL                      COMMENT 'iSens 외부 ID',
    ACC_TOKEN     VARCHAR(500)  NULL                      COMMENT 'access_token',
    REF_TOKEN     VARCHAR(500)  NULL                      COMMENT 'refresh_token',
    EXPRE_TIME    VARCHAR(20)   NULL                      COMMENT '토큰 만료시간(초)',
    TOKEN_YN      CHAR(1)       NULL DEFAULT 'Y'          COMMENT '토큰 유효여부',
    LINK_STRT_DTM DATETIME      NULL                      COMMENT '연동 시작일시',
    LINK_END_DTM  DATETIME      NULL                      COMMENT '연동 종료일시',
    REG_DTM       DATETIME      NULL                      COMMENT '등록일시',
    MOD_DTM       DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (USER_UUID),
    KEY IDX_T_BLDCON_MST_ISENS (ISENS_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='혈당 장비 토큰 마스터';

-- ---------------------------------------------------------------------
-- 9. T_BLDINF_TRAN  — CGM 혈당 측정 시계열
--    PK: (USER_UUID, CGM_DTM) 자연키
--    빈번한 BETWEEN/DATE()/TIME() 조회 → (USER_UUID, CGM_DTM) 인덱스 필수
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_BLDINF_TRAN;
CREATE TABLE T_BLDINF_TRAN (
    USER_UUID     VARCHAR(50)   NOT NULL                  COMMENT '환자 UUID',
    CGM_DTM       DATETIME      NOT NULL                  COMMENT '측정일시',
    SERIAL        VARCHAR(50)   NULL                      COMMENT '센서 시리얼',
    CGM_SEQ       INT           NULL                      COMMENT 'CGM 측정 순번',
    INIT_VALUE    INT           NULL                      COMMENT '초기 측정값',
    UPT_VALUE     INT           NULL                      COMMENT '보정 혈당값(mg/dL)',
    TREND_RATE    INT           NULL                      COMMENT '변동률',
    TREND         INT           NULL                      COMMENT '추세',
    ERROR_CODE    INT           NULL                      COMMENT '오류 코드',
    PRIMARY KEY (USER_UUID, CGM_DTM),
    KEY IDX_T_BLDINF_TRAN_DTM (CGM_DTM),
    KEY IDX_T_BLDINF_TRAN_VALUE (UPT_VALUE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='CGM 혈당 측정';

-- ---------------------------------------------------------------------
-- 10. T_FOODHIS_TRAN  — 식사 이력 (헤더, 한 끼 단위)
--     PK: FOODHIS_SEQ (AUTO_INCREMENT) — Food_SQL useGeneratedKeys 명시
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_FOODHIS_TRAN;
CREATE TABLE T_FOODHIS_TRAN (
    FOODHIS_SEQ            INT           NOT NULL AUTO_INCREMENT   COMMENT '식사이력 SEQ',
    USER_UUID              VARCHAR(50)   NOT NULL                  COMMENT '환자 UUID',
    EAT_DATE               DATETIME      NULL                      COMMENT '식사일시',
    EAT_TYPE               TINYINT       NULL                      COMMENT '식사구분 0=아침 1=점심 2=저녁',
    MEAL_TYPE              VARCHAR(20)   NULL                      COMMENT '식사유형',
    PREDICTED_IMAGE_PATH   VARCHAR(500)  NULL                      COMMENT '예측 이미지 경로',
    REG_DTM                DATETIME      NULL                      COMMENT '등록일시',
    MOD_DTM                DATETIME      NULL                      COMMENT '수정일시',
    PRIMARY KEY (FOODHIS_SEQ),
    KEY IDX_T_FOODHIS_TRAN_USER_DT (USER_UUID, EAT_DATE)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='식사 이력 (헤더)';

-- ---------------------------------------------------------------------
-- 11. T_FOOD_TRAN  — 식사 상세 (음식별 영양정보)
--     PK: FOOD_SEQ (AUTO_INCREMENT)
--     FK: FOODHIS_SEQ → T_FOODHIS_TRAN.FOODHIS_SEQ
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS T_FOOD_TRAN;
CREATE TABLE T_FOOD_TRAN (
    FOOD_SEQ          INT           NOT NULL AUTO_INCREMENT   COMMENT '음식 SEQ',
    FOODHIS_SEQ       INT           NOT NULL                  COMMENT '식사이력 SEQ (FK)',
    EAT_AMOUNT        FLOAT         NULL                      COMMENT '섭취량(배)',
    FOOD_IMAGEPATH    VARCHAR(500)  NULL                      COMMENT '음식 이미지 경로',
    FOOD_ID           INT           NULL                      COMMENT '음식 ID',
    FOOD_NAME         VARCHAR(200)  NULL                      COMMENT '음식명',
    KEY_NAME          VARCHAR(100)  NULL                      COMMENT '키 명',
    CUSTOM_FOOD_INFO  VARCHAR(500)  NULL                      COMMENT '사용자 음식정보',
    FOOD_TYPE         VARCHAR(50)   NULL                      COMMENT '음식 유형',
    UNIT              VARCHAR(20)   NULL                      COMMENT '단위',
    TOTAL_GRAM        FLOAT         NULL                      COMMENT '총량(g)',
    RAW_TOTAL_GRAM    FLOAT         NULL                      COMMENT '원시 총량(g)',
    CALORIES          FLOAT         NULL                      COMMENT '칼로리',
    RAW_CALORIES      FLOAT         NULL                      COMMENT '원시 칼로리',
    CARBONHYDRATE     FLOAT         NULL                      COMMENT '탄수화물',
    PROTEIN           FLOAT         NULL                      COMMENT '단백질',
    FAT               FLOAT         NULL                      COMMENT '지방',
    SATURATEDFAT      FLOAT         NULL                      COMMENT '포화지방',
    TRANSFAT          FLOAT         NULL                      COMMENT '트랜스지방',
    CHOLESTEROL       FLOAT         NULL                      COMMENT '콜레스테롤',
    SODIUM            FLOAT         NULL                      COMMENT '나트륨',
    SUGAR             FLOAT         NULL                      COMMENT '당류',
    DIETRAYFIBER      FLOAT         NULL                      COMMENT '식이섬유',
    CALCIUM           FLOAT         NULL                      COMMENT '칼슘',
    VITAMINA          FLOAT         NULL                      COMMENT '비타민A',
    VITAMINB          FLOAT         NULL                      COMMENT '비타민B',
    VITAMINC          FLOAT         NULL                      COMMENT '비타민C',
    VITAMIND          FLOAT         NULL                      COMMENT '비타민D',
    VITAMINE          FLOAT         NULL                      COMMENT '비타민E',
    PRIMARY KEY (FOOD_SEQ),
    KEY IDX_T_FOOD_TRAN_HIS (FOODHIS_SEQ),
    KEY IDX_T_FOOD_TRAN_NAME (FOOD_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='식사 상세 (음식 영양정보)';

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- DDL 끝 (11개 테이블: T_* 10개 + T_USER_TRAN 1개)
-- =====================================================================
