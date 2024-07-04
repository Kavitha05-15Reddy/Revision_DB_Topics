use Practice

--1.E-commerce application: 
--  Suppose you have an e-commerce application where customers can place orders, and the orders need to be processed and shipped.
--  You could create a stored procedure that takes in the order details, validates the data, creates a new order in the database,
--  updates the inventory, and sends an email confirmation to the customer. This stored procedure could be called from the application
--  whenever a new order is placed.

create or alter procedure PlaceOrder
(
    @CustomerId int,
    @ProductId int,
    @Quantity int
)
as
begin
    declare @OrderId int,
            @TotalPrice decimal(10, 2),
            @CurrentInventory int,
            @CustomerEmail varchar(100)

    SET NOCOUNT ON;
    begin try
        -- Check if the product exists and retrieve current inventory
        if exists (select 1 from Products where ProductId = @ProductId)
        begin
            select @CurrentInventory = Inventory
			from Products
			where ProductId = @ProductId
        end
        else
        begin
            RAISERROR('Product with ProductId %d does not exist.', 16, 1, @ProductId);
            return
        end

		-- Validate if there is enough inventory
        if @CurrentInventory < @Quantity
        begin
            RAISERROR('Not enough inventory available for ProductId %d.', 16, 1, @ProductId);
            return
        end

		-- Calculate total price for the specific product and quantity
        select @TotalPrice = Price * @Quantity
        from Products
        where ProductId = @ProductId

        BEGIN TRANSACTION;

		-- Insert into Orders table
        insert into Orders (CustomerId, OrderDate, TotalPrice, Status)
        values (@CustomerId, GETDATE(), @TotalPrice, 'Processing')
		
		-- Get the new OrderId
        set @OrderId = SCOPE_IDENTITY();

		-- Insert into OrderDetails table
        insert into OrderDetails (OrderId, ProductId, Quantity)
        values (@OrderId, @ProductId, @Quantity)

		-- Update product inventory
        update Products
        set Inventory = Inventory - @Quantity
        where ProductId = @ProductId

        -- Check if the customer exists and retrieve customer email for email confirmation
        if exists (select 1 from Customers where CustomerId = @CustomerId)
        begin
            select @CustomerEmail = Email
			from Customers
			where CustomerId = @CustomerId
        end
        else
        begin
            RAISERROR('Customer with CustomerId %d does not exist.', 16, 1, @CustomerId);
            return
        end

        COMMIT TRANSACTION;

        -- Simulate sending an email confirmation
        print 'Email sent to ' + @CustomerEmail;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
end

exec PlaceOrder 
		@CustomerId = 2,
		@ProductId = 3, 
		@Quantity = 2

select * from Customers
select * from Products
select * from Orders
select * from OrderDetails

--2.Banking application: 
--  In a banking application, you could create a stored procedure that transfers funds between accounts. The stored procedure would
--  take in the account numbers, validate the data, check the balance, and update the account balances in the database. You could also
--  include additional logic to handle currency conversions, transaction fees, and other business rules.

create or alter procedure TransferFunds
    @FromAccountId int,
    @ToAccountId int,
    @Amount decimal(10, 2)
as
begin
    declare @FromAccountBalance decimal(10, 2),
		    @ToAccountBalance decimal(10, 2)
    
    SET NOCOUNT ON;
    begin try
        -- Check if the from account exists and get its balance
        if exists (select 1 from Accounts where AccountId = @FromAccountId)
        begin
            select @FromAccountBalance = Balance
            from Accounts
            where AccountId = @FromAccountId;
        end
        else
        begin
            RAISERROR('From account with AccountId %d does not exist.', 16, 1, @FromAccountId);
            return
        end
        
        -- Check if the to account exists and get its balance
        if exists (select 1 from Accounts where AccountId = @ToAccountId)
        begin
            select @ToAccountBalance = Balance
            from Accounts
            where AccountId = @ToAccountId;
        end
        else
        begin
            RAISERROR('To account with AccountId %d does not exist.', 16, 1, @ToAccountId);
            return
        end
        
        -- Validate sufficient balance
        if @FromAccountBalance < @Amount
        begin
            RAISERROR('Insufficient balance in from account.', 16, 1);
            return
        end
        
		BEGIN TRANSACTION;

        -- Update the balances
        update Accounts
        set Balance = Balance - @Amount
        where AccountId = @FromAccountId;
        
        update Accounts
        set Balance = Balance + @Amount
        where AccountId = @ToAccountId;
        
        -- Insert the transactions
        insert into Transactions (AccountId, TransactionType, Amount, TransactionDate, RelatedAccountId)
        values (@FromAccountId, 'Debit', @Amount, GETDATE(), @ToAccountId);
        
        insert into Transactions (AccountId, TransactionType, Amount, TransactionDate, RelatedAccountId)
        values (@ToAccountId, 'Credit', @Amount, GETDATE(), @FromAccountId);
        
        COMMIT TRANSACTION;
    end try
    begin catch
        -- Rollback the transaction if an error occurs
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
end

exec TransferFunds
		@FromAccountId = 3, 
		@ToAccountId = 4, 
		@Amount = 100.00

select * from Accounts
select * from Transactions

--3.Healthcare application: 
--  In a healthcare application, you could create a stored procedure that schedules appointments for patients. The stored procedure
--  would take in the patient details, validate the data, check for conflicting appointments, and create a new appointment in the
--  database. You could also include additional logic to send reminders to patients, update the doctor's schedule, and handle 
--  cancellations or rescheduling requests.

create or alter procedure ScheduleAppointment
    @PatientId int,
    @AppointmentDate datetime,
    @DoctorName varchar(50),
    @Notes text
as
begin
	SET NOCOUNT ON;
    begin try
		--Validate patient Id
		if not exists (select 1 from Patients where PatientId = @PatientId)
		begin
			RAISERROR ('Invalid patient Id.', 16, 1);
			return
		end

		--Check for conflicting appointments
		if exists (
			select 1
			from Appointments
			where PatientId = @PatientId and 
				  AppointmentDate = @AppointmentDate
		)
		begin
			RAISERROR ('The patient already has an appointment at this time.', 16, 1);
			return
		end

		--Create a new appointment
		insert into Appointments (PatientId, AppointmentDate, DoctorName, Notes)
		values (@PatientId, @AppointmentDate, @DoctorName, @Notes)

		print 'Appointment scheduled successfully.'
	end try
    begin catch
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(), 
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
end

exec ScheduleAppointment 
		@PatientId = 1, 
		@AppointmentDate = '2024-07-01 10:00', 
		@DoctorName = 'Dr. Smith', 
		@Notes = 'Routine check-up'

select * from Patients
select * from Appointments

--4.Social media application:
--  In a social media application, you could create a stored procedure that generates personalized content recommendations for users
--  based on their browsing history and preferences. The stored procedure would query the user's activity log, analyze the data, and
--  generate a list of recommended posts or articles. You could also include additional logic to filter out inappropriate or
--  low-quality content, track user engagement, and refine the recommendation algorithm over time.

create or alter procedure GenerateRecommendations
@UserId int
as
begin
    SET NOCOUNT ON;
	begin try
		-- Select recommended content based on user activity
		select
			al.ActivityType,
			al.Details,
			COUNT(al.ActivityId) as ActivityCount
		from
			ActivityLog al
		where
			al.UserId = @UserId
		group by
			al.ActivityType, al.Details
		having
			COUNT(al.ActivityId) > 1  
		order by
			ActivityCount desc
	end try
    begin catch
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(), 
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
end

exec GenerateRecommendations 
		@UserId = 1

select * from Users
select * from ActivityLog

--5.Travel booking application: 
--  In a travel booking application, you could create a stored procedure that searches for the best flight or hotel deals based on
--  user preferences and availability. The stored procedure would query multiple databases, compare prices and availability, and
--  generate a list of options for the user. You could also include additional logic to handle cancellations or changes to the booking,
--  track loyalty points or rewards, and provide personalized recommendations for future bookings.

create or alter procedure SearchTravelOptions
    @Destination varchar(100),
    @StartDate datetime,
    @EndDate datetime,
    @NumTravelers int,
    @Budget decimal(10, 2) = NULL
as
begin
    SET NOCOUNT ON;
	begin try
		-- Search for available flights
		select 'Flight' as Type, FlightId as TypeId, FlightNumber, DepartureAirport, ArrivalAirport, DepartureTime, ArrivalTime, Availability, Price
		from Flights
		where DepartureAirport = @Destination
		  and DepartureTime >= @StartDate
		  and DepartureTime <= @EndDate
		  and Availability >= @NumTravelers
		  and (@Budget IS NULL OR Price <= @Budget);

		-- Search for available hotels
		select 'Hotel' as Type, HotelId as TypeId, HotelName, Location, CheckIn, CheckOut, Availability, Price
		from Hotels
		where Location = @Destination
		  and CheckIn >= @StartDate
		  and CheckOut <= @EndDate
		  and Availability >= @NumTravelers
		  and (@Budget IS NULL OR Price <= @Budget);
	end try
    begin catch
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(), 
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    end catch
end


exec SearchTravelOptions
		@Destination = 'New York',
		@StartDate = '2023-07-01',
		@EndDate = '2023-07-02',
		@NumTravelers = 2,
		@Budget = 400.00;

select * from Flights
select * from Hotels
select * from Bookings
