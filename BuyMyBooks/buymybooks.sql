DROP DATABASE IF EXISTS buymybooks;
CREATE DATABASE  buymybooks;
\c buymybooks;

CREATE EXTENSION pgcrypto;

--
-- Table structure for table City
--

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  email TEXT PRIMARY KEY,
  firstname TEXT NOT NULL,
  lastname TEXT NOT NULL,
  school TEXT NOT NULL,
  password TEXT NOT NULL
) ;

DROP TABLE IF EXISTS listedbooks;
CREATE TABLE listedbooks (
  bookid SERIAL PRIMARY KEY,
  isbn TEXT NOT NULL,
  title TEXT NOT NULL,
  price MONEY NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  pictureurl TEXT,
  userid TEXT NOT NULL REFERENCES users(email),
  sold BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS authors;
CREATE TABLE authors (
  authorid SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

DROP TABLE IF EXISTS authortobook;
CREATE TABLE authortobook (
  authorid INT NOT NULL REFERENCES authors(authorid),
  bookid INT NOT NULL REFERENCES listedbooks(bookid)
);

DROP TABLE IF EXISTS soldbooks;
CREATE TABLE soldbooks (
  bookid INT NOT NULL REFERENCES listedbooks(bookid),
  userid TEXT NOT NULL REFERENCES users(email),
  purchasedate DATE NOT NULL
);

DROP TABLE IF EXISTS cart;
CREATE TABLE cart(
  bookid INT NOT NULL REFERENCES listedbooks(bookid),
  userid TEXT NOT NULL REFERENCES users(email)
);
  

INSERT INTO users VALUES ('lcarter@mail.com', 'Lisa', 'Carter', 'University of Mary Washington', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('sholt@mail.com', 'Steve', 'Holt', 'University of Southern California', crypt('password', gen_salt('bf')));

INSERT INTO authors (name) VALUES ('Marty Knorre');
INSERT INTO authors (name) VALUES ('Thalia Dorwick');
INSERT INTO authors (name) VALUES ('Ana Maria Perez-Girones');
INSERT INTO authors (name) VALUES ('William R. Glass');
INSERT INTO authors (name) VALUES ('Hildebrando Villarreal');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0073534420', 'Puntos de Partida', '10', 'Foreign Language', '', 'http://ecx.images-amazon.com/images/I/51WykD8deWL._SX398_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid) VALUES (1, 1);
INSERT INTO authortobook (authorid, bookid) VALUES (2, 1);
INSERT INTO authortobook (authorid, bookid) VALUES (3, 1);
INSERT INTO authortobook (authorid, bookid) VALUES (4, 1);
INSERT INTO authortobook (authorid, bookid) VALUES (5, 1);

INSERT INTO authors (name) VALUES ('James F. Kurose');
INSERT INTO authors (name) VALUES ('Keith W. Ross');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0132856204', 'Computer Networking', '40', 'Computer Science', '', 'http://ecx.images-amazon.com/images/I/51xfeAQU6dL._SX414_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid) VALUES (6, 2);
INSERT INTO authortobook (authorid, bookid) VALUES (7, 2);

INSERT INTO authors (name) VALUES ('Lynn Beighley');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0596526849', 'Head First SQL', '10', 'Computer Science', '', 'http://ecx.images-amazon.com/images/I/51F8NgTHQOL._SX431_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid) VALUES (8, 3);

INSERT INTO authors (name) VALUES ('Luke Eric Lassiter');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0759111537', 'Invitation to Anthropology', '10', 'Anthropology', '', 'http://ecx.images-amazon.com/images/I/41wPfysCLDL._SX331_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid) VALUES (9, 4);

DROP ROLE IF EXISTS bookuser;
CREATE ROLE bookuser LOGIN PASSWORD 'Lv+;92>&';
GRANT SELECT, INSERT on users TO bookuser;
GRANT SELECT, INSERT, UPDATE on listedbooks TO bookuser;
GRANT SELECT, INSERT on authors TO bookuser;
GRANT SELECT, INSERT on authortobook TO bookuser;
GRANT USAGE on listedbooks_bookid_seq TO bookuser;
GRANT USAGE on authors_authorid_seq TO bookuser;
GRANT SELECT, INSERT on soldbooks TO bookuser;
GRANT SELECT, INSERT, UPDATE, DELETE on cart TO bookuser;


