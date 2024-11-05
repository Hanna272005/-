USE master
GO
DROP DATABASE  IF EXISTS LABA;
CREATE DATABASE [LABA];
GO
USE [LABA];

GO
--проверка существование таблицы
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'KLIENT')
DROP TABLE KLIENT;
CREATE TABLE dbo.KLIENT
(
    IDklient INT NOT NULL,
    FIO VARCHAR(50) NOT NULL,
    KOLICHPOSESH INT NOT NULL,
    Telefon VARCHAR(50) NOT NULL,
    DATAZAPIS DATE NOT NULL,
    CONSTRAINT PK_KLIENT_IDklient PRIMARY KEY (IDklient)
);
ALTER TABLE dbo.KLIENT ADD CONSTRAINT CK_KLIENT_KOLICHPOSESH CHECK (KOLICHPOSESH > 0 AND KOLICHPOSESH < 10000);
GO

-- Вставка данных в таблицу KLIENT
INSERT INTO dbo.KLIENT (IDklient, FIO, KOLICHPOSESH, Telefon, DATAZAPIS)
VALUES 
(1, 'Иванов Иван Иванович', 5, '1234567890', '2023-05-01'),
(2, 'Петров Петр Петрович', 3, '2345678901', '2023-05-02'),
(3, 'Сидоров Сидор Сидорович', 2, '3456789012', '2023-05-03'),
(4, 'Кузнецов Алексей Алексеевич', 4, '4567890123', '2023-05-04'),
(5, 'Михайлов Михаил Михайлович', 6, '5678901234', '2023-06-05'),
(6, 'Дирко Кристина Юрьевна', 1, '5678901234', '2023-06-01'),
(7, 'Лепс Дмитрий Зурабович', 1, '5678901234', '2023-06-10'),
(8, 'Будевич Марк Валерьевич', 2, '5678901234', '2023-07-05'),
(9, 'Апекунова Анастасия Александровна', 3, '5678901234', '2023-09-05'),
(10, 'Журов Богдан Витальевич', 5, '5665901234', '2023-09-05');

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TIPSTRIZHKI')
DROP TABLE TIPSTRIZHKI;
CREATE TABLE dbo.TIPSTRIZHKI
(
    IDTIPSTRIZH INT NOT NULL,
    NAZV VARCHAR(50) NOT NULL,
    CONSTRAINT PK_TIPSTRIZHKI_IDTIPSTRIZH PRIMARY KEY (IDTIPSTRIZH)
);
GO

-- Вставка данных в таблицу TIPSTRIZHKI
INSERT INTO dbo.TIPSTRIZHKI (IDTIPSTRIZH, NAZV)
VALUES 
(1, 'Короткая стрижка'),
(2, 'Средняя стрижка'),
(3, 'Длинная стрижка'),
(4, 'Мужская стрижка'),
(5, 'Женская стрижка');

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'STRIZHKA')
DROP TABLE STRIZHKA;
CREATE TABLE dbo.STRIZHKA
(
    IDSTRIZH INT NOT NULL,
    NAZV VARCHAR(50) NOT NULL,
    SLOZHNOST VARCHAR(5) NOT NULL,
    IDTIPSTRIZH INT NOT NULL,
    POL VARCHAR(1) NOT NULL,
    CONSTRAINT PK_STRIZHKA_IDSTRIZH PRIMARY KEY (IDSTRIZH),
   
);
ALTER TABLE dbo.STRIZHKA ADD CONSTRAINT FK_STRIZHKA_IDTIPSTRIZH FOREIGN KEY (IDTIPSTRIZH) REFERENCES dbo.TIPSTRIZHKI(IDTIPSTRIZH) ON DELETE CASCADE ON UPDATE CASCADE;
-- Добавление ограничений через ALTER TABLE
ALTER TABLE STRIZHKA ADD CONSTRAINT CS_POL CHECK (POL IN ('М', 'Ж'));
ALTER TABLE STRIZHKA ADD CONSTRAINT CS_SLOZHNOST CHECK (SLOZHNOST IN ('HARD', 'EASY'));
GO

-- Вставка данных в таблицу STRIZHKA
INSERT INTO dbo.STRIZHKA (IDSTRIZH, NAZV, SLOZHNOST, IDTIPSTRIZH, POL)
VALUES 
(1, 'Боб', 'EASY', 1, 'Ж'),
(2, 'Каре', 'HARD', 2, 'Ж'),
(3, 'Пикси', 'EASY', 3, 'Ж'),
(4, 'Классическая мужская', 'HARD', 4, 'М'),
(5, 'Спортивная', 'EASY', 4, 'М'),
(6, 'Волнистая', 'HARD', 5, 'Ж'),
(7, 'Гаврош', 'EASY', 1, 'Ж'),
(8, 'Цезарь', 'HARD', 4, 'М'),
(9, 'Каскад', 'EASY', 3, 'Ж'),
(10, 'Андеркат', 'HARD', 4, 'М'),
(11, 'Лесенка', 'EASY', 3, 'Ж'),
(12, 'Фейд', 'HARD', 4, 'М'),
(13, 'Бокс', 'EASY', 4, 'М'),
(14, 'Полубокс', 'HARD', 4, 'М'),
(15, 'Паж', 'EASY', 2, 'Ж');


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PHOTO')
DROP TABLE PHOTO;
CREATE TABLE dbo.PHOTO
(
    IDPHOTO INT  NOT NULL,
    NAZV VARCHAR(50) NOT NULL,
    IDSTRIZH INT NOT NULL,
    CONSTRAINT PK_PHOTO_IDPHOTO PRIMARY KEY (IDPHOTO),
    CONSTRAINT FK_PHOTO_IDSTRIZH FOREIGN KEY (IDSTRIZH) REFERENCES dbo.STRIZHKA(IDSTRIZH) ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- Вставка данных в таблицу PHOTO
INSERT INTO dbo.PHOTO (IDPHOTO, NAZV, IDSTRIZH)
VALUES 
(1, 'Боб',  1),
(2, 'Каре',  2),
(3, 'Пикси', 3),
(4, 'Классическая мужская', 4),
(5, 'Спортивная', 5),
(6, 'Волнистая', 6),
(1, 'Боб',  7);


IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ZAPIS')
DROP TABLE ZAPIS;
CREATE TABLE dbo.ZAPIS
(
    DATAVREMZAP DATETIME NOT NULL,
    IDZAP INT NOT NULL,
    IDklient INT NOT NULL,
    IDSTRIZH INT NOT NULL,
    CONSTRAINT PK_ZAPIS_IDZAP PRIMARY KEY (IDZAP),
    CONSTRAINT FK_ZAPIS_IDKLIENT FOREIGN KEY (IDklient) REFERENCES dbo.KLIENT(IDklient) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_ZAPIS_IDSTRIZH FOREIGN KEY (IDSTRIZH) REFERENCES dbo.STRIZHKA(IDSTRIZH) ON DELETE CASCADE ON UPDATE CASCADE
);
GO


-- Вставка данных в таблицу ZAPIS используя SELECT
INSERT INTO dbo.ZAPIS (DATAVREMZAP, IDZAP, IDklient, IDSTRIZH)
values ('2023-06-01 10:00', 1, (select IDklient from KLIENT where FIO='Дирко Кристина Юрьевна'),(select IDSTRIZH from STRIZHKA where NAZV = 'Боб')),
('2023-09-05 12:00', 2, (select IDklient from KLIENT where FIO='Апекунова Анастасия Александровна'),(select IDSTRIZH from STRIZHKA where NAZV = 'Каре')),
('2023-06-10 15:00', 3, (select IDklient from KLIENT where FIO='Лепс Дмитрий Зурабович'),(select IDSTRIZH from STRIZHKA where NAZV = 'Пикси')),
('2023-07-05 10:00', 4, (select IDklient from KLIENT where FIO='Будевич Марк Валерьевич'),(select IDSTRIZH from STRIZHKA where NAZV = 'Классическая мужская')),
('2023-05-03 11:30', 5, (select IDklient from KLIENT where FIO='Сидоров Сидор Сидорович'),(select IDSTRIZH from STRIZHKA where NAZV = 'Спортивная')),
('2023-05-01 14:50', 6, (select IDklient from KLIENT where FIO='Иванов Иван Иванович'),(select IDSTRIZH from STRIZHKA where NAZV = 'Волнистая')),
('2023-06-05 10:25', 7, (select IDklient from KLIENT where FIO='Михайлов Михаил Михайлович'),(select IDSTRIZH from STRIZHKA where NAZV = 'Гаврош')),
('2023-05-04 18:00', 8, (select IDklient from KLIENT where FIO='Кузнецов Алексей Алексеевич'),(select IDSTRIZH from STRIZHKA where NAZV = 'Цезарь'));


-- Обновление данных в таблице KLIENT
UPDATE dbo.KLIENT
SET FIO = 'Иванов Иван Петрович'
WHERE IDklient = 1;

-- Обновление данных в таблице STRIZHKA
UPDATE dbo.STRIZHKA
SET SLOZHNOST = 'HARD'
WHERE IDSTRIZH = 5;

-- Обновление данных в таблице PHOTO
UPDATE dbo.PHOTO
SET NAZV = 'Новое фото'
WHERE IDPHOTO = 1;

-- Обновление данных в таблице ZAPIS
UPDATE dbo.ZAPIS
SET DATAVREMZAP = '2023-07-01 10:00'
WHERE IDZAP = 1;

-- Обновление данных с составным условием
UPDATE dbo.ZAPIS
SET IDklient = 3
WHERE IDSTRIZH = 4 AND DATAVREMZAP = '2023-06-04 13:00';


-- Удаление данных из таблицы KLIENT
DELETE FROM dbo.KLIENT
WHERE IDklient = 5;

-- Удаление данных из таблицы TIPSTRIZHKI
DELETE FROM dbo.TIPSTRIZHKI
WHERE IDTIPSTRIZH = 5;

-- Удаление данных из таблицы STRIZHKA
DELETE FROM dbo.STRIZHKA
WHERE IDSTRIZH = 15;

-- Удаление данных из таблицы PHOTO
DELETE FROM dbo.PHOTO
WHERE IDPHOTO = 10;

-- Удаление данных из таблицы ZAPIS
DELETE FROM dbo.ZAPIS
WHERE IDZAP = 15;

