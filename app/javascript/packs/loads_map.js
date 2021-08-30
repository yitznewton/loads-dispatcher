import {Loader} from "@googlemaps/js-api-loader"

let map;

const loader = new Loader({
  apiKey: document.getElementById("google-maps-api-key").dataset.key,
  version: "weekly",
  libraries: []
})

const urlParams = new URLSearchParams({
  earliest_pickup: document.getElementById("earliest-pickup").dataset.date,
  latest_pickup: document.getElementById("latest-pickup").dataset.date
})

loader.load().then(() => {
  fetch('/loads.json?' + urlParams).then(data => {
    data.json().then(json => {
      return;
      const bounds = new google.maps.LatLngBounds();

      map = new google.maps.Map(document.getElementById("map"));
      let markers = [];

      // json.slice(0, 10).forEach(load => {
      json.forEach(load => {
        bounds.extend(load.pickup_location);
        bounds.extend(load.dropoff_location);
        const title = `${load.pickup_location.readable} to ${load.dropoff_location.readable}`
        const opacity = load.equipment_type_code === 'SB' ? 1.0 : 0.3;
        const weightMultiplier = load.equipment_type_code === 'SB' ? 2 : 1;
        const strokeColor = load.equipment_type_code === 'SB' ? '#000' : '#666';

        const listener = (strokeWeight) => () => {
          line.setOptions({strokeWeight: strokeWeight, icons: icons(strokeWeight)});
        };

        const markerA = new google.maps.Marker({
          position: load.pickup_location,
          map,
          opacity: opacity,
          label: "A",
          title: title
        });
        const markerB = new google.maps.Marker({
          position: load.dropoff_location,
          map,
          opacity: opacity,
          label: "B",
          title: title
        });
        markers.push(markerA);
        markers.push(markerB);
        const icons = strokeWeight => (
          [{icon: {path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW, scale: 3, strokeWeight: strokeWeight*weightMultiplier}, offset: '50%'}]
        );
        const line = new google.maps.Polyline({
          path: [load.pickup_location, load.dropoff_location],
          icons: icons(1),
          geodesic: true,
          strokeWeight: weightMultiplier,
          strokeColor: strokeColor,
          map: map
        });
        document.addEventListener(`load:${load.id}:delete`, () => {
          markerA.setMap(null);
          markerB.setMap(null);
          line.setMap(null);
        });
        // line.addListener('mouseover', function(e) {
        //   // TODO: overlay with origin and destination names & other info
        //   this.setOptions({strokeWeight: 2, icons: icons(2)});
        // });
        [line, markerA, markerB].forEach(obj => {
          obj.addListener('mouseover', listener(weightMultiplier*2));
          obj.addListener('mouseout', listener(weightMultiplier));
        });
      });
      map.setCenter(bounds.getCenter());
      map.fitBounds(bounds);
    });
  });
});
