from flask import Flask, render_template, request, redirect, url_for, session
import psycopg2
import psycopg2.extras
import os

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def mainIndex():
    return render_template('index.html')
    
@app.route('/account', methods=['GET', 'POST'])
def account():
    return render_template('account.html')
    
@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    return render_template('checkout.html')    
    
@app.route('/contact', methods=['GET', 'POST'])
def contact():
    return render_template('contact.html')
    
@app.route('/product', methods=['GET', 'POST'])
def product():
    return render_template('product.html')
    
@app.route('/single', methods=['GET', 'POST'])
def single():
    return render_template('single.html')

if __name__ == '__main__':
    app.debug=True
    app.run(host='0.0.0.0', port=8080)