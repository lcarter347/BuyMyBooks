DROP DATABASE IF EXISTS buymybooks;
CREATE DATABASE  buymybooks;
\c buymybooks;

CREATE EXTENSION pgcrypto;


DROP TABLE IF EXISTS users;
CREATE TABLE users (
  email TEXT PRIMARY KEY CONSTRAINT valid_email CHECK(email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  firstname TEXT NOT NULL CONSTRAINT valid_first_name CHECK(firstname ~* '^[A-Za-z''\-\.\s]+$'),
  lastname TEXT NOT NULL CONSTRAINT valid_last_name CHECK(lastname ~* '^[A-Za-z''\-\.\s]+$'),
  school TEXT NOT NULL CONSTRAINT valid_school CHECK(school ~* '^[A-Za-z''\-\.\s]+$'),
  password TEXT NOT NULL CONSTRAINT valid_password CHECK(password ~* '^.+$')
) ;

DROP TABLE IF EXISTS listedbooks;
CREATE TABLE listedbooks (
  bookid SERIAL PRIMARY KEY,
  isbn TEXT NOT NULL CONSTRAINT valid_isbn CHECK(isbn ~*'^[A-Z0-9\-]{10,14}$'),
  title TEXT NOT NULL CONSTRAINT valid_title CHECK(title ~* '^.+$'),
  price NUMERIC(10, 2) NOT NULL CONSTRAINT valid_price CHECK(price > 0),
  subject TEXT NOT NULL CONSTRAINT valid_subject CHECK(subject ~* '^.+$'),
  description TEXT,
  pictureurl TEXT,
  userid TEXT NOT NULL REFERENCES users(email),
  sold BOOLEAN NOT NULL DEFAULT FALSE
);

DROP TABLE IF EXISTS authors;
CREATE TABLE authors (
  authorid SERIAL PRIMARY KEY,
  name TEXT NOT NULL CONSTRAINT valid_author_name CHECK(name ~* '^[A-Za-z''\-\.\s]+$')
);

DROP TABLE IF EXISTS authortobook;
CREATE TABLE authortobook (
  authorid INT NOT NULL REFERENCES authors(authorid) ON DELETE CASCADE,
  bookid INT NOT NULL REFERENCES listedbooks(bookid) ON DELETE CASCADE,
  priority INTEGER NOT NULL
);

DROP TABLE IF EXISTS soldbooks;
CREATE TABLE soldbooks (
  bookid INT NOT NULL REFERENCES listedbooks(bookid) ON DELETE RESTRICT,
  userid TEXT NOT NULL REFERENCES users(email),
  purchasedate TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

DROP TABLE IF EXISTS cart;
CREATE TABLE cart(
  bookid INT NOT NULL REFERENCES listedbooks(bookid) ON DELETE CASCADE,
  userid TEXT NOT NULL REFERENCES users(email)
);
  

INSERT INTO users VALUES ('lcarter@mail.com', 'Lisa', 'Carter', 'University of Mary Washington', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('sholt@mail.com', 'Steve', 'Holt', 'University of Southern California', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('bderry@mail.com', 'Bob', 'Derry', 'University of Richmond', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('bofur@mail.com', 'Bofur', 'DeSmaug', 'Catsville College', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('lknope@mail.com', 'Leslie ', 'Knope', 'Indiana University', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('bwyatt@mail.com', 'Ben ', 'Wyatt', 'Carleton College', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('thaverford@mail.com', 'Tom', 'Haverford', 'The SWAG Conservatory', crypt('swag', gen_salt('bf')));
INSERT INTO users VALUES ('aperkins@mail.com', 'Ann', 'Perkins', 'Pawnee School of Nursing', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('adwyer@mail.com', 'Andy', 'Dwyer', 'Pawnee Community College', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('aludgate@mail.com', 'April', 'Ludgate', 'Bloomington School of Veterinary Science', crypt('password', gen_salt('bf')));
INSERT INTO users VALUES ('rswanson@mail.com', 'Ron', 'Swanson', 'School of Life', crypt('password', gen_salt('bf')));


INSERT INTO authors (name) VALUES ('Marty Knorre');
INSERT INTO authors (name) VALUES ('Thalia Dorwick');
INSERT INTO authors (name) VALUES ('Ana Maria Perez-Girones');
INSERT INTO authors (name) VALUES ('William R. Glass');
INSERT INTO authors (name) VALUES ('Hildebrando Villarreal');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0073534420', 'Puntos de Partida', '10', 'Foreign Language', '', 'http://ecx.images-amazon.com/images/I/51WykD8deWL._SX398_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (1, 1, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (2, 1, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (3, 1, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (4, 1, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (5, 1, 1);

INSERT INTO authors (name) VALUES ('James F. Kurose');
INSERT INTO authors (name) VALUES ('Keith W. Ross');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0132856204', 'Computer Networking', '40', 'Computer Science', '', 'http://ecx.images-amazon.com/images/I/51xfeAQU6dL._SX414_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (6, 2, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (7, 2, 1);

INSERT INTO authors (name) VALUES ('Lynn Beighley');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0596526849', 'Head First SQL', '10', 'Computer Science', '', 'http://ecx.images-amazon.com/images/I/51F8NgTHQOL._SX431_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (8, 3, 1);

INSERT INTO authors (name) VALUES ('Luke Eric Lassiter');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid ) VALUES ('0759111537', 'Invitation to Anthropology', '10', 'Anthropology', '', 'http://ecx.images-amazon.com/images/I/41wPfysCLDL._SX331_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (9, 4, 1);

INSERT INTO authors (name) VALUES ('Susan Standring');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0702052302', 'Gray''s Anatomy: The Anatomical Basis of Clinical Practice', '80', 'Medical', 'The definitive, comprehensive reference on the medicine.', 'http://ecx.images-amazon.com/images/I/51t4gVZ1hML._SX387_BO1,204,203,200_.jpg', 'aperkins@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (10, 5, 1);

INSERT INTO authors (name) VALUES ('Walter L. Pyle');
INSERT INTO authors (name) VALUES ('George M. Gould');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1124019529', 'Anomalies and Curiosities of Medicine', '15', 'Medical', 'A catalogue of medical marvels going as far back as ancient Rome.', 'http://ecx.images-amazon.com/images/I/51xv5pka8WL._SX331_BO1,204,203,200_.jpg', 'aperkins@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (11, 6, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (12, 6, 1);

INSERT INTO authors (name) VALUES ('M.G. Bulmer');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0486637603', 'Principles of Statistics', '5', 'Mathematics', 'Merges theory and practice at an intermediate level.', 'http://ecx.images-amazon.com/images/I/41Ll5tQN9JL._SX322_BO1,204,203,200_.jpg', 'aperkins@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (13, 7, 1);

INSERT INTO authors (name) VALUES ('Morris Kline');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0486404536', 'Calculus: An Intuitive and Physical Approach', '10', 'Mathematics', 'Application-oriented introduction relates the subject as closely as possible to science.', 'http://ecx.images-amazon.com/images/I/51KTL5IEp8L._SX332_BO1,204,203,200_.jpg', 'aperkins@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (14, 8, 1);

INSERT INTO authors (name) VALUES ('Jane B. Reece');
INSERT INTO authors (name) VALUES ('Lisa A. Urry');
INSERT INTO authors (name) VALUES ('Michael L. Cain');
INSERT INTO authors (name) VALUES ('Steven A. Wasserman');
INSERT INTO authors (name) VALUES ('Peter V. Minorsky');
INSERT INTO authors (name) VALUES ('Robert B. Jackson');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0321775651', 'Campbell Biology', '65', 'Biology', 'Helps launch you to success in biology through its clear and engaging narrative.', 'http://ecx.images-amazon.com/images/I/41B8tOvRAuL._SX412_BO1,204,203,200_.jpg', 'aperkins@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (15, 9, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (16, 9, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (17, 9, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (18, 9, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (19, 9, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (20, 9, 2);

INSERT INTO authors (name) VALUES ('Karl F. Kuhn');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0471134473', 'Basic Physics: A Self-Teaching Guide', '7', 'Physics', 'The fast, easy way to master the fundamentals of physics.', 'http://ecx.images-amazon.com/images/I/51GJy6M7YwL._SX403_BO1,204,203,200_.jpg', 'aperkins@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (21, 10, 1);

INSERT INTO authors (name) VALUES ('David Klein');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('111801040X', 'Organic Chemistry As a Second Language', '10', 'Chemistry', 'Explores the major principles in the field and explains why they are relevant.', 'http://ecx.images-amazon.com/images/I/41nkWMDjZoL._SX329_BO1,204,203,200_.jpg', 'aperkins@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (22, 11, 1);

INSERT INTO authors (name) VALUES ('Mark Cuban');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1626810915', 'How to Win at the Sport of Business: If I Can Do It, You Can Do It ', '5', 'Business Administration', 'Mark Cuban shares his wealth of experience and business savvy in his first published book.', 'http://ecx.images-amazon.com/images/I/51jSEGGeGJL._SX308_BO1,204,203,200_.jpg', 'thaverford@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (23, 12, 1);

INSERT INTO authors (name) VALUES ('Paul Scherz');
INSERT INTO authors (name) VALUES ('Simon Monk');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0071771336', 'Practical Electronics for Inventors', '10', 'Engineering', 'Hands-on guide that outlines electrical principles and provides thorough, easy-to-follow instructions, schematics, and illustrations. ', 'http://ecx.images-amazon.com/images/I/51aOgq4k1GL._SX385_BO1,204,203,200_.jpg', 'rswanson@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (24, 13, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (25, 13, 1);

INSERT INTO authors (name) VALUES ('Saeed Moaveni');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1439062080', 'Engineering Fundamentals: An Introduction to Engineering ', '15', 'Engineering', 'Encourages students to become engineers and prepares them with a solid foundation in the fundamental principles and physical laws.', 'http://ecx.images-amazon.com/images/I/51bOO7eGElL._SX430_BO1,204,203,200_.jpg', 'rswanson@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (26, 14, 1);

INSERT INTO authors (name) VALUES ('Jay Feinman');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0199341699', 'Law 101: Everything You Need to Know About American Law', '10', 'Law', 'Provides a clear introduction to the main subjects taught in the first year of law school.', 'http://ecx.images-amazon.com/images/I/41QfOodjdHL._SX327_BO1,204,203,200_.jpg', 'rswanson@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (27, 15, 1);

INSERT INTO authors (name) VALUES ('Charles T. Horngren');
INSERT INTO authors (name) VALUES ('Gary L. Sundem');
INSERT INTO authors (name) VALUES ('John A. Elliott');
INSERT INTO authors (name) VALUES ('Donna R. Philbrick');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0136122973', 'Introduction to Financial Accounting', '12', 'Business Administration', 'Describes the most widely accepted accounting theory and practice with an emphasis on using and analyzing the information in financial statements.', 'http://ecx.images-amazon.com/images/I/41usMvkrwPL._SX380_BO1,204,203,200_.jpg', 'bwyatt@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (28, 16, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (29, 16, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (30, 16, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (31, 16, 2);

INSERT INTO authors (name) VALUES ('Jeffrey Brodd');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1599823292', 'World Religions: A Voyage of Discovery', '15', 'Religion', 'Encourages understanding of the people, dimensions, and religious principles of the world''s major religions.', 'http://ecx.images-amazon.com/images/I/51weZbq0lvL._SX402_BO1,204,203,200_.jpg', 'adwyer@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (32, 17, 1);

INSERT INTO authors (name) VALUES ('Paul Kleinman');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1440567670', 'Philosophy 101: From Plato and Socrates to Ethics and Metaphysics, an Essential Primer on the History of Thought', '5', 'Philosophy', 'Cuts out the boring details and keeps you engaged as you explore the fascinating history of human thought and inquisition.', 'http://ecx.images-amazon.com/images/I/51R4ayDbFlL._SX382_BO1,204,203,200_.jpg', 'adwyer@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (33, 18, 1);

INSERT INTO authors (name) VALUES ('Carl H. Dahlman');
INSERT INTO authors (name) VALUES ('William H. Renwick');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0321843339', 'Introduction to Geography: People, Places & Environment', '90', 'Geography', 'Introduces the major tools, techniques, and methodological approaches of the discipline.', 'http://ecx.images-amazon.com/images/I/51yeImKQd4L._SX384_BO1,204,203,200_.jpg', 'adwyer@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (34, 19, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (35, 19, 1);

INSERT INTO authors (name) VALUES ('Charlotte Bronte');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0141441143', 'Jane Eyre', '3', 'English', 'A novel of intense power and intrigue that has dazzled generations of readers with its depiction of a woman''s quest for freedom. ', 'http://ecx.images-amazon.com/images/I/41g4DSszOTL._SX322_BO1,204,203,200_.jpg', 'adwyer@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (36, 20, 1);

INSERT INTO authors (name) VALUES ('Claire M. Renzetti');
INSERT INTO authors (name) VALUES ('Daniel J. Curran');
INSERT INTO authors (name) VALUES ('Shana L. Maier');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0205459595', 'Women, Men, and Society', '55', 'Sociology', 'Assists students in connecting their personal gender experiences with the social and political world in which they live.', 'http://ecx.images-amazon.com/images/I/51xpApOblhL._SX381_BO1,204,203,200_.jpg', 'adwyer@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (37, 21, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (38, 21, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (39, 21, 2);

INSERT INTO authors (name) VALUES ('Daron Acemoglu');
INSERT INTO authors (name) VALUES ('James Robinson');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0307719227', 'Why Nations Fail: The Origins of Power, Prosperity, and Poverty', '4', 'Political Science', 'Answers the question why are some nations rich and others poor, divided by wealth and poverty, health and sickness, food and famine? ', 'http://ecx.images-amazon.com/images/I/51XYz-Um3pL._SX322_BO1,204,203,200_.jpg', 'lknope@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (40, 22, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (41, 22, 1);

INSERT INTO authors (name) VALUES ('Diane Ravitch');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0465025579', 'The Death and Life of the Great American School System', '4', 'Education', 'A passionate plea to preserve and renew public education.', 'http://ecx.images-amazon.com/images/I/51TldZax1YL._SX329_BO1,204,203,200_.jpg', 'lknope@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (42, 23, 1);

INSERT INTO authors (name) VALUES ('Henry Kissinger');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0143127713', 'World Order', '6', 'International Relations', 'Offers a deep meditation on the roots of international harmony and global disorder. ', 'http://ecx.images-amazon.com/images/I/41fWrNb%2BJoL._SX324_BO1,204,203,200_.jpg', 'lknope@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (43, 24, 1);

INSERT INTO authors (name) VALUES ('Janet Coryell');
INSERT INTO authors (name) VALUES ('Nora Faires');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0072878134', 'A History of Women in America', '25', 'History', 'Integrates the stories of women in America into the national narrative of American history.', 'http://ecx.images-amazon.com/images/I/51szqfmMpIL._SX346_BO1,204,203,200_.jpg', 'lknope@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (44, 25, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (45, 25, 1);

INSERT INTO authors (name) VALUES ('Marilyn Stokstad');
INSERT INTO authors (name) VALUES ('Michael Cothren');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0205873480', 'Art History Volume 1', '75', 'Art', ' Balances formal analysis with contextual art history in order to engage a diverse student audience.', 'http://ecx.images-amazon.com/images/I/610h%2B5pNCbL._SX407_BO1,204,203,200_.jpg', 'aludgate@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (46, 26, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (47, 26, 1);

INSERT INTO authors (name) VALUES ('Marilyn Stokstad');
INSERT INTO authors (name) VALUES ('Michael W. Cothren');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0205744214', 'Art History, Volume 2', '15', 'Art', 'The most student-friendly, contextual, and inclusive art history survey text on the market. ', 'http://ecx.images-amazon.com/images/I/51pxm4jP9oL._SX359_BO1,204,203,200_.jpg', 'aludgate@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (48, 27, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (49, 27, 1);

INSERT INTO authors (name) VALUES ('James W. Kalat');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1133956602', 'Introduction to Psychology', '50', 'Psychology', 'Challenges your preconceptions about psychology to help you become more informed.', 'http://ecx.images-amazon.com/images/I/51ddN9xBrhL._SX412_BO1,204,203,200_.jpg', 'aludgate@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (50, 28, 1);

INSERT INTO authors (name) VALUES ('Toby Cole');
INSERT INTO authors (name) VALUES ('Helen Krich Chinoy');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('051788478X', 'Actors on Acting', '2', 'Theatre', 'Comprehensive consideration of the actor''s art and craft, as told by the theater''s greatest practitioners.', 'http://ecx.images-amazon.com/images/I/51synwvl9vL._SX344_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (51, 29, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (52, 29, 1);

INSERT INTO authors (name) VALUES ('Carl H. Klaus');
INSERT INTO authors (name) VALUES ('Miriam Gilbert');
INSERT INTO authors (name) VALUES ('Bradford S. Field');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('031239733X', 'Stages of Drama: Classical to Contemporary Theater', '15', 'Theatre', 'Engages students by presenting plays as works that come to life on the stage.', 'http://ecx.images-amazon.com/images/I/51Z7ZGR90AL._SX375_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (53, 30, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (54, 30, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (55, 30, 2);

INSERT INTO authors (name) VALUES ('Robert W. Sebesta');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0132130815', 'Programming the World Wide Web', '2', 'Computer Science', 'Comprehensive introduction to the tools and skills required for both client and server-side programming', 'http://ecx.images-amazon.com/images/I/412dlhu-wBL._SX403_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (56, 31, 1);

INSERT INTO authors (name) VALUES ('Richard A. LaFleur');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0061997226', 'Wheelock''s Latin ', '7', 'Foreign Language', 'Introduces students to elementary Latin.', 'http://ecx.images-amazon.com/images/I/61ku9dtvI0L._SX397_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (57, 32, 1);

INSERT INTO authors (name) VALUES ('Yuehua Liu');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0887276393', 'Integrated Chinese, Level 1 Part 1 Textbook', '20', 'Foreign Language', 'The leading introductory Chinese textbook at colleges and universities around the world.', 'http://ecx.images-amazon.com/images/I/51xIyhJn15L._SX362_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (58, 33, 1);

INSERT INTO authors (name) VALUES ('Yuehua Liu');
INSERT INTO authors (name) VALUES ('Daozhong Yao');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0887276709', 'Integrated Chinese: Level 1, Part 2', '25', 'Foreign Language', 'The leading introductory Chinese textbook at colleges and universities around the world.', 'http://ecx.images-amazon.com/images/I/51huem7PYUL._SX364_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (59, 34, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (60, 34, 1);

INSERT INTO authors (name) VALUES ('Paul A. Erickson');
INSERT INTO authors (name) VALUES ('Liam D. Murphy');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1442601108', 'A History of Anthropological Theory', '8', 'Anthropology', 'Overview of the history of anthropological theory.', 'http://ecx.images-amazon.com/images/I/51Zg3VvnumL._SX387_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (61, 35, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (62, 35, 1);

INSERT INTO authors (name) VALUES ('Liza Dalby');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0520257898', 'Geisha, 25th Anniversary Edition', '7', 'Anthropology', 'Story of the first non-Japanese ever to have trained as a geisha.', 'http://ecx.images-amazon.com/images/I/51xzWL%2BdwkL._SX258_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (63, 36, 1);

INSERT INTO authors (name) VALUES ('Joseph M. Boggs');
INSERT INTO authors (name) VALUES ('Dennis W. Petrie');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0073535079', 'The Art of Watching Films', '7', 'Other', 'Helps students develop critical skills in the analysis and evaluation of film.', 'http://ecx.images-amazon.com/images/I/511Tl5deKmL._SX404_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (64, 37, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (65, 37, 1);

INSERT INTO authors (name) VALUES ('David Bordwell');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0073535060', 'Film Art: an Introduction ', '4', 'Other', 'Overview of film production, techniques, criticism and history.', 'http://ecx.images-amazon.com/images/I/51YRV1cMLHL._SX389_BO1,204,203,200_.jpg', 'lcarter@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (66, 38, 1);

INSERT INTO authors (name) VALUES ('J. Peter Burkholder');
INSERT INTO authors (name) VALUES ('Donald Jay Grout');
INSERT INTO authors (name) VALUES ('Claude V. Palisca');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0393918297', 'A History of Western Music', '75', 'Other', 'The definitive history of Western music.', 'http://ecx.images-amazon.com/images/I/61qJDgKvxlL._SX348_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (67, 39, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (68, 39, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (69, 39, 2);

INSERT INTO authors (name) VALUES ('Dean A. Kowalski');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1118585607', 'Classic Questions and Contemporary Film: An Introduction to Philosophy', '25', 'Philosophy', 'Uses popular movies as a highly accessible framework for introducing key philosophical concepts.', 'http://ecx.images-amazon.com/images/I/51V5HgboIPL._SX382_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (70, 40, 1);

INSERT INTO authors (name) VALUES ('Jackson J. Spielvogel');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0495913243', 'Western Civilization, 8th Edition', '30', 'History', 'Interweaves the political, economic, social, religious, and cultural aspects of history.', 'http://ecx.images-amazon.com/images/I/61qKyc83VnL._SX389_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (71, 41, 1);

INSERT INTO authors (name) VALUES ('Edmund Spenser');
INSERT INTO authors (name) VALUES ('Thomas P. Roche');
INSERT INTO authors (name) VALUES ('C. Patrick O''Donnell');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0140422072', 'The Faerie Queene', '7', 'English', 'One of the most influential poems in the English language.', 'http://ecx.images-amazon.com/images/I/51fFB7zn5fL._SX322_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (72, 42, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (73, 42, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (74, 42, 2);

INSERT INTO authors (name) VALUES ('John Milton');
INSERT INTO authors (name) VALUES ('Gordon Teskey');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0393924289', 'Paradise Lost', '7', 'English', 'Gordon Teskey''s freshly edited text of Milton''s masterpiece.', 'http://ecx.images-amazon.com/images/I/41adm9RzsxL._SX304_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (75, 43, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (76, 43, 2);

INSERT INTO authors (name) VALUES ('William Shakespeare');
INSERT INTO authors (name) VALUES ('Stanley Wells');
INSERT INTO authors (name) VALUES ('Gary Taylor');
INSERT INTO authors (name) VALUES ('John Jowett');
INSERT INTO authors (name) VALUES ('William Montgomery');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0199267170', 'The Oxford Shakespeare: The Complete Works', '15', 'English', 'The most authoritative edition of the Bard''s plays and poems ever published. ', 'http://ecx.images-amazon.com/images/I/51VGMdzOsrL._SX364_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (77, 44, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (78, 44, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (79, 44, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (80, 44, 2);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (81, 44, 2);

INSERT INTO authors (name) VALUES ('J.R.R. Tolkien');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0345325818', 'The Silmarillion', '3', 'English', 'The tragic tale of the struggle for control of the Silmarils.', 'http://ecx.images-amazon.com/images/I/51tDzXVWy4L._SX296_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (82, 45, 1);

INSERT INTO authors (name) VALUES ('Richard Dawkins');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0199291152', 'The Selfish Gene', '6', 'Biology', 'Richard Dawkins'' brilliant reformulation of the theory of natural selection.', 'http://ecx.images-amazon.com/images/I/41SHx3tPusL._SX321_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (83, 46, 1);

INSERT INTO authors (name) VALUES ('Kimberly Jansma');
INSERT INTO authors (name) VALUES ('Margaret Ann Kassen');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1133311288', 'Motifs: An Introduction to French', '15', 'Foreign Language', 'Immerses you in the world of French language and culture.', 'http://ecx.images-amazon.com/images/I/51wnQ14fBjL._SX385_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (84, 47, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (85, 47, 1);

INSERT INTO authors (name) VALUES ('A.P. French');
INSERT INTO authors (name) VALUES ('Edwin F. Taylor');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0393091066', 'Introduction to Quantum Physics', '15', 'Physics', 'Introduces quantum physics, studying the behavior of the smallest things we know.', 'http://ecx.images-amazon.com/images/I/41h5lGLONZL._SX331_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (86, 48, 1);
INSERT INTO authortobook (authorid, bookid, priority) VALUES (87, 48, 1);

INSERT INTO authors (name) VALUES ('William Zinsser');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('0060891548', 'On Writing Well: The Classic Guide to Writing Nonfiction', '5', 'English', 'A book for everybody who wants to learn how to write.', 'http://ecx.images-amazon.com/images/I/41BG2%2B-AlVL._SX329_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (88, 49, 1);

INSERT INTO authors (name) VALUES ('Jonathan E. Peters');
INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES ('1499113374', 'Music Theory: An in-depth and straight forward approach to understanding music', '15', 'Other', 'A comprehensive course in the study of music.', 'http://ecx.images-amazon.com/images/I/51-i7aujlDL._SX331_BO1,204,203,200_.jpg', 'bderry@mail.com');
INSERT INTO authortobook (authorid, bookid, priority) VALUES (89, 50, 1);

INSERT INTO cart (userid, bookid) VALUES ('bderry@mail.com', 31);
INSERT INTO cart (userid, bookid) VALUES ('bderry@mail.com', 4);
INSERT INTO cart (userid, bookid) VALUES ('bderry@mail.com', 26);

CREATE INDEX lb_subject_index ON listedbooks(subject);
CREATE INDEX lb_isbn_index ON listedbooks(isbn);
CREATE INDEX atb_authorid_index ON authortobook(authorid);
CREATE INDEX atb_bookid_index ON authortobook(bookid);
CREATE INDEX cart_bookid_index ON cart(bookid);
CREATE INDEX cart_userid_index ON cart(userid);
CREATE INDEX sold_userid_index ON soldbooks(userid);
CREATE INDEX sold_bookid_index ON soldbooks(bookid);

DROP ROLE IF EXISTS bookuser;
CREATE ROLE bookuser LOGIN PASSWORD 'Lv+;92>&';
GRANT SELECT, INSERT, UPDATE on users TO bookuser;
GRANT SELECT, INSERT, UPDATE, DELETE on listedbooks TO bookuser;
GRANT SELECT, INSERT, DELETE on authors TO bookuser;
GRANT SELECT, INSERT on authortobook TO bookuser;
GRANT USAGE on listedbooks_bookid_seq TO bookuser;
GRANT USAGE on authors_authorid_seq TO bookuser;
GRANT SELECT, INSERT on soldbooks TO bookuser;
GRANT SELECT, INSERT, UPDATE, DELETE on cart TO bookuser;


