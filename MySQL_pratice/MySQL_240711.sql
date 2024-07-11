-- Churn Rate(%) 구하기 

USE classicmodels;

-- 현재 테이블의 가장 최근 날짜
SELECT MAX(orderdate) MX_order
FROM orders
;

-- 현재 테이블의 가장 오래된 날짜
SELECT MIN(orderdate) MIN_order
FROM orders
;

-- 각 고객의 마지막 구매일
SELECT 
	customernumber
    , MAX(orderdate) 마지막구매일자
FROM orders
GROUP BY 1
;

-- 현재 시점은 2006-06-01
SELECT '2006-06-01';

-- 2006-06-01 기준으로 가장 마지막에 구매한 날짜를 빼서 기간 구하기
SELECT 
	customernumber
	, DATEDIFF('2006-06-01', MAX(orderdate))
FROM orders
GROUP BY 1
;

SELECT 
	*
    , '2006-06-01' AS 오늘날짜
    , DATEDIFF('2006-06-01', 마지막구매일) DIFF
FROM
	(
	SELECT
		customernumber
        , MAX(orderdate) 마지막구매일
	FROM orders
    GROUP BY 1
    )A
;

-- DIFF 90일 기준으로 churn, Non-churn 구하기
SELECT 
	customernumber
	, DATEDIFF(CURRENT_DATE, '2006-06-01') 
    , CASE
		WHEN DATEDIFF(CURRENT_DATE, '2006-06-01') >= 90 THEN 'CHURN'
        ELSE 'NON-CHURN'
	END AS Y_N
FROM orders
GROUP BY 1
;

SELECT
	*
    , CASE WHEN DIFF >= 90 THEN '이탈발생' ELSE '이탈미발생' END 이탈유무
FROM(
	SELECT
		*
        , '2006-06-01' AS 오늘날짜
        , DATEDIFF('2006-06-01', 마지막구매일) DIFF
	FROM(
		SELECT
			customernumber
            , MAX(orderdate) 마지막구매일
		FROM orders
        GROUP BY 1
        )A 
	)A
;

-- Churn 고객이 가장 많이 구매한 productline을 구해봅시당.
/*
SELECT 
	D.churn_type
	, C.productline,
	COUNT(DISTINCT B.customernumber) BU
FROM orderdetails A
LEFT
JOIN orders B
ON A.ordernumber = B.ordernumber
LEFT
JOIN products C
ON A.productcode = C.productcode
LEFT JOIN CHURN_LIST D
ON B.customernumber = D.customernumber
GROUP
BY 1, 2
HAVING churn_type = 'CHURN'
;
*/
/*
SELECT 
	C.productline,
	COUNT(DISTINCT B.customernumber) BU
FROM orderdetails A
LEFT
JOIN orders B
ON A.ordernumber = B.ordernumber
LEFT
JOIN products C
ON A.productcode = C.productcode
LEFT JOIN CHURN_LIST D
ON B.customernumber = D.customernumber
WHERE D.churn_type = 'CHURN'
GROUP BY 1
;
*/

-- CHAPTER2
use mydata;
SELECT * FROM dataset2;

-- 쇼핑몰, 리뷰 데이터
-- 댓글 분석, 감정 분석

SELECT 
	`Division Name`
    , AVG(RATING) AVG_RATE
FROM dataset2
GROUP BY 1
;
    
-- 
SELECT 
	`Department Name`
    , AVG(RATING) AVG_RATE
FROM dataset2
GROUP BY 1
;    

-- Trend의 평균 평점이 3.85

-- 세부적으로 내용을 확인해봅시당.
-- Department Name이 Trend인 것만 조회
-- RATING이 3점 이하인 것만 조회

SELECT *
FROM dataset2
WHERE `Department Name` = 'Trend' AND rating <=3
;    
    
-- 연령대를 10세 단위로 그룹핑
-- 10-19세 => 10대
/* 교재 예시 
SELECT CASE WHEN AGE BETWEEN 0 AND 9 THEN '0009'
WHEN AGE BETWEEN 10 AND 19 THEN '1019'
WHEN AGE BETWEEN 20 AND 29 THEN '2029'
WHEN AGE BETWEEN 30 AND 39 THEN '3039'
WHEN AGE BETWEEN 40 AND 49 THEN '4049'
WHEN AGE BETWEEN 50 AND 59 THEN '5059'
WHEN AGE BETWEEN 60 AND 69 THEN '6069'
WHEN AGE BETWEEN 70 AND 79 THEN '7079'
WHEN AGE BETWEEN 80 AND 89 THEN '8089'
WHEN AGE BETWEEN 90 AND 99 THEN '9099' END AGEBAND,
AGE
FROM dataset2
WHERE 'DEPARTMENT NAME' = 'Trend'
AND RATING <= 3
;
*/

-- 나눗셈을 이용해서 쉽게 코드를 짜자

SELECT FLOOR(Age/10) *10 AS 연령대, AGE  -- CAST 활용하면 형변환, 문자->숫자, 숫자->문자
FROM dataset2
;
    
-- 연령대별 분포: 평점 3점 이하 리뷰

SELECT FLOOR(age/10)*10 AS 연령대, COUNT(*)
FROM dataset2
WHERE rating<=3 AND `DEPARTMENT NAME` = 'Trend'
GROUP BY 1
ORDER BY 2 DESC;
;


-- 50대 3점 이하 Trend 리뷰만 추출
SELECT `Review Text`
FROM dataset2
WHERE FLOOR(age/10)*10 = 50 AND rating<=3 AND `DEPARTMENT NAME` = 'Trend'
;

-- 평점이 낮은 상품의 주요 complain
SELECT
	`Department Name`
    , ClothingID
    , AVG(rating) AVG_RATE
FROM dataset2
GROUP BY 1,2
;

SELECT 
	*
    , ROW_NUMBER() OVER (PARTITION BY `Department Name` ORDER BY AVG_RATE) RNK
FROM (
	SELECT 
		`Department Name`
        , ClothingID
        , AVG(rating) AVG_RATE
	FROM dataset2
    GROUP BY 1,2
    ) A
;
    

-- 위 결과를 토대로,
-- 1-10위 데이터 필터링
-- CREATE TABLE mydata.stat AS
SELECT *
FROM(
	SELECT 
		*
		, ROW_NUMBER() OVER (PARTITION BY `Department Name` ORDER BY AVG_RATE) RNK
	FROM (
		SELECT 
			`Department Name`
			, ClothingID
			, AVG(rating) AVG_RATE
		FROM dataset2
		GROUP BY 1,2
		) A
    )A
WHERE RNK <=10
;

-- 문제: department에서 bottoms 불만족 1위-10위인 리뷰 텍스트를 가져오세여
-- 해당 clothingID에 해당하는 리뷰 텍스트
-- 메인쿼리: dataset2에서 review text만 가져오기
-- 서브쿼리: stat 테이블에서 department가 bottoms인 clothingID

SELECT `review text`
FROM dataset2
WHERE clothingid IN (
	SELECT clothingid 
	FROM stat
	WHERE `department name` = 'bottoms'
)
;

SELECT clothingid 
FROM stat
WHERE `department name` = 'bottoms'
;


--
SELECT 
	`Review Text`
    , CASE WHEN `Review Text` LIKE '%SIZE%' THEN 1 ELSE 0 END SIZE_YN
FROM dataset2
;

-- SIZE가 나온 댓글은 총 몇 개일까?
SELECT
	SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) N_SIZE
    , COUNT(*) N_TOTAL
    , SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END) / COUNT(*) AS ratio
FROM dataset2
;

-- 사이즈와 관련된 다른 키워드도 확인해봅시당.
SELECT SUM(CASE WHEN `REVIEW TEXT` LIKE '%SIZE%' THEN 1 ELSE 0 END )
N_SIZE,
SUM(CASE WHEN `REVIEW TEXT` LIKE '%LARGE%' THEN 1 ELSE 0 END ) N_LARGE,
SUM(CASE WHEN `REVIEW TEXT` LIKE '%LOOSE%' THEN 1 ELSE 0 END ) N_LOOSE,
SUM(CASE WHEN `REVIEW TEXT` LIKE '%SMALL%' THEN 1 ELSE 0 END ) N_SMALL,
SUM(CASE WHEN `REVIEW TEXT` LIKE '%TIGHT%' THEN 1 ELSE 0 END ) N_TIGHT,
SUM(1) N_TOTAL
FROM MYDATA.DATASET2
;

-- SELECT clothingid, 1 FROM dataset2;
USE titanic;
SELECT * FROM titanic;


-- 중복값 유무 확인
SELECT
	COUNT(passengerid) N_PASS
    , COUNT(DISTINCT passengerid) N_UNIQUE_PASS
FROM titanic
;

-- 요인별 생존 여부 집계
SELECT survived FROM titanic;

-- 성별에 따른 승객수와 생존자 수, 비율 구하기
SELECT
	Sex
	, COUNT(passengerid) AS 승객수
    , SUM(survived) AS 생존자수
    , ROUND(SUM(survived) / COUNT(passengerid),3) AS 비율
FROM titanic
GROUP BY 1
;

-- 연령대별 승객수, 생존자수, 비율 구하기
SELECT
	FLOOR(Age/10)*10 AS 연령대
    , sex
	, COUNT(passengerid) AS 승객수
    , SUM(survived) AS 생존자수
    , ROUND(SUM(survived) / COUNT(passengerid),3) AS 비율
FROM titanic
GROUP BY 1,2
-- HAVING sex='male'
ORDER BY 1,2
;

-- 좋은 코드! 연습하기
SELECT 
	A.연령대
    , A.비율 AS 남성비율
    , B.비율 AS 여성비율
    , B.비율 - A.비율 AS 차이
FROM(
	SELECT
		FLOOR(Age/10)*10 AS 연령대
		, sex
		, COUNT(passengerid) AS 승객수
		, SUM(survived) AS 생존자수
		, ROUND(SUM(survived) / COUNT(passengerid),3) AS 비율
	FROM titanic
	GROUP BY 1,2
	HAVING sex='male'
	ORDER BY 1,2
)A
LEFT JOIN
( SELECT
		FLOOR(Age/10)*10 AS 연령대
		, sex
		, COUNT(passengerid) AS 승객수
		, SUM(survived) AS 생존자수
		, ROUND(SUM(survived) / COUNT(passengerid),3) AS 비율
	FROM titanic
	GROUP BY 1,2
	HAVING sex='female'
	ORDER BY 1,2
)B
ON A.연령대 = B. 연령대
;

-- 필드명 embarked
-- 승선 항구별, 성별 승객 수, 성별 승객 비중(%)
SELECT 
	A.embarked
    , A.sex
    , A.s_passengers 
    , B.n_passengers 
    , ROUND(A.s_passengers/B.n_passengers,2) AS ratio
FROM(
	SELECT
		embarked
		, sex
		, COUNT(passengerid) AS s_passengers
	FROM titanic
	GROUP BY 1,2
	ORDER BY 1,2
)A
LEFT JOIN(
	SELECT
		embarked
		, COUNT(passengerid) AS n_passengers
	FROM titanic
	GROUP BY 1
	ORDER BY 1
)B
ON A.embarked = B.embarked
;


