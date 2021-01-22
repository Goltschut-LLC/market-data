const BATCH_COUNT = 10 // Concurrent ingest jobs

exports.handler = async (event) => {
  const { Input } = event;
  
  console.log("Handler called with event:", event);
  const { Payload } = Input;
  const { symbols } = Payload

  const jobsPerBatch = Math.ceil(symbols.length/BATCH_COUNT)
  
  const batches = Array.from(Array(BATCH_COUNT).keys()).map(index => {
    return symbols.slice(
        jobsPerBatch*index,
        jobsPerBatch*(index+1)
    )
  })
  
  return { batches }
};
