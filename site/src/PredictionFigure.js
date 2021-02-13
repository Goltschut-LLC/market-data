import { useState, useEffect, useRef } from "react";
import Chartjs from "chart.js";
import "./App.css";
const https = require("https");

const PredictionFigure = ({ ticker }) => {
  const initialPredictionJSON = {
    index: {},
    predicted_percent_change: [],
  };
  const [predictionJSON, setPredictionJSON] = useState(initialPredictionJSON);
  const chartContainer = useRef(null);
  const [chartInstance, setChartInstance] = useState(null);

  useEffect(() => {
    getPredictionJson();
  }, [ticker]);

  useEffect(() => {
    if (chartContainer && chartContainer.current) {
      if (chartInstance) {
        chartInstance.destroy();
      }
      const newChartInstance = new Chartjs(chartContainer.current, chartConfig);
      setChartInstance(newChartInstance);
    }
  }, [chartContainer, predictionJSON]);

  const getPredictionJson = async () => {
    const options = {
      hostname: "goltschut-market-data-prod-public.s3.amazonaws.com",
      path: `/predictions/arima/symbol%3D${ticker}/prediction.json`,
      headers: {"Cache-Control": "max-age=60"},
    };

    https
      .get(options, (res) => {
        res.on("data", (d) => {
          try {
            setPredictionJSON(JSON.parse(d));
          } catch (e) {
            console.log("Unable to getPredictionJson for ticker.");
            setPredictionJSON(initialPredictionJSON);
          }
        });
      })
      .on("error", (e) => {
        console.error(e);
      });
  };

  const date_strings = Object.keys(predictionJSON["index"]).map(
    (i) => predictionJSON["date_string"][i]
  );
  const mid_prices = Object.keys(predictionJSON["index"]).map(
    (i) => predictionJSON["mid_price"][i]
  );
  const volumes = Object.keys(predictionJSON["index"]).map(
    (i) => predictionJSON["volume"][i]
  );
  const predicted_percent_changes = Object.keys(predictionJSON["index"]).map(
    (i) => predictionJSON["predicted_percent_change"][i]
  );
  const predicted_prices = mid_prices.map(
    (mp, i) => (1 + predicted_percent_changes[i]) * mp
  );

  const min_price = Math.min(...mid_prices, ...predicted_prices);
  const max_price = Math.max(...mid_prices, ...predicted_prices);
  const price_range = Math.abs(max_price - min_price);
  const buffer = 0.1 * price_range;

  const chartConfig = {
    type: "bar",
    data: {
      labels: [...date_strings.slice(1), "Forecast"],
      datasets: [
        {
          type: "line",
          label: "Actual Price",
          yAxisID: "Price",
          data: [...mid_prices.slice(1), null],
          backgroundColor: ["rgba(127, 229, 240, 0.69)"],
          borderColor: ["rgba(255, 99, 132, 1)"],
          borderWidth: 1,
        },
        {
          type: "line",
          label: "Predicted Price",
          yAxisID: "Price",
          data: [...predicted_prices],
          fill: false,
          borderColor: ["rgba(0, 0, 0, 1)"],
          borderDash: [10,10],
          borderWidth: 1,
        },
        {
          type: "bar",
          label: "Volume",
          yAxisID: "Volume",
          data: [...volumes.slice(1), null],
          backgroundColor: "rgba(252, 81, 133, 0.69)",
        },
      ],
    },
    options: {
      tooltips: {
        callbacks: {
          label: function (tooltipItem, data) {
            return `$${Number(tooltipItem.yLabel).toFixed(2)}`;
          },
        },
        callbacks: {
          label: function (tooltipItem, d) {
            if (tooltipItem.datasetIndex === 0) {
              return `Price: $${Number(tooltipItem.yLabel).toFixed(2)}`;
            } else if (tooltipItem.datasetIndex === 1) {
              return `Volume: ${tooltipItem.yLabel}`;
            }
          },
        },
      },
      scales: {
        yAxes: [
          {
            id: "Price",
            type: "linear",
            position: "left",
            ticks: {
              suggestedMin: min_price - buffer,
              suggestedMax: max_price + buffer,
            },
          },
          {
            id: "Volume",
            type: "linear",
            position: "right",
          },
        ],
      },
    },
  };

  return (
    <div className="Chart-container">
      <canvas ref={chartContainer}></canvas>
    </div>
  );
};

export default PredictionFigure;
