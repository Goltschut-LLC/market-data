/*
IMPORTANT - For best success, run from Node shell/REPL

Also, be sure to export any Lambda expected env variables:
    export ALPACA_SECRET_NAME=alpaca
    export RDS_SECRET_NAME=rds
    export REGION=us-east-1
*/

const { handler } = require('./index')

const event = {
    "timeframe": "day",
    "symbols": ["AAPL", "GOOG"],
    "limit": "2",
    "start": "2020-12-28",
    "end": "2020-12-30"
}

(async (event) => {
    try{
        res = await handler(event)
        console.log("res:", JSON.stringify(res))
    } catch (e) {
        console.error("Error encountered during sanity test:", e)
    }
})(event)
