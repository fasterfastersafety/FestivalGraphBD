USE master;
GO
DROP DATABASE IF EXISTS FestivalGraphDB;
GO
CREATE DATABASE FestivalGraphDB;
GO
USE FestivalGraphDB;
GO

-- 1. СОЗДАНИЕ ТАБЛИЦ УЗЛОВ 

CREATE TABLE Stage (
    StageID INT PRIMARY KEY,
    StageName NVARCHAR(100),
    Capacity INT
) AS NODE;

CREATE TABLE Band (
    BandID INT PRIMARY KEY,
    BandName NVARCHAR(100),
    Genre NVARCHAR(50)
) AS NODE;

CREATE TABLE TechStaff (
    StaffID INT PRIMARY KEY,
    FullName NVARCHAR(100),
    Role NVARCHAR(50)
) AS NODE;

-- 2. СОЗДАНИЕ ТАБЛИЦ РЁБЕР

CREATE TABLE PerformsOn (
    StartTime TIME,
    EndTime TIME
) AS EDGE;

CREATE TABLE ServesAt (
    ShiftType NVARCHAR(50)
) AS EDGE;

CREATE TABLE RecommendsBand (
    Reason NVARCHAR(100)
) AS EDGE;

-- 3. ЗАПОЛНЕНИЕ УЗЛОВ

INSERT INTO Stage (StageID, StageName, Capacity) VALUES
(1, 'Main Stage', 50000), (2, 'Rock Arena', 15000), (3, 'Indie Tent', 5000),
(4, 'Electronic Dome', 20000), (5, 'Acoustic Lounge', 1000), (6, 'Metal Forge', 12000),
(7, 'Jazz Corner', 3000), (8, 'Local Talent Stage', 2000), (9, 'VIP Hall', 500),
(10, 'Open Air Field', 35000);

INSERT INTO Band (BandID, BandName, Genre) VALUES
(1, 'The Rockers', 'Rock'), (2, 'Electro Mages', 'Electronic'), (3, 'Acoustic Soul', 'Acoustic'),
(4, 'Metal Titans', 'Metal'), (5, 'Jazz Hands', 'Jazz'), (6, 'Indie Dreamers', 'Indie'),
(7, 'Pop Idols', 'Pop'), (8, 'Blues Brothers', 'Blues'), (9, 'Techno Vibe', 'Electronic'),
(10, 'Folk Tales', 'Folk'), (11, 'Synth Wave', 'Electronic');

INSERT INTO TechStaff (StaffID, FullName, Role) VALUES
(1, 'Ivanov Ivan', 'Sound Engineer'), (2, 'Petrov Petr', 'Lighting Technician'),
(3, 'Smirnov Alex', 'Stage Manager'), (4, 'Sokolova Anna', 'Security Lead'),
(5, 'Kozlov Egor', 'Pyrotechnics'), (6, 'Morozov Dmitry', 'Sound Engineer'),
(7, 'Volkova Maria', 'Lighting Technician'), (8, 'Lebedev Sergey', 'Stage Manager'),
(9, 'Novikov Pavel', 'Rigging Specialist'), (10, 'Zaitsev Anton', 'Catering Coord');

-- 4. УСТАНОВКА СВЯЗЕЙ МЕЖДУ УЗЛАМИ

-- Связь: Группа выступает на Сцене
INSERT INTO PerformsOn ($from_id, $to_id, StartTime, EndTime) VALUES
((SELECT $node_id FROM Band WHERE BandName = 'The Rockers'), (SELECT $node_id FROM Stage WHERE StageName = 'Main Stage'), '18:00', '19:30'),
((SELECT $node_id FROM Band WHERE BandName = 'Pop Idols'), (SELECT $node_id FROM Stage WHERE StageName = 'Main Stage'), '20:00', '21:30'),
((SELECT $node_id FROM Band WHERE BandName = 'Electro Mages'), (SELECT $node_id FROM Stage WHERE StageName = 'Electronic Dome'), '22:00', '02:00'),
((SELECT $node_id FROM Band WHERE BandName = 'Techno Vibe'), (SELECT $node_id FROM Stage WHERE StageName = 'Electronic Dome'), '02:00', '05:00'),
((SELECT $node_id FROM Band WHERE BandName = 'Metal Titans'), (SELECT $node_id FROM Stage WHERE StageName = 'Metal Forge'), '19:00', '21:00'),
((SELECT $node_id FROM Band WHERE BandName = 'Indie Dreamers'), (SELECT $node_id FROM Stage WHERE StageName = 'Indie Tent'), '17:00', '18:30'),
((SELECT $node_id FROM Band WHERE BandName = 'Jazz Hands'), (SELECT $node_id FROM Stage WHERE StageName = 'Jazz Corner'), '16:00', '18:00'),
((SELECT $node_id FROM Band WHERE BandName = 'Acoustic Soul'), (SELECT $node_id FROM Stage WHERE StageName = 'Acoustic Lounge'), '14:00', '15:30');

-- Связь: Персонал обслуживает Сцену
INSERT INTO ServesAt ($from_id, $to_id, ShiftType) VALUES
((SELECT $node_id FROM TechStaff WHERE FullName = 'Ivanov Ivan'), (SELECT $node_id FROM Stage WHERE StageName = 'Main Stage'), 'Night Shift'),
((SELECT $node_id FROM TechStaff WHERE FullName = 'Petrov Petr'), (SELECT $node_id FROM Stage WHERE StageName = 'Main Stage'), 'Night Shift'),
((SELECT $node_id FROM TechStaff WHERE FullName = 'Smirnov Alex'), (SELECT $node_id FROM Stage WHERE StageName = 'Electronic Dome'), 'Night Shift'),
((SELECT $node_id FROM TechStaff WHERE FullName = 'Morozov Dmitry'), (SELECT $node_id FROM Stage WHERE StageName = 'Metal Forge'), 'Evening Shift'),
((SELECT $node_id FROM TechStaff WHERE FullName = 'Volkova Maria'), (SELECT $node_id FROM Stage WHERE StageName = 'Indie Tent'), 'Day Shift');

-- Связь: Группа рекомендует другую Группу
INSERT INTO RecommendsBand ($from_id, $to_id, Reason) VALUES
((SELECT $node_id FROM Band WHERE BandName = 'Acoustic Soul'), (SELECT $node_id FROM Band WHERE BandName = 'Folk Tales'), 'Схожий стиль'),
((SELECT $node_id FROM Band WHERE BandName = 'Folk Tales'), (SELECT $node_id FROM Band WHERE BandName = 'Indie Dreamers'), 'Отличные тексты'),
((SELECT $node_id FROM Band WHERE BandName = 'Indie Dreamers'), (SELECT $node_id FROM Band WHERE BandName = 'The Rockers'), 'Мощная энергетика'),
((SELECT $node_id FROM Band WHERE BandName = 'The Rockers'), (SELECT $node_id FROM Band WHERE BandName = 'Metal Titans'), 'Тяжелый звук'),
((SELECT $node_id FROM Band WHERE BandName = 'Electro Mages'), (SELECT $node_id FROM Band WHERE BandName = 'Techno Vibe'), 'Крутые биты'),
((SELECT $node_id FROM Band WHERE BandName = 'Techno Vibe'), (SELECT $node_id FROM Band WHERE BandName = 'Synth Wave'), 'Классика электроники');

-- 5. ПЯТЬ ЗАПРОСОВ С ИСПОЛЬЗОВАНИЕМ MATCH 

-- 1. Какие группы выступают на 'Main Stage'?
SELECT b.BandName, b.Genre, p.StartTime, p.EndTime 
FROM Band b, PerformsOn p, Stage s 
WHERE MATCH(b-(p)->s) AND s.StageName = 'Main Stage';

-- 2. Какой персонал обслуживает сцены, где выступают 'Electronic' группы?
SELECT DISTINCT t.FullName, t.Role, s.StageName 
FROM Band b, PerformsOn p, Stage s, ServesAt sa, TechStaff t 
WHERE MATCH(b-(p)->s<-(sa)-t) AND b.Genre = 'Electronic';

-- 3. Какие сцены обслуживает 'Ivanov Ivan' и какие группы он там услышит?
SELECT s.StageName, b.BandName, p.StartTime 
FROM TechStaff t, ServesAt sa, Stage s, PerformsOn p, Band b 
WHERE MATCH(t-(sa)->s<-(p)-b) AND t.FullName = 'Ivanov Ivan';

-- 4. Кого рекомендует группа 'Acoustic Soul'?
SELECT b2.BandName AS RecommendedBand, r.Reason 
FROM Band b1, RecommendsBand r, Band b2 
WHERE MATCH(b1-(r)->b2) AND b1.BandName = 'Acoustic Soul';

-- 5. Какие группы играют на сценах вместимостью больше 10000 человек?
SELECT b.BandName, s.StageName, s.Capacity 
FROM Band b, PerformsOn p, Stage s 
WHERE MATCH(b-(p)->s) AND s.Capacity > 10000;

-- 6. ДВА ЗАПРОСА С ИСПОЛЬЗОВАНИЕМ SHORTEST_PATH

-- 1. Кратчайший путь рекомендаций (любое количество шагов "+") от 'Acoustic Soul'
SELECT 
    b1.BandName AS StartBand, 
    STRING_AGG(b2.BandName, ' -> ') WITHIN GROUP (GRAPH PATH) AS RecommendationChain 
FROM 
    Band AS b1, 
    RecommendsBand FOR PATH AS r, 
    Band FOR PATH AS b2 
WHERE MATCH(SHORTEST_PATH(b1(-(r)->b2)+)) 
  AND b1.BandName = 'Acoustic Soul';

-- 2. Путь рекомендаций от 'Acoustic Soul' с ограничением в 1-2 шага "{1,2}"
SELECT 
    b1.BandName AS StartBand, 
    STRING_AGG(b2.BandName, ' -> ') WITHIN GROUP (GRAPH PATH) AS RecommendationChain 
FROM 
    Band AS b1, 
    RecommendsBand FOR PATH AS r, 
    Band FOR PATH AS b2 
WHERE MATCH(SHORTEST_PATH(b1(-(r)->b2){1,2})) 
  AND b1.BandName = 'Acoustic Soul';
GO