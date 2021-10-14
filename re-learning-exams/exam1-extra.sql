# Q1 Find the names of all reviewers who rated Gone with the Wind.

select distinct name
from Movie 
join Rating using (mID)
join Reviewer using (rID)
where title = "Gone with the Wind";

# Q2 For any rating where the reviewer is the same as the director 
# of the movie, return the reviewer name, movie title, and number 
# of stars.

select name, title, stars
from Movie
join Rating using (mID)
join Reviewer using (rID);


# Q3 Return all reviewer names and movie names together in a single list
# , alphabetized. (Sorting by the first name of the reviewer and first 
# word in the title is fine; no need for special processing on last names 
# or removing "The".)
##

## order by second word
select title as T
from Movie
union
select name as T
from Reviewer
order by SUBSTRING_INDEX(SUBSTRING_INDEX(T, ' ', 2), ' ', -1);#SUBSTRING_INDEX(`T`, ' ', 1);

## order by first word
select title as T
from Movie
union
select name as T
from Reviewer
order by SUBSTRING_INDEX(`T`, ' ', 1);


# Q4 Find the titles of all movies not reviewed by Chris Jackson.

select title
from Movie left join (
		select rID,mID
		from Reviewer join Rating using(rID)
		where name = "Chris Jackson") as G
using (mID)
where rID is Null;

## don't use not in or not exists as it is supposed to be slow
select title
from Movie as M1
where title not in (select title from Movie M2 join Rating using(mID) join Reviewer using(rID)
					where name like '%Chris%');

# Q5 For all pairs of reviewers such that both reviewers gave a rating 
# to the same movie, return the names of both reviewers. Eliminate 
# duplicates, don't pair reviewers with themselves, and include each pair 
# only once. For each pair, return the names in the pair in alphabetical 
# order.

## testing
select Re1.name, R1.rID, R2.rID, Re2.name, mID
from Rating R1 join Rating R2 using (mID)
join Reviewer Re1 on (R1.rID = Re1.rID)
join  Reviewer Re2 on (R2.rID = Re2.rID)
where R1.rID != R2.rID and R1.rID > R2.rID;

## final
select distinct Re1.name, Re2.name
from Rating R1 join Rating R2 using (mID)
join Reviewer Re1 on (R1.rID = Re1.rID)
join  Reviewer Re2 on (R2.rID = Re2.rID)
where R1.rID != R2.rID and Re1.name<Re2.name
order by Re1.name;#and R1.rID > R2.rID;

## old answer

Select distinct G1.name,G2.name
From (select Re1.rID,mID,name
		from Rating R1, Reviewer Re1
        where R1.rID=Re1.rID) as G1,
      (select Re2.rID,mID,name
		from Rating R2, Reviewer Re2
        where R2.rID=Re2.rID) as G2
where G1.mID=G2.mID
And G1.name < G2.name
order by G1.name;

# Q6 For each rating that is the lowest (fewest stars) currently in the 
# database, return the reviewer name, movie title, and number of stars.

select name, title, stars
from Movie 
join Rating using (mID)
join Reviewer using (rID)
where stars = (select min(stars)
				from Rating);

# Q7 List movie titles and average ratings, from highest-rated to 
# lowest-rated. If two or more movies have the same average rating, 
# list them in alphabetical order.

## attempt 1, overly done.
 select title, avg_rating
 from Movie
 join (select mID,avg(stars) as avg_rating
		from Rating
        group by mID) as G using (mID)
order by avg_rating DESC, title;

## attempt, proper

select title, avg(stars) as av
from Movie join Rating using (mID)
group by title
order by av DESC, title;
 
# Q8 Find the names of all reviewers who have contributed three or more 
# ratings. (As an extra challenge, try writing the query without HAVING 
# or without COUNT.)

select name
from Rating join Reviewer using(rID)
group by name
having count(stars)>2;

# Q9 Some directors directed more than one movie. For all such directors
# , return the titles of all movies directed by them, along with the 
# director name. Sort by director name, then movie title. 
# (As an extra challenge, try writing the query both with and without 
# COUNT.)

## from subquery
select title, director
from Movie join (select director
				from Movie
                group by director
                having count(mID)>1) as G using (director)
order by director, title;

## Where subquery

Select title, director
From Movie
Where director in (Select director
					From Movie M2
					Group By director
					having count(title)>1)
Order by director,title;

# Q10 Find the movie(s) with the highest average rating. 
# Return the movie title(s) and average rating. (Hint: This query is 
# more difficult to write in SQLite than other systems; you might think 
# of it as finding the highest average rating and then choosing the 
# movie(s) with that average rating.)

## best sol with 2 select statements
select title, avg(stars) avg_rating
from Rating join Movie using (mID)
group by title
having avg_rating = (select avg(stars) as avg_rating
					from Rating
                    group by mID
                    order by avg_rating
                    DESC LIMIT 1);
					
select title , avg(stars) as avg_rating
		from Rating join Movie using (mID)
		group by title;
        
select  avg(stars) as avg_rating
from Rating
group by mID
order by avg_rating
DESC LIMIT 1;

# Q11 Find the movie(s) with the lowest average rating. Return the movie 
# title(s) and average rating. (Hint: This query may be more difficult 
# to write in SQLite than other systems; you might think of it as 
# finding the lowest average rating and then choosing the movie(s) 
# with that average rating.)

select title, avg(stars) as avg_rating
from Rating join Movie using (mID)
group by title
having avg_rating =	(select avg(stars) as avg_rating
					from Rating
					group by  mID
					order by avg_rating Asc LIMIT 1);


## My old 3 select solution

Select title, avg(stars)
From Movie join Rating using(mID)
Group by title
Having avg(stars) = (Select MIN(avg_stars)
					From (Select avg(stars) as avg_stars
							From Movie join Rating using(mID)
                            group by title) as G);


# Q12 For each director, return the director's name together with the 
# title(s) of the movie(s) they directed that received the highest 
# rating among all of their movies, and the value of that rating. 
# Ignore movies whose director is NULL.

## new solution using join (probably faster)
select distinct director, title, stars
from Movie join Rating using (mID)
join (select director, max(stars) as mx_stars
	from Rating join Movie using (mID)
    where director is not NULL
	group by director) as G using (director)
where stars=mx_stars
order by director;

## old solution 
SELECT distinct director, title, stars
From (select * From Movie join Rating using(mID) where director is not NULL) as A1
where  not exists (select * 
				From (select * From Movie join Rating using(mID) ) as A2
                where A1.director = A2.director and A1.stars<A2.stars)
order by director;

## tests

select director, max(stars)
from Rating join Movie using (mID)
where director is not NULL
group by director;












