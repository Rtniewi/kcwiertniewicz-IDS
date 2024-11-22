/*
DB Assignment 5
Katrina Cwiertniewicz
11/22/2024
*/
/*
    Query 1: Over how many years was the unemployment data collected?
    =================================================================
*/
  db.unemployment.aggregate([
    {
      $group: {
        _id: "$Year"                // Group by Year to get unique Years
      }
    },
    {
      $count: "Amount_of_Years"     // Counts the number of Years (distinct Years)
    }
  ])


/*
    Query 2: How many states were reported on in this dataset?
    ==========================================================
 */

  db.unemployment.aggregate([
    {
      $group: {
        _id: "$State"                // Group by State to get unique States
      }
    },
    {
      $count: "Unique_State_Count"   // Count the number of States (distinct States)
    }
  ])


/*
    Query 3: What does this query compute?
    ======================================
*/

  db.unemployment.find({Rate : {$lt: 1.0}}).count() // Count rates that unemployment rate is under 1.0%


/*
    Query 4: Find all counties with unemployment rate higher than 10%
    ===============================================================
*/
  db.unemployment.aggregate([
    {
      $match: { Rate: { $gt: 10 } }  // Filter documents where unemployment rate > 10%
    },
    {
      $group: { _id: "$County" }     // Group by county to get unique counties
    }
  ])


/*
    Query 5: Calculate the average unemployment rate across all states.
    ===================================================================
*/
  db.unemployment.aggregate([
    {
      $project: {
        _id:0, Rate: {$ifNull: ["$Rate", 0]}          // Project Rate. If rate is null rate = 0
      }
    },
    {
      $group: {
        _id: null,
        average_unemployment_rate: {$avg: "$Rate"}    // Group by average unemployment rate
        }
    },
    {
      $project: {
        roundedAvg: {
          $round: ["$average_unemployment_rate",2]    // Round average unemployment rate
        }
      }
    }
  ])


/*
    Query 6: Find all counties with an unemployment rate between 5% and 8%.
    =====================================================================
*/
  db.unemployment.aggregate([
    {
      $match: {
        Rate: { $gte: 5, $lte: 8 }  // Filter documents where unemployment rate is between 5% and 8%
      }
    },
    {
      $group: { _id: "$County" }  // Group by county to get unique counties
    }
  ])


/*
    Query 7: Find the state with the highest unemployment rate. Hint. Use { $limit: 1 }
    ===================================================================================
*/
  db.unemployment.aggregate([
    {
      $project: {
        State: 1, Rate: 1, _id: 0}      // Project State and Rate
    },
    {
      $sort: {Rate: -1}                 // Sort Rate descending
    },
    {
      $limit:1                          // Show top result
    }
  ])


/*
    Query 8: Count how many counties have an unemployment rate above 5%.
    ==================================================================
*/
  db.unemployment.aggregate([
    {
      $match: {
        Rate: {$gt:5}}            // Filter documents where unemployment rate is greater than 5%
    },
    {
      $group: {_id: "$County"}    // Group by county to get unique counties
    },
    {
      $count: 'County_Rates'      // Count counties with unemployment rates greater than 5%
    }
  ])


/*
    Query 9: Calculate the average unemployment rate per state by year.
    ==================================================================
*/
  db.unemployment.aggregate([
    {
      $project: {
        _id:0, State:1, Year:1, Rate: {$ifNull: ["$Rate", 0]}                 // Project State, Year and Rate. If rate is null rate=0
      }
    },
    {
      $group: {
        _id: {state: "$State", year: "$Year"}, avg_rate: {$avg: "$Rate"}      // Group by State, Year, and Average Unemployment Rate
      }
    }
  ])


/*
    Query 10: (Extra Credit) For each state, calculate the total unemployment rate across all counties (sum of all county rates).
    =============================================================================================================================
*/
  db.unemployment.aggregate([
    {
      $project: {
        _id:0, State:1, County:1,  Rate: {$ifNull: ["$Rate", 0]}                  // Project State, County and Rate. If rate is null rate=0
      }
    },
    {
      $group: {
        _id: {State: "$State"}, sum_of_all_county_rates: {$sum: {$avg: "$Rate"}}  // Average and Sum all unemployment rates, group by State
      }
    }
  ])


/*
    Query 11: Extra Credit) The same as Query 10 but for states with data from 2015 onward
    ======================================================================================
*/
db.unemployment.aggregate([
    {
      $project: {
        _id:0, State:1, County:1, Year:1,  Rate: {$ifNull: ["$Rate", 0]}           // Project State, County, Year, and Rate. If rate is null rate=0
      }
    },
    {
      $match: {
        Year: {$gte: 2015}                                                         // Filter Years that are >= 2015
      }
    },
    {
      $group: {
        _id: {State: "$State"}, sum_of_all_county_rates: {$sum: {$avg: "$Rate"}}   // Average and Sum all unemployment rates, group by State
      }
    }
  ])





