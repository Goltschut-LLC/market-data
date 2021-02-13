import MetaTags from 'react-meta-tags';

const Meta = ({ ticker }) => {

  const url = window.location.href;
  const urlParts = url.split('?');
  const baseUrl = urlParts[0];
  const updatedQueryString = '?t=' + ticker 
  const formattedUrl = baseUrl + updatedQueryString;
  const ogImage = `http://goltschut-market-data-prod-public.s3.amazonaws.com/predictions/arima/symbol%3D${ticker}/prediction.jpg`

  return (
    <div>
      <MetaTags>
        <meta property="og:title" content={"GOMFD - Stock market price forecast for ticker " + ticker} />
        <meta property="og:type" content="website" />
        <meta property="og:url" content={formattedUrl} />
        <meta property="og:image" content={ogImage} />
        <meta property="og:description" content="Disclaimer: Information provided on this site is not financial advice. Invest at your own risk." />
        <meta name="twitter:card" value="summary" />
      </MetaTags>
    </div>
  );
};

export default Meta;
