BEGIN
  -- Create a Customers Table
  EXECUTE IMMEDIATE 'CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    DOB DATE,
    Balance NUMBER,
    LastModified DATE
  )';

  -- Create a Accounts Table
  EXECUTE IMMEDIATE 'CREATE TABLE Accounts (
    AccountID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    AccountType VARCHAR2(20),
    Balance NUMBER,
    LastModified DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create a Transactions Table
  EXECUTE IMMEDIATE 'CREATE TABLE Transactions (
    TransactionID NUMBER PRIMARY KEY,
    AccountID NUMBER,
    TransactionDate DATE,
    Amount NUMBER,
    TransactionType VARCHAR2(10),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
  )';

  -- Create a Loans Table
  EXECUTE IMMEDIATE 'CREATE TABLE Loans (
    LoanID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    LoanAmount NUMBER,
    InterestRate NUMBER,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
  )';

  -- Create a Employees Table
  EXECUTE IMMEDIATE 'CREATE TABLE Employees (
    EmployeeID NUMBER PRIMARY KEY,
    Name VARCHAR2(100),
    Position VARCHAR2(50),
    Salary NUMBER,
    Department VARCHAR2(50),
    HireDate DATE
  )';
END;
/
BEGIN
  -- Insert into Customers table
  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (1, 'John Doe', TO_DATE('1985-05-15', 'YYYY-MM-DD'), 1000, SYSDATE);

  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (2, 'Jane Smith', TO_DATE('1990-07-20', 'YYYY-MM-DD'), 1500, SYSDATE);

  -- Insert into Accounts table
  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (1, 1, 'Savings', 1000, SYSDATE);

  INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
  VALUES (2, 2, 'Checking', 1500, SYSDATE);

  -- Insert into Transactions table
  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (1, 1, SYSDATE, 200, 'Deposit');

  INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
  VALUES (2, 2, SYSDATE, 300, 'Withdrawal');

  -- Insert into Loans table
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (1, 1, 5000, 5, SYSDATE, ADD_MONTHS(SYSDATE, 60));
  INSERT INTO Loans (LoanID, CustomerID, LoanAmount, InterestRate, StartDate, EndDate)
  VALUES (2, 2, 5000, 10, SYSDATE, ADD_MONTHS(SYSDATE, 60));

  -- Insert into Employees table
  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (1, 'Alice Johnson', 'Manager', 70000, 'HR', TO_DATE('2015-06-15', 'YYYY-MM-DD'));

  INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
  VALUES (2, 'Bob Brown', 'Developer', 60000, 'IT', TO_DATE('2017-03-20', 'YYYY-MM-DD'));
END;
/
--------------------------------------------------------------------

----Scenario-1
CREATE OR REPLACE FUNCTION CalculateAge(
  birthDate IN DATE
)
RETURN NUMBER
IS 
  currentAge NUMBER;
BEGIN
  currentAge := FLOOR(MONTHS_BETWEEN(SYSDATE, birthDate) / 12);
  RETURN currentAge;
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(CalculateAge(TO_DATE('1985-05-15', 'YYYY-MM-DD')));
END;
/



--Scenario:2
CREATE OR REPLACE FUNCTION CalculateMonthlyInstallment(
  principalAmount IN NUMBER,
  annualRate IN NUMBER,
  termYears IN NUMBER
)
RETURN NUMBER
IS 
  monthlyRate NUMBER;  
  totalPayments NUMBER;  
  monthlyInstallment NUMBER;  
BEGIN
  monthlyRate := (annualRate / 100) / 12;
  totalPayments := termYears * 12;
  monthlyInstallment := (principalAmount * monthlyRate * POWER(1 + monthlyRate, totalPayments)) / (POWER(1 + monthlyRate, totalPayments) - 1); 
  RETURN monthlyInstallment;
END;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE(CalculateMonthlyInstallment(principalAmount => 100000, annualRate => 2, termYears => 2));
END;
/



--Scenario:3
CREATE OR REPLACE FUNCTION HasSufficientBalance (
  acctID IN NUMBER,
  minBalance IN NUMBER
) RETURN BOOLEAN
IS
  currentBalance NUMBER;
BEGIN
  SELECT Balance INTO currentBalance 
  FROM Accounts 
  WHERE AccountID = acctID
  AND ROWNUM = 1;

  IF currentBalance >= minBalance THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END HasSufficientBalance;
/

BEGIN
   IF HasSufficientBalance(acctID => 1, minBalance => 10000) THEN
    DBMS_OUTPUT.PUT_LINE('Funds are sufficient for transfer.');
   ELSE
     DBMS_OUTPUT.PUT_LINE('Funds are insufficient.');
   END IF;
   
END;
/





















