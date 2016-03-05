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
  id SERIAL PRIMARY KEY,
  isbn TEXT NOT NULL,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  price MONEY NOT NULL,
  subject TEXT NOT NULL,
  description TEXT,
  pictureurl TEXT,
  userid TEXT NOT NULL REFERENCES users(email),
  sold BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS soldbooks;
CREATE TABLE soldbooks (
  bookid INT NOT NULL REFERENCES listedbooks(id),
  userid TEXT NOT NULL REFERENCES users(email),
  purchasedate DATE NOT NULL
);

DROP TABLE IF EXISTS cart;
CREATE TABLE cart(
  bookid INT NOT NULL REFERENCES listedbooks(id),
  userid TEXT NOT NULL REFERENCES users(email)
);
  

INSERT INTO users VALUES ('lcarter@mail.com', 'Lisa', 'Carter', 'University of Mary Washington', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('sholt@mail.com', 'Steve', 'Holt', 'University of Southern California', crypt('password', gen_salt('bf')));

INSERT INTO listedbooks (isbn, title, author, price, subject, description, pictureurl, userid ) VALUES ('0596526849', 'Head First SQL', 'Lynn Beighley', '20', 'Computer Science', '', 'https://books.google.com/books/content?id=ZO6MF9Ja1zoC&printsec=frontcover&img=1&zoom=5&edge=curl&imgtk=AFLRE71EpWayqKSolAUG6tzzxQICvYhHdRjbxi8AaAhNb642kn17Tr4wOSbV1S68BIxLaPokCfKuZ_KVrxz9lSEVOBJxk0v8vuw5GUWdMegnSHmFKauZ3ki9lES5s7RrgHOA95lUGUxz', 'lcarter@mail.com');
INSERT INTO listedbooks (isbn, title, author, price, subject, description, pictureurl, userid ) VALUES ('0132856204', 'Computer Networking', 'James Kurose', '50', 'Computer Science', 'Message', 'http://ecx.images-amazon.com/images/I/51xfeAQU6dL._SX414_BO1,204,203,200_.jpg', 'lcarter@mail.com');

DROP ROLE IF EXISTS bookuser;
CREATE ROLE bookuser LOGIN PASSWORD 'Lv+;92>&';
GRANT SELECT, INSERT on users TO bookuser;
GRANT SELECT, INSERT, UPDATE on listedbooks TO bookuser;
GRANT USAGE on listedbooks_id_seq TO bookuser;
GRANT SELECT, INSERT on soldbooks TO bookuser;
GRANT SELECT, INSERT, UPDATE, DELETE on cart TO bookuser;


