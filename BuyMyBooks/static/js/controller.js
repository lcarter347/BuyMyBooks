var BuyMyBooksApp= angular.module('BuyMyBooksApp',[])

BuyMyBooksApp.controller('SearchController', function($scope, $window){
    var socket = io.connect('https://' + document.domain + ':' + location.port + '/search')
    
    $scope.searchresults = [];
    $scope.searchtext = '';
    $scope.searched = false;
    $scope.noresults = false;
    $scope.allsub = true;
    $scope.anthro, $scope.art, $scope.bio, $scope.buad, $scope.chem, $scope.cs, $scope.edu, $scope.engineering = false;
    $scope.english, $scope.foreign, $scope.geography, $scope.hist, $scope.ir, $scope.law, $scope.math = false;
    $scope.med, $scope.other, $scope.philosophy, $scope.physics, $scope.polisci, $scope.psych, $scope.religion = false;
    $scope.sociology, $scope.theatre = false;
    $scope.sortby = "Price: Low to High";
    $scope.itemadded = false;
    $scope.incart = false;
    $scope.error = false;


    socket.on('connect', function(){
        console.log('connected');
    });
    
    $scope.search = function search(){
        $scope.searchresults = []
        console.log("Search for: ", $scope.searchtext);
        var subjectfilter = subjects();
        var sortfilter = sort();
        socket.emit('search', $scope.searchtext, subjectfilter, sortfilter);
    }
    
    $scope.addToCart = function addToCart(bookid){
        console.log("Book to be added: "+ bookid);
        socket.emit('addtocart', bookid);
    }
    
    $scope.dismiss = function dismiss(){
        $scope.itemadded = false;
        $scope.incart = false;
        $scope.error = false;
        $scope.$apply();
    }
    
     $scope.deleteFromCart = function deleteFromCart(id){
        console.log("book to delete: " + id)
    }
    
    $scope.toggleCheck = function toggleCheck(sub){
        if ($scope.sub == false){
            $scope.sub = true;
        } else {
            $scope.sub = false;
        }
    }
    
    
   var subjects = function subjects(){
       var subjectfilter = "";
       var subjects = []
        if ($scope.allsub){
            subjectfilter += "all";
        } else {
            if ($scope.anthro) 
                subjects.push("\'Anthropology\'")
            if ($scope.art)
                subjects.push("\'Art\'")
            if ($scope.bio)
                subjects.push("\'Biology\'")
            if ($scope.buad)
                subjects.push("\'Business Administration\'")
            if ($scope.chem)
                subjects.push("\'Chemistry\'")
            if ($scope.cs)
                subjects.push("\'Computer Science\'")
            if ($scope.edu)
                subjects.push("\'Education\'")
            if ($scope.engineering)
                subjects.push("\'Engineering\'")
            if ($scope.english)
                subjects.push("\'English\'")
            if ($scope.foreign)
                subjects.push("\'Foreign Language\'")
            if ($scope.geography)
                subjects.push("\'Geography\'")
            if ($scope.hist)
                subjects.push("\'History\'")
            if ($scope.ir)
                subjects.push("\'International Relations\'")
            if ($scope.law)
                subjects.push("\'Law\'")
            if ($scope.math)
                subjects.push("\'Mathematics\'")
            if ($scope.med)
                subjects.push("\'Medical\'")
            if ($scope.other)
                subjects.push("\'Other\'")
            if ($scope.philosophy)
                subjects.push("\'Philosophy\'")
            if ($scope.physics)
                subjects.push("\'Physics\'")
            if ($scope.polisci)
                subjects.push("\'Political Science\'")
            if ($scope.psych)
                subjects.push("\'Psychology\'")
            if ($scope.religion)
                subjects.push("\'Religion\'")
            if ($scope.sociology)
                subjects.push("\'Sociology\'")
            if ($scope.theatre)
                subjects.push("\'Theatre\'")
                
            subjectfilter = subjects.join(", ");
        }
        console.log("Subject filter: " + subjectfilter);
        return subjectfilter;
    }
    
    var sort = function sort(){
        var sortfilter = "";
        switch($scope.sortby){
            case "Price: Low to High":
                sortfilter = "ORDER BY lb.price ASC";
                break;
            case "Price: High to Low":
                sortfilter = "ORDER BY lb.price DESC";
                break;
            case "Newest":
                sortfilter = "ORDER BY lb.bookid DESC";
                break;
            case "Alphabetical":
                sortfilter = "ORDER BY lb.title ASC";
                break;
            default:
                console.log("Error trying to sort");
        }
        return sortfilter;
    }
    
   socket.on('search', function(txt){
        $scope.searched = true;
        $scope.searchresults.push(txt);
        console.log($scope.searchresults);
        var elem = document.getElementById('searchresultspane');
        elem.scrollTop = elem.scrollHeight;
        $scope.$apply();
    });
    
    socket.on('noresults', function(){
        console.log("No results")
        $scope.searched = true;
        $scope.noresults = true;
        $scope.$apply();
    });
    
    socket.on('addedtocart', function(message){
        switch(message){
            case 'already in cart':
                $scope.incart = true;
                break;
            case 'item added':
                $scope.itemadded = true;
                break;
            case 'error':
                $scope.error = true;
                break;
            default:
                break;
        }        
        $scope.$apply();
    });

});
    
    
    



