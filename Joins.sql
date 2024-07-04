create database Practice

--Joins:
--1.E-commerce application: 
--  In an e-commerce application, you could use a join to retrieve the order details and customer information for a specific order.
--  For example, you could join the orders table with the customers table on the customer ID 
--  to get the customer's name, address, and contact information for the order.

--Customers-table
create table Customers
(
	CustomerId int Identity(1,1) Primary key,
	Name varchar(50),
	Email varchar(100),
	Address varchar(100),
	MobileNo varchar(15)
)

alter table Customers
add CreditScore int default 0;

update Customers
set CreditScore = 0 

alter table Customers
add OrderCount int default 0;

update Customers
set OrderCount = 0 

select * from Customers

insert into Customers (Name,Email,Address,MobileNo)
values 
('krish','krish@gmail.com','BTM 1st stage,Bangalore,Karnataka','8765894563'),
('smith','smith@gmail.com','1/1A,kadapa,AP','9765894565'),
('ram','ram@gmail.com','Maratalli,Bangalore,Karnataka','6765894562'),
('kavitha','kavitha@gmail.com','HSR,Bangalore,Karnataka','7765894565')

--Orders-table
create table Orders
(
	OrderId int Identity(1,1) Primary key,
	CustomerId int foreign key references Customers(CustomerId),
	OrderDate date,
	TotalPrice decimal(10,2),
	Status varchar(50)
)

select * from Orders

insert into Orders (CustomerId,OrderDate,TotalPrice,Status)
values 
(1,'2023-04-15',2000,'shipped'),
(2,'2024-06-25',5000,'pending'),
(3,'2023-05-01',15000,'shipped'),
(4,'2023-05-01',2000,'shipped')


select o.OrderId,
	   o.OrderDate,
	   o.TotalPrice,
	   o.Status,
	   c.CustomerId,
	   c.Name,
	   c.Email,
	   c.Address,
	   c.MobileNo
from Customers c,Orders o
where c.CustomerId = o.CustomerId and
	  o.OrderId = 1

--2.Healthcare application: 
--  In a healthcare application, you could use a join to retrieve the patient information and medical history 
--  for a specific appointment. For example, you could join the appointments table with the patients table and 
--  the medical history table on the patient ID to get the patient's name, age, medical conditions, and previous treatments.

--Patients-table
 create table Patients 
 (
    PatientId int Identity(1,1) Primary key,
	Name varchar(50),
    Age int,
    Gender varchar(10),
    Address varchar(100),
    MobileNo varchar(15)
)

select * from Patients

insert into Patients (Name,Age,Gender,Address,MobileNo)
values 
('smith',22,'Male','1/1A,kadapa,AP','9765894565'),
('kavitha',23,'Female','403D,amaravathi,AP','66765894563'),
('sri',28,'Male','Maratalli,Bangalore,KA','87765894564')

--Appointments-table
create table Appointments
(
	AppointmentId int Identity(1,1) Primary key,
	PatientId int foreign key references Patients(PatientId),
    AppointmentDate datetime,
    DoctorName varchar(50),
    notes text
)

select * from Appointments

insert into Appointments (PatientId,AppointmentDate,DoctorName,notes)
values 
(1,'2023-06-15 12:00','Dr.Adams','Regular check-up'),
(3,'2023-07-25 11:00','Dr.Brown','Follow-up visit'),
(2,'2023-08-05 10:00','Dr.Brown','Regular check-up')

--MedicalHistory-table
create table MedicalHistory 
(
    HistoryId int Identity(1,1) Primary key,
	PatientId int foreign key references Patients(PatientId),
    Condition  varchar(100),
    Treatment varchar(100),
    DiagnosisDate date
)

select * from MedicalHistory

insert into MedicalHistory (PatientId,Condition,Treatment,DiagnosisDate)
values
(1,'Hypertension','Medication','2020-05-01'),
(2,'Asthma','Inhaler','2018-11-20')

update MedicalHistory set PatientId = 3 where HistoryId=2


select a.AppointmentId,
	   a.AppointmentDate,
	   a.DoctorName,
	   a.notes,
	   p.PatientId,
	   p.Name,
	   p.Age,
	   p.Gender,
	   p.MobileNo,
	   p.Address,
	   m.Condition,
	   m.Treatment,
	   m.DiagnosisDate
from Appointments a,Patients p, MedicalHistory m
where p.PatientId = a.PatientId and
	  p.PatientId = m.PatientId and
	  a.AppointmentId = 1

--3.Banking application: 
--  In a banking application, you could use a join to retrieve the account details and transaction history for a specific customer.
--  For example, you could join the customers table with the accounts table and the transactions table on the account ID 
--  to get the account balance, transaction dates, and amounts for the customer's account.

--Accounts-table
create table Accounts
(
	AccountId int Identity(1,1) Primary key,
	CustomerId int foreign key references Customers(CustomerId),
	AccountType varchar(50),
    Balance decimal(10, 2)
)

select * from Accounts

insert into Accounts (CustomerId,AccountType,Balance)
values
(1,'Checking',1000),
(2,'Savings',2000),
(3,'Checking',2000),
(4,'Savings',4000)

--Transactions-table
create table Transactions
(
	TransactionId int Identity(1,1) Primary key,
	AccountId int foreign key references Accounts(AccountId),
	TransactionType varchar(50),
    Amount decimal(10, 2),
	TransactionDate datetime
)

alter table Transactions
add RelatedAccountId int

select * from Transactions

insert into Transactions (AccountId,TransactionType,Amount,TransactionDate)
values 
(1,'Credit',1000.00,'2023-07-01 10:00'),
(2,'Debit',500.00,'2023-07-02 12:00')


select c.CustomerId,
	   c.Name,
	   c.Email,
	   c.Address,
	   c.MobileNo,
	   a.AccountId,
	   a.AccountType,
	   a.Balance,
	   t.TransactionId,
	   t.TransactionType,
	   t.Amount,
	   t.TransactionDate
from Customers c, Accounts a, Transactions t
where c.CustomerId = a.CustomerId and
      a.AccountId = t.AccountId and
	  c.CustomerId = 1

--4.Social media application: 
--  In a social media application, you could use a join to retrieve the user profiles and activity logs for a specific user. 
--  For example, you could join the users table with the activity log table on the user ID 
--  to get the user's name, age, location, and activity history.

--Users-table
create table Users
(
	UserId int Identity(1,1) Primary key,
	Name varchar(50),
	Age int,
	Location varchar(100),
	Email varchar(100)
)

select * from Users

insert into Users (Name,Age,Location,Email)
values 
('smith',25,'New York, USA','smith@gmail.com'),
('ram',30,'London, UK','ram@gmail.com')

--ActivityLog-table
create table ActivityLog
(
	ActivityId int Identity(1,1) Primary key,
	UserId int foreign key references Users(UserId),
	ActivityType varchar(50),
    ActivityDate datetime,
    Details varchar(max)
)

select * from ActivityLog

insert into ActivityLog (UserId,ActivityType,ActivityDate,Details)
values
(1,'Post','2023-06-03 09:00','Posted a new photo'),
(1,'Like','2023-05-02 10:00','Liked a post'),
(2,'Comment','2024-05-05 11:00','Commented on a post'),
(1,'Post','2024-06-05 20:00','Posted a new photo'),
(1,'Like','2024-05-02 12:00','Liked a post')


select u.UserId,
	   u.Name,
	   u.Age,
	   u.Location,
	   u.Email,
	   a.ActivityId,
	   a.ActivityType,
	   a.ActivityDate,
	   a.Details
from Users u, ActivityLog a
where u.UserId = a.UserId and
	  u.UserId = 2

--5.Travel booking application: 
--  In a travel booking application, you could use a join to retrieve the flight or hotel details and customer information 
--  for a specific booking. For example, you could join the bookings table with the flights table or the hotels table and 
--  the customers table on the booking ID to get the booking details, customer names, and contact information.

--Bookings-table
create table Bookings 
(
	BookingId int Identity(1,1) Primary key,
	CustomerId int foreign key references Customers(CustomerId),
	BookingDate datetime,
    BookingType varchar(10),
    TypeId int
)

select * from Bookings

insert into Bookings (CustomerId,BookingDate,BookingType,TypeId)
values 
(1,'2023-06-01 09:00','Flight',1),
(2,'2023-06-02 10:00','Hotel',1)

--Flights-table
create table Flights 
(
    FlightId int Identity(1,1) Primary key,
    FlightNumber varchar(20),
    DepartureAirport varchar(100),
    ArrivalAirport varchar(100),
    DepartureTime datetime,
    ArrivalTime datetime,
	Availability int
)

select * from Flights

insert into  Flights (FlightNumber, DepartureAirport, ArrivalAirport, DepartureTime, ArrivalTime, Availability)
values
('FL123', 'JFK', 'LAX', '2023-07-01 08:00:00', '2023-07-01 11:00:00', 100),
('FL456', 'LAX', 'ORD', '2023-07-02 09:00:00', '2023-07-02 12:00:00', 150)

alter table Flights
add Price decimal(10, 2);

update Flights
set DepartureAirport = 'New York'
where FlightId = 4

insert into Flights (FlightNumber, DepartureAirport, ArrivalAirport, DepartureTime, ArrivalTime, Availability, Price)
values
('FL456', 'LAX', 'ORD', '2023-07-02 09:00:00', '2023-07-02 12:00:00', 150, 380.00),
('FL789', 'JFK', 'SFO', '2023-07-01 10:00:00', '2023-07-01 13:00:00', 120, 320.00);

--Hotels-table
create table Hotels 
(
    HotelId int Identity(1,1) Primary key,
    HotelName varchar(100),
    Location varchar(100),
    CheckIn datetime,
    CheckOut datetime,
	Availability int
)

select * from Hotels

insert into Hotels (HotelName, Location, CheckIn, CheckOut, Availability)
values
('Grand Hotel', 'New York', '2023-07-01 15:00:00', '2023-07-05 12:00:00', 50),
('City Inn', 'Los Angeles', '2023-07-02 15:00:00', '2023-07-06 12:00:00', 75);


alter table Hotels
add Price decimal(10, 2);

update Hotels
set Price = 250
where HotelId = 1

insert into Hotels (HotelName, Location, CheckIn, CheckOut, Availability, Price)
values
('Ocean View Resort', 'Los Angeles', '2023-07-01 14:00:00', '2023-07-05 10:00:00', 60, 200.00),
('Downtown Suites', 'New York', '2023-07-01 16:00:00', '2023-07-05 12:00:00', 40, 180.00);


select c.CustomerId,
	   c.Name,
	   c.Email,
	   c.MobileNo,
	   b.BookingId,
	   b.BookingDate,
	   f.FlightNumber,
	   f.DepartureAirport,
	   f.ArrivalAirport,
	   f.DepartureTime,
	   f.ArrivalTime
from Bookings b, Customers c, Flights f
where b.CustomerId = c.CustomerId and
	  b.TypeId = f.FlightId and
	  b.BookingId = 1 and
	  b.BookingType = 'Flight'


select c.CustomerId,
	   c.Name,
	   c.Email,
	   c.MobileNo,
	   b.BookingId,
	   b.BookingDate,
	   h.HotelName,
	   h.Location,
	   h.CheckIn,
	   h.CheckOut
from Bookings b, Customers c, Hotels h
where b.CustomerId = c.CustomerId and
	  b.TypeId = h.HotelId and
	  b.BookingId = 2 and
	  b.BookingType = 'Hotel'