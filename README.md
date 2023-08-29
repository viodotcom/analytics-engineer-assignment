# Vio.com Analytics Engineer assignment

## Introduction

This assignment is part of the recruitment process of Analytics Engineers here at Vio.com. The purpose is to assess the technical skills of our candidates in a generic scenario, similar to the one they would experience at Vio.com.

Please, read carefully all the instructions before starting to work on your solution and feel free to contact us if you have any doubt.

## Setup

You need to fork this repository to work on your solution to the assignment.

The repository has the following content:
- A [Dockerfile](.Dockerfile) to build the base docker image for the assignment.
- A [Makefile](.Makefile) that should be used to execute all the necessary steps of the assignment.
- A [data](./data) directory with the source raw data files.
- A [sql](./sql) directory for your SQL scripts. We have added a sample script for reference.

The `Dockerfile` is based on Ubuntu 20.04 and has SQLite, the RDBMS that you will use in this exercise, installed. It also has the `make` utility installed, which you will have to use to execute all the necessary steps of the assignment.

We have created a sample `Makefile` for reference with a target that executes the sample SQL script (`create-empty-table.sql`). We have also added an empty `run` target, which is the default one for the `make` utility. We expect you to add more targets for all the different steps of your solution and to trigger them in the correct order from the `run` target.

We will test your solution in the following way:
- Building the docker image
```bash
$ docker build -t viodotcom/assignment .
```
- Running the docker container interactively to connect to the DB:
```bash
$ docker run -it --rm viodotcom/assignment
```
- Checking the tables that you have produced:
```bash
sqlite> .tables
sqlite> SELECT * FROM <table_name>;
...
sqlite> .exit
```

We will also have a look at your SQL scripts, which we expect to be available in the `sql` directory, to understand how did you build all the different tables in the DB.

## Source data

You will work with a dataset of events from an online cosmetics store collected using a Customer Data Platform (CDP). It is stored in the form of CSV files in the [data](./data) directory with the following structure:

- `event_time`: Time when event happened at (in UTC).
- `event_type`:	Type of behavioural event.
- `product_id`:	Unique numeric identifier of a product.
- `category_id`: Unique numeric identifier of the category of a product.
- `category_code`: Text identifier of the category of a product.
- `brand`: Text identifier of the brand of a product.
- `price`: Float price of a product.
- `user_id`: Unique numeric identifier of a user.
- `user_session`: Unique UUID identifier of a user session. A session is closed after a predefined time period.

The dataset contains 4 types of behavioural events defined as follows:

- `view`, a user viewed a product.
- `cart`, a user added a product to the shopping cart.
- `remove_from_cart`, a user removed a product from the shopping cart.
- `purchase`, a user purchased a product.

The sample dataset is composed of 2 CSV files, one with data for January 2020 and one with data for February 2020.

Note that the files have been compressed to meet the GitHub file size limit policy. However, the docker image takes care of uncompressing them.

## Assignment

The overal objective of the assignment is to ingest the raw files with the behavioural event data, clean them up and create a series of tables with aggregated data for analytical purposes. We will divide the challenge into several tasks. Remember to create a SQL script for each task, store it in the `sql` directory and add them to a target of the `Makefile` that will be executed when building the docker image.

It is not mandatory, but you can also include an additional `README` file to explain any of the tasks of your solution and the decisions you've made.

### Task 1: Ingesting the data

The objective of this step is to ingest the source data from January (`2020-Jan.csv`) into a table named `event_raw`. For example, you can use the `.import` command from SQLite to do it. The structure of this table will depend on the process that you use to ingest the data, but it should have **at least one column for each of the columns in the source CSV file**.

### Task 2: Cleaning up the data

Depending on the process you've followed to ingest the data, the `event_raw` table may have incorrect data types, the `NULL` values may have been ingested as empty strings, etc. In this step we want you to perform all the necessary clean up to make sure that the quality of the data is high and it is ready to be consumed. The task is open ended in the sense that you can apply any processing that you think will improve the quality of the dataset.

The output should be a table named `event_clean` with **exactly one column for each of the columns in the source CSV file** and the most appropriate data types. You will use the `event_clean` table in the following steps as the basis to extract meaningfull insights.

### Task 3: Daily sales

Here we want you to calculate the aggregated sales per day. The output should be a `daily_sales` table with the following shape:

| DATE       | TOTAL_SALES |
|------------|-------------|
| 2020-01-01 |        1000 |
|        ... |         ... |


### Task 4: Daily stats of visitors, sessions, viewers, views, leaders, leads, purchasers and purchases

In this step we would like you to calculate the daily stats for the following metrics:
- `visitors`: Number of different users that have visited the store.
- `sessions`: Number of different user sessions for the users that have visited the store.
- `viewers`: Number of different users that have viewed at least one item.
- `views`: Total number of products viewed.
- `leaders`: Number of different users that have added at least one item to the cart.
- `leads`: Total number of products added to the cart.
- `purchasers`: Number of different users that have purchased at least one item.
- `purchases`: Total number of products purchased.

The output should be a `daily_stats` table with the following shape:

| DATE       | VISITORS | SESSIONS | VIEWERS | VIEWS | LEADERS | LEADS | PRUCHASERS | PURCHASES |
|------------|----------|----------|---------|-------|---------|-------|------------|-----------|
| 2020-01-01 |     1000 |     1250 | 950     | 1125  |     750 |   825 |        250 |       500 |
|        ... |      ... |      ... |         |       |     ... |   ... |        ... |       ... |

### Task 5: Daily conversion funnel

Building up on top of the previous insight, now we want you to calculate the daily conversion funnel. For that we want to know the ratio of users that make it from one step to the next of the journey.

We consider the user journey to go through the following steps:

```
visitor -> viewer -> leader -> purchaser
```

The output should be a `daily_funnel` table with the following shape:

| DATE       | VISITORS | VIEWERS | LEADERS | PRUCHASERS | VISITOR_TO_VIEWER | VIEWER_TO_LEADER | LEADER_TO_PURCHASER |
|------------|----------|---------|---------|------------|-------------------|------------------|---------------------|
| 2020-01-01 |     1000 | 950     |     750 |        250 |              0.95 |             0.79 |                0.33 |
|        ... |      ... |         |     ... |        ... |               ... |              ... |                 ... |

### Task 6: Daily ticket size

We want to understand which is the distribution of the purchase or ticket size per user daily. For that, we consider that all the items purchased by a user during one session belong to the same purchase or ticket. We will calculate some basic statistics (min, max and 25th, 50th and 75th percentiles) about the ticket size to estimate it's distribution.

The output should be a `daily_ticket` table with the following shape:

| DATE       | TOTAL_SALES | MIN_TICKET | 25TH_PERC_TICKET | 50TH_PERC_TICKET | 75TH_PERC_TICKET | MAX_TICKET |
|------------|-------------|------------|------------------|------------------|------------------|------------|
| 2020-01-01 |        1000 |       1.25 |             2.50 |            10.35 |            25.50 |     150.25 |
|        ... |         ... |        ... |              ... |              ... |              ... |        ... |

### Task 7: Incremental load

So far you have only worked with one of the source CSV files. The objective now is to reproduce all the previous steps with the other file with data for February 2020 (`2020-Feb.csv`). Make sure to **load the data incrementally** into the existing tables without droping or truncating them. The objective is to simulate a batch process that would happen every once in a while when new data is available.

## References

- [eCommerce Events History in Cosmetics Shop](https://www.kaggle.com/mkechinov/ecommerce-events-history-in-cosmetics-shop)
- [REES46 Marketing Platform](https://rees46.com/)
- [Customer Data Platform](https://en.wikipedia.org/wiki/Customer_data_platform)
- [Conversion funnel](https://chartio.com/learn/product-analytics/what-is-a-funnel-analysis/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [GNU Make utility](https://www.gnu.org/software/make/)
