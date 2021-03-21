# Add the reviewer Roger Ebert to your database, with an rID of 209.

select *
From Reviewer;


insert into Reviewer values(209,'Roger Ebert');


# For all movies that have an average rating of 4 stars or higher, 
# add 25 to the release year. 
# (Update the existing tuples; don't insert new tuples.)

Select *
From Movie
where mID in (Select mID
		From Movie join Rating using(mID)
		group by mID
		Having avg(stars)>=4);

Select *
From Movie;

Update Movie
Set year=year+25
Where mID in (select mID
				From (select mID
					From Movie join Rating using(mID)
					group by mID
					having avg(stars)>=4) as C);

# Remove all ratings where the movie's year is before 1970 or after 2000, 
# and the rating is fewer than 4 stars.

## find the selection

Select *
From Movie join Rating using (mID)
Where (stars<4) and (year<1970 or year>2000);

## rewrite to avoid error 1093 but it works on sql lite

Select *
From (Select *
	From Movie join Rating using (mID)
	Where (stars<4) and (year<1970 or year>2000)) as c;

## Delete statement

Delete From Rating
where mID in (Select mID
			From (Select *
				From Movie join Rating using (mID)
				Where (stars<4) and (year<1970 or year>2000)) as c) 
And stars<4;
	


