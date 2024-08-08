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
CREATE OR REPLACE PROCEDURE ProcessMonthlyInterest IS
  CURSOR savingsCursor IS
    SELECT AccountID, CustomerID, Balance
    FROM Accounts
    WHERE AccountType = 'Savings'
      AND (SYSDATE - LastModified) >= 30
      FOR UPDATE;
  
  accID Accounts.AccountID%TYPE;
  custID Accounts.CustomerID%TYPE;
  accBalance Accounts.Balance%TYPE;
BEGIN
  OPEN savingsCursor;
  
  LOOP
    FETCH savingsCursor INTO accID, custID, accBalance;
    EXIT WHEN savingsCursor%NOTFOUND;
    
    UPDATE Accounts
    SET Balance = accBalance * 1.01,
        LastModified = SYSDATE
    WHERE AccountID = accID;
    
    DBMS_OUTPUT.PUT_LINE('AccountID: ' || accID || 
                         ', CustomerID: ' || custID || 
                         ', New Balance: ' || accBalance * 1.01);
  END LOOP;
  
  CLOSE savingsCursor;
  
  COMMIT;
  
  DBMS_OUTPUT.PUT_LINE('Monthly interest of 1% applied to all eligible savings accounts.');
END;
/

BEGIN
  ProcessMonthlyInterest;
END;
/





--Scenario:2
CREATE OR REPLACE PROCEDURE UpdateEmployeeBonus(
    deptName IN Employees.Department%TYPE,
    bonusPercentage IN NUMBER
)
IS
  -- Define a variable to hold the number of employees updated
  updatedCount NUMBER;
BEGIN
  -- Update the salary of employees in the specified department by adding the bonus
  UPDATE Employees
  SET Salary = Salary + (Salary * bonusPercentage / 100)
  WHERE Department = deptName;
  
  -- Get the count of updated rows
  updatedCount := SQL%ROWCOUNT;
  
  DBMS_OUTPUT.PUT_LINE(updatedCount || ' employees in department ' || deptName || 
                       ' received a bonus of ' || bonusPercentage || '%');
  
  -- Commit the transaction
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Handle any unexpected errors
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
BEGIN
  UpdateEmployeeBonus(deptName => 'HR', bonusPercentage => 10);
END;
/




--Scenario:3
CREATE OR REPLACE PROCEDURE TransferFunds(
    src_acc_id IN Accounts.AccountID%TYPE,
    tgt_acc_id IN Accounts.AccountID%TYPE,
    amt IN NUMBER
) IS
    src_balance Accounts.Balance%TYPE;
BEGIN
    -- Retrieve the balance of the source account
    SELECT Balance
    INTO src_balance
    FROM Accounts
    WHERE AccountID = src_acc_id
    FOR UPDATE;

    -- Check if the source account has sufficient balance
    IF src_balance < amt THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient balance in source account.');
    END IF;

    -- Deduct the amount from the source account
    UPDATE Accounts
    SET Balance = Balance - amt
    WHERE AccountID = src_acc_id;

    -- Add the amount to the target account
    UPDATE Accounts
    SET Balance = Balance + amt
    WHERE AccountID = tgt_acc_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Funds transferred successfully: ' ||
                         'From AccountID ' || src_acc_id || 
                         ' To AccountID ' || tgt_acc_id ||
                         ' Amount ' || amt);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('One or both account IDs do not exist.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
BEGIN
  TransferFunds(src_acc_id => 1, 
                tgt_acc_id => 2, 
                amt => 500);
END;
/






















