USE classicmodels; -- 해당 데이터베이스를 사용하겠음



SELECT * FROM customers;   -- Ctrl + Enter

SELECT * FROM classicmodels.customers; -- 이렇게 하기 귀찮으니까
USE classicmodels;  -- 사용
SHOW tables;
SELECT * FROM customers; -- 간결하게


-- 현재 사용 중인 스키마를 확인
SELECT DATABASE();

-- USE sakila;

SELECT * FROM customers;


-- 
DESC customers;


-- SELECT
SELECT * FROM customers;
SELECT customerNumber, customerName, contactFirstName FROM customers;

-- customerNumber, customerName, contactLastName, contactFirstName, phone, addressLine1, addressLine2, city, state, postalCode, country, salesRepEmployeeNumber, creditLimit

-- where  조건
SELECT *
FROM
	customers
WHERE country = 'USA'
;

SELECT *
FROM
	customers
WHERE customerNumber = 112
;

SELECT *
FROM
	customers
WHERE customerNumber >= 112
;

-- 문자열과 부등호 연산자
SELECT * 
FROM
	customers
WHERE
	country >= 'T'
;
    

-- WHERE LIKE 연산자
SELECT *
FROM	
	customers
WHERE customerName LIKE '%Gift%'   -- 양 옆에 %를 꼭 달자
;


-- 문자열 검색할 때 가장 유용한 것: 정규표현식을 활용한 검색
-- 매우 어려움, 근데 필요함

SELECT *
FROM	
	customers
WHERE customerName REGEXP '^LA'
;


-- AND
-- country가 USA 이면서 city가  NYC 인 고객을 조회하세요.
-- 필드는 전체 조회
SELECT * FROM customers WHERE country='USA' AND city='NYC';


-- OR 조건
SELECT * FROM customers WHERE country='USA' OR contactLastName = "Lee";


-- BETWEEN 연산자
SELECT *
FROM
	payments
WHERE 
	amount BETWEEN 10000 AND 50000
    AND paymentDate BETWEEN '2003-05-20' AND '2003-06-05'
    AND checkNumber LIKE '%JM%'
;

-- IN 연산자
SELECT *
FROM 
	offices
WHERE country IN ('USA', 'FRANCE', 'UK')
;

/*
--
SELECT 필드명
FROM 테이블명
WHERE 필드명에 관한 여러 조건식
*/


-- OREDER BY 절, sort_values()
SELECT *
FROM orders
ORDER BY orderNumber DESC  -- 내림차순
;


SELECT *
FROM orders
ORDER BY orderNumber ASC  --  오름차순
;


SELECT customerNumber, orderNumber
FROM orders
ORDER BY customerNumber ASC  -- 오름차순
;


SELECT customerNumber, orderNumber
FROM orders
ORDER BY 1 ASC, 2 DESC
;


-- GROUP BY와 HAVING
SELECT * FROM orders;
SELECT
	DISTINCT status  --  중복값 제거
FROM
	orders
GROUP BY
	status
;


SELECT 
	status
    , COUNT(*) AS '갯수'  -- 집계함수
FROM 
	orders
GROUP BY
	status
HAVING COUNT(*) >= 5
ORDER BY 2 DESC
;










