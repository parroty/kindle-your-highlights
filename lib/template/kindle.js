app = angular.module("Kindle", ["ngResource"])

function KindleCtrl($scope, $http) {
  $scope.load = function() {
    $scope.results = get_json()["books"];
  }
}
