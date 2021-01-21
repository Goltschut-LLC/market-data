const CALENDAR_YEARS_TO_INGEST = 6 // Ensures 5 complete years (if available)

exports.handler = async (event) => {
  const { Input: symbol } = event;
    
  console.log("Handler called with event:", event);
 
  const currentYear = (new Date()).getFullYear();
  const years = Array.from(Array(
    CALENDAR_YEARS_TO_INGEST
  ).keys()).map(index => currentYear-index)
  
  const payloads = years.map(year => ({
    timeframe: "day",
    symbols: [symbol],
    limit: 1000,
    start: `${year}-01-01`,
    end: `${year}-12-31`
  }))
  
  return { payloads }
};
