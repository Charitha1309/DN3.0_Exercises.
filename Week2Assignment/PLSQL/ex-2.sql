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
CREATE OR REPLACE PROCEDURE SafeTransferFunds(
  sourceAcc IN Accounts.AccountID%TYPE,
  destAcc IN Accounts.AccountID%TYPE,
  transferAmt IN Accounts.Balance%TYPE
)
IS
  InsufficientFunds EXCEPTION;
  SourceBalance Accounts.Balance%TYPE;
BEGIN
  -- Retrieve balance from the source account
  SELECT Balance INTO SourceBalance FROM Accounts WHERE AccountID = sourceAcc;
  
  -- Check if there are sufficient funds
  IF SourceBalance < transferAmt THEN
    RAISE InsufficientFunds;
  END IF;

  -- The actual fund transfer logic should go here (not included in original code)

  DBMS_OUTPUT.PUT_LINE('*** TRANSFER DONE SUCCESSFULLY ***');
  
EXCEPTION
  WHEN InsufficientFunds THEN 
    DBMS_OUTPUT.PUT_LINE('*** INSUFFICIENT AMOUNT ***');
END;
/
BEGIN
  SafeTransferFunds(sourceAcc => 1, destAcc => 2, transferAmt => 500);
END;
/



--Scenario:2
CREATE OR REPLACE PROCEDURE UpdateEmployeeSalary(
  empId IN Employees.EmployeeID%TYPE,
  salaryIncrease IN NUMBER
)
IS
  EmployeeNotFound EXCEPTION;
  numEmployees NUMBER;
BEGIN
  SELECT count(*) INTO numEmployees FROM Employees WHERE EmployeeID = empId;
  
  IF numEmployees < 1 THEN
    RAISE EmployeeNotFound;
  END IF;
  
  UPDATE Employees
  SET Salary = Salary + (Salary * salaryIncrease * 0.01)
  WHERE EmployeeID = empId;
  
  DBMS_OUTPUT.PUT_LINE('Salary Updated Successfully');
  
EXCEPTION
  WHEN EmployeeNotFound THEN
    DBMS_OUTPUT.PUT_LINE('Invalid Employee ID');
END;
/
BEGIN
  UpdateEmployeeSalary(empId => 4, salaryIncrease => 5);
END;
/






--Scenario:3

CREATE OR REPLACE PROCEDURE AddNewCustomer(
    customerID IN NUMBER,
    customerName IN VARCHAR2,
    customerDOB IN DATE,
    customerBalance IN NUMBER,
    customerLastModified IN DATE
)
IS
  CustomerExists EXCEPTION;
  customerCount NUMBER;
BEGIN
  -- Check if a customer with the given ID already exists
  SELECT count(*) INTO customerCount FROM Customers WHERE CustomerID = customerID;
  
  IF customerCount > 0 THEN
    RAISE CustomerExists;
  END IF;
  
  -- Insert the new customer record
  INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
  VALUES (customerID, customerName, customerDOB, customerBalance, customerLastModified);
  
  DBMS_OUTPUT.PUT_LINE('Customer registered successfully');
  
EXCEPTION
  WHEN CustomerExists THEN
    DBMS_OUTPUT.PUT_LINE('Error: Customer ID already exists');
END;
/
BEGIN
  AddNewCustomer(
    customerID => 1,
    customerName => 'sricharitha',
    customerDOB => SYSDATE,
    customerBalance => 9000,
    customerLastModified => SYSDATE
  );
END;
/





















