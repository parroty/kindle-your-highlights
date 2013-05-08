app = angular.module("Kindle", []);
app.directive('postRender', ['$timeout', '$interpolate', function($timeout, $interpolate) {
  return function (scope, element, attrs) {
    if($.trim(scope.searchTerm) !== "") {
      var rawCode = $interpolate(element.html())(scope);
      var formatedCode = rawCode.replace(new RegExp(scope.searchTerm, 'gi'), '<div class="highlight">$&</div>');
      $timeout(function() {
        element.html(formatedCode);
      });
    }
  };
}]);


function KindleCtrl($scope, $http) {
  $scope.load = function() {
    var json = get_json();

    $scope.books          = json["books"];
    $scope.total_books    = json["info"]["total_books"];
    $scope.total_articles = json["info"]["total_articles"];

    $scope.book_count     = $scope.total_books;
    $scope.article_count  = $scope.total_articles;
  },

  $scope.doSearch = function() {
    var books = get_json()["books"];
    var queryRegExp = RegExp($scope.searchTerm, 'i'); //'i' -> case insensitive
    var filteredBooks = [];

    var article_count = 0;
    angular.forEach(books, function(book) {
      var filteredArticles = [];

      angular.forEach(book.articles, function(article) {
        if(article.content.match(queryRegExp)) {
          filteredArticles.push(article);
        }
      });

      if(filteredArticles.length > 0) {
        book.articles = filteredArticles;
        filteredBooks.push(book);
      }

      article_count += filteredArticles.length;
    });

    $scope.books = filteredBooks;

    $scope.book_count = $scope.books.length;
    $scope.article_count = article_count;
  };
}
