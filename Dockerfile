# Use Ubuntu 20.04 LTS as the base image
FROM ubuntu:20.04

# Install all the necessary packages
RUN apt-get update
RUN apt-get install -y sqlite3
RUN apt-get install -y make
RUN apt-get install -y unzip

# Create the directories for the assignment
RUN mkdir /assignment
RUN mkdir /assignment/data
RUN mkdir /assignment/sql
RUN mkdir /assignment/db

# Move to the assignment directory
WORKDIR /assignment

# Copy the source data and sql scripts
COPY data/ data
COPY sql/ sql

# Unzip the source data files
RUN unzip 'data/*.zip' -d data
RUN rm data/*.zip

# Copy and run the Makefile
COPY Makefile .
RUN make

# Open a SQLite session
CMD ["sqlite3", "db/assignment.db"]
