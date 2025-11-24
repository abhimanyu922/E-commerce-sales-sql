# E-Commerce Sales Analytics System 

This is a compact, portfolio-ready **E-Commerce Sales Analytics Project** designed for  
Data Analyst, Data Engineer, and SQL/BI roles.  
It contains realistic datasets, SQL schema, insert scripts, KPIs, and fraud analytics use-cases.

---

## Project Structure

```
Ecommerce_Mini_Project/
│── data/
│   ├── users.csv
│   ├── products.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── payments.csv
│   ├── shipments.csv
│   ├── merchants.csv
│
│── sql/
│   ├── schema.sql
│   ├── users_insert.sql
│   ├── products_insert.sql
│   ├── orders_insert.sql
│   ├── order_items_insert.sql
│   ├── payments_insert.sql
│   ├── shipments_insert.sql
│   ├── merchants_insert.sql
│
│── docs/
│   ├── README.md
│
│── README.md  ← (this main file)
```

---

## About The Project

This mini E-Commerce analytics system simulates an online retail platform  
similar to Flipkart, Amazon, or Meesho.

It includes:

- 100 customers  
- 100 products across 5 categories  
- 100 orders  
- 200+ order items  
- 100 payments  
- Shipments data (delivered + processing)  
- 100 merchants (for analytics)

The goal is to demonstrate **SQL skills, analytics thinking, and fraud detection logic**.

---

## Database Schema (Tables)

| Table | Purpose |
|-------|---------|
| **users** | Customer information |
| **products** | Product catalog with price & cost |
| **orders** | Order-level data |
| **order_items** | Line-item details |
| **payments** | Payment logs |
| **shipments** | Order shipping lifecycle |
| **merchants** | Merchant-level metadata |

All tables are linked through primary–foreign keys.

---



### KPIs or Fraud queries


## 20 Business KPIs (Real-World Questions)

The project includes SQL for the following real KPIs:

1. Daily sales revenue  
2. Daily / weekly / monthly order count  
3. Top revenue-generating products  
4. Category-wise sales  
5. Average Order Value (AOV)  
6. Top-spending customers  
7. Delivered vs Cancelled vs Returned trends  
8. Payment method popularity  
9. Unique buyers in last 30 days  
10. Repeat purchase rate  
11. Quantity sold per product  
12. Product-level profitability  
13. Month-on-month revenue growth  
14. Orders with more than 3 items  
15. City-wise order volume  
16. City-wise delivery time analysis  
17. Cart abandonment approximation  
18. Peak-hours product sales  
19. Category-level order status distribution  
20. Processing-time KPI

---

## Fraud Detection Use Cases

Real-life fraud scenarios included:

1. Excessive orders in short time window  
2. Same address used by multiple customers  
3. Frequent refunds by the same user  
4. High-priced products with return abuse  
5. High failed payments count  
6. Multiple accounts sharing behavior  
7. Refund loops with multiple addresses  
8. Product-level high return ratio  
9. Delivery–payment mismatch  
10. Late-night high-value orders  


Project generated & curated for learning and portfolio building.

