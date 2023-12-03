-- Active: 1699918152805@@127.0.0.1@1433@AdventureWorks2022
--basic selection
SELECT * FROM [AdventureWorks2022].[Sales].[SalesOrderHeader] 

SELECT SUM([TotalDue]) FROM [AdventureWorks2022].[Sales].[SalesOrderHeader]

SELECT SUM([TotalDue]) AS TotalOrderQty , [SalesPersonID]
FROM [AdventureWorks2022].[Sales].[SalesOrderHeader]
GROUP BY [SalesPersonID]


-- Windows Function

SELECT [BusinessEntityID],
[TerritoryID],
[SalesQuota],
[Bonus],
[CommissionPct],
[SalesYTD],
[SUMWindowFunction]=SUM([SalesYTD]) OVER(),
[MAXWindowFunction]=MAX([SalesYTD]) OVER(),
[% of Best Performance]=[SalesYTD]/MAX([SalesYTD]) OVER(),
[SalesLastYear],
[rowguid],
[ModifiedDate]
FROM [AdventureWorks2022].[Sales].[SalesPerson] 


SELECT [TotalYTDSalesWindowFunction]=SUM([SalesYTD])
FROM [AdventureWorks2022].[Sales].[SalesPerson] 


-----PARTITION BY




SELECT 
    [ProductID],
    [OrderQty],
    [LineTotal],
    SUM([LineTotal]) OVER()
FROM 
    [AdventureWorks2022].[Sales].[SalesOrderDetail]
ORDER BY 1,2

SELECT 
    [ProductID],
    [OrderQty],
    SUM([LineTotal]) AS TotalLine
FROM 
    [AdventureWorks2022].[Sales].[SalesOrderDetail]
GROUP BY 
    [ProductID],
    [OrderQty]
ORDER BY 1,2;

SELECT 
    [ProductID],
    [OrderQty],
    [LineTotal],
    SUM([LineTotal]) OVER(PARTITION BY [ProductID], [OrderQty] ) ,*
FROM 
    [AdventureWorks2022].[Sales].[SalesOrderDetail]
ORDER BY 1,2

------- ROW_NUMBER()
--ranking all records within each group of sales order ID
SELECT 
    [SalesOrderID],
    [OrderQty],
    [LineTotal],
    Ranking = ROW_NUMBER() OVER( PARTITION BY [SalesOrderID]  ORDER BY [LineTotal]  ),* --DESC without partition by means consider the entire data
FROM 
    [AdventureWorks2022].[Sales].[SalesOrderDetail]
--where [ProductID]=793 --707

-------- RANK and DENSE rank 

SELECT 
    [SalesOrderID],
    [OrderQty],
    [LineTotal],
    Ranking = ROW_NUMBER() OVER( PARTITION BY [SalesOrderID]  ORDER BY [LineTotal]  ),
    RankingWithRank = Rank() OVER( PARTITION BY [SalesOrderID]  ORDER BY [LineTotal]  ),
    RankingWithDenseRank= dense_rank() OVER( PARTITION BY [SalesOrderID]  ORDER BY [LineTotal]  )
FROM 
    [AdventureWorks2022].[Sales].[SalesOrderDetail]
--where [ProductID]=793 --707





-------- LEAD and LAG

SELECT SalesOrderID, OrderDate, CustomerID, TotalDue,
        NEXTTOTALDUE = LEAD(TotalDue,2) OVER(ORDER BY SalesOrderID)
FROM [AdventureWorks2022].[Sales].[SalesOrderHeader]
ORDER BY SalesOrderID


SELECT SalesOrderID, OrderDate, CustomerID, TotalDue,
        PERTOTALDUE = LAG(TotalDue,1) OVER(PARTITION BY OrderDate ORDER BY SalesOrderID)
FROM [AdventureWorks2022].[Sales].[SalesOrderHeader]
ORDER BY SalesOrderID



----------- subqueries
SELECT * 
FROM (
    SELECT 
        [SalesOrderID],
        [OrderQty],
        [LineTotal],
        Ranking = ROW_NUMBER() OVER (PARTITION BY [SalesOrderID] ORDER BY [LineTotal])
    FROM 
        [AdventureWorks2022].[Sales].[SalesOrderDetail]
) A--AS Subquery
WHERE Ranking = 1;


-------------------------------------------- PART2 

------ simple calculation simple subquery with doing calculation
select AVG(ListPrice) FROM [AdventureWorks2022].[production].[Product] /*ProductID, one column one row*/

select 
ProductID,
[Name],
StandardCost,
ListPrice,
AvgListPrice = (select AVG(ListPrice) FROM [AdventureWorks2022].[production].[Product]),
DiffFromAvgPrice = ListPrice - (select AVG(ListPrice) FROM [AdventureWorks2022].[production].[Product])
from [AdventureWorks2022].[production].[Product] 
where ListPrice > (select AVG(ListPrice) FROM [AdventureWorks2022].[production].[Product] )
ORDER BY ListPrice DESC


------------------------------- correlated subqueries
--outer query
select  SalesOrderID,
        OrderDate,
        SubTotal,
        TaxAmt,
        Freight,
        TotalDue
 from [AdventureWorks2022].[Sales].[SalesOrderHeader] A

--inner query
select SalesOrderID,OrderQty  FROM [AdventureWorks2022].[Sales].[SalesOrderDetail] B

---the subquery has to be run once for each record in outer query / how to run the code for each record?
--we are selecting multiple things so in where clasue we dont restricted to one id
-- it is not just one column one row / it is one column for each row!

select  SalesOrderID,
        OrderDate,
        SubTotal,
        TaxAmt,
        Freight,
        TotalDue,
        MultiOrderCount =
        ( select COUNT(*)  
          FROM [AdventureWorks2022].[Sales].[SalesOrderDetail] B
          where a.SalesOrderID=b.SalesOrderID AND b.OrderQty>1)
 from [AdventureWorks2022].[Sales].[SalesOrderHeader] A


 ---------- EXISTS

 select * from [AdventureWorks2022].[Sales].[SalesOrderHeader] where [SalesOrderID]=43659
 select * FROM [AdventureWorks2022].[Sales].[SalesOrderDetail] where [SalesOrderID]=43659

 select A.SalesOrderID,
        A.OrderDate,
        A.TotalDue
  from  [AdventureWorks2022].[Sales].[SalesOrderHeader] A 
  where EXISTS(select 1 from [AdventureWorks2022].[Sales].[SalesOrderDetail] B where B.LineTotal>10000 and A.SalesOrderID=B.SalesOrderID )
  and A.SalesOrderID=43683

SELECT A.SalesOrderID,
        A.OrderDate,
        A.TotalDue
FROM [AdventureWorks2022].[Sales].[SalesOrderHeader] AS A
INNER JOIN [AdventureWorks2022].[Sales].[SalesOrderDetail] AS B
ON A.SalesOrderID = B.SalesOrderID
WHERE A.SalesOrderID = 43683 and B.LineTotal>10000


select LineTotal,* from [AdventureWorks2022].[Sales].[SalesOrderDetail] where SalesOrderID=43683

select LineTotal from [AdventureWorks2022].[Sales].[SalesOrderDetail] where SalesOrderID=43683
for XML path('')


select ','+ CAST(CAST(LineTotal as Money) as varchar) 
from [AdventureWorks2022].[Sales].[SalesOrderDetail] where SalesOrderID=43683
for XML path('')


select Stuff(
(select ','+ CAST(CAST(LineTotal as Money) as varchar) 
from [AdventureWorks2022].[Sales].[SalesOrderDetail] where SalesOrderID=43683
for XML path('')),
1,1,'')


/*plug into the correlated query*/

SELECT  B.SalesOrderID,
        B.OrderDate,
        B.TotalDue,
        LineTotals= Stuff(
                    (select ','+ CAST(CAST(LineTotal as Money) as varchar) 
                    from [AdventureWorks2022].[Sales].[SalesOrderDetail] A where A.SalesOrderID=B.SalesOrderID
                    for XML path('')),
                    1,1,'')
FROM [AdventureWorks2022].[Sales].[SalesOrderHeader] B


--------------CTEs --- A
---- 1. making order month COLUMN
---- 2. ranking our data for grabbing top 10 amount per month
select T1.orderMonth,
        T1.top10total,
        PervTop10=T2.top10total
 from 
(select orderMonth,
        top10total=sum(TotalDue)
 from (
    SELECT  B.SalesOrderID,
        B.OrderDate,
        B.TotalDue,
        orderMonth=DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
        orderRank=ROW_Number() OVER(partition by DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue)
FROM [AdventureWorks2022].[Sales].[SalesOrderHeader] B
) X where orderRank<=10
group by orderMonth
) T1
LEFT JOIN
(select orderMonth,
        top10total=sum(TotalDue)
 from (
    SELECT  B.SalesOrderID,
        B.OrderDate,
        B.TotalDue,
        orderMonth=DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1),
        orderRank=ROW_Number() OVER(partition by DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue)
FROM [AdventureWorks2022].[Sales].[SalesOrderHeader] B
) X where orderRank<=10
group by orderMonth
) T2 ON T1.orderMonth=DATEADD(MONTH,1,T2.orderMonth)
order by 1



--- compare this out put to itself



WITH Top10CTE AS (
    SELECT
        orderMonth,
        top10total = SUM(TotalDue)
    FROM (
        SELECT
            B.SalesOrderID,
            B.OrderDate,
            B.TotalDue,
            orderMonth = DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1),
            orderRank = ROW_NUMBER() OVER (PARTITION BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) ORDER BY TotalDue)
        FROM [AdventureWorks2022].[Sales].[SalesOrderHeader] B
    ) X
    WHERE orderRank <= 10
    GROUP BY orderMonth
)
select * from Top10CTE