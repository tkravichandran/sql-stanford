# It's time for the seniors to graduate. Remove all 12th graders from Highschooler.

Select *
From Highschooler
Where grade=12;

Delete from Highschooler
Where grade=12;

# If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple.

Select L1.ID2 as Alikes,F1.ID1 A,F1.ID2 B, L2.ID2 as Alikeslikes
From Friend F1 join Likes L1 on F1.ID1=L1.ID1  left outer join Likes L2 on F1.ID2=L2.ID1
Where L1.ID2=F1.ID2 and (L2.ID2<>F1.ID1 or L2.ID2 is Null)
order by F1.ID1,F1.ID2;

Delete From Likes
Where exists ( Select * 
				From (Select F1.ID1 as id1, F1.ID2 as id2
					From Friend F1 join Likes L1 on F1.ID1=L1.ID1  left outer join Likes L2 on F1.ID2=L2.ID1
					Where L1.ID2=F1.ID2 and (L2.ID2<>F1.ID1 or L2.ID2 is Null)) as C
				Where C.id1=Likes.ID1 and C.id2=Likes.ID2);

select *
From Likes;

SELECT H1.name,
       H1.grade,
       H2.name,
       H2.grade
FROM Likes L,
     Highschooler H1,
     Highschooler H2
WHERE L.ID1 = H1.ID
  AND L.ID2 = H2.ID
ORDER BY H1.name,
         H1.grade;
         
# For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. 
# Do not add duplicate friendships, friendships that already exist, or friendships with oneself.
# (This one is a bit challenging; congratulations if you get it right.)

## table with A and C pairs. Removed same A and C
Select distinct F1.ID1 as A, F2.ID2 as C
From Friend F1 join Friend F2 on F1.ID2=F2.ID1
where F1.ID1 <> F2. ID2
order by F1.ID1, F2.ID2;

## check if A and C pairs exist previously

Select distinct F1.ID1 as A, F1.ID2 as B, F2.ID2 as C
From Friend F1 join Friend F2 on F1.ID2=F2.ID1
where F1.ID1 <> F2. ID2 
and not exists (Select * 
				From Friend F3
                Where F1.ID1=F3.ID1 and F2.ID2=F3.ID2)
order by F1.ID1, F2.ID2;

## insert

Insert into Friend
	Select distinct F1.ID1 as A, F2.ID2 as C
	From Friend F1 join Friend F2 on F1.ID2=F2.ID1
	where F1.ID1 <> F2. ID2 
	and not exists (Select * 
					From Friend F3
					Where F1.ID1=F3.ID1 and F2.ID2=F3.ID2)
	order by F1.ID1, F2.ID2

## solution for sqllite with except

insert into friend
select f1.id1, f2.id2
from friend f1 join friend f2 on f1.id2 = f2.id1
where f1.id1 <> f2.id2
except
select * from friend;