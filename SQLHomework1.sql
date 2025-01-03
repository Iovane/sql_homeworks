use [DB_BANK]

--Task 1--
select * from [dbo].[Accounts] 
	where AccountID > 5 and AccountID < 100

select * from [dbo].[AccountTypes] 
	where AccountTypeID = 5 or AccountTypeID = 4

select * from [dbo].[AccountTypes] 
	where AccountTypeID != 5 or AccountTypeID = 4

select * from [dbo].[AccountTypes] 
	where AccountTypeID = 5 or AccountTypeID <> 4

select * from [dbo].[AccountTypes] 
	where AccountTypeID = 5 and not AccountTypeID = 4


--Task 2--
--მოგვაქვს ისეთი დეპოზიტები რომლებიც არის (30 000.00, 55 000.00) შუალედში და ამასთან--
--მათი საპროცენტო განაკვეთი ტოლია 6-ის ან მეტია ან ტოლი 8-ზე--
select * from [dbo].[Deposits] 
where (Amount > 30000.00 and Amount < 55000.00) and (InterestRate = 6 or not InterestRate < 8)


--Task 3--
select * from [dbo].[Deposits] 
	where InterestRate in (5, 7, 8)

select * from [dbo].[Deposits] 
	where InterestRate not in (5, 7, 8)

select * from [dbo].[Deposits] 
	where InterestRate between 7 and 9


--Task 4--
select * from [loan].[Loans] 
	where LoanID in (
		select AccountID
		from [loan].[LoanAccounts]
	)


--Task 5--
select * from [dbo].[Customers]
	where (CustomerFirstName like '[A-C]____%')
	and CustomerID in (
		select CustomerID
		from [dbo].[Deposits]
	) order by CustomerID DESC


--Task 6--
select distinct CustomerFirstName, CustomerLastName
from dbo.Customers


--Task 7--
select 
	CustomerFirstName,
	CustomerLastName,
    BirthDate,
    
    case 
        (year(BirthDate) % 12)
        when 0 then 'Monkey'
        when 1 then 'Rooster'
        when 2 then 'Dog'
        when 3 then 'Pig'
        when 4 then 'Rat'
        when 5 then 'Ox'
        when 6 then 'Tiger'
        when 7 then 'Rabbit'
        when 8 then 'Dragon'
        when 9 then 'Snake'
        when 10 then 'Horse'
        when 11 then 'Goat'
    end as AnimalsYear,
    
    case
        when month(BirthDate) = 1 and day(BirthDate) >= 20 or month(BirthDate) = 2 and day(BirthDate) <= 18 then 'Aquarius'
        when month(BirthDate) = 2 and day(BirthDate) >= 19 or month(BirthDate) = 3 and day(BirthDate) <= 20 then 'Pisces'
        when month(BirthDate) = 3 and day(BirthDate) >= 21 or month(BirthDate) = 4 and day(BirthDate) <= 19 then 'Aries'
        when month(BirthDate) = 4 and day(BirthDate) >= 20 or month(BirthDate) = 5 and day(BirthDate) <= 20 then 'Taurus'
        when month(BirthDate) = 5 and day(BirthDate) >= 21 or month(BirthDate) = 6 and day(BirthDate) <= 20 then 'Gemini'
        when month(BirthDate) = 6 and day(BirthDate) >= 21 or month(BirthDate) = 7 and day(BirthDate) <= 22 then 'Cancer'
        when month(BirthDate) = 7 and day(BirthDate) >= 23 or month(BirthDate) = 8 and day(BirthDate) <= 22 then 'Leo'
        when month(BirthDate) = 8 and day(BirthDate) >= 23 or month(BirthDate) = 9 and day(BirthDate) <= 22 then 'Virgo'
        when month(BirthDate) = 9 and day(BirthDate) >= 23 or month(BirthDate) = 10 and day(BirthDate) <= 22 then 'Libra'
        when month(BirthDate) = 10 and day(BirthDate) >= 23 or month(BirthDate) = 11 and day(BirthDate) <= 21 then 'Scorpio'
        when month(BirthDate) = 11 and day(BirthDate) >= 22 or month(BirthDate) = 12 and day(BirthDate) <= 21 then 'Sagittarius'
        when month(BirthDate) = 12 and day(BirthDate) >= 22 or month(BirthDate) = 1 and day(BirthDate) <= 19 then 'Capricorn'
    end as ZodiacSign

from dbo.Customers