# Find the titles of all movies directed by Steven Spielberg.

select title
from Movie 
where director="Steven Spielberg";

# Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
# write in join as well as where

select distinct year
from Movie M, Rating R
where M.mId=R.mID and stars>=4
order by year;

select distinct year
from Movie M join Rating R using(mID)
where stars>=4
order by year;

## Different joins testing (inner joins), outerjoins have null values beware

select rID, M.mID, stars
from Movie M, Rating R
where M.mID=R.mID
order by year;

select rID,mID,stars
from Movie M join Rating R using (mid);

select rID,mID,stars
from Movie M left join Rating R using (mID);

select rID,mID,stars
from Movie M right join Rating R using (mID);

# Find the titles of all movies that have no ratings.

select title
from Movie M left join Rating R using (mID)
where rID is null;

select title
from Movie M
where not exists (select * from Rating R where M.mID=R.mID);

Select title
from Movie 
where mID not in (select mID from Rating);

# Some reviewers didn't provide a date with their rating. 
# Find the names of all reviewers who have ratings with a NULL value for the date.

select name
from Rating R join Reviewer Re using (rID)
where ratingDate is null;

select name
from Reviewer
where rID in (select rID from Rating where ratingDate is Null);

# Q5 Write a query to return the ratings data in a more readable format: 
# reviewer name, movie title, stars, and ratingDate. 
# Also, sort the data, first by reviewer name, then by movie title, 
# and lastly by number of stars. (The answer seems to want only inner joins)


select name, title, stars, ratingDate
from Movie join Rating using (mID) join Reviewer using (rID)
order by name, title, stars;

select name, title, stars, ratingDate
from Movie M, Rating Rat, Reviewer Rev
where M.mID=Rat.mID and Rev.rID=Rat.rID
order by name, title, stars;

# Q6 For all cases where the same reviewer rated the same movie twice and 
# gave it a higher rating the second time, return the reviewer's name and 
# the title of the movie.

## testing with one rid = 201
select R1.rID, R2.rID, R1.mID, R1.stars, R2.stars
from Rating R1 join Rating R2 using (rID)
where R2.stars > R1.stars and R2.ratingDate > R1.ratingDate and rID = 203;

## any number of movies not just 2
select name 
from Reviewer Re
where rID in (select R1.rID
from Rating R1 join Rating R2 using (rID)
where R1.stars > R2.stars and R1.ratingDate>R2.ratingDate and R1.rID=201);

## final answer 1 (full with count and stuff)
select name, title
from 
	(select rID
	from Rating
	group by rID,mID
	having count(mID)=2) as G 
join Rating R1 using (rID)
join Rating R2  using (rID) 
join Reviewer Re using (rID)
join Movie M on R1.mID=M.mID#using (R1.mID=M.mID)## (mID)
where R1.mID=R2.mID and R1.stars > R2.stars and R1.ratingDate > R2.ratingDate;

## final answer 2
SELECT name, title
FROM Movie
INNER JOIN Rating R1 USING(mId)
INNER JOIN Rating R2 USING(rId)
INNER JOIN Reviewer USING(rId)
WHERE R1.mId = R2.mId AND R1.ratingDate < R2.ratingDate AND R1.stars < R2.stars;

## My previous final answer (shit complicated)

select name, title
from (select *
	from Rating R1 join 
		(select rID,mID, count(mID)
		from Rating
		group by rID, mID
		having count(mID)=2) as G using(rID,mID)) as t1 join Reviewer using(rID) join Movie using(mID)
where exists(select * from Rating t2
			where t1.rID=t2.rID and t1.mID=t2.mID and t1.ratingDate>t2.ratingDate and t1.stars>t2.stars);

## using count
select count(mID),rID
from Rating
group by rID,mID
having count(mID)=2;

# Q7 For each movie that has at least one rating, find the highest number of stars
# that movie received. Return the movie title and number of stars. 
# Sort by movie title.

select title, max(stars)
from Movie join Rating using (mID)
group by mID,title
having count(mID)>0
order by title;

# Q8 For each movie, return the title and the 'rating spread', that is,
# the difference between highest and lowest ratings given to that movie. 
# Sort by rating spread from highest to lowest, then by movie title.

select title, mID, max(stars)-min(stars) G
from Movie join Rating using (mID)
group by mID, title
order by G desc, title;


# Q9 Find the difference between the average rating of movies released before 1980 
# and the average rating of movies released after 1980.
# (Make sure to calculate the average rating for each movie, 
# then the average of those averages for movies before 1980 and movies after.
# Don't just calculate the overall average rating before and after 1980.)

## test get avg stars using where conditie
select mid, title, avg(stars)
from Movie join Rating using (mID)
where year <1980
group by mID, title;

## next step
select avg(avg_pre) - avg(avg_post)
from
	(select avg(stars) as avg_pre
	from Movie join Rating using (mID)
	where year <1980
	group by mID, title) as pandian,
    (select avg(stars) as avg_post
	from Movie join Rating using (mID)
	where year >=1980
	group by mID, title) as indian;




select count(*) from Movie;
select count(*) from sql_stanford_movie.Movie;
select count(*) from Rating;




