# Find the names of all students who are friends with someone named Gabriel.

Select name,ID,ID1,ID2
From (select name,ID,ID1,ID2
		From Highschooler join Friend on Highschooler.ID=Friend.ID1
		where name = 'Gabriel') as S1;
        

Select S1.name,S1.ID,ID1,ID2, HS.name,HS.ID
From (select name,ID,ID1,ID2
		From Highschooler HS join Friend on HS.ID=Friend.ID1
		where name = 'Gabriel') as S1 join Highschooler HS on HS.ID=S1.ID2;
        
Select distinct HS.name
From (select name,ID,ID1,ID2
		From Highschooler HS join Friend on HS.ID=Friend.ID1
		where name = 'Gabriel') as S1 join Highschooler HS on HS.ID=S1.ID2;

## another solution by someone else (very elegant) how to look up
SELECT name 
FROM Highschooler h
JOIN Friend f
ON f.ID1 = h.ID
WHERE f.ID2 in (
	SELECT ID 
	FROM Highschooler 
	WHERE name = "Gabriel");
    
# For every student who likes someone 2 or more grades younger than themselves, 
# return that student's name and grade, and the name and grade of the student they like.

select * FROM Likes L join Highschooler HS on L.ID1=HS.ID;

Select t1.grade,t1.name,t1.ID1,t2.name,t2.ID2,t2.grade
From (select name,ID1,grade FROM Likes L join Highschooler HS on L.ID1=HS.ID) as t1 
join (select name,ID1,ID2,grade FROM Likes L join Highschooler HS on L.ID2=HS.ID) as t2 using(ID1)
where t1.grade>=t2.grade+2;

## submission
Select t1.name, t1.grade,t2.name,t2.grade
From (select name,ID1,grade FROM Likes L join Highschooler HS on L.ID1=HS.ID) as t1 
join (select name,ID1,ID2,grade FROM Likes L join Highschooler HS on L.ID2=HS.ID) as t2 using(ID1)
where t1.grade>=t2.grade+2;

## elegant solutions from iets anders

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM Highschooler h1
JOIN Likes l
ON h1.ID = l.ID1
JOIN Highschooler h2
ON h2.ID = l.ID2
WHERE h1.grade >=h2.grade+2;


# For every pair of students who both like each other, return the name and grade of both students. 
# Include each pair only once, with the two names in alphabetical order.

SELECT *
FROM (select h1.name as n1, h1.grade g1,ID1,ID2, h2.name as n2, h2.grade g2 from Highschooler h1 
	JOIN Likes l
	ON h1.ID = l.ID1
	JOIN Highschooler h2
	ON h2.ID = l.ID2) as t1
where exists (select * from Likes l1
		where t1.ID2=l1.ID1 and t1.ID1=l1.ID2 and t1.n1<t1.n2);


## more elegant solution

SELECT h1.name, h1.grade, h2.name, h2.grade
FROM Highschooler h1
JOIN Likes l1 on h1.ID = l1.ID1
JOIN Highschooler h2 on h2.ID = l1.ID2 
JOIN Likes l2 on l2.ID1 = l1.ID2 and l1.ID1 = l2.ID2 
WHERE h1.name < h2.name;

# Find all students who do not appear in the Likes table 
# (as a student who likes or is liked) 
# and return their names and grades. 
# Sort by grade, then by name within each grade.

select ID1 
From Likes
union
select ID2
From Likes;

Select name, grade
From Highschooler
WHERE ID not in (select ID1
				From Likes
                union
                select ID2 
                From Likes);


## eleganter solution

Select name, grade
From Highschooler HS left outer join Likes L1 on HS.ID=L1.ID1 or HS.ID=L1.ID2
WHERE L1.ID1 IS NULL
ORDER BY HS.grade, HS.name;

# For every situation where student A likes student B, 
# but we have no information about whom B likes 
#(that is, B does not appear as an ID1 in the Likes table), 
# return A and B's names and grades.


SELECT distinct h1.name, h1.grade,l1.ID1,l1.ID2, h2.name, h2.grade
FROM Highschooler h1
JOIN Likes l1 on h1.ID = l1.ID1
JOIN Highschooler h2 on h2.ID = l1.ID2 
Where l1.ID2 not in (select ID1 From Likes);

# Find names and grades of students who only have friends in the same grade. 
# Return the result sorted by grade, then by name within each grade.

select h1.name n1, h1.grade g1, h2.name n2, h2.grade g2
FROM Highschooler h1
JOIN Friend l1 on h1.ID = l1.ID1
JOIN Highschooler h2 on h2.ID = l1.ID2; 

SELECT distinct name, grade
FROM Highschooler h1 join Friend F1 on h1.ID=F1.ID1
where not exists (select *
			FROM Highschooler h2 join Friend F2 on h2.ID=F2.ID2
            Where F1.ID1 = F2.ID1 and h2.grade<>h1.grade)
order by grade, h1.name;

# For each student A who likes a student B where the two are not friends, 
# find if they have a friend C in common (who can introduce them!).
# For all such trios, return the name and grade of A, B, and C.

Select count(*)
From Friend;

Select L1.ID1,L1.ID2,F1.ID1,F1.ID2
From Likes L1 join Friend F1 using(ID1,ID2);

## For each student A who likes a student B where the two are not friends
Select L1.ID1,L1.ID2,F1.ID1,F1.ID2
From Likes L1 left outer join Friend F1 using(ID1,ID2)
where F1.ID1 is Null;

## Complexcated and returns the common friends
Select NFID1, NFID2, F2.ID2, F3.ID2
From (Select L1.ID1 NFID1,L1.ID2 NFID2
From Likes L1 left outer join Friend F1 using(ID1,ID2)
where F1.ID1 is Null) as NF join Friend F2 on NF.NFID1= F2.ID1 join Friend F3 on NF.NFID2=F3.ID1
where F2.ID2 = F3.ID2;


Select NFID1, NFID2, F2.ID2 as CF,C.name,C.grade
From (Select L1.ID1 NFID1,L1.ID2 NFID2
From Likes L1 left outer join Friend F1 using(ID1,ID2)
where F1.ID1 is Null) as NF join Friend F2 on NF.NFID1= F2.ID1 join Friend F3 on NF.NFID2=F3.ID1
join Highschooler A on A.ID=NF.NFID1
join Highschooler B on B.ID=NF.NFID2
join Highschooler C on C.ID=F2.ID2
where F2.ID2 = F3.ID2;


# final form

Select A.name, A.grade, B.name, B.grade, C.name,C.grade
From (Select L1.ID1 NFID1,L1.ID2 NFID2
From Likes L1 left outer join Friend F1 using(ID1,ID2)
where F1.ID1 is Null) as NF join Friend F2 on NF.NFID1= F2.ID1 join Friend F3 on NF.NFID2=F3.ID1
join Highschooler A on A.ID=NF.NFID1
join Highschooler B on B.ID=NF.NFID2
join Highschooler C on C.ID=F2.ID2
where F2.ID2 = F3.ID2;


Select L1.ID1,L1.ID2,F1.ID2
From Likes L1 join Friend F1 using(ID1)
Where not exists (select *
					From Friend);



# Find the difference between the number of students in the school and the number of different first names.
SELECT COUNT(ID)-COUNT(DISTINCT name) 
FROM Highschooler;

# Find the name and grade of all students who are liked by more than one other student.

Select name, grade
From Highschooler
where ID in (Select ID2
From Likes
group by ID2
having count(ID1)>1)
























