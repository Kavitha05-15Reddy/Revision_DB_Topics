use Practice

--1.Problem Statement: Identifying Indexing Needs
--Description: Analyze the frequently executed queries in the sales database and determine the optimal columns to create indexes on,
--considering the search conditions used in the queries.

CREATE INDEX idx_Orders_CustomerId_Status 
ON Orders (CustomerId, Status);

select * 
from Orders
where CustomerId=4 and Status = 'shipped'

--2.Problem Statement: Indexing Large Tables
--Description: Design an indexing strategy for the "Orders" table, which contains millions of records, to improve the performance
--of select queries while minimizing the impact on insert and update operations.

CREATE INDEX idx_Orders_CustomerId 
ON Orders (CustomerId);

select *
from Orders
where CustomerId = 3

CREATE INDEX idx_Orders_OrderDate 
ON Orders (OrderDate);

select * 
from Orders
where OrderDate between '2022-12-15' and'2023-04-15'

CREATE INDEX idx_Orders_Shipped 
ON Orders (Status) WHERE Status = 'shipped';

select * 
from Orders
where Status = 'shipped'

--3.Problem Statement: Indexing Join Operations
--Description: Create appropriate indexes on the "Customers" and "Orders" tables to optimize join operations, such as retrieving
--all orders placed by a specific customer, thereby reducing the need for full table scans.

CREATE INDEX idx_Orders_CustomerId 
ON Orders (CustomerId);

CREATE INDEX idx_Customers_CustomerId
ON Customers (CustomerId);

select c.Name, o.OrderId, o.TotalPrice
from Customers c, Orders o 
where c.CustomerId = o.CustomerId and
	  c.CustomerId = 2;

--4.Problem Statement: Indexing String Columns
--Description: Improve the search performance of queries that involve searching for specific product names in the "Products" table
--by creating an index on the "ProductName" column, taking into account collation settings and data distribution patterns.

alter table Products
alter column ProductName varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS;

alter table Products
alter column ProductName varchar(100) COLLATE SQL_Latin1_General_CP1_CS_AS;

insert into Products (ProductName, Price, Inventory)
values 
('laptop', 11000, 10),
('LAPTOP', 13000, 5)

CREATE INDEX idx_Products_ProductName 
ON Products (ProductName);

DROP INDEX idx_Products_ProductName 
ON Products;

select * 
from Products 
where ProductName = 'Laptop'

--5.Problem Statement: Indexing Date/Time Columns
--Description: Enhance the query performance on date-based operations, such as retrieving all orders placed within a specific date range, 
--by creating an index on the "OrderDate" column, considering the range, frequency, and distribution of the date/time values.

CREATE INDEX idx_Orders_OrderDate 
ON Orders (OrderDate);

select *
from Orders 
where OrderDate between '2023-01-01' and '2023-12-31';

--6.Problem Statement: Indexing Composite Columns
--Description: Create a composite index on the "FirstName" and "LastName" columns in the "Employees" table to optimize queries that involve 
--searching for employees based on both first and last names, improving overall query execution time.

CREATE INDEX idx_Employees_FirstName_LastName 
ON Employees (FirstName, LastName);

select * 
from Employees 
where FirstName = 'hari' and LastName = 'krishna'

--7.Problem Statement: Indexing for Sorting and Ordering
--Description: Design indexes on the "Price" column in the "Products" table to support efficient sorting and ordering operations, enhancing
--the performance of queries that involve sorting products by price or retrieving the top N expensive products

CREATE INDEX idx_Products_Price 
ON Products (Price);

select * 
from Products 
order by Price desc

select top 5 * 
from Products 
order by Price desc
