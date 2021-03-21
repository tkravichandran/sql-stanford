# For every situation where student A likes student B, 
# but student B likes a different student C,
# return the names and grades of A, B, and C.

Select AL.ID1,AL.ID2,BL.ID1,BL.ID2
From Likes AL join Likes BL on AL.ID2=BL.ID1
where AL.ID1<>BL.ID2;

## with all the fluss
Select A.name, A.grade, B.name, B.grade, C.name,C.grade
From Likes AL join Likes BL on AL.ID2=BL.ID1
join Highschooler A on A.ID=AL.ID1
join Highschooler B on B.ID=AL.ID2
join Highschooler C on C.ID=BL.ID2
where AL.ID1<>BL.ID2;

# Find those students for whom all of their friends are in different grades from themselves. 
# Return the students' names and grades.

SELECT distinct name, grade
FROM Highschooler h1 join Friend F1 on h1.ID=F1.ID1
where not exists (select *
			FROM Highschooler h2 join Friend F2 on h2.ID=F2.ID2
            Where F1.ID1 = F2.ID1 and h2.grade=h1.grade)
order by grade, h1.name;

# What is the average number of friends per student? 

Select ID1, Count(ID2) as Ct_ID2
From Friend 
group by ID1;

Select Avg(Ct_ID2)
From (Select ID1, Count(ID2) as Ct_ID2
		From Friend 
		group by ID1) as pandian;
        
# Find the number of students who are either friends with Cassandra 
# or are friends of friends of Cassandra. 
# Do not count Cassandra, even though technically she is a friend of a friend.

Select F1.ID1, F1.ID2, F2.ID2
From Friend F1 join Friend F2 on F1.ID2=F2.ID1
order by F1.ID1, F1.ID2, F2.ID2;

Select F1.ID1, F1.ID2, F2.ID2
From Friend F1 join Friend F2 on F1.ID2=F2.ID1
where F1.ID1=1709 and F2.ID2<>1709
order by F1.ID1, F1.ID2, F2.ID2;

## baba counting
Select Count(distinct F1.ID2)+ Count(F2.ID2)
From Friend F1 join Friend F2 on F1.ID2=F2.ID1
where F1.ID1=1709 and F2.ID2<>1709
order by F1.ID1, F1.ID2, F2.ID2;

## with high schooler name

Select Count(distinct F1.ID2)+ Count(F2.ID2)
From Friend F1 
join Friend F2 on F1.ID2=F2.ID1
join Highschooler A on A.ID=F1.ID1
join Highschooler B on B.ID=F1.ID2
join Highschooler C on C.ID=F2.ID2
where A.name='Cassandra' and C.name!='Cassandra';


# Find the name and grade of the student(s) with the greatest number of friends.

## friend count
Select name,grade, ID1, Count(ID2) as Ct_ID2
	From Friend F1 join Highschooler A on A.ID=F1.ID1
	group by ID1, name, grade
    order by Ct_ID2 desc;

Select name, grade, Ct_ID2
From (
	Select name,grade, ID1, Count(ID2) as Ct_ID2
	From Friend F1 join Highschooler A on A.ID=F1.ID1
	group by ID1, name, grade
    ) as pandian
where Ct_ID2 in (select Max(Ct_ID2) 
				From (select Count(ID2) as Ct_ID2
					From Friend F2
					group by ID1) as pandian2)



