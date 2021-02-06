import './App.css';

const PredictionFigure = ({ ticker })  => {
    return <img 
        className="Prediction-figure"
        src={`https://goltschut-market-data-prod-public.s3.amazonaws.com/predictions/arima/symbol%3D${ticker}/prediction.png`}
        alt={`Prediction figure for ticker "${ticker}" not found`}
    /> 

}

export default PredictionFigure;
