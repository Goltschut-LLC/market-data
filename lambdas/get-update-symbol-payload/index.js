const DAYS_TO_INGEST = 7

const formatDate = (date) => {
  const year = date.getFullYear();
  var month = `${date.getMonth() + 1}`
  var day = `${date.getDate()}`

  if (month.length < 2) 
      month = '0' + month;
  if (day.length < 2) 
      day = '0' + day;

  return [year, month, day].join('-');
}

exports.handler = async (event) => {
  const { Input: symbol } = event;
    
  console.log("Handler called with event:", event);
 
  const start = formatDate(new Date(Date.now() - DAYS_TO_INGEST*24*60*60*1000));
  const end = formatDate(new Date());
  
  return {
    timeframe: "day",
    symbols: [symbol],
    limit: 1000,
    start,
    end
  }
  
};
