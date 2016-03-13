Welcome to BuyMyBooks!

BuyMyBooks is a web app where students can sell their textbooks to other students.

In order to get the site up and running, you must do the following things:

Clone this repo into your workspace.
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
    
Note: As of right now, descriptions for book listings can't be much more than 1 line long, or else the listing will fail. This will (hopefully) be fixed by the next sprint.