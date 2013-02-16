app = angular.module("Kindle", [])

function KindleCtrl($scope, $http) {
  $scope.load = function() {
    $scope.results = get_json()["books"];
  }
}
