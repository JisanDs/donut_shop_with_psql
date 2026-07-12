/*
    This schemas containt all table, procedures and triggers related to schema name.
    Every schema have his owne diractory and every dir containt plan.md file.
*/

-- create DB change current db to donut_shop.
CREATE DATABASE donut_shop;

create schemas
CREATE SCHEMA inventory;
CREATE SCHEMA hr;
CREATE SCHEMA sales;

-- set search path for full DB
ALTER DATABASE donut_shop
SET search_path TO public, inventory, hr, sales;


-- this is global types
CREATE TYPE pay_types AS ENUM('cash', 'm_bk', 'crd', 'bank'); -- crd = card, m_bk = mobile_banking
CREATE TYPE reasons AS ENUM('sale', 'restock', 'add', 'damaged', 'use');
