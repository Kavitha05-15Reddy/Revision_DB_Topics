use Practice

--1.E-commerce application: 
--  In an e-commerce application, you could create a trigger that sends an email notification to the customer and 
--  the customer service team when an order is placed. The trigger would be fired automatically when a new order is inserted into
--  the orders table, and it would execute the email sending code to notify the relevant parties.

--NotificationLog-table
create table NotificationLog 
(
    LogId int Identity(1,1) Primary key,
    OrderId int,
    CustomerId int,
    CustomerName varchar(100),
    CustomerEmail varchar(100),
    OrderDate date,
    TotalPrice decimal(10, 2),
    Status varchar(30),
    LogMessage varchar(1000),
    LogDateTime datetime default GETDATE()
)

select * from NotificationLog

create trigger trg_AfterOrderInsert
on Orders
after insert
as
begin
    insert into NotificationLog (
        OrderId,
        CustomerId,
        CustomerName,
        CustomerEmail,
        OrderDate,
        TotalPrice,
        Status,
        LogMessage
    )
    select 
        i.OrderId,
        i.CustomerId,
        c.Name,
        c.Email,
        i.OrderDate,
        i.TotalPrice,
        i.Status,
        'Order placed: Notification sent to customer and customer service team.'
    from inserted i ,Customers c 
	where i.CustomerId = c.CustomerId;
end

insert into Orders (CustomerId,OrderDate,TotalPrice,Status)
values (1,'2023-08-25',25000,'completed')

select * from Customers
select * from Orders
select * from NotificationLog

--2.Healthcare application: 
--  In a healthcare application, you could create a trigger that logs the changes made to the patient's medical history table.
--  The trigger would be fired automatically when an update or delete operation is performed on the medical history table, and
--  it would insert a new record into the audit log table with the details of the change, such as the user who made the change and
--  the timestamp.

--AuditLog-table
create table AuditLog 
(
    LogId int Identity(1,1) Primary key,
    HistoryId int,
    PatientId int,
    Operation varchar(10),
    OldCondition varchar(100),
    NewCondition varchar(100),
    OldTreatment varchar(100),
    NewTreatment varchar(100),
    UserName varchar(100),
    ChangeTimestamp datetime default GETDATE()
)

select * from AuditLog

create trigger trg_AfterMedicalHistoryUpdate
on MedicalHistory
after update
as
begin
    insert into AuditLog (
        HistoryId,
        PatientId,
        Operation,
        OldCondition,
        NewCondition,
        OldTreatment,
        NewTreatment,
        UserName,
        ChangeTimestamp
    )
    select 
        d.HistoryId,
        d.PatientId,
        'update',
        d.Condition as OldCondition,
        i.Condition as NewCondition,
        d.Treatment as OldTreatment,
        i.Treatment as NewTreatment,
        SYSTEM_USER,
        GETDATE()
    from deleted d, inserted i 
	where d.HistoryId = i.HistoryId;
end

update MedicalHistory
set Condition = 'Asthmaa', Treatment = 'Opreation'
where HistoryId = 3

select * from MedicalHistory
select * from AuditLog

create trigger trg_AfterMedicalHistoryDelete
on MedicalHistory
after delete
as
begin
    insert into AuditLog (
        HistoryId,
        PatientId,
        Operation,
        OldCondition,
        NewCondition,
        OldTreatment,
        NewTreatment,
        UserName,
        ChangeTimestamp
    )
    select 
        d.HistoryId,
        d.PatientId,
        'delete',
        d.Condition as OldCondition,
        NULL as NewCondition,
        d.Treatment as OldTreatment,
        NULL as NewTreatment,
        SYSTEM_USER,
        GETDATE()
    from 
        deleted d
end

delete from MedicalHistory
where HistoryId = 2

select * from MedicalHistory
select * from AuditLog

--3.Banking application: 
--  In a banking application, you could create a trigger that updates the customer's credit score when a new transaction is made.
--  The trigger would be fired automatically when a new transaction is inserted into the transactions table, and
--  it would execute the credit score calculation code to update the customer's credit score based on the transaction amount 
--  and type.

--CreditscoreLog-table
create table CreditscoreLog (
    LogId int Identity(1,1) Primary key,
    CustomerId int,
    TransactionAmount decimal(10, 2),
    TransactionType varchar(50),
    OldCreditScore int,
    NewCreditScore int,
	LogDateTime datetime default GETDATE()
)

select * from CreditscoreLog

create trigger trg_AfterTransactionInsert
on Transactions
after insert
as
begin
    insert into CreditscoreLog (
        CustomerId,
        TransactionAmount,
        TransactionType,
        OldCreditScore,
        NewCreditScore,
        LogDateTime
    )
    select
        a.CustomerId,
        i.Amount,
        i.TransactionType,
        c.CreditScore as OldCreditScore,
        case 
            when i.TransactionType = 'Credit' then c.CreditScore + i.Amount * 0.1
            when i.TransactionType = 'Debit' then c.CreditScore - i.Amount * 0.1
        end as NewCreditScore,
        GETDATE()
    from inserted i, Accounts a, Customers c
	where i.AccountId = a.AccountId and 
		  a.CustomerId = c.CustomerId

	update c
    set
        CreditScore =  case 
							when i.TransactionType = 'Credit' then c.CreditScore + i.Amount * 0.1
							when i.TransactionType = 'Debit' then c.CreditScore - i.Amount * 0.1
						end
    from Customers c, Accounts a, inserted i 
	where c.CustomerId = a.CustomerId and
		  a.AccountId = i.AccountId
end


insert into Transactions (AccountId, TransactionType, Amount, TransactionDate)
values (1, 'Credit', 1000.00, '2023-07-01'),
	   (2, 'Debit', 500.00, '2023-07-02')


select * from Customers
select * from Transactions
select * from CreditscoreLog

--4.Social media application: 
--  In a social media application, you could create a trigger that logs the user activity and generates personalized recommendations
--  based on the activity. The trigger would be fired automatically when an insert or update operation is performed on the activity
--  log table, and it would execute the recommendation generation code to suggest relevant content or connections to the user.

--Recommendations-table
create table Recommendations 
(
    RecommendationId int Identity(1,1) Primary key,
    UserId int foreign key references Users(UserId),
    RecommendationText text,
    RecommendationDate datetime default GETDATE()
)

select * from Recommendations

create trigger trg_AfterActivityInsertOrUpdate
on ActivityLog
after insert, update
as
begin
    insert into Recommendations (
        UserId,
        RecommendationText,
        RecommendationDate
    )
    select
        i.UserId,
        case 
            when i.ActivityType = 'Post' then 'Based on your recent post, check out these new posts!'
            when i.ActivityType = 'Comment' then 'Based on your recent comment, engage with these discussions!'
            when i.ActivityType = 'Like' then 'Based on your recent like, here are some posts you might like!'
            else 'Explore new content and connections!'
        end as RecommendationText,
        getdate() as RecommendationDate
    from inserted i
end


insert into ActivityLog (UserId, ActivityType, ActivityDate, Details)
values (1, 'Like', '2023-07-03 12:00', 'Liked a post')

select * from ActivityLog
select * from Recommendations

--5.Travel booking application: 
--  In a travel booking application, you could create a trigger that updates the flight or hotel availability when a booking is made.
--  The trigger would be fired automatically when a new booking is inserted into the bookings table, and it would execute the 
--  availability update code to adjust the availability based on the booking details.

create  or alter trigger trg_AfterBookingInsert
on Bookings
after insert
as
begin
    update Flights
    set Availability = Availability - 1
    from Flights f, inserted i 
	where f.FlightId = i.TypeId and
		  i.BookingType = 'Flight'
    
	update Hotels
    set Availability = Availability - 1
    from Hotels h, inserted i
	where h.HotelId = i.TypeId and
		  i.BookingType = 'Hotel'
end


insert into Bookings (CustomerId, BookingDate, BookingType, TypeId)
values (3, '2024-08-25', 'Flight', 2)

insert into Bookings (CustomerId, BookingDate, BookingType, TypeId)
values (2, '2024-01-09', 'Hotel', 2);


select * from Bookings
select * from Flights
select * from Hotels
