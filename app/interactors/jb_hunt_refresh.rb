class JbHuntRefresh < BaseRefresh
  REQUEST_HEADERS = {
    'Accept' => 'application/json',
    'Content-Type' => 'application/json',
    'Loadboard-Type' => 'EXTERNAL',
    'Origin' => 'https://www.jbhunt.com',
    'Referer' => 'https://www.jbhunt.com/',
    'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0'
  }.freeze

  URL = 'https://scm.jbhunt.com/carrier/public/rest/loadboard/graphql/external'.freeze

  # rubocop:disable Lint/MissingSuper
  def initialize(origin_date:)
    @origin_date = origin_date
  end
  # rubocop:enable Lint/MissingSuper

  attr_reader :origin_date

  def self.call(**kwargs)
    new(**kwargs).call
  end

  def response_exception_klass
    BadJbHuntResponse
  end

  def load_factory_klass
    JbHuntLoadFactory
  end

  def loads?(data)
    data.dig('data', 'searchTripsElasticOptimized', 'success') == true
  end

  def loads(data)
    data.dig('data', 'searchTripsElasticOptimized', 'data', 'loads')
  end

  def load_board
    LoadBoard.jb_hunt
  end

  def response_body(origin_city:, destination_city:)
    JSON.parse(Faraday.post(
      URL,
      request_payload(pickup_location: origin_city, dropoff_location: destination_city),
      REQUEST_HEADERS
    ).body)
  end

  # rubocop:todo Metrics/AbcSize
  # rubocop:todo Metrics/MethodLength
  def request_payload(pickup_location:, dropoff_location:)
    {
      'operationName' => 'searchTripsElasticOptimized',
      'variables' =>
        {
          'source' => 'CARRIER360EXTERNAL',
          'LoadRequestFiltersInput' =>
            {
              'includeExtendedResults' => true,
              'originCity' => pickup_location.city,
              'originState' => pickup_location.state,
              'originCountry' => 'USA',
              'originLatitude' => pickup_location.latitude.to_s,
              'originLongitude' => pickup_location.longitude.to_s,
              'deadheadOrigin' => pickup_location.radius.to_s,
              'destinationCity' => dropoff_location.city,
              'destinationState' => dropoff_location.state,
              'destinationCountry' => 'USA',
              'destinationLatitude' => dropoff_location.latitude.to_s,
              'destinationLongitude' => dropoff_location.longitude.to_s,
              'deadheadDestination' => dropoff_location.radius.to_s,
              'equipmentType' => 'DRY VAN',
              'earliestStartDate' => origin_date,
              'maxLoads' => '1',
              'maxStops' => '40',
              'maxWeight' => '17000'
            },
          'page' => 0,
          'pageSize' => 300,
          'withEquipmentSubType' => false,
          'sort' => []
        },
      # rubocop:todo Layout/LineLength
      'query' => "query searchTripsElasticOptimized($LoadRequestFiltersInput: LoadRequestFiltersInput, $page: Int!, $pageSize: Int!, $sort: [SortInput], $source: ProgramName = CARRIER360EXTERNAL, $withEquipmentSubType: Boolean!) {\n  searchTripsElasticOptimized(loadSearchRequest: {filters: $LoadRequestFiltersInput, page: $page, pageSize: $pageSize, sort: $sort, source: $source}) {\n    success\n    data {\n      page\n      totalPages\n      pageSize\n      totalElements\n      isExtendedResults\n      loads {\n        loadboardStatus\n        firstPickupDate\n        lastDeliveryDate\n        numberOfStops\n        emptyMiles\n        deadheadOrigin\n        deadheadDestination\n        hazmat\n        orderNumber\n        weight\n        certifications\n        firstPickupLocation {\n          appointmentBegin\n          appointmentEnd\n          location {\n            city\n            state\n            country\n            zip: zipcode\n            latitude\n            longitude\n            __typename\n          }\n          __typename\n        }\n        lastDeliveryLocation {\n          appointmentBegin\n          appointmentEnd\n          location {\n            city\n            state\n            country\n            zip: zipcode\n            latitude\n            longitude\n            __typename\n          }\n          __typename\n        }\n        stops {\n          appointmentBegin\n          appointmentEnd\n          deadHeadMiles\n          __typename\n        }\n        equipment {\n          type\n          subType @include(if: $withEquipmentSubType)\n          __typename\n        }\n        __typename\n      }\n      __typename\n    }\n    __typename\n  }\n}\n"
      # rubocop:enable Layout/LineLength
    }.to_json
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
