-- Ch04. 자동차 매출 데이터를 이용한 리포트 작성 
-- 일별 매출액 조회

USE classicmodels;
SELECT
	A.Orderdate
    , priceeach * quantityordered
FROM ORDERS A 
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
;


-- GROUP BY 절을 활용해서 일별 매출액을 구하세요!
SELECT
	A.Orderdate
    , SUM(priceeach * quantityordered) AS 매출액
FROM ORDERS A 
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1
;



-- SUBSTR : Python에서 slicing과 같은 개념
-- 인덱스 번호가 1부터 시작
-- 

SELECT SUBSTR("ABCDE", 1,2);
SELECT SUBSTR('2003-01-06', 1,7);

-- 월별 매출액, 연도별 매출액

SELECT
	SUBSTR(A.Orderdate, 1, 7) AS 월별
    , SUM(priceeach * quantityordered) AS 매출액
FROM ORDERS A 
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1
;


SELECT
	SUBSTR(A.Orderdate, 1, 4) AS 연도별
    , SUM(priceeach * quantityordered) AS 매출액
FROM ORDERS A 
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1
;


-- p92
-- 일자별, 월별, 연도별 구매자 수 
SELECT
	COUNT(ordernumber) N_ORDERS
    , COUNT(DISTINCT ordernumber) N_ORDERS_DISTINCT
FROM
	ORDERS
;

SELECT 
	orderdate
    , COUNT(DISTINCT customernumber) 구매고객수 
    , COUNT(ordernumber) 주문건수
FROM
	orders
GROUP BY 1
ORDER BY 1
;

-- 연도, 구매고객수, 매출액
-- 테이블: orders, orderdetails

SELECT 
	SUBSTR(A.Orderdate, 1, 4) 연도
    , COUNT(DISTINCT A.customernumber) 구매고객수 
    , SUM(priceeach * quantityordered) 매출액
FROM ORDERS A 
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1
;

-- 인당 구매금액
SELECT
	SUBSTR(A.Orderdate, 1, 4) YY
    , COUNT(DISTINCT A.customernumber) 구매고객수
    , SUM(B.priceeach * B.quantityordered) 매출
    , SUM(B.priceeach * B.quantityordered) / COUNT(DISTINCT A.ordernumber) 건당구매금액
FROM orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1
;

-- 건당 구매금액
SELECT
	SUBSTR(A.Orderdate, 1, 4) YY
    , COUNT(DISTINCT A.ordernumber) 구매횟수
    , SUM(B.priceeach * B.quantityordered) 매출
    , SUM(B.priceeach * B.quantityordered) / COUNT(DISTINCT A.customernumber) AMV
FROM orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
GROUP BY 1
ORDER BY 1
;

-- 국가별, 도시별 매출액 구하기 
SELECT
    C.country 국가
    , C.city 도시별
    , SUM(B.priceeach * B.quantityordered) 매출
FROM orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
RIGHT JOIN customers C 
ON A.customerNumber = C.customerNumber
GROUP BY 1,2
ORDER BY 1,2
;


-- CASE WHEN 사용
-- 북미 vs 비북미 매출액 비교
/* 참고 코드
SELECT
	CASE WHEN country IN ('USA', 'CANADA') THEN 'NORTH America'
    ELSE 'Others' END country_gap
FROM customers
;
*/

SELECT
	CASE WHEN country IN ('USA', 'CANADA') THEN 'NORTH America'
    ELSE 'Others' END country_gap
    , SUM(B.priceeach * B.quantityordered) 매출
FROM orders A
LEFT JOIN orderdetails B
ON A.ordernumber = B.ordernumber
RIGHT JOIN customers C 
ON A.customerNumber = C.customerNumber
GROUP BY 1
ORDER BY 1
;

USE classicmodels;

-- p103. 매출 Top5 국가 및 매출 
-- row_number, rank, dense_rank

-- CREATE TABLE CLASSICMODELS.STAT AS
SELECT C.COUNTRY,
	SUM(PRICEEACH*QUANTITYORDERED) SALES
FROM CLASSICMODELS.ORDERS A
LEFT
JOIN CLASSICMODELS.ORDERDETAILS B
ON A.ORDERNUMBER = B.ORDERNUMBER
LEFT
JOIN CLASSICMODELS.CUSTOMERS C
ON A.CUSTOMERNUMBER = C.CUSTOMERNUMBER
GROUP BY 1
ORDER BY 2 DESC
;

SELECT * FROM stat;

SELECT 
	country
    , sales
    , DENSE_RANK() OVER(ORDER BY SALES DESC) RNK
FROM stat
;

/* 
Query 실행 순서
 FROM -> WHERE -> GROUP BY -> HAVING -> SELECT
*/


-- CREATE TABLE stat_rnk AS
SELECT
	country
    , sales
    , DENSE_RANK() OVER(ORDER BY SALES DESC) RNK
FROM stat
;

SELECT *
FROM stat_rnk
WHERE RNK BETWEEN 1 AND 5
;

-- 서브쿼리
SELECT * FROM employees;
SELECT * FROM offices;

-- USA에 거주하는 직원의 이름을 출력하세요
SELECT lastName, firstName, country
FROM offices A
LEFT JOIN employees B
ON A.officeCode = B.officeCode
WHERE country = 'USA'
;


-- 서브쿼리로 바꾸기 
SELECT 
	lastName, firstName
FROM employees
WHERE officeCode IN (
	SELECT officeCode 
    FROM offices
	WHERE country = 'USA'
)
;

-- 문제: amount가 최대값인 것을 조회하세용.
SELECT customerNumber, checkNumber, amount 
FROM payments
WHERE amount = (SELECT MAX(amount) FROM payments)
;

-- 문제: 전체 고객 중에서 주문을 하지 않은 고객을 찾으세용.
-- 테이블: customers, orders
SELECT customerName
FROM customers
WHERE customerNumber NOT IN (SELECT DISTINCT customerNumber  FROM orders)
;

-- 인라인 뷰: FROM
SELECT
	ordernumber
    , COUNT(ordernumber) AS items
FROM orderdetails
GROUP BY 1
;

-- 위 코드를 기반으로 각 주문건당 최소, 최대, 평균을 구해봅시당.
SELECT 
	MIN(items)
	, MAX(items)
    , AVG(items)
FROM (
	SELECT
		ordernumber
		, COUNT(ordernumber) AS items
	FROM orderdetails
	GROUP BY 1
) A
;

-- stat 테이블 저장
-- stat_rnk 테이블 저장
SELECT *
FROM stat_rnk
WHERE RNK BETWEEN 1 AND 5
;

-- 위 쿼리와 결과는 동일, 인라인 뷰 서브쿼리가 2번 사용됨 
SELECT *
FROM
(SELECT COUNTRY,
SALES,
DENSE_RANK() OVER(ORDER BY SALES DESC) RNK
FROM
(SELECT C.COUNTRY,
SUM(PRICEEACH*QUANTITYORDERED) SALES
FROM CLASSICMODELS.ORDERS A
LEFT
JOIN CLASSICMODELS.ORDERDETAILS B
ON A.ORDERNUMBER = B.ORDERNUMBER
LEFT
JOIN CLASSICMODELS.CUSTOMERS C
ON A.CUSTOMERNUMBER = C.CUSTOMERNUMBER
GROUP
BY 1) A) A
WHERE RNK <= 5
;

-- 
SELECT C.COUNTRY,
SUBSTR(A.ORDERDATE,1,4) YY,
COUNT(DISTINCT A.CUSTOMERNUMBER) BU_1,
COUNT(DISTINCT B.CUSTOMERNUMBER) BU_2,
COUNT(DISTINCT B.CUSTOMERNUMBER)/COUNT(DISTINCT A.CUSTOMERNUMBER)
RETENTION_RATE
FROM CLASSICMODELS.ORDERS A
LEFT
JOIN CLASSICMODELS.ORDERS B
ON A.CUSTOMERNUMBER = B.CUSTOMERNUMBER AND SUBSTR(A.ORDERDATE,1,4)
= SUBSTR(B.ORDERDATE,1,4)-1
LEFT
JOIN CLASSICMODELS.CUSTOMERS C
ON A.CUSTOMERNUMBER = C.CUSTOMERNUMBER
GROUP
BY 1,2
;

-- 셀프 조인
SELECT *
FROM orders A
LEFT JOIN orders B
ON A.customernumber = B.customernumber
	AND SUBSTR(A.orderdate, 1, 4) = SUBSTR(B.orderdate, 1, 4) - 1
;


-- BEST SELLER
-- 미국 고객의 Retention Rate가 제일 높은 걸 확인
-- 미국에 집중
-- 미국의 Top5 차량 모델 추출을 부탁 
-- 차량 모델별로 매출이 가장 잘 나온 것 Top 5
-- 차량 모델별로 매출액 구하기 
 

SELECT *
FROM (
	SELECT
		*
		, ROW_NUMBER() OVER (ORDER BY Sales DESC) RNK
	FROM (
		SELECT 
			D.productName
			, SUM(C.priceeach * C.quantityordered) AS Sales
		FROM orders A
		LEFT JOIN customers B
		ON A.customernumber = B.customernumber
		LEFT JOIN orderdetails C
		ON A.ordernumber = C.ordernumber
		LEFT JOIN products D
		ON C.productcode = D.productcode
		WHERE B.country = 'USA'
		GROUP BY 1
	) A 
) A
WHERE RNK BETWEEN 1 AND 5
;




