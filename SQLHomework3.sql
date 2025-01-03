--1--
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

into #TempZodiac
from dbo.Customers

-- Step 2: დავთვალოთ ჩინური ზოდიაქოს მიხედვით (AnimalsYear) --
select 
    AnimalsYear,
    count(*) as Count
from #TempZodiac
group by AnimalsYear
order by Count desc

-- Step 3: დავთავლოთ ზოდიაქოს ნიშნებით (ZodiacSign) --
select 
    ZodiacSign,
    count(*) as Count
from #TempZodiac
group by ZodiacSign
order by Count desc

-- Step 4: ორივე ერთად --
select 
    AnimalsYear,
    ZodiacSign,
    count(*) as Count
from #TempZodiac
group by AnimalsYear, ZodiacSign
order by Count desc

drop table #TempZodiac


--2--
declare @Terms int = 20;

create table #FibonacciTable (
    Position int not null,
    Value int not null)

declare @Index int = 1;

while @Index <= @Terms
begin
    insert into #FibonacciTable (Position, Value)
    select 
        @Index,
        cast((power((1 + sqrt(5)) / 2, @Index) - power((1 - sqrt(5)) / 2, @Index)) / sqrt(5) as int)

    set @Index = @Index + 1;
end

select * from #FibonacciTable

drop table #FibonacciTable


--3--
declare @number int = 12152
declare @count int = 0
declare @divisor int = 1

while @divisor <= @number
begin
    if @number % @divisor = 0
	begin
		print @divisor
        set @count = @count + 1
	end

    set @divisor = @divisor + 1
end

print 'Total divisors: ' + cast(@count as varchar)


--4--
declare @low money = 10000; -- Change this value as desired
declare @high money = 30000; -- Change this value as desired

create table #SegmentedCustomers (
    CustomerID int not null,
    TotalAmount money not null,
    Segment nvarchar(6) not null
)

insert into #SegmentedCustomers (CustomerID, TotalAmount, Segment)
select 
    CustomerID,
    sum(Amount) as TotalAmount,
    case 
        when sum(Amount) < @low then 'Low'
        when sum(Amount) between @low and @high then 'Medium'
        else 'High'
    end as Segment
from Deposits
group by CustomerID

select * from #SegmentedCustomers

declare @CustomerID int = 69

select * 
from #SegmentedCustomers
where CustomerID = @CustomerID

drop table #SegmentedCustomers


--5--
Use DB_BANK

CREATE TABLE [loan].[Schedules]
(
    Id int not null identity (1,1),
    LoanId int not null FOREIGN KEY
        REFERENCES [loan].[loans] ([LoanID]),
    Payment Money not null,
    PaymentDate date not null

)

declare @LoanID int = 952
declare @Amount money
declare @InterestRate decimal(4,2)
declare @StartDate datetime
declare @EndDate datetime
declare @PaymentDay int

select 
    @Amount = Amount,
    @InterestRate = InterestRate,
    @StartDate = StartDate,
    @EndDate = EndDate,
    @PaymentDay = PaymentDay
from loan.Loans
where LoanID = @LoanID

declare @TermMonths int = datediff(month, @StartDate, @EndDate) + 1
declare @MonthlyPayment money = (@Amount + @InterestRate) / @TermMonths
declare @CurrentMonth int = 1
declare @PaymentDate date

while @CurrentMonth <= @TermMonths
begin
    set @PaymentDate = dateadd(month, @CurrentMonth - 1, dateadd(day, @PaymentDay - day(@StartDate), @StartDate))

    insert into loan.Schedules (LoanId, Payment, PaymentDate)
    values (@LoanID, @MonthlyPayment, @PaymentDate)

    set @CurrentMonth = @CurrentMonth + 1
end

select * from loan.Schedules
where LoanId = @LoanID


--6--
with EligibleCustomers as (
    select 
        d.CustomerID,
        sum(d.Amount) as TotalDeposit,
        sum(l.Amount) as TotalLoan
    from Deposits d
    inner join loan.Loans l
        on d.CustomerID = l.CustomerID
    where d.Amount > 10000 and l.Amount > 10000
    group by d.CustomerID
),

RankedCustomers as (
    select 
        CustomerID,
        TotalDeposit,
        TotalLoan,
        row_number() over (order by TotalDeposit desc, TotalLoan desc) as RowNum
    from EligibleCustomers
)

select 
    CustomerID,
    TotalDeposit,
    TotalLoan
from RankedCustomers
where RowNum = 17
