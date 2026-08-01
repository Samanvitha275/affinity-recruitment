# Affinity Answers Recruitment Challenge

This repository contains my solutions for the Affinity Answers Recruitment Challenge.

---

## Project Structure

```
affinity-recruitment/
├── q1_scraper.py
├── q2_rfam_queries.sql
├── q3_sp500.sh
├── requirements.txt
└── README.md
```

---

# Question 1 - MDComputers Web Scraper 

## Description

A Python script that searches products on **mdcomputers.in** and extracts:

- Product name
- Price
- Stock status
- Product URL

Duplicate products are filtered before displaying the results.

## Requirements

- Python 3.8+
- requests
- beautifulsoup4

## Installation

```bash
pip install -r requirements.txt
```

## Usage

```bash
python3 q1_scraper.py "external hard drive"
```

Example:

```bash
python3 q1_scraper.py "SSD"
```

---

# Question 2 - Rfam SQL Queries

The SQL file contains solutions for:

1. Count the number of Acacia species.
2. Find the wheat species with the longest DNA sequence.
3. Display Rfam families with maximum DNA sequence length greater than 1,000,000 using pagination.

## Running the queries

```bash
mysql -u rfamro -h mysql-rfam-public.ebi.ac.uk -P 4497 Rfam
```

Execute the queries from:

```
q2_rfam_queries.sql
```

---

# Question 3 - S&P 500 Company Sorter

A Bash script that:

- Downloads the CSV dataset
- Extracts Company Name
- Extracts Headquarters Location
- Extracts Founded Year
- Sorts companies by founding year

## Usage

Make the script executable:

```bash
chmod +x q3_sp500.sh
```

Run:

```bash
./q3_sp500.sh https://raw.githubusercontent.com/datasets/s-and-p-500-companies/refs/heads/main/data/constituents.csv
```

---

# Requirements

Python packages:

```
requests
beautifulsoup4
```

System tools:

- bash
- curl
- Python 3

---

# Design Notes

## Q1

- Uses requests and BeautifulSoup.
- Removes duplicate products.
- Handles missing product information gracefully.

## Q2

- Uses SQL joins where required.
- Uses aggregation functions.
- Implements pagination with LIMIT and OFFSET.

## Q3

- Downloads the CSV from a supplied URL.
- Uses Python's csv module to correctly parse quoted CSV fields.
- Sorts companies by founding year before displaying the results.

---

# Repository Contents

```
README.md
q1_scraper.py
q2_rfam_queries.sql
q3_sp500.sh
requirements.txt
```
