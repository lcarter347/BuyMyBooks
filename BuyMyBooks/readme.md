Welcome to BuyMyBooks!

BuyMyBooks is a web app where students can sell their textbooks to other students.

In order to get the site up and running, you must do the following things (this assumes you are using Cloud9):

Clone this repo into your workspace.
Make sure you have Flask, Postgres, and SocketIO installed on your server.
Run BuyMyBooks/buymybooks.sql in order to set up the database.
Once the database is set up, you can test the site with one of the existing user accounts, or you can create one of your own. 

Credentials for a few of the existing accounts are: 
Email: lcarter@mail.com     Password: password 
Email: bderry@mail.com      Password: password
Email: lknope@mail.com      Password: password
Email: aperkins@mail.com    Password: password

bderry currently has items in his cart, so you may want to login to his to see that.


The current functionality of the website includes:
    Login/account creation/logout
    Searching for listed books by name, author, or isbn - narrowing the search by subject - ordering the search by price, newest, or alphabetically (this is implemented through angular and socketio)
    Listing books for sale - current listed books for each account may be seen on the user's account page
    Adding and removing books from cart
    Updating user account information
    Deleting user's listed books 
    Books a user has bought or sold are listed on their account page
    Resetting passwords - if the user forgot their password, a randomly generated one can be sent to their email address - a logged in user can manually change their password
    Purchasing items (note: this only simulates buying, no money changes hands, no card information is being stored in the database, and there is no encryption) 
    Client-side validation - user input will be checked before any forms are submitted - passwords must be at least 5 characters: 1 uppercase, 1 lowercase, and 1 number
    
Note: In order to test the forgotten password functionality, you will need to create an account with a valid email address first. 
This has been tested and works with gmail, but I can't speak for other email services.