use Practice

--1.a scalar function called GetOrderTotal. It calculates and returns the total order amount by multiplying the quantity and price for
--each order detail row in the "order_details" table associated with a given order_id.

create or alter function GetOrderTotal(@OrderId int)
returns decimal(10, 2)
as
begin
    declare @Total decimal(10, 2);

    select @Total = SUM(od.Quantity * p.Price)
    from OrderDetails od, Products p 
	where od.ProductId = p.ProductId and
		  od.OrderId = @OrderId;

    return @Total;
end;

select dbo.GetOrderTotal(1) as TotalOrderAmount;

--2.a table-valued function called GetProductsWithLowStock. It returns a result set containing the product_id, product_name, and 
--stock_quantity columns from the "products" table for products that have a stock quantity less than 10.

create or alter function GetProductsWithLowStock()
returns @ProductsWithLowStock table
(
    ProductId int,
    ProductName varchar(100),
    StockQuantity int
)
as
begin
    insert into @ProductsWithLowStock (ProductId, ProductName, StockQuantity)
    select ProductId, ProductName, Inventory
    from Products
    where Inventory < 10;

    return;
end;

select * from dbo.GetProductsWithLowStock();

--3.table-valued function called GetOrdersByCustomer. It returns a result set containing the order_id, order_date, and total_amount
--columns from the "orders" table for orders associated with a specific customer_id.

create  or alter function GetOrdersByCustomer(@CustomerId int)
returns @CustomerOrders table
(
    OrderId int,
    OrderDate date,
    TotalAmount decimal(10, 2)
)
as
begin
    insert into @CustomerOrders (OrderId, OrderDate, TotalAmount)
    select OrderId, OrderDate, TotalPrice
    from Orders
    where CustomerId = @CustomerId;

    return;
end;

select * from dbo.GetOrdersByCustomer(1);

--4.aggregate function called GetTotalOrderAmountByCustomer. It calculates and returns the total order amount for a specific 
--customer_id by summing the total_amount column in the "orders" table.

create or alter function GetTotalOrderAmountByCustomer(@CustomerId int)
returns decimal(10, 2)
as
begin
    declare @TotalAmount decimal(10, 2);

    select @TotalAmount = SUM(TotalPrice)
    from Orders
    where CustomerId = @CustomerId;

    return @TotalAmount;
end;

select dbo.GetTotalOrderAmountByCustomer(2) as TotalOrderAmount;

