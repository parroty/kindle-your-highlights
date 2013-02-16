app = angular.module("Kindle", [])

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
