import { Loader } from "@googlemaps/js-api-loader"
import MarkerClusterer from '@googlemaps/markerclustererplus';

let map;

const loader = new Loader({
  apiKey: "AIzaSyA4vUx9y-AKt-THxhqNTniE5WK36HTcHmQ",
  version: "weekly",
  libraries: []
})

loader.load().then(() => {
  fetch('/loads.json').then(data => {
    data.json().then(json => {
      const bounds = new google.maps.LatLngBounds();

      map = new google.maps.Map(document.getElementById("map"));
      let markers = [];

      json.slice(0, 5).forEach(load => {
        bounds.extend(load.pickup_location);
        bounds.extend(load.dropoff_location);

        markers.push(new google.maps.Marker({
          position: load.pickup_location,
          map,
          title: load.pickup_location.readable
        }));
        markers.push(new google.maps.Marker({
          position: load.dropoff_location,
          map,
          title: load.dropoff_location.readable
        }));
        const icons = strokeWeight => (
          [{icon: {path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW, scale: 3, strokeWeight: strokeWeight}, offset: '50%'}]
        );
        const line = new google.maps.Polyline({
          path: [load.pickup_location, load.dropoff_location],
          icons: icons(1),
          geodesic: true,
          strokeWeight: 1,
          map: map
        });
        line.addListener('mouseover', function(e) {this.setOptions({strokeWeight: 2, icons: icons(2)})});
        line.addListener('mouseout', function(e) {this.setOptions({strokeWeight: 1, icons: icons(1)})});
      });
      map.setCenter(bounds.getCenter());
      map.fitBounds(bounds);
      new MarkerClusterer(map, markers, {
        averageCenter: true,
        imagePath: 'https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/m',
      });
    });
  });
});
