app = angular.module("Kindle", []);
app.directive('postRender', ['$timeout', '$interpolate', function($timeout, $interpolate) {
  return function (scope, element, attrs) {
    if($.trim(scope.searchTerm) != "") {
      var rawCode = $interpolate(element.text())(scope);
      var formatedCode = rawCode.replace(new RegExp(scope.searchTerm, 'gi'), '<div class="highlight">$&</div>');
      $timeout(function() {
        element.html(formatedCode);
      });
    }
  }
}]);


function KindleCtrl($scope, $http) {
  $scope.load = function() {
    $scope.results = get_json()["books"];
  },

  $scope.doSearch = function() {
    var books = get_json()["books"];
    var queryRegExp = RegExp($scope.searchTerm, 'i'); //'i' -> case insensitive
    var filteredBooks = [];

    angular.forEach(books, function(book) {
      var filteredArticles = [];

      angular.forEach(book.articles, function(article) {
        if(article.content.match(queryRegExp)) {
          filteredArticles.push(article);
        }
      })

      if(filteredArticles.length > 0) {
        book.articles = filteredArticles;
        filteredBooks.push(book);
      }
    });

    $scope.results = filteredBooks;
  }
}
