angular.module("myapp",['ngRoute']);
angular.module("myapp")
.config([ '$routeProvider','$httpProvider',
function($routeProvider,$httpProvider){
	$routeProvider.when("/login",{
		templateUrl: 'login.html'
	})
	.when("/home",{
		templateUrl: 'home.html'
	})
	.otherwise({
		templateUrl: 'login.html'
	});
	
	$httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest';
	
}])
.service('authInterceptor', function($q) {
    var service = this;

    service.responseError = function(response) {
        if (response.status == 401){
            window.location = "/login";
        }
        return $q.reject(response);
    };
})
.config(['$httpProvider', function($httpProvider) {
    $httpProvider.interceptors.push('authInterceptor');
}])

angular.module("myapp")
.controller("LoginController", ['$scope','$rootScope','$http','$location',function($scope,$rootScope,$http,$location){
    $scope.login = function(){
        $.ajax("rest/login", {data:{username: $scope.username, password: $scope.password},type:'post'}).then( function(data){
            console.log(data)
            $scope.status = data.status;
            if(data.status === "success") {
                $scope.message = data.welcome;
				$location.path("/home")
            } else {
				$location.path("/login")
                $scope.message = data.error;
            }
            
        },
        function(e){
            $scope.status = 'error';
            $scope.message = e;
        });
    }

    
	/*$scope.login = function(){
        $http.post("rest/login",{username: $scope.username, password: $scope.password}).then( function(data){
            console.log(data)
            $scope.status = data.data.status;
            if(data.data.status === "success") {
                $scope.message = data.data.welcome;
            } else {
                $scope.message = data.data.error;
            }
            
        },
        function(e){
            $scope.status = 'error';
            $scope.message = e;
        });
    }*/
	
    $scope.sayHello = function(){
        $.get("rest/hello/"+$scope.name,).then( function(data){
            console.log(data)
            $scope.$apply(function(){
                $scope.status = "success";
                $scope.message = data;
            })
           
            
        },
        function(e){
			$scope.$apply(function(){
				$scope.status = 'error';
				$scope.message = e;
			});
        });
    }
	
	$scope.basicLogin = function() {

		var headers = {authorization : "Basic "
			+ btoa("admin:admin")
		};

		$http.get('rest/user', {headers : headers}).then(function(data) {
		  if (data.data.name) {
			$rootScope.authenticated = true;
			$location.path("/home")
		  } else {
			$rootScope.authenticated = false;
			$location.path("/login")
		  }
		   
		},function() {
		  $rootScope.authenticated = false;
		  $location.path("/login")
		});

	}
	
	$scope.logout = function() {

		$http.get('rest/logout').then(function(data) {
		   $rootScope.authenticated = false;
		},function() {
		  $rootScope.authenticated = false;
		   
		});

	}
	
}])
.controller("HomeController", ['$scope','$rootScope','$http','$location',function($scope,$rootScope,$http,$location){
	$scope.title="Home Title";
	$scope.body="Home body";
	
	$scope.sayHello = function(){
        $.get("rest/hello/"+$scope.name,).then( function(data){
            console.log(data)
            $scope.$apply(function(){
                $scope.status = "success";
                $scope.message = data;
            })
           
            
        },
        function(e){
			$scope.$apply(function(){
				$scope.status = 'error';
				$scope.message = e;
			});
        });
    }
	
	$scope.logout = function() {

		$http.get('rest/logout').then(function(data) {
		   $rootScope.authenticated = false;
		   $location.path("/login")
		},function() {
		  $rootScope.authenticated = false;
		   $location.path("/login")
		});

	}
}])