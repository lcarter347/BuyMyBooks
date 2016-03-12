import os
import psycopg2
import psycopg2.extras
from flask import Flask, session, render_template, request, redirect, url_for, make_response
from flask.ext.socketio import SocketIO, emit
import unicodedata

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'

socketio = SocketIO(app)

def connectToDB():
    connectionString = 'dbname=buymybooks user=bookuser password=Lv+;92>& host=localhost'
    print connectionString
    try:
        return psycopg2.connect(connectionString)
    except:
        print "Cannot connect to database"


@socketio.on('connect', namespace='/search')
def connection():
    print('connected')
    
@socketio.on('search', namespace='/search')    
def search(txt, subjectfilter, sortfilter):
    description = "No description available"
    conn = connectToDB()
    cur = conn.cursor()
    txt = txt.lower()
    txt = remove_accents(txt)
    print txt
    txt = '%' + txt + '%'
    if (subjectfilter=="all"):
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', '), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
            lb.bookid FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid \
            INNER JOIN authors as a ON atb.authorid=a.authorid WHERE LOWER(lb.title) LIKE %s OR LOWER(a.name) LIKE %s \
            OR lb.isbn Like %s AND lb.sold=False GROUP BY lb.bookid " + sortfilter + ";"
        query = cur.mogrify(q, (txt, txt, txt))
    else:
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', '), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
            lb.bookid FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid INNER JOIN authors as a ON \
            atb.authorid=a.authorid WHERE (lb.subject IN (" + subjectfilter + ") AND lb.sold=False) AND (LOWER(lb.title) \
            LIKE %s OR LOWER(a.name) LIKE %s OR lb.isbn LIKE %s) GROUP BY lb.bookid " + sortfilter + ";"
        query = cur.mogrify(q, (txt, txt, txt))
    
    print query
    cur.execute(query)  
    results = cur.fetchall()
    print results
    if results != []:
        for result in results:
            if result[5] != "":
                description = result[5]
            tmp = {'isbn':result[0], 'title':result[2], 'author':result[1],
            'price':result[3], 'subject':result[4], 'description':description, 
            'pictureurl':result[6], 'id':result[7]}
            emit('search', tmp)
    else:
        emit('noresults')
        print "No results"
    
@socketio.on('addtocart', namespace='/search')
def addToCart(bookid):
    cart = []
    if 'user' in session:
        currentUser = session['user']
        message = ''
        conn = connectToDB()
        cur = conn.cursor()
        query = cur.mogrify("""SELECT * FROM cart WHERE userid=%s and bookid=%s;""", (currentUser, bookid))
        print query
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            message = 'already in cart'      
        else:
            try:
                query = cur.mogrify("""INSERT INTO cart (userid, bookid) VALUES (%s, %s);""", (currentUser,bookid))
                print cur.mogrify(query)
                cur.execute(query)
                message = 'item added'
                if 'cart' in session:
                    cart = session['cart']
                cart.append(bookid)
            except:
                print("Error inserting into cart")
                conn.rollback()
                message = 'error'  
            conn.commit()
        emit('addedtocart', message)  


def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    return u"".join([c for c in nfkd_form if not unicodedata.combining(c)])    
    
@app.route('/', methods=['GET', 'POST'])
def mainIndex():
    loggedIn = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    return render_template('index.html', loggedIn=loggedIn)
    
@app.route('/login', methods=['GET', 'POST'])
def login():
    conn = connectToDB()
    cur = conn.cursor()
    currentUser = ""
    loggedIn = False
    logInError = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    # if user typed in a post ...
    if request.method == 'POST':
      print "HI"
      username = request.form['email']
      pw = request.form['password']
      q= "SELECT * FROM users WHERE email = %s AND password = crypt(%s, password);"
      query = cur.mogrify(q, (username, pw))
      print query
      cur.execute(query)
      results = cur.fetchall()
      print results
      if results != []:
          session['user'] = username
          return redirect(url_for('mainIndex'))
      else:
          logInError = True
    return render_template('login.html', loggedIn=loggedIn, 
    currentUser=currentUser, logInError=logInError)
    
@app.route('/createaccount', methods=['GET', 'POST'])
def createAccount():
    loggedIn = False
    currentUser = ""
    nameTaken = False
    accountCreated = False
    if request.method == 'POST':
        conn = connectToDB()
        cur = conn.cursor()
        try:
            q =cur.mogrify("""SELECT * FROM users WHERE email = %s;""", (request.form['email'],))
            cur.execute(q)
            if cur.fetchall() != []:
                nameTaken = True
                print "Name taken."
            else:
                try:
                    q = "INSERT INTO users VALUES (%s, %s, %s, %s, crypt(%s, gen_salt('bf')));"
                    query = cur.mogrify(q, (request.form['email'], request.form['firstname'], request.form['lastname'], 
                    request.form['school'], request.form['password']))
                    print cur.mogrify(query)
                    cur.execute(query)
                    accountCreated = True
                except:
                    print("Error inserting into users")
                    conn.rollback()
                conn.commit()
        except:
            print("Error checking if name taken")
    return render_template('createaccount.html', loggedIn=loggedIn, 
    currentUser=currentUser, nameTaken=nameTaken, accountCreated = accountCreated)
    
@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    cartItems = []
    cartIds = []
    loggedIn = False
    deleteError = False
    deletedItem = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
        conn = connectToDB()
        cur = conn.cursor()
        if request.method == 'POST':
            itemToDelete = int(request.form['itemtodelete'])
            print(itemToDelete)
            try:
                query = cur.mogrify("""DELETE FROM cart WHERE userid=%s AND bookid=%s;""", (currentUser, itemToDelete))
                print query
                cur.execute(query)
                deletedItem = True
            except:
                    print("Error deleting from cart")
                    deleteError = True
                    conn.rollback()
            conn.commit()
        query = cur.mogrify("""SELECT * FROM cart WHERE userid=%s;""", (currentUser,))
        print query
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            for result in results:
                cartIds.append(result[0])
            session['cart'] = cartIds
        print(cartIds)
        for i in cartIds:
            query = cur.mogrify("SELECT lb.isbn, STRING_AGG(a.name, ', '), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
                lb.bookid FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid INNER JOIN authors as a ON atb.authorid=a.authorid \
                WHERE lb.bookid=%s GROUP BY lb.bookid;""", (i,))
            print query
            cur.execute(query)
            result = cur.fetchall()
            for res in result:
                if res[5] != "":
                    description = res[5]
                else:
                    description = "No description available"
                tmp = {'isbn':res[0], 'title':res[2], 'author':res[1], 'price':res[3], 
                'subject':res[4], 'description':description, 
                'picture':res[6], 'id':res[7]}
                cartItems.append(tmp)
    print(cartItems)
    return render_template('checkout.html', loggedIn=loggedIn, cartItems=cartItems, deleteError=deleteError, deletedItem=deletedItem)    
    
@app.route('/sell', methods=['GET', 'POST'])
def sell():
    loggedIn = False
    description = ""
    pictureurl = ""
    listingSuccess = False
    listingFailure = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
        if request.method == 'POST':
            conn = connectToDB()
            cur = conn.cursor()
            bookid = 0
            authorids = []
            authors = []
            try:
                if request.form.get('description'):
                    description = remove_accents(request.form['description'])
                if request.form.get('url'):
                    pictureurl = request.form['url']
                authors = [x.strip() for x in request.form['author'].split(',')]
                print(authors)
                for a in authors:
                    a = remove_accents(a)
                    query = cur.mogrify("INSERT INTO authors (name) VALUES (%s);", (a,))
                    print cur.mogrify(query)
                    cur.execute(query)
                    query = cur.mogrify("SELECT authorid FROM authors ORDER BY authorid DESC LIMIT 1;")
                    print query
                    cur.execute(query)
                    results = cur.fetchall()
                    print results
                    if results != []:
                        for result in results:
                            authorids.append(result[0]) 
                    print(authorids)
                title = remove_accents(request.form['title'])
                q = "INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES (%s, %s, %s, %s, %s, %s, %s);"
                query = cur.mogrify(q, (request.form['isbn'], title, request.form['price'], request.form['subject'], description, pictureurl, currentUser))
                print(query)
                cur.execute(query)
                query = cur.mogrify("SELECT bookid FROM listedbooks ORDER BY bookid DESC LIMIT 1;")
                cur.execute(query)
                results = cur.fetchall()
                print results
                if results != []:
                    for result in results:
                        bookid = result[0]
                for id in authorids:
                    q = "INSERT INTO authortobook (authorid, bookid) VALUES (%s, %s);"
                    query = cur.mogrify(q, (id, bookid))
                    print cur.mogrify(query)
                    cur.execute(query)
                listingSuccess = True
            except:
                print("Error inserting book listing")
                conn.rollback()
                listingFailure = True
            conn.commit()
    return render_template('sell.html', loggedIn=loggedIn, listingSuccess=listingSuccess, listingFailure=listingFailure)
    
@app.route('/product', methods=['GET', 'POST'])
def product():
    loggedIn = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    return render_template('product.html', loggedIn=loggedIn)
    
@app.route('/about', methods=['GET', 'POST'])
def aboutUs():
    loggedIn = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    return render_template('about.html', loggedIn=loggedIn)
    
@app.route('/account', methods=['GET', 'POST'])
def account():
    loggedIn = False
    accountInfo = ''
    listedBooks = []
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    if loggedIn:
        conn = connectToDB()
        cur = conn.cursor()
        q= "SELECT * FROM users WHERE email = %s;"
        query = cur.mogrify(q, (currentUser,))
        print query
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            for result in results:
                accountInfo = {"email":result[0], 'firstname':result[1], 'lastname':result[2], 'school':result[3]}
                
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', '), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl \
            FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid INNER JOIN authors as a ON \
            atb.authorid=a.authorid WHERE lb.sold=False AND lb.userid = %s GROUP BY lb.bookid ORDER BY lb.bookid DESC;"
        query = cur.mogrify(q, (currentUser,))
        print query
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            for result in results:
                listedBooks.append({"isbn":result[0], 'title':result[2], 'author':result[1], 'price':result[3], 
                'subject':result[4], 'description':result[5], 'picture':result[6]})
    return render_template('account.html', loggedIn=loggedIn, accountInfo=accountInfo, listedBooks=listedBooks)
    
@app.route('/single', methods=['GET', 'POST'])
def single():
    loggedIn = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    return render_template('single.html', loggedIn=loggedIn)

@app.route('/logout', methods=['GET', 'POST'])
def logout():
    loggedIn = False
    if 'user' in session:
        del session['user']
    return render_template('logout.html', loggedIn=loggedIn)


if __name__ == '__main__':
    socketio.run(app, host=os.getenv('IP', '0.0.0.0'), port =int(os.getenv('PORT', 8080)), debug=True)