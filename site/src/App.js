import React, { useState, useEffect } from 'react';
import './App.css';
import Meta from './Meta';
import Navbar from "./Navbar";
import Search from "./Search";
import PredictionFigure from "./PredictionFigure";
import Disqus from "./Disqus";
import ReactGA from 'react-ga';
import ad from './static/your-ad-here.gif';
const querystring = require('querystring');

ReactGA.initialize('UA-181672128-4');
ReactGA.pageview(window.location.pathname + window.location.search);

const DEFAULT_TICKER = 'QQQ'

const App = () => {
  const urlTicker = (querystring.parse(window.location.search.replace('?', ''))['t'] || DEFAULT_TICKER).toUpperCase();
  const [activeTicker, setActiveTicker] = useState(urlTicker);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);

  useEffect(() => alert("Disclaimer: Information provided on this site is not financial advice.\n\nInvest at your own risk."), []);
  useEffect(() => {
    const url = window.location.href;
    const urlParts = url.split('?');
    if (urlParts.length > 0) {
        const baseUrl = urlParts[0];
        const updatedQueryString = '?t=' + activeTicker 
        const updatedUri = baseUrl + updatedQueryString;
        window.history.replaceState({}, document.title, updatedUri);
    }
  }, [activeTicker]);

  return (
    <div className="App">
      <Meta ticker={activeTicker} />
      <Navbar aboutModalOpen={aboutModalOpen} setAboutModalOpen={setAboutModalOpen}/>
      <Search activeTicker={activeTicker} setActiveTicker={event => setActiveTicker(event.target.value.toUpperCase())}/>
      <PredictionFigure ticker={activeTicker} />
      <Disqus ticker={activeTicker} />
      <a href="https://www.goltschut.com/contact" target="_blank" rel="noopener noreferrer">
        <img src={ad} alt="Your ad here" className="Ad-banner" />
      </a>
    </div>
  );
}

export default App;
