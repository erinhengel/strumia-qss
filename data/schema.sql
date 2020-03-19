PRAGMA foreign_keys=off;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS Article;
CREATE TABLE Article (
	ArticleID INTEGER PRIMARY KEY NOT NULL,
	arXivID INTEGER,
	PubDate FLOAT(53),
	Title TEXT,
	arXivDate FLOAT(53),
	AuthorN INTEGER,
	RefN INTEGER,
	Cite INTEGER,
	PageRank FLOAT(53),
	PageRankNoSelf FLOAT(53),
	iCite FLOAT(53)
);

DROP TABLE IF EXISTS AuthorCorr;
CREATE TABLE AuthorCorr (
	ArticleID INTEGER NOT NULL,
	AuthorID INTEGER NOT NULL,
	PRIMARY KEY (ArticleID, AuthorID)
);

DROP TABLE IF EXISTS Author;
CREATE TABLE Author (
	AuthorID INTEGER PRIMARY KEY NOT NULL,
	Gender VARCHAR(6),
	Name VARCHAR(1026),
	Country CHAR(2),
	LeftHEP VARCHAR(5)
);

DROP TABLE IF EXISTS Alias;
CREATE TABLE Alias (
	AuthorID INTEGER NOT NULL,
	Alias VARCHAR(1026),
	PRIMARY KEY (AuthorID, Alias)
);

DROP TABLE IF EXISTS JournalCorr;
CREATE TABLE JournalCorr (
	ArticleID INTEGER NOT NULL,
	JournalID INTEGER NOT NULL,
	PRIMARY KEY (ArticleID, JournalID)
);

COMMIT;
PRAGMA foreign_keys=on;