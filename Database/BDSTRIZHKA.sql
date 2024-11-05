USE master
GO
DROP DATABASE  IF EXISTS LABA;
CREATE DATABASE [LABA];
GO
USE [LABA];

GO
--�������� ������������� �������
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

-- ������� ������ � ������� KLIENT
INSERT INTO dbo.KLIENT (IDklient, FIO, KOLICHPOSESH, Telefon, DATAZAPIS)
VALUES 
(1, '������ ���� ��������', 5, '1234567890', '2023-05-01'),
(2, '������ ���� ��������', 3, '2345678901', '2023-05-02'),
(3, '������� ����� ���������', 2, '3456789012', '2023-05-03'),
(4, '�������� ������� ����������', 4, '4567890123', '2023-05-04'),
(5, '�������� ������ ����������', 6, '5678901234', '2023-06-05'),
(6, '����� �������� �������', 1, '5678901234', '2023-06-01'),
(7, '���� ������� ���������', 1, '5678901234', '2023-06-10'),
(8, '������� ���� ����������', 2, '5678901234', '2023-07-05'),
(9, '��������� ��������� �������������', 3, '5678901234', '2023-09-05'),
(10, '����� ������ ����������', 5, '5665901234', '2023-09-05');

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'TIPSTRIZHKI')
DROP TABLE TIPSTRIZHKI;
CREATE TABLE dbo.TIPSTRIZHKI
(
    IDTIPSTRIZH INT NOT NULL,
    NAZV VARCHAR(50) NOT NULL,
    CONSTRAINT PK_TIPSTRIZHKI_IDTIPSTRIZH PRIMARY KEY (IDTIPSTRIZH)
);
GO

-- ������� ������ � ������� TIPSTRIZHKI
INSERT INTO dbo.TIPSTRIZHKI (IDTIPSTRIZH, NAZV)
VALUES 
(1, '�������� �������'),
(2, '������� �������'),
(3, '������� �������'),
(4, '������� �������'),
(5, '������� �������');

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
-- ���������� ����������� ����� ALTER TABLE
ALTER TABLE STRIZHKA ADD CONSTRAINT CS_POL CHECK (POL IN ('�', '�'));
ALTER TABLE STRIZHKA ADD CONSTRAINT CS_SLOZHNOST CHECK (SLOZHNOST IN ('HARD', 'EASY'));
GO

-- ������� ������ � ������� STRIZHKA
INSERT INTO dbo.STRIZHKA (IDSTRIZH, NAZV, SLOZHNOST, IDTIPSTRIZH, POL)
VALUES 
(1, '���', 'EASY', 1, '�'),
(2, '����', 'HARD', 2, '�'),
(3, '�����', 'EASY', 3, '�'),
(4, '������������ �������', 'HARD', 4, '�'),
(5, '����������', 'EASY', 4, '�'),
(6, '���������', 'HARD', 5, '�'),
(7, '������', 'EASY', 1, '�'),
(8, '������', 'HARD', 4, '�'),
(9, '������', 'EASY', 3, '�'),
(10, '��������', 'HARD', 4, '�'),
(11, '�������', 'EASY', 3, '�'),
(12, '����', 'HARD', 4, '�'),
(13, '����', 'EASY', 4, '�'),
(14, '��������', 'HARD', 4, '�'),
(15, '���', 'EASY', 2, '�');


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

-- ������� ������ � ������� PHOTO
INSERT INTO dbo.PHOTO (IDPHOTO, NAZV, IDSTRIZH)
VALUES 
(1, '���',  1),
(2, '����',  2),
(3, '�����', 3),
(4, '������������ �������', 4),
(5, '����������', 5),
(6, '���������', 6),
(1, '���',  7);


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


-- ������� ������ � ������� ZAPIS ��������� SELECT
INSERT INTO dbo.ZAPIS (DATAVREMZAP, IDZAP, IDklient, IDSTRIZH)
values ('2023-06-01 10:00', 1, (select IDklient from KLIENT where FIO='����� �������� �������'),(select IDSTRIZH from STRIZHKA where NAZV = '���')),
('2023-09-05 12:00', 2, (select IDklient from KLIENT where FIO='��������� ��������� �������������'),(select IDSTRIZH from STRIZHKA where NAZV = '����')),
('2023-06-10 15:00', 3, (select IDklient from KLIENT where FIO='���� ������� ���������'),(select IDSTRIZH from STRIZHKA where NAZV = '�����')),
('2023-07-05 10:00', 4, (select IDklient from KLIENT where FIO='������� ���� ����������'),(select IDSTRIZH from STRIZHKA where NAZV = '������������ �������')),
('2023-05-03 11:30', 5, (select IDklient from KLIENT where FIO='������� ����� ���������'),(select IDSTRIZH from STRIZHKA where NAZV = '����������')),
('2023-05-01 14:50', 6, (select IDklient from KLIENT where FIO='������ ���� ��������'),(select IDSTRIZH from STRIZHKA where NAZV = '���������')),
('2023-06-05 10:25', 7, (select IDklient from KLIENT where FIO='�������� ������ ����������'),(select IDSTRIZH from STRIZHKA where NAZV = '������')),
('2023-05-04 18:00', 8, (select IDklient from KLIENT where FIO='�������� ������� ����������'),(select IDSTRIZH from STRIZHKA where NAZV = '������'));


-- ���������� ������ � ������� KLIENT
UPDATE dbo.KLIENT
SET FIO = '������ ���� ��������'
WHERE IDklient = 1;

-- ���������� ������ � ������� STRIZHKA
UPDATE dbo.STRIZHKA
SET SLOZHNOST = 'HARD'
WHERE IDSTRIZH = 5;

-- ���������� ������ � ������� PHOTO
UPDATE dbo.PHOTO
SET NAZV = '����� ����'
WHERE IDPHOTO = 1;

-- ���������� ������ � ������� ZAPIS
UPDATE dbo.ZAPIS
SET DATAVREMZAP = '2023-07-01 10:00'
WHERE IDZAP = 1;

-- ���������� ������ � ��������� ��������
UPDATE dbo.ZAPIS
SET IDklient = 3
WHERE IDSTRIZH = 4 AND DATAVREMZAP = '2023-06-04 13:00';


-- �������� ������ �� ������� KLIENT
DELETE FROM dbo.KLIENT
WHERE IDklient = 5;

-- �������� ������ �� ������� TIPSTRIZHKI
DELETE FROM dbo.TIPSTRIZHKI
WHERE IDTIPSTRIZH = 5;

-- �������� ������ �� ������� STRIZHKA
DELETE FROM dbo.STRIZHKA
WHERE IDSTRIZH = 15;

-- �������� ������ �� ������� PHOTO
DELETE FROM dbo.PHOTO
WHERE IDPHOTO = 10;

-- �������� ������ �� ������� ZAPIS
DELETE FROM dbo.ZAPIS
WHERE IDZAP = 15;

