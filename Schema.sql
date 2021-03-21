DROP DATABASE IF EXISTS `sql_stanford`;
CREATE DATABASE `sql_stanford`; 
USE `sql_stanford`;

SET NAMES utf8 ;
SET character_set_client = utf8mb4 ;


drop table if exists College;
drop table if exists Student;
drop table if exists Apply;

create table College(cName text, state text, enrollment int);
create table Student(sID int, sName text, GPA real, sizeHS int);
create table Apply(sID int, cName text, major text, decision text);
