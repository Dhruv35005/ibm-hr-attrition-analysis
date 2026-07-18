CREATE TABLE demographics (
    EmployeeID     INTEGER PRIMARY KEY,
    Age            INTEGER,
    Gender         TEXT,
    Department     TEXT,
    JobRole        TEXT,
    Education      INTEGER,   -- 1=Below College ... 5=Doctor
    MaritalStatus  TEXT
);


CREATE TABLE employment (
    EmployeeID              INTEGER PRIMARY KEY,
    BusinessTravel          TEXT,
    OverTime                TEXT,   -- Yes/No
    YearsAtCompany          INTEGER,
    YearsInCurrentRole      INTEGER,
    TotalWorkingYears       INTEGER,
    YearsSinceLastPromotion INTEGER,
    FOREIGN KEY (EmployeeID) REFERENCES demographics(EmployeeID)
);

CREATE TABLE compensation (
    EmployeeID         INTEGER PRIMARY KEY,
    MonthlyIncome      INTEGER,
    PercentSalaryHike  INTEGER,
    StockOptionLevel   INTEGER,  -- 0-3
    FOREIGN KEY (EmployeeID) REFERENCES demographics(EmployeeID)
);


CREATE TABLE satisfaction (
    EmployeeID               INTEGER PRIMARY KEY,
    JobSatisfaction          INTEGER,  -- 1-4
    EnvironmentSatisfaction  INTEGER,  -- 1-4
    WorkLifeBalance          INTEGER,  -- 1-4
    JobInvolvement           INTEGER,  -- 1-4
    PerformanceRating        INTEGER,  -- 1-4
    FOREIGN KEY (EmployeeID) REFERENCES demographics(EmployeeID)
);


CREATE TABLE attrition (
    EmployeeID  INTEGER PRIMARY KEY,
    Attrition   TEXT,   -- Yes/No
    FOREIGN KEY (EmployeeID) REFERENCES demographics(EmployeeID)
);