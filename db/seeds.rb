City.create!([
               {
                 city: 'Kutztown',
                 state: 'PA',
                 tql_id: 58690,
                 latitude: 40.511340,
                 longitude: -75.776401,
                 county: 'Berks',
                 radius: 125
               },
               {
                 city: 'Manchester',
                 state: 'CT',
                 tql_id: 4123,
                 latitude: 41.778160,
                 longitude: -72.520670,
                 county: 'Hartford',
                 radius: 125
               }
             ])

LoadBoard.create!([
                    {
                      name: 'Truckers Edge'
                    },
                    {
                      name: 'TQL'
                    }
                  ])
