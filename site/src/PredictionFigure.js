import { useState, useEffect, useRef } from "react";
import Chartjs from "chart.js";
import "./App.css";
const https = require("https");

{
  /* <img 
    className="Prediction-figure"
    src={`https://goltschut-market-data-prod-public.s3.amazonaws.com/predictions/arima/symbol%3D${ticker}/prediction.png`}
    alt={`Prediction figure for ticker "${ticker}" not found`}
/> */
}

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
      if(chartInstance){
        chartInstance.destroy()
      }
      const newChartInstance = new Chartjs(chartContainer.current, chartConfig);
      setChartInstance(newChartInstance);
    }
  }, [chartContainer, predictionJSON]);

  const getPredictionJson = async () => {
    https
      .get(
        `https://goltschut-market-data-prod-public.s3.amazonaws.com/predictions/arima/symbol%3D${ticker}/prediction.json`,
        (res) => {
          res.on("data", (d) => {
            try {
              setPredictionJSON(JSON.parse(d));
            } catch (e) {
              console.log("Unable to getPredictionJson for ticker.");
              setPredictionJSON(initialPredictionJSON);
            }
          });
        }
      )
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
  // Should be same across all items
  const predicted_percent_change =
    predictionJSON["predicted_percent_change"][0];
  const target_price =
    (1 + predicted_percent_change) * mid_prices[mid_prices.length - 1];
  const min_mid_price = Math.min(...mid_prices);
  const max_mid_price = Math.max(...mid_prices);
  const mid_price_range = Math.abs(max_mid_price - min_mid_price);
  const buffer = 0.1 * mid_price_range;

  const chartConfig = {
    type: "bar",
    data: {
      labels: [...date_strings, "Forecast"],
      datasets: [
        {
          type: "line",
          label: "Stock Price",
          yAxisID: "Price",
          data: [...mid_prices, target_price],
          pointRadius: [
            ...Object.keys(predictionJSON["index"]).map(() => 6),
            24,
          ],
          pointStyle: [
            ...Object.keys(predictionJSON["index"]).map(() => "circle"),
            "crossRot",
          ],
          pointBorderColor: [
            ...Object.keys(predictionJSON["index"]).map(
              () => "rgba(127, 229, 240, 1)"
              ),
              "rgba(0, 0, 0, 1)",
            ],
            backgroundColor: ["rgba(127, 229, 240, 0.69)"],
            borderColor: ["rgba(255, 99, 132, 1)"],
            borderWidth: 1,
          },
        {
          type: "bar",
          label: "Volume",
          yAxisID: "Volume",
          data: [...volumes],
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
                  return `Price: $${Number(tooltipItem.yLabel).toFixed(2)}`
              } else if (tooltipItem.datasetIndex === 1) {
                  return `Volume: ${tooltipItem.yLabel}`;
              }
          }
      }
      },
      scales: {
        yAxes: [
          {
            id: "Price",
            type: "linear",
            position: "left",
            ticks: {
              suggestedMin: min_mid_price - buffer,
              suggestedMax: max_mid_price + buffer,
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
