# Find the titles of all movies directed by Steven Spielberg

select title
from Movie
where director='Steven Spielberg';

select title
from Movie
where director='Steven Spielberg';

# Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.

select R.mID, year,stars
from Movie M, Rating R 
where R.mID=M.mID and stars>=4
order by year;

## using where

select distinct year
from Movie M, Rating R 
where R.mID=M.mID and stars>=4
order by year;

## using join

select distinct year
from Movie M join Rating R using(mID)
where stars>=4
order by year;


## Find the titles of all movies that have no ratings.

Select mID,title
from Movie 
where mID not in (select mID from Rating);

Select title
from Movie 
where mID not in (select mID from Rating);

Select title
from Movie M
where not exists (select * from Rating R where M.mID=R.mID);

# Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.

select Reviewer.rID,name
from Reviewer
where rID in (select rID from Rating where ratingDate is Null);

select name
from Reviewer
where rID in (select rID from Rating where ratingDate is Null);

# Write a query to return the ratings data in a more readable format: 
# reviewer name, movie title, stars, and ratingDate. 
# Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.

select name, title, stars, ratingDate
from Movie M, Rating Rat, Reviewer Rev
where M.mID=Rat.mID and Rev.rID=Rat.rID
order by name, title, stars;

## using join

select name, title, stars, ratingDate
from Movie join Rating using(mID) join Reviewer using(rID)
order by name, title, stars;

# For all cases where the same reviewer rated the same movie twice
# and gave it a higher rating the second time,
# return the reviewer's name and the title of the movie.


## make table from rating with rID, mId where count of each  film is exactly 2

select rID,mID, count(mID)
from Rating
group by rID, mID
having count(mID)=2;

select *
from Rating R1 join 
	(select rID,mID, count(mID)
	from Rating
	group by rID, mID
	having count(mID)=2) as G using(rID,mID);

## full solution using temp table as `with` doesn't work in sql 5.7

drop table if exists temp;
create table temp(rID int, mID int, stars int, ratingDate date, countmid int);

insert into temp
	select *
	from Rating R1 join 
		(select rID,mID, count(mID)
		from Rating
		group by rID, mID
		having count(mID)=2) as G using(rID,mID);

select rID, name, title
from temp as t1 join Reviewer using(rID) join Movie using(mID)
where exists(select * from temp t2
			where t1.ratingDate>t2.ratingDate and t1.stars>t2.stars);
        
### full solution ugly solution without `CTE` or anything.

select rID, name, title
from Rating as t1 join Reviewer using(rID) join Movie using(mID)
where exists(select * from Rating t2
			where t1.rID=t2.rID and t1.mID=t2.mID and t1.ratingDate>t2.ratingDate and t1.stars>t2.stars);

select rID, name, title
from (
	select *
	from Rating R1 join 
		(select rID,mID, count(mID)
		from Rating
		group by rID, mID
		having count(mID)=2) as G using(rID,mID)
        ) as t1 join Reviewer using(rID) join Movie using(mID)
where exists(select * from Rating t2
			where t1.rID=t2.rID and t1.mID=t2.mID and t1.ratingDate>t2.ratingDate and t1.stars>t2.stars);
            
# For each movie that has at least one rating, 
# find the highest number of stars that movie received. 
# Return the movie title and number of stars. 
# Sort by movie title.

select  title, max(stars)
from Rating join Movie using(mID)
group by mID,title
having count(stars)>1;

#For each movie, return the title and the 'rating spread', that is, 
# the difference between highest and lowest ratings given to that movie. 
#Sort by rating spread from highest to lowest, then by movie title.

select title, max(stars)-min(stars) as ratingSpread
from Rating join Movie using(mID)
group by mID,title
order by ratingSpread desc, title;


# Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.
# (Make sure to calculate the average rating for each movie, 
# then the average of those averages for movies before 1980 and movies after.
# Don't just calculate the overall average rating before and after 1980.)

## avg of each movie before 1980
select mID, title, avg(stars) as avg_stars
from Rating join Movie using(mID)
where year < 1980
group by mID, title;

## rest of solution

select avg(b1980.avg_stars) - avg(a1980.avg_stars)
from (
	select mID, title, avg(stars) as avg_stars
	from Rating join Movie using(mID)
	where year < 1980
	group by mID, title
	) as b1980, 
    (
	select mID, title, avg(stars) as avg_stars
	from Rating join Movie using(mID)
	where year > 1980
	group by mID, title
	) as a1980


