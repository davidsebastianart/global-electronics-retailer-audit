-- Create a Data Mart table for analysis
CREATE OR REPLACE TABLE `PROJECT_ID.global_electronics_retailer.sales_data_mart` AS
SELECT 
    -- 1. Sales & Order Information
    s.`Order Number`,
    s.`Line Item`,
    s.`Order Date`,
    s.`Delivery Date`,
    s.Quantity,
    s.`Currency Code`,
    
    -- 2. Feature Engineering: Delivery Time & Sales Channel
    -- Calculates the difference in days between order and delivery
    DATE_DIFF(s.`Delivery Date`, s.`Order Date`, DAY) AS Delivery_Time_Days,
    
    -- Categorizes sales channel based on StoreKey mapping
    CASE 
        WHEN s.StoreKey = 0 THEN 'Online'
        ELSE 'In-Store'
    END AS Sales_Channel,

    -- 3. Product Information & Financial Metrics
    p.`Product Name`,
    p.Brand,
    p.Category,
    p.Subcategory,
    p.`Unit Cost USD`,
    p.`Unit Price USD`,
    
    -- Calculating Revenue, Cost, and Profit in standard USD
    (s.Quantity * p.`Unit Cost USD`) AS Total_Cost_USD,
    (s.Quantity * p.`Unit Price USD`) AS Total_Revenue_USD,
    (s.Quantity * p.`Unit Price USD`) - (s.Quantity * p.`Unit Cost USD`) AS Total_Profit_USD,

    -- 4. Customer Demographics
    c.Gender,
    c.Birthday,

    -- Calculating Customer Age at the time of the order
    DATE_DIFF(s.`Order Date`, c.Birthday, YEAR) AS Customer_Age,
    c.City AS Customer_City,
    c.State AS Customer_State,
    c.Country AS Customer_Country,
    c.Continent AS Customer_Continent,

    -- 5. Store Information
    st.Country AS Store_Country,
    st.State AS Store_State,
    st.`Square Meters` AS Store_Square_Meters,

    -- 6. Exchange Rate Data
    e.Exchange AS Exchange_Rate

FROM `PROJECT_ID.global_electronics_retailer.Sales` s
LEFT JOIN `PROJECT_ID.global_electronics_retailer.Products` p 
    ON s.ProductKey = p.ProductKey
LEFT JOIN `PROJECT_ID.global_electronics_retailer.Customers` c 
    ON s.CustomerKey = c.CustomerKey
LEFT JOIN `PROJECT_ID.global_electronics_retailer.Stores` st 
    ON s.StoreKey = st.StoreKey
LEFT JOIN `PROJECT_ID.global_electronics_retailer.Exchange_Rates` e 
    ON s.`Order Date` = e.Date AND s.`Currency Code` = e.Currency;
