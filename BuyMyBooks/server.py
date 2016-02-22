from flask import Flask, render_template, request, redirect, url_for, session
import psycopg2
import psycopg2.extras
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'


def connectToDB():
    connectionString = 'dbname=buymybooks user=bookuser password=Lv+;92>& host=localhost'
    print connectionString
    try:
        return psycopg2.connect(connectionString)
    except:
        print "Cannot connect to database"

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
    loggedIn = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    return render_template('checkout.html', loggedIn=loggedIn)    
    
@app.route('/sell', methods=['GET', 'POST'])
def sell():
    loggedIn = False
    if 'user' in session:
        currentUser = session['user']
        loggedIn = True
    return render_template('sell.html', loggedIn=loggedIn)
    
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
    return render_template('account.html', loggedIn=loggedIn, accountInfo=accountInfo)
    
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
    app.debug=True
    app.run(host='0.0.0.0', port=8080)