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

INSERT INTO users VALUES ('lcarter@mail.com', 'Lisa', 'Carter', 'University of Mary Washington', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('sholt@mail.com', 'Steve', 'Holt', 'University of Southern California', crypt('password', gen_salt('bf')));

DROP ROLE IF EXISTS bookuser;
CREATE ROLE bookuser LOGIN PASSWORD 'Lv+;92>&';
GRANT SELECT, INSERT on users TO bookuser;


