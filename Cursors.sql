use Practice

--1.cursor that selects the customer_id and customer_name columns from the "customers" table. It then iterates over the result set,
--performing operations with each fetched row. The cursor is opened, fetched row by row, and closed and deallocated after the loop.

declare 
@CustomerId int,
@Name varchar(50);

declare Customer_Cursor cursor for
select CustomerId, Name
from Customers;

open Customer_Cursor;

-- Fetch the first row
fetch next from Customer_Cursor into @CustomerId, @Name;

while @@FETCH_STATUS = 0
begin
	print concat('CustomerId:',@CustomerId);
	print concat('Name:',@Name);

	print '-----------------------------';

    -- Fetch the next row
    fetch next from Customer_Cursor into @CustomerId, @Name;
end;

close Customer_Cursor;

deallocate Customer_Cursor;

--2.cursor that selects the product_id and product_name columns from the "products" table for products with a price less than 50. 
--It then updates the product_price by increasing it by 10% for each fetched row. The cursor iterates over the result set, performing
--an update operation for each fetched row.

SET NOCOUNT ON;

declare 
@ProductId int,
@ProductName varchar(100),
@ProductPrice decimal(10, 2);

declare Product_Cursor cursor for
select ProductId, ProductName, Price
from Products
where Price < 50;

open Product_Cursor;

fetch next from Product_Cursor into @ProductId, @ProductName, @ProductPrice;

while @@FETCH_STATUS = 0
begin
    -- Update the product price by increasing it by 10%
    update Products
    set Price = Price * 1.10
    where ProductId = @ProductId;

	-- Print the update details 
	print concat('Updated ProductId:',@ProductId);
	print concat('ProductName:',@ProductName);
	print concat('Old Price:',@ProductPrice);
	print concat('New Price:',@ProductPrice * 1.10);

	print '-----------------------------';

    fetch next from Product_Cursor into @ProductId, @ProductName, @ProductPrice;
end;

close Product_Cursor;

deallocate Product_Cursor;

select * from Products

--3.a cursor is used to select employee_id, employee_name, and department_id from the "employees" table. The fetched values are then
--inserted into the "new_employees" table using an INSERT statement. The cursor iterates over the result set, performing the insert
--operation for each fetched row.

create table New_Employees 
(
    EmployeeId int Primary key,
    EmployeeName varchar(100),
    DepartmentId int
)

SET NOCOUNT ON;

declare 
@EmployeeId int,
@EmployeeName varchar(100),
@DepartmentId int;

declare Employee_Cursor cursor for
select EmployeeId, EmployeeName, DepartmentId
from Employees;

open Employee_Cursor;

fetch next from Employee_Cursor into @EmployeeId, @EmployeeName, @DepartmentId;

while @@FETCH_STATUS = 0
begin
    -- Insert into the new table
    insert into New_Employees (EmployeeId, EmployeeName, DepartmentId)
    values (@EmployeeId, @EmployeeName, @DepartmentId);

    -- Print the insertion details
    print concat('Inserted EmployeeId: ', @EmployeeId);
    print concat('EmployeeName: ', @EmployeeName);
    print concat('DepartmentId: ', @DepartmentId);

	print '-----------------------------';

    fetch next from Employee_Cursor into @EmployeeId, @EmployeeName, @DepartmentId;

end;

close Employee_Cursor;

deallocate Employee_Cursor;

select * from New_Employees

--4.a cursor that selects the customer_id and the count of orders (total_orders) for each customer from the "orders" table.
--The cursor then performs an UPDATE operation on the "customers" table, setting the order_count column to the corresponding 
--total_orders value. The cursor iterates over the result set, updating the rows in the "customers" table for each fetched row.

SET NOCOUNT ON;

declare 
@Customer_Id int,
@TotalOrders int;

declare Order_Cursor cursor for
select CustomerId, COUNT(*) as TotalOrders
from Orders
group by CustomerId;

open Order_Cursor;

fetch next from Order_Cursor INTO @Customer_Id, @TotalOrders;

while @@FETCH_STATUS = 0
begin
    -- Update Customers table with total orders count
    update Customers
    set OrderCount = @TotalOrders
    where CustomerId = @Customer_Id;

    -- Print the update details
    print concat('Updated CustomerId: ', @Customer_Id);
    print concat('Total Orders: ', @TotalOrders);

    print '-----------------------------';

    fetch next from Order_Cursor into @Customer_Id, @TotalOrders;
end;

close Order_Cursor;

deallocate Order_Cursor;

select * from Customers

--5.cursor that selects the table_name and column_name columns from the information_schema.columns view for columns of the varchar
--data type. It then constructs and executes dynamic SQL statements to count the number of NULL values in each varchar column of 
--each table. The cursor iterates over the result set, executing dynamic SQL statements for each fetched row.

declare 
@TableName SYSNAME,
@ColumnName SYSNAME,
@SQL NVARCHAR(MAX);

declare Column_Cursor cursor for
select table_name, column_name
from information_schema.columns
where data_type = 'varchar';

open Column_Cursor;

-- Initialize variables to hold previous table name
declare @PrevTableName SYSNAME = '';

fetch next from Column_Cursor INTO @TableName, @ColumnName;

while @@FETCH_STATUS = 0
begin
    -- Check if table name has changed
    if @TableName <> @PrevTableName
    begin
        -- Print table name once
        print 'Table: ' + @TableName;
        set @PrevTableName = @TableName;
    end

    -- Construct dynamic SQL to count NULLs for each column
    set @SQL = '
        DECLARE @NullCount INT;
        SELECT @NullCount = COUNT(*)
        FROM ' + QUOTENAME(@TableName) + '
        WHERE ' + QUOTENAME(@ColumnName) + ' IS NULL;
        PRINT ''    Column: ' + @ColumnName + ', Null Count: '' + CAST(@NullCount AS VARCHAR(10));';

    -- Execute dynamic SQL
    exec sp_executesql @SQL;

    fetch next from Column_Cursor into @TableName, @ColumnName;
end;

close Column_Cursor;

deallocate Column_Cursor;
