import { Loader } from "@googlemaps/js-api-loader"

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
      // json.forEach(load => {
        bounds.extend(load.pickup_location);
        bounds.extend(load.dropoff_location);
        const title = `${load.pickup_location.readable} to ${load.dropoff_location.readable}`

        const listener = (strokeWeight) => () => {
          line.setOptions({strokeWeight: strokeWeight, icons: icons(strokeWeight)});
        };

        const markerA = new google.maps.Marker({
          position: load.pickup_location,
          map,
          label: "A",
          title: title
        });
        const markerB = new google.maps.Marker({
          position: load.dropoff_location,
          map,
          label: "B",
          title: title
        });
        markers.push(markerA);
        markers.push(markerB);
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
        // line.addListener('mouseover', function(e) {
        //   // TODO: overlay with origin and destination names & other info
        //   this.setOptions({strokeWeight: 2, icons: icons(2)});
        // });
        [line, markerA, markerB].forEach(obj => {
          obj.addListener('mouseover', listener(2));
          obj.addListener('mouseout', listener(1));
        });
      });
      map.setCenter(bounds.getCenter());
      map.fitBounds(bounds);
    });
  });
});
