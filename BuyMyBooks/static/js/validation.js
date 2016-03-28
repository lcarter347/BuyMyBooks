function checkEmail(){
	var emailpat = /(^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$)/;
  	var email = document.getElementById("email");
	var emailtest = emailpat.test(email.value);
	if (!emailtest){
		document.getElementById("errorinfo").innerHTML = "The email address you have entered is not valid. &nbsp; Please enter a valid email address.";
		$('#validationfailed').modal();
		return false;
	} else {
		return true;
	}
}  


function checkPswd(){
	var pswdpat = /([A-Z]+)([a-z]+)([0-9]+)/;
	var pswdpat2 = /\S{5}/;
	var pswd = document.getElementById("password");
	var pswdtest = pswdpat.test(pswd.value);
	var pswdtest2 = pswdpat2.test(pswd.value);
	if (!pswdtest || !pswdtest2){
		document.getElementById("errorinfo").innerHTML = "Your password must be at least 5 characters long and contain 1 uppercase letter, 1 lowercase letter, and 1 number. &nbsp; Please re-enter your password.";
		$('#validationfailed').modal();
		return false;
	} else {
		return true;
	}
}

function checkPswd1(){
	var pswdpat = /([A-Z]+)([a-z]+)([0-9]+)/;
	var pswdpat2 = /\S{5}/;
	var pswd = document.getElementById("password1");
	var pswdtest = pswdpat.test(pswd.value);
	var pswdtest2 = pswdpat2.test(pswd.value);
	if (!pswdtest || !pswdtest2){
		document.getElementById("errorinfo").innerHTML = "Your password must be at least 5 characters long and contain 1 uppercase letter, 1 lowercase letter, and 1 number. &nbsp; Please re-enter your password.";
		$('#validationfailed').modal();
		return false;
	} else {
		return true;
	}
}


function checkPswdMatch(){
	var initial = document.getElementById("password1");
	var second = document.getElementById("password2");
	if (initial.value != second.value){
        document.getElementById("errorinfo").innerHTML = "The passwords you have entered do not match. &nbsp; Please re-enter your password.";
        $('#validationfailed').modal();
        return false;
    } else {
        return true;
    }
}


function checkFirstName(){
	var namepat = /(^[A-Z]{1}[A-Za-z\'\-\.\s]+$)/;
	var name = document.getElementById("firstname");
	var testname = namepat.test(name.value);
	if (!testname){
		document.getElementById("errorinfo").innerHTML = "The name you have entered is not valid. &nbsp; Please enter a valid (capitalized) first name.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}


function checkLastName(){
	var namepat = /(^[A-Z]{1})([A-Za-z\'\-\.\s]+$)/;
	var name2 = document.getElementById("lastname");
	var testname = namepat.test(name2.value);
	if (!testname){
		document.getElementById("errorinfo").innerHTML = "The name you have entered is not valid. &nbsp; Please enter a valid (capitalized) last name.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkSchool(){
	var schoolpat = /(^[A-Za-z\'\-\.\s]+$)/;
	var school = document.getElementById("school");
	var testschool = schoolpat.test(school.value);
	if (!testschool){
		document.getElementById("errorinfo").innerHTML = "The school you have entered is not valid. &nbsp; Please enter a valid school.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkISBN(){
	var isbnpat = /(^[A-Z0-9\-]{10,14}$)/;
	var isbn = document.getElementById("isbn");
	var testisbn = isbnpat.test(isbn.value);
	if (!testisbn){
		document.getElementById("errorinfo").innerHTML = "The ISBN you have entered is not valid. &nbsp; Please enter a valid ISBN.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkTitle(){
	var titlepat = /(^.+$)/;
	var title = document.getElementById("title");
	var testtitle = titlepat.test(title.value);
	if (!testtitle){
		document.getElementById("errorinfo").innerHTML = "You must enter a valid title.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkPrice(){
	var pricepat = /(^[0-9\.]+$)/;
	var price = document.getElementById("price");
	var testprice = pricepat.test(price.value);
	if (!testprice){
		document.getElementById("errorinfo").innerHTML = "The price you have entered is not valid. &nbsp; You must enter a valid price.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkPrimaryAuthor(){
	var authorpat = /(^[A-Za-z\,\'\-\.\s]+)/;
	var author = document.getElementById("primaryauthor");
	var testauthor = authorpat.test(author.value);
	if (!testauthor){
		document.getElementById("errorinfo").innerHTML = "The author(s) you have entered is not valid. &nbsp; You must enter a valid author.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkSecondaryAuthor(){
	var authorpat1 = /(^.+$)/;
	var authorpat2 = /(^[A-Za-z\,\'\-\.\s]+)/;
	var author = document.getElementById("secondaryauthor");
	var testauthor1 = authorpat1.test(author.value);
	if (testauthor1){
		var testauthor2 = authorpat2.test(author.value);
		if (!testauthor2){
			document.getElementById("errorinfo").innerHTML = "The author(s) you have entered is not valid. &nbsp; You must enter a valid author.";
			$('#validationfailed').modal();
			return false;
		} else {
	        return true;
	    }
	} else {
		return true;
	}
}

function checkCardName(){
	var namepat = /(^[A-Z]{1}[A-Za-z\'\-\.\s]+$)/;
	var name = document.getElementById("cardholdername");
	var testname = namepat.test(name.value);
	if (!testname){
		document.getElementById("errorinfo").innerHTML = "The name you have entered is not valid. &nbsp; Please enter a valid cardholder name.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkCardNumber(){
	var cardpat = /(^[0-9]{16}$)/;
	var card = document.getElementById("cardnumber");
	var testcard = cardpat.test(card.value);
	if (!testcard){
		document.getElementById("errorinfo").innerHTML = "The card number you have entered is not valid. &nbsp; Please enter a valid card number (with no spaces or hyphens).";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkCVC(){
	var cvcpat = /(^[0-9]{3}$)/;
	var cvc = document.getElementById("cvc");
	var testcvc= cvcpat.test(cvc.value);
	if (!testcvc){
		document.getElementById("errorinfo").innerHTML = "The CVC you have entered is not valid. &nbsp; Please enter a valid CVC.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkMonth(){
	var monthpat = /(^[0-9]{2}$)/;
	var month = document.getElementById("expirationmonth");
	var testmonth = monthpat.test(month.value);
	var monthnum = Number(month.value);
	if (!testmonth){
		document.getElementById("errorinfo").innerHTML = "The expiration month you have entered is not valid. &nbsp; Please enter a valid expiration month.";
		$('#validationfailed').modal();
		return false;
	} else if (monthnum > 12 || monthnum < 1){
		document.getElementById("errorinfo").innerHTML ="The expiration month you have entered is not valid. &nbsp; Please enter a valid expiration month.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkYear(){
	var yearpat = /(^[0-9]{4}$)/;
	var year = document.getElementById("expirationyear");
	var testyear= yearpat.test(year.value);
	var yearnum = Number(year.value);
	if (!testyear){
		document.getElementById("errorinfo").innerHTML = "The expiration year you have entered is not valid. &nbsp; Please enter a valid expiration year.";
		$('#validationfailed').modal();
		return false;
	} else if (yearnum < 2016){
		document.getElementById("errorinfo").innerHTML = "This card has expired. &nbsp; Please enter a non-expired card.";
		$('#validationfailed').modal();
		return false;
	} else if (yearnum > 2030){
		document.getElementById("errorinfo").innerHTML = "The expiration year you have entered is not valid. &nbsp; Please enter a valid expiration year.";
		$('#validationfailed').modal();
		return false;
	} else {
    	return true;

    }
}

function checkDate(){
	var month = Number(document.getElementById("expirationmonth").value);
	var year = Number(document.getElementById("expirationyear").value);
	if (year==2016 && month < 3){
		document.getElementById("errorinfo").innerHTML = "This card has expired. &nbsp; Please enter a non-expired card.";
		$('#validationfailed').modal();
		return false;
	} else {
		return true;
	}
}

function checkStreet(){
	var streetpat = /(^[0-9A-Za-z\.\-\'\s]+$)/;
	var street = document.getElementById("street");
	var teststreet= streetpat.test(street.value);
	if (!teststreet){
		document.getElementById("errorinfo").innerHTML = "The street address you have entered is not valid. &nbsp; Please enter a valid street address.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkCity(){
	var citypat = /(^[A-Za-z\-\.\'\s]+$)/;
	var city = document.getElementById("city");
	var testcity= citypat.test(city.value);
	if (!testcity){
		document.getElementById("errorinfo").innerHTML = "The city you have entered is not valid. &nbsp; Please enter a valid city.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkState(){
	var statepat = /(^[A-Za-z]{2}$)/;
	var state = document.getElementById("state");
	var teststate= statepat.test(state.value);
	if (!teststate){
		document.getElementById("errorinfo").innerHTML = "The state you have entered is not valid. &nbsp; Please enter a valid state.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}

function checkZip(){
	var zippat = /(^[0-9]{5}$)/;
	var zip = document.getElementById("zipcode");
	var testzip= zippat.test(zip.value);
	if (!testzip){
		document.getElementById("errorinfo").innerHTML = "The zip code you have entered is not valid. &nbsp; Please enter a valid zip code.";
		$('#validationfailed').modal();
		return false;
	} else {
        return true;
    }
}