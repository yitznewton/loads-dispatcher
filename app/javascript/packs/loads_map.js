import {Loader} from "@googlemaps/js-api-loader"

let map;

const loader = new Loader({
  apiKey: document.getElementById("google-maps-api-key").dataset.key,
  version: "weekly",
  libraries: []
})

const urlParams = new URLSearchParams({
  earliest_pickup: document.getElementById("earliest-pickup").dataset.date || '',
  latest_pickup: document.getElementById("latest-pickup").dataset.date || '',
  shortlisted: document.getElementById("shortlisted").dataset.shortlisted || ''
})

const dismissLoad = load => evt => {
  evt.stopPropagation();
  fetch(`/loads/${load.id}.json`, {method: 'DELETE'}).then(() => {
    const deleteEvent = new Event(`load:${load.id}:delete`);
    document.dispatchEvent(deleteEvent);
  });
};

const shortlistLoad = load => function(evt) {
  evt.stopPropagation();
  fetch(`/loads/${load.id}/shortlist.json`, {method: 'POST'});
  const shortlistedText = document.createElement('span');
  shortlistedText.textContent = 'Shortlisted';
  this.replaceWith(shortlistedText);
};

const polyLineStrokeColor = load => {
  const orange = '#ff8c00';
  const magenta = '#ff00ff';

  if (load.is_old) return magenta;
  if (load.is_high_rate) return orange;
  if (load.is_box_truck) return '#000'

  return '#666';
};

const weightMultiplier = load => {
  let multiplier = 1;

  if (load.is_old) multiplier *= 2;
  if (load.is_box_truck) multiplier *= 2;
  if (load.is_high_rate) multiplier *= 2;

  return multiplier;
};

loader.load().then(() => {
  fetch('/loads.json?' + urlParams).then(data => {
    data.json().then(json => {
      const bounds = new google.maps.LatLngBounds();

      map = new google.maps.Map(document.getElementById("map"));
      let markers = [];

      json.slice(0, 10).forEach(load => {
      // json.forEach(load => {
        bounds.extend(load.pickup_location);
        bounds.extend(load.dropoff_location);
        const isOld = load.hours_old > 18;
        const title = `${load.pickup_location.readable} to ${load.dropoff_location.readable}`
        const opacity = load.is_box_truck ? 1.0 : 0.3;

        const emboldenListener = (strokeWeight) => () => {
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
          [{icon: {path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW, scale: 3, strokeWeight: strokeWeight*weightMultiplier(load)}, offset: '50%'}]
        );
        const line = new google.maps.Polyline({
          path: [load.pickup_location, load.dropoff_location],
          icons: icons(1),
          geodesic: true,
          strokeWeight: weightMultiplier(load),
          strokeColor: polyLineStrokeColor(load),
          map: map
        });
        const curr = x => `$${x/100}`;
        const infoWindowContent3 = load.rate && `<div>${curr(load.rate)} - ${curr(load.rate_per_mile)} per mile</div>` || '';
        const dismissButtonId = `dismiss-button-${load.id}`;
        const shortlistButtonId = `shortlist-button-${load.id}`
        const shortlistButton = load.shortlisted ? 'Shortlisted' : `<button id="${shortlistButtonId}">Shortlist</button>`;
        const age = load.is_old ? `<div>${parseInt(load.hours_old)} hours old</div>` : '';
        const infoWindowContent = `
          <div><a href="/loads/${load.id}">${title}</a></div>
          <div>${load.distance} mi</div>
          ${infoWindowContent3}
          <div>${Number(load.weight).toLocaleString()} lbs</div>
          ${age}
          <div>
            <button id="${dismissButtonId}">Dismiss</button>
            ${shortlistButton}
          </div>
          <div><a href="#load_${load.id}">scroll up</a></div>
        `;
        const infoWindow = new google.maps.InfoWindow({
          // TODO: pass link to load via API
          content: infoWindowContent,
          disableAutoPan: true
        });
        google.maps.event.addListener(infoWindow, 'domready', function() {
          document.getElementById(dismissButtonId).addEventListener('click', dismissLoad(load));

          const shortlistButton = document.getElementById(shortlistButtonId);
          shortlistButton && shortlistButton.addEventListener('click', shortlistLoad(load));
        });
        document.addEventListener(`load:${load.id}:delete`, () => {
          markerA.setMap(null);
          markerB.setMap(null);
          line.setMap(null);
        });
        [line, markerA, markerB].forEach(obj => {
          obj.addListener('mouseover', emboldenListener(weightMultiplier(load)*2));
          obj.addListener('mouseout', emboldenListener(weightMultiplier(load)));
          obj.addListener('mouseover', (evt) => {
            infoWindow.setPosition(evt.latLng);
            infoWindow.open({
              map: map
            })
          });
          obj.addListener('mouseout', () => infoWindow.close());
        });
      });
      map.setCenter(bounds.getCenter());
      map.fitBounds(bounds);
    });
  });
});
