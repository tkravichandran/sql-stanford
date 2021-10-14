# Find the names of all reviewers who rated Gone with the Wind.

select distinct name
from Movie join Rating using(mID) join Reviewer using(rID)
where title like 'Gone with%';

# For any rating where the reviewer is the same as the director of the movie, 
# return the reviewer name, movie title, and number of stars.

select name, title, stars
from Movie join Rating using(mID) join Reviewer using(rID)
where director=name;

# Return all reviewer names and movie names together in a single list, alphabetized. 
#(Sorting by the first name of the reviewer and first word in the title is fine; 
# no need for special processing on last names or removing "The".) ???

select substr(G.title, 1,   instr(G.title, ' ') - 1) AS first_name,  G.title
from (Select title
from Movie 
Union
Select name
from Reviewer) as G
order by first_name;


## order by last name in sql lite/
Select substr(name,    instr(name, ' ') + 1) AS last_name,  name
from Reviewer 
order by last_name;

## order by first name in
Select substr(name, 1,   instr(name, ' ') - 1) AS first_name,  name
from Reviewer 
order by first_name;

## final sol without any thing fancy
Select title
from Movie 
Union
Select name
from Reviewer
order by title;

# Find the titles of all movies not reviewed by Chris Jackson.

select title
from Movie as M1
where title not in (select title from Movie M2 join Rating using(mID) join Reviewer using(rID)
					where name like '%Chris%');
                    
# For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
# Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. 
# For each pair, return the names in the pair in alphabetical order.n

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

## also this works

SELECT DISTINCT rev1.name, rev2.name
FROM Reviewer rev1, Reviewer rev2, Rating r1, Rating r2
WHERE r1.rID = rev1
AND r2.rID = rev2.rID
AND r1.mID = r2.mID
AND rev1.name < rev2.name;


# For each rating that is the lowest (fewest stars) currently in the database,
# return the reviewer name, movie title, and number of stars.

SELECT name, title, stars
From Movie join Rating using(mID) join Reviewer using(rID)
Where stars in (select min(stars)
				FROM Rating R2);

select min(stars)
FROM Rating R2;

# List movie titles and average ratings, from highest-rated to lowest-rated. 
# If two or more movies have the same average rating,
# list them in alphabetical order.

SELECT title, avg(stars) av
FROM Movie join Rating using(mID)
Group by title
Order by av desc,title;


# Find the names of all reviewers who have contributed three or more ratings. 
# (As an extra challenge, try writing the query without HAVING or without COUNT.)

Select name, count(name)
From Rating join Reviewer using(rID)
Group by name
having count(name)>=3;

# Some directors directed more than one movie. For all such directors, 
# return the titles of all movies directed by them, along with the director name.
# Sort by director name, then movie title. 
# (As an extra challenge, try writing the query both with and without COUNT.)

Select title, director
From Movie
Where director in (Select director
					From Movie M2
					Group By director
					having count(*)>1)
Order by director;


Select director
From Movie M2
Group By director
having count(title)>1;

#Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.
#(Hint: This query is more difficult to write in SQLite than other systems; you might think of it as 
# finding the highest average rating and then choosing the movie(s) with that average rating.)

Select avg(stars)
From Movie join Rating using(mID)
group by title;


Select MAX(avg_stars)
From (Select avg(stars) as avg_stars
     From Movie join Rating using(mID)
     group by title) as G;

Select title, avg(stars)
From Movie join Rating using(mID)
Group by title
Having avg(stars) = (Select MAX(avg_stars)
					From (Select avg(stars) as avg_stars
							From Movie join Rating using(mID)
                            group by title) as G);

## best sol with 2 select statements
select title, avg(stars) avg_rating
from Rating join Movie using (mID)
group by title
having avg_rating = (select avg(stars) as avg_rating
					from Rating
                    group by mID
                    order by avg_rating
                    DESC LIMIT 1);

                    
# Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
# (Hint: This query may be more difficult to write in SQLite than other systems; 
# you might think of it as finding the lowest average rating 
# and then choosing the movie(s) with that average rating.)                    

Select title, avg(stars)
From Movie join Rating using(mID)
Group by title
Having avg(stars) = (Select MIN(avg_stars)
					From (Select avg(stars) as avg_stars
							From Movie join Rating using(mID)
                            group by title) as G);

## best sol
select title, avg(stars) as avg_rating
from Rating join Movie using (mID)
group by title
having avg_rating =	(select avg(stars) as avg_rating
					from Rating
					group by  mID
					order by avg_rating Asc LIMIT 1);

# For each director, return the director's name together with the title(s) of the movie(s) 
# they directed that received the highest rating among all of their movies, and the value of that rating. 
# Ignore movies whose director is NULL.

SELECT director, title, stars
From (select * From Movie join Rating using(mID) where director is not null) as A1
order by director;


SELECT distinct director, title, stars
From (select * From Movie join Rating using(mID) where director is not NULL) as A1
where not exists (select * 
				From (select * From Movie join Rating using(mID) ) as A2
                where A1.director = A2.director and A1.stars<A2.stars)
order by director;

## new solution using join (probably faster)
select distinct director, title, stars
from Movie join Rating using (mID)
join (select director, max(stars) as mx_stars
	from Rating join Movie using (mID)
    where director is not NULL
	group by director) as G using (director)
where stars=mx_stars
order by director;

# someone elses answer ( soen't work!

SELECT m.director, m.title, max(ra.stars)
FROM Movie m
JOIN Rating ra
ON m.mid = ra.mid
GROUP BY m.director
HAVING m.director is NOT NULL;