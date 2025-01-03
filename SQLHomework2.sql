use DB_BANK

--1--
select * from loan.loans as L
join dbo.Deposits as D on L.CustomerID != D.CustomerID --თითოეულ ჩანაწერს Loans თეიბლიდან მიაბა სათითაოდ ყველა ჩანაწერი სადაც Loans-ის CustomerID არ უდრის Deposits-ის CustomerID-ს--


--2--
select T.TransactionID,
    C1.CustomerFirstName as DebitOwnerFirstName,
    C1.CustomerLastName as DebitOwnerLastName,
    C2.CustomerFirstName as CreditOwnerFirstName,
    C2.CustomerLastName as CreditOwnerLastName

from Transactions as T
join dbo.Accounts as Debit on T.DebitAccountID = Debit.AccountID

join dbo.Customers as C1 on Debit.CustomerID = C1.CustomerID

join dbo.Accounts as Credit on T.CreditAccountID = Credit.AccountID

join dbo.Customers as C2 on Credit.CustomerID = C2.CustomerID


--3--
select * from dbo.Customers as C
left join loan.Loans as L on C.CustomerID = L.CustomerID
left join dbo.Deposits as D on C.CustomerID = D.CustomerID
where (L.CustomerID is not null and D.CustomerID is null) 
	  or 
	  (L.CustomerID is null and D.CustomerID is not null)


--4--
select LoanID, 
	   CustomerID,
	   Amount,
	   Currency,
	   coalesce(Purpose, 'Without') as Purpose 
from loan.Loans


--5--
select CustomerID, CustomerFirstName, SUBSTRING(Phone, 1, 5) as Phone,
    left(EmailAddress, CHARINDEX('@', EmailAddress) - 1) as Email, 
    case 
        when LEN(CustomerFirstName) <= 10 then DATEDIFF(MONTH, BirthDate, GETDATE()) 
    end as AgeInMonths
from 
    dbo.Customers


 --6--
declare @futuredate DATE = DATEADD(day, 18000, '2001-12-31')
select 
    @futuredate as FutureDate, 
    DATENAME(WEEKDAY, @futuredate) as DayOfWeek;


--7--
select *, DATEDIFF(DAY, StartDate, EndDate) as LoanDealine
from loan.Loans


--8--
declare @name1 varchar(255) = 'Diego Armando Maradona'
declare @name2 varchar(255) = 'Pablo Diego José Francisco de Paula Juan Nepomuceno María de los Remedios Cipriano de la Santísima Trinidad Ruiz y Picasso'

declare @reversedName varchar(255) = reverse(@name2)

select reverse(left(@reversedName, CHARINDEX(' ', @reversedName) - 1)) as name


--9--
select State, COUNT(*) AS NumberOfUsers
from 
    dbo.Customers
group by State


--10--
declare @USDToGEL money = 2.81
declare @EURToGEL money = 2.95
declare @GBPToGEL money = 3.59

select CustomerID,COUNT(*) AS LoanQuantity,
    MIN(CASE
            when Currency = 'USD' then Amount * @USDToGEL
            when Currency = 'EUR' then Amount * @EURToGEL
			when Currency = 'GPB' then Amount * @GBPToGEL
        end) AS MinLoanAmountInGEL,
    MAX(case 
            when Currency = 'USD' then Amount * @USDToGEL
            when Currency = 'EUR' then Amount * @EURToGEL
			when Currency = 'GPB' then Amount * @GBPToGEL
        end) AS MaxLoanAmountInGEL
from 
    loan.Loans
group by CustomerID
order by CustomerID


--11--
select DebitAccountID as AccountID, SUM(Amount) as TotalDifference
from(   
		select DebitAccountID, Amount 
        from Transactions 
        where TransactionTypeID = 1
        
        union all
        
        select DebitAccountID, Amount * -1 as Amount
        from Transactions
        where TransactionTypeID = 2

    ) as Combined
group by DebitAccountID
order by DebitAccountID


--12--
select CustomerAddress, COUNT(*) as NumberOfUsers
from dbo.Customers
group by CustomerAddress


--13--
select CustomerID, SUM(TotalDebt) as TotalDebt
from (
        select A.CustomerID, OD.OverDraftAmount as TotalDebt
        from dbo.OverDrafts as OD
        join dbo.Accounts as A on OD.AccountID = A.AccountID
        
        union all
        
        select L.CustomerID, L.Amount as TotalDebt
        from loan.Loans as L
        
    ) as CombinedDebts
group by CustomerID

having SUM(TotalDebt) > 50000
order by CustomerID


--14--
select distinct L.CustomerID
from loan.Loans L

except

select distinct D.CustomerID
from dbo.Deposits D