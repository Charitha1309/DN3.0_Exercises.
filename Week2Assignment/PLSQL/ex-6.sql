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

DECLARE
  -- Define a record type to hold the transaction details
  TYPE TransactionRecType IS RECORD (
    v_CustomerID Customers.CustomerID%TYPE,
    v_CustomerName Customers.Name%TYPE,
    v_AccountID Accounts.AccountID%TYPE,
    v_TransactionDate Transactions.TransactionDate%TYPE,
    v_Amount Transactions.Amount%TYPE,
    v_TransactionType Transactions.TransactionType%TYPE
  );
  
  CURSOR cur_GenerateMonthlyStatements IS
    SELECT c.CustomerID, c.Name, a.AccountID, t.TransactionDate, t.Amount, t.TransactionType
    FROM Customers c
    JOIN Accounts a ON c.CustomerID = a.CustomerID
    JOIN Transactions t ON a.AccountID = t.AccountID
    WHERE EXTRACT(YEAR FROM t.TransactionDate) = EXTRACT(YEAR FROM SYSDATE)
      AND EXTRACT(MONTH FROM t.TransactionDate) = EXTRACT(MONTH FROM SYSDATE)
    ORDER BY c.CustomerID, t.TransactionDate;
  
  rec_Transaction TransactionRecType;

BEGIN
  OPEN cur_GenerateMonthlyStatements;
  LOOP
    FETCH cur_GenerateMonthlyStatements INTO rec_Transaction;
    EXIT WHEN cur_GenerateMonthlyStatements%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || rec_Transaction.v_CustomerID || ', Name: ' || rec_Transaction.v_CustomerName);
    DBMS_OUTPUT.PUT_LINE('Account ID: ' || rec_Transaction.v_AccountID);
    DBMS_OUTPUT.PUT_LINE('Transaction Date: ' || TO_CHAR(rec_Transaction.v_TransactionDate, 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Amount: ' || rec_Transaction.v_Amount || ', Type: ' || rec_Transaction.v_TransactionType);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
  END LOOP;
  CLOSE cur_GenerateMonthlyStatements;
END;
/


--Scenario:2
DECLARE
  CURSOR cur_ApplyAnnualFee IS 
    SELECT AccountID, Balance 
    FROM Accounts;
    
  v_AccountID Accounts.AccountID%TYPE;
  v_CurrentBalance Accounts.Balance%TYPE;

BEGIN
  OPEN cur_ApplyAnnualFee;
  
  LOOP
    FETCH cur_ApplyAnnualFee INTO v_AccountID, v_CurrentBalance;
    EXIT WHEN cur_ApplyAnnualFee%NOTFOUND;
    
    UPDATE Accounts
    SET Balance = v_CurrentBalance - 250 
    WHERE AccountID = v_AccountID;
    
    DBMS_OUTPUT.PUT_LINE('ACCOUNT ID: ' || v_AccountID || ' || Balance: ' || (v_CurrentBalance - 250));
    
  END LOOP;
  
  CLOSE cur_ApplyAnnualFee;
END;
/





--Scenario:3

CREATE OR REPLACE PACKAGE pkg_AccountOperations AS
  PROCEDURE proc_OpenAccount(
    p_AccountID IN NUMBER,
    p_CustomerID IN NUMBER,
    p_AccountType IN VARCHAR2,
    p_InitialBalance IN NUMBER
  );

  PROCEDURE proc_CloseAccount(
    p_AccountID IN NUMBER
  );

  FUNCTION func_GetTotalBalance(
    p_CustomerID IN NUMBER
  ) RETURN NUMBER;
END pkg_AccountOperations;
/

CREATE OR REPLACE PACKAGE BODY pkg_AccountOperations AS

  PROCEDURE proc_OpenAccount(
    p_AccountID IN NUMBER,
    p_CustomerID IN NUMBER,
    p_AccountType IN VARCHAR2,
    p_InitialBalance IN NUMBER
  ) IS
  BEGIN
    INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
    VALUES (p_AccountID, p_CustomerID, p_AccountType, p_InitialBalance, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Account opened successfully: ' || p_AccountID);
  END proc_OpenAccount;

  PROCEDURE proc_CloseAccount(
    p_AccountID IN NUMBER
  ) IS
  BEGIN
    DELETE FROM Transactions
    WHERE AccountID = p_AccountID;

    DELETE FROM Accounts
    WHERE AccountID = p_AccountID;

    DBMS_OUTPUT.PUT_LINE('Account closed successfully: ' || p_AccountID);
  END proc_CloseAccount;

  FUNCTION func_GetTotalBalance(
    p_CustomerID IN NUMBER
  ) RETURN NUMBER IS
    v_TotalBalance NUMBER;
  BEGIN
    SELECT SUM(Balance)
    INTO v_TotalBalance
    FROM Accounts
    WHERE CustomerID = p_CustomerID;

    RETURN v_TotalBalance;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0;
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Error calculating total balance.');
  END func_GetTotalBalance;

END pkg_AccountOperations;
/

BEGIN
  -- Test proc_OpenAccount
  pkg_AccountOperations.proc_OpenAccount(
    p_AccountID => 3, 
    p_CustomerID => 1, 
    p_AccountType => 'Checking', 
    p_InitialBalance => 2000
  );

  -- Test proc_CloseAccount
  pkg_AccountOperations.proc_CloseAccount(p_AccountID => 2);

  -- Test func_GetTotalBalance
  DECLARE
    v_TotalBalance NUMBER;
  BEGIN
    v_TotalBalance := pkg_AccountOperations.func_GetTotalBalance(1);
    DBMS_OUTPUT.PUT_LINE('Total balance for customer 1: ' || v_TotalBalance);
  END;
END;
/




























