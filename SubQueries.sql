use Practice

select * from Orders
select * from Customers

--1.Write a query retrieves the customer name, order date, and total amount from the "orders" table for orders 
--  with a total amount greater than the average total amount of orders placed in the year 2023.

select c.Name as CustomerName,
	   o.OrderDate,
	   o.TotalPrice as TotalAmount
from Customers c, Orders o
where c.CustomerId = o.CustomerId and
	  o.TotalPrice > (select avg(TotalPrice) 
					  from Orders
					  where year(OrderDate)=2023)

--2.Write a	query retrieves the customer names from the "customers" table for customers who have placed an order 
--on a specific date, in this case, May 1, 2023.

select c.Name as CustomerName
from Customers c, Orders o
where  c.CustomerId = o.CustomerId and
	  o.OrderDate = '2023-05-01'

--3.Write a query retrieves the customer name from the "customers" table along with the count of orders made by each customer. 
--The subquery is used within the SELECT statement to calculate the order count for each customer.

select c.Name as CustomerName, COUNT(*) as OrderCount
from Customers c, Orders o
where c.CustomerId = o.CustomerId 
group by c.Name

select c.Name as CustomerName,
	   (select COUNT(*)
       from Orders o
       where c.CustomerId = o.CustomerId ) as OrderCount
from Customers c

--4.Write a query deletes rows from the "customers" table where there exists an order in the "orders" table 
--for that customer with an order date earlier than January 1, 2023. The subquery with EXISTS is used in the WHERE clause to check 
--for the existence of such orders.

delete from Customers
where exists (select 1
			  from Orders
			  where Orders.CustomerId = Customers.CustomerId and
					OrderDate > '2023-01-01')

--5.Write a query retrieves the product name and price from the "products" table for products that have been ordered by
--a specific customer with the ID 123.
create table Products 
(
    ProductId int Identity(1,1) Primary key,
    ProductName varchar(100),
    Price decimal(10, 2)
)

select * from Products

insert into Products (ProductName,Price)
values 
('Laptop', 12000),
('Monitor', 5000),
('keyboard', 1000)

create table OrderDetails
(
    OrderDetailId int Identity(1,1) Primary key,
	OrderId int foreign key references Orders(OrderId),
	ProductId int foreign key references Products(ProductId),
    Quantity int
)

select * from OrderDetails

insert into OrderDetails (OrderId,ProductId,quantity)
values 
(1,1,2),
(1,2,1),
(2,3,3),
(3,1,1),
(3,2,2)

select p.ProductName, p.Price
from Products p, Customers c, Orders o, OrderDetails od
where c.CustomerId = o.CustomerId and
	  o.OrderId = od.OrderId and 
	  od.ProductId = p.ProductId and 
	  c.CustomerId = 2

--6.Write a query calculates the total number of orders for each product in the "order_details" table and 
--then retrieves the product name along with the total_orders. The subquery is used in the FROM clause to generate 
--a temporary result set that is then joined with the "products" table.

select p.ProductName,COUNT(*) as TotalOrders
from Products p, OrderDetails od
where p.ProductId = od.ProductId 
group by p.ProductName

select p.ProductName, od.TotalOrders
from Products p, (select ProductId, COUNT(*) as TotalOrders
				  from OrderDetails
				  group by ProductId) od
where p.ProductId = od.ProductId

--7.Write a query retrieves the employee name and hire date from the "employees" table 
--for employees who were hired most recently in their respective departments.

create table Employees 
(
    EmployeeId int Identity(1,1) Primary key,
    EmployeeName varchar(100),
    DepartmentId int,
    HireDate date,
    Salary decimal(10, 2)
)

select * from Employees

insert into Employees (EmployeeName,DepartmentId,HireDate,Salary)
values
('hari',100,'2022-01-01',60000),
('rishi',100,'2023-02-01',70000),
('prem',101,'2021-03-01',50000),
('tanu',101,'2022-05-01',80000)

select e.EmployeeName,e.HireDate
from Employees e
where e.HireDate = (select MAX(HireDate)
					from Employees emp
					where emp.DepartmentId = e.DepartmentId)

--8.Write a query retrieves the employee name and salary from the "employees" table
--for employees whose salary is greater than the average salary of employees in the department with ID 100. 
--The subquery is used in the WHERE clause to compare the salary of each employee with the average salary.

select e.EmployeeName, e.Salary
from Employees e
where e.Salary > (select avg(emp.Salary)
				  from Employees emp
				  where emp.DepartmentId = 100) and
	  e.DepartmentId = 100

select * from Employees