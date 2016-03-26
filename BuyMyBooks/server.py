import os
import sys
import psycopg2
import psycopg2.extras
from flask import Flask, session, render_template, request, redirect, url_for, make_response
from flask.ext.socketio import SocketIO, emit
import unicodedata
import time
import datetime
import smtplib
from email.mime.text import MIMEText
import string
import random


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
    txt2 = txt
    txt = '%' + txt + '%'
    if (subjectfilter=="all"):
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, \
            lb.price, lb.subject, lb.description, lb.pictureurl, lb.bookid FROM listedbooks as lb JOIN authortobook \
            as atb ON lb.bookid=atb.bookid JOIN authors as a ON atb.authorid=a.authorid WHERE lb.sold IS false AND \
            (LOWER(lb.title) LIKE %s OR LOWER(a.name) LIKE %s OR lb.isbn =%s) GROUP BY lb.bookid " + sortfilter + ";"
        query = cur.mogrify(q, (txt, txt, txt2))
    else:
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
            lb.bookid FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid INNER JOIN authors as a ON \
            atb.authorid=a.authorid WHERE (lb.subject IN (" + subjectfilter + ") AND lb.sold IS false) AND (LOWER(lb.title) \
            LIKE %s OR LOWER(a.name) LIKE %s OR lb.isbn=%s) GROUP BY lb.bookid " + sortfilter + ";"
        query = cur.mogrify(q, (txt, txt, txt))
    
    print query
    cur.execute(query)  
    results = cur.fetchall()
    print results
    if results != []:
        for result in results:
            if result[5] != "":
                description = result[5]
            price = str(result[3])
            tmp = {'isbn':result[0], 'title':result[2], 'author':result[1],
            'price':price, 'subject':result[4], 'description':description, 
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
    subtotal = 0
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
            query = cur.mogrify("SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
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
                subtotal += res[3]
                tmp = {'isbn':res[0], 'title':res[2], 'author':res[1], 'price':res[3], 
                'subject':res[4], 'description':description, 
                'picture':res[6], 'id':res[7]}
                cartItems.append(tmp)
        session['subtotal'] = subtotal
    print(cartItems)
    return render_template('cart.html', loggedIn=loggedIn, cartItems=cartItems, 
    deleteError=deleteError, deletedItem=deletedItem, subtotal=subtotal)    
    
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
            primaryauthorids = []
            secondaryauthorids = []
            authors = []
            try:
                if request.form.get('description'):
                    description = remove_accents(request.form['description'])
                if request.form.get('url'):
                    pictureurl = request.form['url']
                primaryauthors = [x.strip() for x in request.form['primaryauthor'].split(',')]
                print(primaryauthors)
                for a in primaryauthors:
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
                            primaryauthorids.append(result[0]) 
                    print(primaryauthorids)
                secondaryauthors = [x.strip() for x in request.form['secondaryauthor'].split(',')]
                print(secondaryauthors)
                for a in secondaryauthors:
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
                            secondaryauthorids.append(result[0]) 
                    print(secondaryauthorids)
                title = remove_accents(request.form['title'])
                query = cur.mogrify("""INSERT INTO listedbooks (isbn, title, price, subject, description, pictureurl, userid) VALUES (%s, %s, %s, %s, %s, %s, %s);""", 
                    (request.form['isbn'], title, request.form['price'], request.form['subject'], description, pictureurl, currentUser))
                print query
                cur.execute(query)
                query = cur.mogrify("SELECT bookid FROM listedbooks ORDER BY bookid DESC LIMIT 1;")
                cur.execute(query)
                results = cur.fetchall()
                print results
                if results != []:
                    for result in results:
                        bookid = result[0]
                for i in primaryauthorids:
                    q = "INSERT INTO authortobook (authorid, bookid, priority) VALUES (%s, %s, 1);"
                    query = cur.mogrify(q, (i, bookid))
                    print cur.mogrify(query)
                    cur.execute(query)
                for i in secondaryauthorids:
                    q = "INSERT INTO authortobook (authorid, bookid, priority) VALUES (%s, %s, 2);"
                    query = cur.mogrify(q, (i, bookid))
                    print cur.mogrify(query)
                    cur.execute(query)
                listingSuccess = True
            except:
                print("Error inserting book listing")
                conn.rollback()
                listingFailure = True
            conn.commit()
    return render_template('sell.html', loggedIn=loggedIn, listingSuccess=listingSuccess, listingFailure=listingFailure)
    
@app.route('/pay', methods=['GET', 'POST'])
def pay():
    loggedIn = False
    itemcount = 0
    complete = False
    subtotal = 0
    if 'subtotal' in session:
        subtotal = session['subtotal']
    tax = 0
    total = 0
    date = ''
    purchasedItems=[]
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
        if 'cart' in session:
            cartItems = session['cart']
            for item in cartItems:
                itemcount += 1
        if request.method=="POST":
            conn = connectToDB()
            cur = conn.cursor()
            currentTime = time.time()
            date = datetime.datetime.fromtimestamp(currentTime).strftime('%Y-%m-%d %H:%M:%S')
            try:
                for item in cartItems:
                    query = cur.mogrify("""INSERT INTO soldbooks (bookid, userid, purchasedate) VALUES (%s, %s, %s);""", (item, 
                        currentUser, date))
                    print(query)
                    cur.execute(query)
                    query = cur.mogrify("""UPDATE listedbooks SET sold='true' WHERE bookid=%s;""", (item,))
                    print(query)
                    cur.execute(query)
                    query = cur.mogrify("""DELETE FROM cart WHERE bookid=%s;""", (item,))
                    print query
                    cur.execute(query)
                    query = cur.mogrify("SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
                    lb.bookid FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid INNER JOIN authors as a ON atb.authorid=a.authorid \
                    WHERE lb.bookid=%s GROUP BY lb.bookid;""", (item,))
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
                        purchasedItems.append(tmp)
                print(purchasedItems)
                complete = True
            except:
                print "Error completing purchase"
                conn.rollback()
            conn.commit()
            date = datetime.datetime.fromtimestamp(currentTime).strftime('%B %d, %Y')
        subtotal = float(subtotal)
        tax = subtotal * 0.053
        total = subtotal + tax + 5
        subtotal = '%.2f' %  subtotal
        tax = '%.2f' %  tax
        total = '%.2f' %  total
            
    return render_template('checkout.html', loggedIn=loggedIn, subtotal=subtotal, itemcount = itemcount, 
    tax=tax, total=total, complete=complete, purchasedItems=purchasedItems, date=date)
    
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
    purchasedBooks=[]
    soldBooks=[]
    editFailure = False
    itemDeleted = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    if loggedIn:
        conn = connectToDB()
        cur = conn.cursor()
        if request.method == 'POST':
            if request.form.get('firstname'):
                try:
                    query = cur.mogrify("""UPDATE users SET firstname=%s WHERE email=%s;""", (request.form['firstname'], currentUser))
                    print(query)
                    cur.execute(query)
                    conn.commit()
                except:
                    print("Error editing first name")
                    conn.rollback()
                    editFailure = True
            if request.form.get('lastname'):
                try:
                    query = cur.mogrify("""UPDATE users SET lastname=%s WHERE email=%s;""", (request.form['lastname'], currentUser))
                    print(query)
                    cur.execute(query)
                    conn.commit()
                except:
                    print("Error editing last name")
                    conn.rollback()
                    editFailure = True
            if request.form.get('school'):
                try:
                    query = cur.mogrify("""UPDATE users SET school=%s WHERE email=%s;""", (request.form['school'], currentUser))
                    print(query)
                    cur.execute(query)
                    conn.commit()
                except:
                    print("Error editing school")
                    conn.rollback()
                    editFailure = True
                    
            if request.form.get('itemtodelete'):
                try:
                    query = cur.mogrify("""DELETE FROM authors as a USING authortobook as atb WHERE atb.authorid=a.authorid \
                    AND atb.bookid=%s;""", (request.form['itemtodelete'],))
                    print(query)
                    cur.execute(query)
                    query = cur.mogrify("""DELETE FROM listedbooks WHERE bookid=%s;""", (request.form['itemtodelete'],))
                    print(query)
                    cur.execute(query)
                    conn.commit()
                except:
                    print("Error deleting listing")
                    conn.rollback()
                    editFailure = True
                
                
        q= "SELECT * FROM users WHERE email = %s;"
        query = cur.mogrify(q, (currentUser,))
        print query
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            for result in results:
                accountInfo = {"email":result[0], 'firstname':result[1], 'lastname':result[2], 'school':result[3]}
                
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
            lb.bookid, EXTRACT(EPOCH FROM sb.purchasedate) FROM listedbooks as lb JOIN soldbooks as sb ON lb.bookid = sb.bookid JOIN authortobook as atb ON \
            sb.bookid=atb.bookid JOIN authors as a ON atb.authorid=a.authorid WHERE lb.sold IS true AND \
            sb.userid = %s GROUP BY lb.bookid, sb.purchasedate ORDER BY sb.purchasedate DESC;"
        query = cur.mogrify(q, (currentUser,))
        print query
        cur.execute(query)
        results = cur.fetchall()
        #print results
        if results != []:
            for result in results:
                date = result[8]
                date = datetime.datetime.fromtimestamp(date).strftime('%B %d, %Y')
                purchasedBooks.append({"isbn":result[0], 'title':result[2], 'author':result[1], 'price':result[3], 
                'subject':result[4], 'description':result[5], 'picture':result[6], 'id':result[7], 'date':date})
                
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
            lb.bookid FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid INNER JOIN authors as a ON \
            atb.authorid=a.authorid WHERE lb.sold=False AND lb.userid = %s GROUP BY lb.bookid ORDER BY lb.bookid DESC;"
        query = cur.mogrify(q, (currentUser,))
        print query
        cur.execute(query)
        results = cur.fetchall()
        #print results
        if results != []:
            for result in results:
                listedBooks.append({"isbn":result[0], 'title':result[2], 'author':result[1], 'price':result[3], 
                'subject':result[4], 'description':result[5], 'picture':result[6], 'id':result[7]})
        
        q = "SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl, \
            lb.bookid, EXTRACT(EPOCH FROM sb.purchasedate) FROM listedbooks as lb JOIN soldbooks as sb ON lb.bookid = sb.bookid JOIN authortobook as atb ON \
            sb.bookid=atb.bookid JOIN authors as a ON atb.authorid=a.authorid WHERE lb.sold IS true AND \
            lb.userid = %s GROUP BY lb.bookid, sb.purchasedate ORDER BY sb.purchasedate DESC;"
        query = cur.mogrify(q, (currentUser,))
        print query
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            for result in results:
                date = result[8]
                date = datetime.datetime.fromtimestamp(date).strftime('%B %d, %Y')
                soldBooks.append({"isbn":result[0], 'title':result[2], 'author':result[1], 'price':result[3], 
                'subject':result[4], 'description':result[5], 'picture':result[6], 'id':result[7], 'date':date})
    return render_template('account.html', loggedIn=loggedIn, accountInfo=accountInfo, listedBooks=listedBooks, 
    itemDeleted=itemDeleted, editFailure=editFailure, purchasedBooks=purchasedBooks, soldBooks=soldBooks)
    
@app.route('/edititem', methods=['GET', 'POST'])
def edit():
    item={}
    loggedIn = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    if request.method == "POST":
        conn = connectToDB()
        cur = conn.cursor()
        if request.form.get("itemtoedit"):
            try:
                query = cur.mogrify("""SELECT lb.isbn, STRING_AGG(a.name, ', ' ORDER BY atb.priority), lb.title, lb.price, lb.subject, lb.description, lb.pictureurl \
                FROM listedbooks as lb INNER JOIN authortobook as atb ON lb.bookid=atb.bookid INNER JOIN authors as a ON atb.authorid=a.authorid \
                WHERE lb.bookid=%s GROUP BY lb.bookid;""", (request.form['itemtoedit'],))
                print(query)
                cur.execute(query)
                results = cur.fetchall()
                print results
                if results != []:
                    for result in results:
                        item = {"isbn":result[0], 'title':result[2], 'author':result[1], 'price':result[3], 
                        'subject':result[4], 'description':result[5], 'pictureurl':result[6]}
                
            except:
                print("Error editing listing")
                editFailure = True
    return render_template('edititem.html', loggedIn=loggedIn, item=item)

@app.route('/forgotpassword', methods=['GET', 'POST'])
def forgotPassword():
    loggedIn = False
    passChanged = False
    passFailed = False
    wrongUsername = False
    if request.method=="POST":
        receiver=[request.form['email']]
        sender = ['buymybooks350@gmail.com']
        
        chars = string.ascii_uppercase + string.ascii_lowercase + string.digits
        randomPass = ''.join(random.choice(chars) for _ in range(8))
        print randomPass
        
        emailMSG = "Your new password is:  " + randomPass + "\n\nThank you, \nBuyMyBooks"
        msg = MIMEText(emailMSG)
        msg['Subject'] = 'Reset password'
        msg['From'] = 'buymybooks350@gmail.com'
        msg['To'] = request.form['email']
        
        conn = connectToDB()
        cur = conn.cursor()
        
        query = cur.mogrify("""SELECT * FROM users WHERE email = %s;""", (request.form['email'],))
        print query
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            try:
                query = cur.mogrify("""UPDATE users SET password=crypt(%s, gen_salt('bf')) WHERE email = %s;""", (randomPass, request.form['email'])) 
                print query
                cur.execute(query)
                conn.commit()
                passChanged = True
                print "Password changed"
                try:
                    smtpObj = smtplib.SMTP("smtp.gmail.com", 587)
                    #server.set_debuglevel(1)
                    smtpObj.ehlo()
                    smtpObj.starttls()
                    smtpObj.login('buymybooks350@gmail.com', 'zacharski350')
                    smtpObj.sendmail(sender, receiver, msg.as_string())         
                    print "Successfully sent email"
                except Exception as e:
                    print(e)
            except:
                print("Error changing password")
                conn.rollback()
                passFailed = True
        else:
            wrongUsername = True
            print "Incorrect email"
    return render_template('forgotpassword.html', loggedIn=loggedIn, passChanged=passChanged, passFailed=passFailed,
    wrongUsername=wrongUsername)

@app.route('/resetpassword', methods=['GET', 'POST'])
def resetPassword():
    loggedIn = False
    passChanged = False
    passFailed = False
    wrongPass = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    if request.method=="POST":
        oldpass = request.form['oldpassword']
        newpass = request.form['password1']
        conn = connectToDB()
        cur = conn.cursor()
        query = cur.mogrify("""SELECT * FROM users WHERE email = %s AND password = crypt(%s, password);""", (currentUser, oldpass)) 
        print(query)
        cur.execute(query)
        results = cur.fetchall()
        print results
        if results != []:
            try:
                query = cur.mogrify("""UPDATE users SET password=crypt(%s, gen_salt('bf')) WHERE email = %s;""", (newpass, currentUser)) 
                print query
                cur.execute(query)
                conn.commit()
                passChanged = True
                print "Password changed"
            except:
                print("Error changing password")
                conn.rollback()
                passFailed = True
        else:
            wrongPass = True
            print "Incorrect password"
    return render_template('resetpassword.html', loggedIn=loggedIn, passChanged=passChanged, passFailed=passFailed, 
    wrongPass=wrongPass)
    
@app.route('/logout', methods=['GET', 'POST'])
def logout():
    loggedIn = False
    if 'user' in session:
        del session['user']
    return render_template('logout.html', loggedIn=loggedIn)


if __name__ == '__main__':
    socketio.run(app, host=os.getenv('IP', '0.0.0.0'), port =int(os.getenv('PORT', 8080)), debug=True)
